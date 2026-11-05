-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" (
    "EV_ID",
    "Metadata_EV",
    "ST_ID_hölls",
    "PR_ID_spelades",
    "of_ETY_Checksum",
    "of_ETY_Händelsetyp",
    "of_ETY_EQ",
    "of_Metadata_ETY",
    "ETY_ID_of",
    "EV_DAT_EV_ID",
    "Metadata_EV_DAT",
    "EV_DAT_Händelse_Datum",
    "EV_AUD_EV_ID",
    "Metadata_EV_AUD",
    "EV_AUD_EQ",
    "EV_AUD_Händelse_Publik",
    "EV_REV_EV_ID",
    "Metadata_EV_REV",
    "EV_REV_EQ",
    "EV_REV_Händelse_Intäkt",
    "EV_STA_EV_ID",
    "Metadata_EV_STA",
    "EV_STA_ChangedAt",
    "EV_STA_EQ",
    "EV_STA_Händelse_Status",
    "EV_UTL_EV_ID",
    "Metadata_EV_UTL",
    "EV_UTL_UTL_Utnyttjande",
    "EV_UTL_Metadata_UTL",
    "EV_UTL_UTL_ID",
    "EV_LVL_EV_ID",
    "Metadata_EV_LVL",
    "EV_LVL_ChangedAt",
    "EV_LVL_PLV_Checksum",
    "EV_LVL_PLV_EQ",
    "EV_LVL_PLV_Yrkesnivå",
    "EV_LVL_Metadata_PLV",
    "EV_LVL_PLV_ID"
)
AS
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    knots."eETY_Händelsetyp"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_STA_Händelse_Status"(0::smallint) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."eEV_STA_Händelse_Status"(0::smallint) sub 
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."EV_LVL_Händelse_Level" "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."EV_LVL_Händelse_Level" sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Händelse" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
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
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    knots."eETY_Händelsetyp"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."rEV_STA_Händelse_Status"(0::smallint, changingTimepoint::timestamp) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."rEV_STA_Händelse_Status"(0::smallint, changingTimepoint::timestamp) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" AS
SELECT
    *
FROM
    nexuses."pEV_Händelse"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Händelse" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
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
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        h."EV_STA_EV_ID" AS "EV_ID",
        h."EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."eEV_STA_Händelse_Status"(0::smallint) h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h."EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."EV_LVL_EV_ID" AS "EV_ID",
        h."EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Händelse" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."eETY_Händelsetyp"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_STA_ChangedAt") OVER (
            PARTITION BY h."EV_STA_EV_ID"
            ORDER BY h."EV_STA_ChangedAt"
        ) AS "until"
    FROM
        attributes."eEV_STA_Händelse_Status"(0::smallint) h
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
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_LVL_ChangedAt") OVER (
            PARTITION BY h."EV_LVL_EV_ID"
            ORDER BY h."EV_LVL_ChangedAt"
        ) AS "until"
    FROM
        attributes."EV_LVL_Händelse_Level" h
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
    knots."ePLV_Yrkesnivå"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."elEV_Händelse" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
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
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    knots."eETY_Händelsetyp"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_STA_Händelse_Status"(equivalent) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."eEV_STA_Händelse_Status"(equivalent) sub 
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."EV_LVL_Händelse_Level" "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."EV_LVL_Händelse_Level" sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."epEV_Händelse" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
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
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    knots."eETY_Händelsetyp"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."rEV_STA_Händelse_Status"(equivalent, changingTimepoint::timestamp) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."rEV_STA_Händelse_Status"(equivalent, changingTimepoint::timestamp) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."enEV_Händelse" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    nexuses."epEV_Händelse"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."edEV_Händelse" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        h."EV_STA_EV_ID" AS "EV_ID",
        h."EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."eEV_STA_Händelse_Status"(equivalent) h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h."EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."EV_LVL_EV_ID" AS "EV_ID",
        h."EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Händelse" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."eETY_Händelsetyp"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_STA_ChangedAt") OVER (
            PARTITION BY h."EV_STA_EV_ID"
            ORDER BY h."EV_STA_ChangedAt"
        ) AS "until"
    FROM
        attributes."eEV_STA_Händelse_Status"(equivalent) h
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
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_LVL_ChangedAt") OVER (
            PARTITION BY h."EV_LVL_EV_ID"
            ORDER BY h."EV_LVL_ChangedAt"
        ) AS "until"
    FROM
        attributes."EV_LVL_Händelse_Level" h
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
    knots."ePLV_Yrkesnivå"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
