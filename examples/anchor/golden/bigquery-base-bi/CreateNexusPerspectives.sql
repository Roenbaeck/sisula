-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION public.`tEV_Event` (
    changingTimepoint datetime,
    positingTimepoint datetime
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
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
LEFT JOIN
    public.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rEV_DAT_Event_Date`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_EV_ID`
            ORDER BY
                r.`EV_DAT_PositedAt` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rEV_AUD_Event_Audience`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_EV_ID`
            ORDER BY
                r.`EV_AUD_PositedAt` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rEV_REV_Event_Revenue`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_REV_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_EV_ID`
            ORDER BY
                r.`EV_REV_PositedAt` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
)
;
CREATE OR REPLACE VIEW public.`lEV_Event` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    public.`tEV_Event`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
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
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Event_Date`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Event_Audience`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Event_Revenue`
FROM
    public.`tEV_Event`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
)
;
CREATE OR REPLACE VIEW public.`nEV_Event` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    public.`tEV_Event`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
