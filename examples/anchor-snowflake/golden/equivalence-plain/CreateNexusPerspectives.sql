-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_Event (
    EV_ID,
    ST_ID_wasHeldAt COMMENT 'The stage at which the event was held.',
    PR_ID_wasPlayed COMMENT 'The program that was played at the event.',
    of_ETY_EventType COMMENT 'The type of the event.',
    ETY_ID_of COMMENT 'The type of the event.',
    EV_DAT_EV_ID,
    EV_DAT_EQ,
    EV_DAT_Event_Date COMMENT 'Date and time when the event took place.',
    EV_AUD_EV_ID,
    EV_AUD_Event_Audience COMMENT 'Number of people in the audience at the event.',
    EV_REV_EV_ID,
    EV_REV_EQ,
    EV_REV_Event_Revenue COMMENT 'Revenue from ticket sales for the event.'
) COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(0)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(0)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(0)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(0)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_Event AS
SELECT
    *
FROM
    TABLE(public.pEV_Event(current_timestamp()::timestamp_ntz(9)))
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.elEV_Event (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(equivalent)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(equivalent)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.epEV_Event (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.EV_DAT_EQ,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.eEV_DAT_Event_Date(equivalent)) DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(public.eEV_REV_Event_Revenue(equivalent)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enEV_Event (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    *
FROM
    TABLE(public.epEV_Event(equivalent, current_timestamp()::timestamp_ntz(9)))
$$
;
