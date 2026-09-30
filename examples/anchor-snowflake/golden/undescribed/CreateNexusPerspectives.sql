-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_Event (
    EV_ID,
    Metadata_EV,
    ST_ID_wasHeldAt,
    PR_ID_wasPlayed,
    of_ETY_EventType,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Event_Date,
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_Event_Audience,
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_Event_Revenue
) 
AS
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    public.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_REV_Event_Revenue REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    EV_ID int,
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    Metadata_EV_AUD int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    Metadata_EV_REV int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    public.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_AUD_Event_Audience AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    public.EV_REV_Event_Revenue REV
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
