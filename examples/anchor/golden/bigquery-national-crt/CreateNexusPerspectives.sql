-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`tEV_Händelse` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Positor`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Assertion`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Positor`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Assertion`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Positor`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Assertion`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Positor`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Assertion`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Positor`,
    `UTL`.`EV_UTL_Reliability`,
    `UTL`.`EV_UTL_Assertion`,
    `UTL`.`EV_UTL_UTL_Utnyttjande`,
    `UTL`.`EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Positor`,
    `LVL`.`EV_LVL_Reliability`,
    `LVL`.`EV_LVL_Assertion`,
    `LVL`.`EV_LVL_PLV_Checksum`,
    `LVL`.`EV_LVL_PLV_Yrkesnivå`,
    `LVL`.`EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Händelse` `EV`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw.`_Positor` p
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rEV_DAT_Händelse_Datum`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_DAT_Assertion` = coalesce(assertion, x.`EV_DAT_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_DAT_Positor`, x.`EV_DAT_EV_ID`
            ORDER BY
                x.`EV_DAT_PositedAt` DESC,
                x.`EV_DAT_Reliability` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
AND
    `DAT`.`EV_DAT_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rEV_AUD_Händelse_Publik`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_AUD_Assertion` = coalesce(assertion, x.`EV_AUD_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_AUD_Positor`, x.`EV_AUD_EV_ID`
            ORDER BY
                x.`EV_AUD_PositedAt` DESC,
                x.`EV_AUD_Reliability` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
AND
    `AUD`.`EV_AUD_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rEV_REV_Händelse_Intäkt`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_REV_Assertion` = coalesce(assertion, x.`EV_REV_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_REV_Positor`, x.`EV_REV_EV_ID`
            ORDER BY
                x.`EV_REV_PositedAt` DESC,
                x.`EV_REV_Reliability` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
AND
    `REV`.`EV_REV_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`EV_STA_Assertion` <> '?', r.`EV_STA_ChangedAt`, null)) OVER (
                PARTITION BY r.`EV_STA_Positor`, r.`EV_STA_EV_ID`
            ) AS `inEffect`
        FROM
            attributes.`rEV_STA_Händelse_Status`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_STA_Assertion` = coalesce(assertion, x.`EV_STA_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`EV_STA_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_STA_Positor`, x.`EV_STA_EV_ID`
            ORDER BY
                x.`EV_STA_ChangedAt` DESC,
                x.`EV_STA_PositedAt` DESC,
                x.`EV_STA_Reliability` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
