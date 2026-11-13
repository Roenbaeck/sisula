-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery nexus perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_Event` (
    `EV_ID`,
    `ST_ID_wasHeldAt` OPTIONS(description='The stage at which the event was held.'),
    `PR_ID_wasPlayed` OPTIONS(description='The program that was played at the event.'),
    `ETY_EventType` OPTIONS(description='The type of the event.'),
    `ETY_ID_of` OPTIONS(description='The type of the event.'),
    `EV_DAT_Event_Date` OPTIONS(description='Date and time when the event took place.'),
    `EV_AUD_Event_Audience` OPTIONS(description='Number of people in the audience at the event.'),
    `EV_REV_Event_Revenue` OPTIONS(description='Revenue from ticket sales for the event.')
)
OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.')
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_EventType` AS `ETY_EventType`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
LEFT JOIN
    public.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    public.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_ID` = `EV`.`EV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_EventType` AS `ETY_EventType`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
LEFT JOIN
    public.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    public.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_ID` = `EV`.`EV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_Event` AS
SELECT
    *
FROM
    public.`pEV_Event`(CAST(current_datetime() AS datetime))
;
