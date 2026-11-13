-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tEV_Event` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `kETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Positor`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Assertion`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Positor`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Assertion`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Positor`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Assertion`,
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public.`_Positor` p
LEFT JOIN
    public.`ETY_EventType` `kETY_of`
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
            public.`rEV_DAT_Event_Date`(
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
            public.`rEV_AUD_Event_Audience`(
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
            public.`rEV_REV_Event_Revenue`(
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
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_Event` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    public.`_Positor` p,
    public.`tEV_Event`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `EV`.`of_ETY_EventType`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Positor`,
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Assertion`,
    `EV`.`EV_DAT_Event_Date`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Positor`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Assertion`,
    `EV`.`EV_AUD_Event_Audience`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Positor`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Assertion`,
    `EV`.`EV_REV_Event_Revenue`
FROM
    public.`_Positor` p,
    public.`tEV_Event`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_Event` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    public.`_Positor` p,
    public.`tEV_Event`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