AND
    `STA`.`EV_STA_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
        k.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rEV_UTL_Händelse_Utnyttjande`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_UTL_Assertion` = coalesce(assertion, x.`EV_UTL_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_UTL_Positor`, x.`EV_UTL_EV_ID`
            ORDER BY
                x.`EV_UTL_PositedAt` DESC,
                x.`EV_UTL_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        knots.`UTL_Utnyttjande` k
    ON
        k.`UTL_ID` = y.`EV_UTL_UTL_ID`
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
AND
    `UTL`.`EV_UTL_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
        k.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
        k.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`EV_LVL_Assertion` <> '?', r.`EV_LVL_ChangedAt`, null)) OVER (
                PARTITION BY r.`EV_LVL_Positor`, r.`EV_LVL_EV_ID`
            ) AS `inEffect`
        FROM
            attributes.`rEV_LVL_Händelse_Level`(
                CAST(null AS int64),
                CAST(changingTimepoint AS date),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_LVL_Assertion` = coalesce(assertion, x.`EV_LVL_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`EV_LVL_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_LVL_Positor`, x.`EV_LVL_EV_ID`
            ORDER BY
                x.`EV_LVL_ChangedAt` DESC,
                x.`EV_LVL_PositedAt` DESC,
                x.`EV_LVL_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        knots.`PLV_Yrkesnivå` k
    ON
        k.`PLV_ID` = y.`EV_LVL_PLV_ID`
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
AND
    `LVL`.`EV_LVL_Positor` = p.`Positor`
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`lEV_Händelse` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    dw.`_Positor` p,
    nexuses.`tEV_Händelse`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Händelse` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `EV`.`of_ETY_Checksum`,
    `EV`.`of_ETY_Händelsetyp`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Positor`,
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Assertion`,
    `EV`.`EV_DAT_Händelse_Datum`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Positor`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Assertion`,
    `EV`.`EV_AUD_Händelse_Publik`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Positor`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Assertion`,
    `EV`.`EV_REV_Händelse_Intäkt`,
    `EV`.`EV_STA_EV_ID`,
    `EV`.`Metadata_EV_STA`,
    `EV`.`EV_STA_ID`,
    `EV`.`EV_STA_ChangedAt`,
    `EV`.`EV_STA_PositedAt`,
    `EV`.`EV_STA_Positor`,
    `EV`.`EV_STA_Reliability`,
    `EV`.`EV_STA_Assertion`,
    `EV`.`EV_STA_Händelse_Status`,
    `EV`.`EV_UTL_EV_ID`,
    `EV`.`Metadata_EV_UTL`,
    `EV`.`EV_UTL_ID`,
    `EV`.`EV_UTL_PositedAt`,
    `EV`.`EV_UTL_Positor`,
    `EV`.`EV_UTL_Reliability`,
    `EV`.`EV_UTL_Assertion`,
    `EV`.`EV_UTL_UTL_Utnyttjande`,
    `EV`.`EV_UTL_Metadata_UTL`,
    `EV`.`EV_UTL_UTL_ID`,
    `EV`.`EV_LVL_EV_ID`,
    `EV`.`Metadata_EV_LVL`,
    `EV`.`EV_LVL_ID`,
    `EV`.`EV_LVL_ChangedAt`,
    `EV`.`EV_LVL_PositedAt`,
    `EV`.`EV_LVL_Positor`,
    `EV`.`EV_LVL_Reliability`,
    `EV`.`EV_LVL_Assertion`,
    `EV`.`EV_LVL_PLV_Checksum`,
    `EV`.`EV_LVL_PLV_Yrkesnivå`,
    `EV`.`EV_LVL_Metadata_PLV`,
    `EV`.`EV_LVL_PLV_ID`
FROM
    dw.`_Positor` p,
    nexuses.`tEV_Händelse`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`nEV_Händelse` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    dw.`_Positor` p,
    nexuses.`tEV_Händelse`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Händelse` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with an outer join on its argument for each row of another
-- table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Positor`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Assertion`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Positor`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Assertion`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Positor`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Assertion`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Positor`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Assertion`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Positor`,
    `UTL`.`EV_UTL_Reliability`,
    `UTL`.`EV_UTL_Assertion`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Positor`,
    `LVL`.`EV_LVL_Reliability`,
    `LVL`.`EV_LVL_Assertion`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `EV_STA_Positor` AS positor,
        `EV_STA_EV_ID` AS `EV_ID`,
        CAST(`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Händelse_Status`
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        `EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `EV_LVL_Positor` AS positor,
        `EV_LVL_EV_ID` AS `EV_ID`,
        CAST(`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Händelse_Level`
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        `EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN
    nexuses.`EV_Händelse` `EV`
ON
    `EV`.`EV_ID` = tp.`EV_ID`
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Händelse_Datum`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_Positor`, r.`EV_DAT_EV_ID`
            ORDER BY
                r.`EV_DAT_PositedAt` DESC,
                r.`EV_DAT_Reliability` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
AND
    `DAT`.`EV_DAT_Positor` = tp.positor
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_AUD_Händelse_Publik`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_Positor`, r.`EV_AUD_EV_ID`
            ORDER BY
                r.`EV_AUD_PositedAt` DESC,
                r.`EV_AUD_Reliability` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
AND
    `AUD`.`EV_AUD_Positor` = tp.positor
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_REV_Händelse_Intäkt`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_REV_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_Positor`, r.`EV_REV_EV_ID`
            ORDER BY
                r.`EV_REV_PositedAt` DESC,
                r.`EV_REV_Reliability` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
AND
    `REV`.`EV_REV_Positor` = tp.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`EV_STA_ChangedAt`) OVER (
            PARTITION BY y.`EV_STA_Positor`, y.`EV_STA_EV_ID`
            ORDER BY y.`EV_STA_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            attributes.`rEV_STA_Händelse_Status`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_STA_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_STA_Positor`, r.`EV_STA_EV_ID`, r.`EV_STA_ChangedAt`
                ORDER BY
                    IF(r.`EV_STA_Assertion` = '+', 0, 1),
                    r.`EV_STA_PositedAt` DESC,
                    r.`EV_STA_Reliability` DESC
            ) = 1
    ) y
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
AND
    `STA`.`EV_STA_Positor` = tp.positor
AND
    `STA`.`EV_STA_Assertion` = '+'
AND
    `STA`.`EV_STA_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    `STA`.`until` IS NULL
OR
    `STA`.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_UTL_Händelse_Utnyttjande`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_Positor`, r.`EV_UTL_EV_ID`
            ORDER BY
                r.`EV_UTL_PositedAt` DESC,
                r.`EV_UTL_Reliability` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
AND
    `UTL`.`EV_UTL_Positor` = tp.positor
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY y.`EV_LVL_Positor`, y.`EV_LVL_EV_ID`
            ORDER BY y.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            attributes.`rEV_LVL_Händelse_Level`(
                CAST(null AS int64),
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_LVL_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_LVL_Positor`, r.`EV_LVL_EV_ID`, r.`EV_LVL_ChangedAt`
                ORDER BY
                    IF(r.`EV_LVL_Assertion` = '+', 0, 1),
                    r.`EV_LVL_PositedAt` DESC,
                    r.`EV_LVL_Reliability` DESC
            ) = 1
    ) y
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
AND
    `LVL`.`EV_LVL_Positor` = tp.positor
AND
    `LVL`.`EV_LVL_Assertion` = '+'
AND
    `LVL`.`EV_LVL_ChangedAt` <= CAST(tp.inspectedTimepoint AS date)
AND (
    `LVL`.`until` IS NULL
OR
    `LVL`.`until` > CAST(tp.inspectedTimepoint AS date)
)
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
