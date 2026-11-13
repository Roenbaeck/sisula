-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the now
-- perspectives take none, and are views over the rewinders of the attributes (views that show the latest annex row of every posit
-- for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW nexuses."lEV_Event" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
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
CROSS JOIN
    dw."_Who" p
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
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
            attributes."rEV_DAT_Event_Date" r
    ) x
    WHERE
        x."EV_DAT_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_DAT_Who", x."EV_DAT_EV_ID"
        ORDER BY
            x."EV_DAT_PositedAt" DESC,
            x."EV_DAT_Confidence" DESC
    )
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_AUD_Event_Audience" r
    ) x
    WHERE
        x."EV_AUD_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_AUD_Who", x."EV_AUD_EV_ID"
        ORDER BY
            x."EV_AUD_PositedAt" DESC,
            x."EV_AUD_Confidence" DESC
    )
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_REV_Event_Revenue" r
    ) x
    WHERE
        x."EV_REV_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_REV_Who", x."EV_REV_EV_ID"
        ORDER BY
            x."EV_REV_PositedAt" DESC,
            x."EV_REV_Confidence" DESC
    )
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_STA_Stance" <> '?' THEN r."EV_STA_ChangedAt" END) OVER (
                PARTITION BY r."EV_STA_Who", r."EV_STA_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_STA_Event_Status" r
    ) x
    WHERE
        x."EV_STA_Stance" = '+'
    AND
        x."EV_STA_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_STA_Who", x."EV_STA_EV_ID"
        ORDER BY
            x."EV_STA_ChangedAt" DESC,
            x."EV_STA_PositedAt" DESC,
            x."EV_STA_Confidence" DESC
    )
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
        k."UTL_Utilization" AS "EV_UTL_UTL_Utilization"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_UTL_Event_Utilization" r
    ) x
    WHERE
        x."EV_UTL_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_UTL_Who", x."EV_UTL_EV_ID"
        ORDER BY
            x."EV_UTL_PositedAt" DESC,
            x."EV_UTL_Confidence" DESC
    )
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
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
        k."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
        k."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_LVL_Stance" <> '?' THEN r."EV_LVL_ChangedAt" END) OVER (
                PARTITION BY r."EV_LVL_Who", r."EV_LVL_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_LVL_Event_Level" r
    ) x
    WHERE
        x."EV_LVL_Stance" = '+'
    AND
        x."EV_LVL_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_LVL_Who", x."EV_LVL_EV_ID"
        ORDER BY
            x."EV_LVL_ChangedAt" DESC,
            x."EV_LVL_PositedAt" DESC,
            x."EV_LVL_Confidence" DESC
    )
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
;
CREATE OR REPLACE VIEW nexuses."nEV_Event" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
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
CROSS JOIN
    dw."_Who" p
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
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
            attributes."rEV_DAT_Event_Date" r
    ) x
    WHERE
        x."EV_DAT_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_DAT_Who", x."EV_DAT_EV_ID"
        ORDER BY
            x."EV_DAT_PositedAt" DESC,
            x."EV_DAT_Confidence" DESC
    )
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_AUD_Event_Audience" r
    ) x
    WHERE
        x."EV_AUD_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_AUD_Who", x."EV_AUD_EV_ID"
        ORDER BY
            x."EV_AUD_PositedAt" DESC,
            x."EV_AUD_Confidence" DESC
    )
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_REV_Event_Revenue" r
    ) x
    WHERE
        x."EV_REV_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_REV_Who", x."EV_REV_EV_ID"
        ORDER BY
            x."EV_REV_PositedAt" DESC,
            x."EV_REV_Confidence" DESC
    )
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_STA_Stance" <> '?' THEN r."EV_STA_ChangedAt" END) OVER (
                PARTITION BY r."EV_STA_Who", r."EV_STA_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_STA_Event_Status" r
        WHERE
            r."EV_STA_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."EV_STA_Stance" = '+'
    AND
        x."EV_STA_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_STA_Who", x."EV_STA_EV_ID"
        ORDER BY
            x."EV_STA_ChangedAt" DESC,
            x."EV_STA_PositedAt" DESC,
            x."EV_STA_Confidence" DESC
    )
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
        k."UTL_Utilization" AS "EV_UTL_UTL_Utilization"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_UTL_Event_Utilization" r
    ) x
    WHERE
        x."EV_UTL_Stance" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_UTL_Who", x."EV_UTL_EV_ID"
        ORDER BY
            x."EV_UTL_PositedAt" DESC,
            x."EV_UTL_Confidence" DESC
    )
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
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
        k."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
        k."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_LVL_Stance" <> '?' THEN r."EV_LVL_ChangedAt" END) OVER (
                PARTITION BY r."EV_LVL_Who", r."EV_LVL_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_LVL_Event_Level" r
        WHERE
            r."EV_LVL_ChangedAt" <= current_timestamp::date
    ) x
    WHERE
        x."EV_LVL_Stance" = '+'
    AND
        x."EV_LVL_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."EV_LVL_Who", x."EV_LVL_EV_ID"
        ORDER BY
            x."EV_LVL_ChangedAt" DESC,
            x."EV_LVL_PositedAt" DESC,
            x."EV_LVL_Confidence" DESC
    )
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
;
