-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the now
-- perspectives take none, and are views over the rewinders of the attributes (views that show the latest annex row of every posit
-- for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" AS
SELECT
    p."Positor",
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
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Positor",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Assertion",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Positor",
    "UTL"."EV_UTL_Reliability",
    "UTL"."EV_UTL_Assertion",
    "UTL"."EV_UTL_UTL_Utnyttjande",
    "UTL"."EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Positor",
    "LVL"."EV_LVL_Reliability",
    "LVL"."EV_LVL_Assertion",
    "LVL"."EV_LVL_PLV_Checksum",
    "LVL"."EV_LVL_PLV_Yrkesnivå",
    "LVL"."EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
CROSS JOIN
    dw."_Positor" p
LEFT JOIN
    knots."ETY_Händelsetyp" "kETY_of"
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
            attributes."rEV_DAT_Händelse_Datum" r
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
            attributes."rEV_AUD_Händelse_Publik" r
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
            attributes."rEV_REV_Händelse_Intäkt" r
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
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_STA_Assertion" <> '?' THEN r."EV_STA_ChangedAt" END) OVER (
                PARTITION BY r."EV_STA_Positor", r."EV_STA_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_STA_Händelse_Status" r
    ) x
    WHERE
        x."EV_STA_Assertion" = '+'
    AND
        x."EV_STA_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_STA_Positor", x."EV_STA_EV_ID"
        ORDER BY
            x."EV_STA_ChangedAt" DESC,
            x."EV_STA_PositedAt" DESC,
            x."EV_STA_Reliability" DESC
    )
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
        k."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_UTL_Händelse_Utnyttjande" r
    ) x
    WHERE
        x."EV_UTL_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_UTL_Positor", x."EV_UTL_EV_ID"
        ORDER BY
            x."EV_UTL_PositedAt" DESC,
            x."EV_UTL_Reliability" DESC
    )
    ) y
    LEFT JOIN
        knots."UTL_Utnyttjande" k
    ON
        k."UTL_ID" = y."EV_UTL_UTL_ID"
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
AND
    "UTL"."EV_UTL_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
        k."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
        k."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_LVL_Assertion" <> '?' THEN r."EV_LVL_ChangedAt" END) OVER (
                PARTITION BY r."EV_LVL_Positor", r."EV_LVL_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_LVL_Händelse_Level" r
    ) x
    WHERE
        x."EV_LVL_Assertion" = '+'
    AND
        x."EV_LVL_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_LVL_Positor", x."EV_LVL_EV_ID"
        ORDER BY
            x."EV_LVL_ChangedAt" DESC,
            x."EV_LVL_PositedAt" DESC,
            x."EV_LVL_Reliability" DESC
    )
    ) y
    LEFT JOIN
        knots."PLV_Yrkesnivå" k
    ON
        k."PLV_ID" = y."EV_LVL_PLV_ID"
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" AS
SELECT
    p."Positor",
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
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Positor",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Assertion",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Positor",
    "UTL"."EV_UTL_Reliability",
    "UTL"."EV_UTL_Assertion",
    "UTL"."EV_UTL_UTL_Utnyttjande",
    "UTL"."EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Positor",
    "LVL"."EV_LVL_Reliability",
    "LVL"."EV_LVL_Assertion",
    "LVL"."EV_LVL_PLV_Checksum",
    "LVL"."EV_LVL_PLV_Yrkesnivå",
    "LVL"."EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
CROSS JOIN
    dw."_Positor" p
LEFT JOIN
    knots."ETY_Händelsetyp" "kETY_of"
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
            attributes."rEV_DAT_Händelse_Datum" r
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
            attributes."rEV_AUD_Händelse_Publik" r
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
            attributes."rEV_REV_Händelse_Intäkt" r
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
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_STA_Assertion" <> '?' THEN r."EV_STA_ChangedAt" END) OVER (
                PARTITION BY r."EV_STA_Positor", r."EV_STA_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_STA_Händelse_Status" r
        WHERE
            r."EV_STA_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."EV_STA_Assertion" = '+'
    AND
        x."EV_STA_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_STA_Positor", x."EV_STA_EV_ID"
        ORDER BY
            x."EV_STA_ChangedAt" DESC,
            x."EV_STA_PositedAt" DESC,
            x."EV_STA_Reliability" DESC
    )
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
        k."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_UTL_Händelse_Utnyttjande" r
    ) x
    WHERE
        x."EV_UTL_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_UTL_Positor", x."EV_UTL_EV_ID"
        ORDER BY
            x."EV_UTL_PositedAt" DESC,
            x."EV_UTL_Reliability" DESC
    )
    ) y
    LEFT JOIN
        knots."UTL_Utnyttjande" k
    ON
        k."UTL_ID" = y."EV_UTL_UTL_ID"
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
AND
    "UTL"."EV_UTL_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
        k."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
        k."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_LVL_Assertion" <> '?' THEN r."EV_LVL_ChangedAt" END) OVER (
                PARTITION BY r."EV_LVL_Positor", r."EV_LVL_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_LVL_Händelse_Level" r
        WHERE
            r."EV_LVL_ChangedAt" <= current_timestamp::date
    ) x
    WHERE
        x."EV_LVL_Assertion" = '+'
    AND
        x."EV_LVL_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_LVL_Positor", x."EV_LVL_EV_ID"
        ORDER BY
            x."EV_LVL_ChangedAt" DESC,
            x."EV_LVL_PositedAt" DESC,
            x."EV_LVL_Reliability" DESC
    )
    ) y
    LEFT JOIN
        knots."PLV_Yrkesnivå" k
    ON
        k."PLV_ID" = y."EV_LVL_PLV_ID"
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_Positor" = p."Positor"
;
