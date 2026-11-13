-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none,
-- and are views over the rewinders of the attributes (views that show the latest annex row of every posit).
--
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
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
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_DAT_Händelse_Datum" r
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
        attributes."rEV_AUD_Händelse_Publik" r
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
        attributes."rEV_REV_Händelse_Intäkt" r
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
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_STA_Händelse_Status" r
    WHERE
        r."EV_STA_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_STA_EV_ID"
        ORDER BY
            r."EV_STA_ChangedAt" DESC,
            r."EV_STA_PositedAt" DESC
    )
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_UTL_Händelse_Utnyttjande" r
    WHERE
        r."EV_UTL_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_UTL_EV_ID"
        ORDER BY
            r."EV_UTL_PositedAt" DESC
    )
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_LVL_Händelse_Level" r
    WHERE
        r."EV_LVL_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_LVL_EV_ID"
        ORDER BY
            r."EV_LVL_ChangedAt" DESC,
            r."EV_LVL_PositedAt" DESC
    )
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
;
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
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
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_DAT_Händelse_Datum" r
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
        attributes."rEV_AUD_Händelse_Publik" r
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
        attributes."rEV_REV_Händelse_Intäkt" r
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
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_STA_Händelse_Status" r
    WHERE
        r."EV_STA_Reliability" = 1
    AND
        r."EV_STA_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."EV_STA_EV_ID"
        ORDER BY
            r."EV_STA_ChangedAt" DESC,
            r."EV_STA_PositedAt" DESC
    )
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_UTL_Händelse_Utnyttjande" r
    WHERE
        r."EV_UTL_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."EV_UTL_EV_ID"
        ORDER BY
            r."EV_UTL_PositedAt" DESC
    )
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus
    SELECT
        r.*
    FROM
        attributes."rEV_LVL_Händelse_Level" r
    WHERE
        r."EV_LVL_Reliability" = 1
    AND
        r."EV_LVL_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY r."EV_LVL_EV_ID"
        ORDER BY
            r."EV_LVL_ChangedAt" DESC,
            r."EV_LVL_PositedAt" DESC
    )
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
;
