-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tEV_Event (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
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
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    kETY_of.ETY_EventType AS of_ETY_EventType,
    kETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_ID,
    DAT.EV_DAT_PositedAt,
    DAT.EV_DAT_Positor,
    DAT.EV_DAT_Reliability,
    DAT.EV_DAT_Assertion,
    DAT.,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_ID,
    AUD.EV_AUD_PositedAt,
    AUD.EV_AUD_Positor,
    AUD.EV_AUD_Reliability,
    AUD.EV_AUD_Assertion,
    AUD.,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_ID,
    REV.EV_REV_PositedAt,
    REV.EV_REV_Positor,
    REV.EV_REV_Reliability,
    REV.EV_REV_Assertion,
    REV.,
    REV.EV_REV_Event_Revenue
FROM
    public.EV_Event EV
LEFT JOIN
    public.ETY_EventType kETY_of
ON
    kETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(public.rEV_DAT_Event_Date(
        positor,
        :,
        positingTimepoint::datetime
    )) DAT
ON
    DAT.EV_DAT_ID = (
        SELECT
            sub.EV_DAT_ID
        FROM
            TABLE(public.rEV_DAT_Event_Date(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_DAT_EV_ID = EV.EV_ID
        AND
            sub.EV_DAT_Assertion = coalesce(assertion, sub.EV_DAT_Assertion)
        ORDER BY
            sub.EV_DAT_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rEV_AUD_Event_Audience(
        positor,
        :,
        positingTimepoint::datetime
    )) AUD
ON
    AUD.EV_AUD_ID = (
        SELECT
            sub.EV_AUD_ID
        FROM
            TABLE(public.rEV_AUD_Event_Audience(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_AUD_EV_ID = EV.EV_ID
        AND
            sub.EV_AUD_Assertion = coalesce(assertion, sub.EV_AUD_Assertion)
        ORDER BY
            sub.EV_AUD_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public.rEV_REV_Event_Revenue(
        positor,
        :,
        positingTimepoint::datetime
    )) REV
ON
    REV.EV_REV_ID = (
        SELECT
            sub.EV_REV_ID
        FROM
            TABLE(public.rEV_REV_Event_Revenue(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_REV_EV_ID = EV.EV_ID
        AND
            sub.EV_REV_Assertion = coalesce(assertion, sub.EV_REV_Assertion)
        ORDER BY
            sub.EV_REV_PositedAt DESC
        LIMIT 1
    )
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_Event AS
SELECT
    p.Positor,
     AS Reliability,
    EV.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tEV_Event(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    EV_ID int,
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed int,
    of_ETY_EventType varchar(42),
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID int,
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID int,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    EV.of_ETY_EventType,
    EV.of_Metadata_ETY,
    EV.ETY_ID_of,
    EV.EV_DAT_EV_ID,
    EV.Metadata_EV_DAT,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Positor,
    EV.EV_DAT_Reliability,
    EV.EV_DAT_Assertion,
    EV.,
    EV.EV_DAT_Event_Date,
    EV.EV_AUD_EV_ID,
    EV.Metadata_EV_AUD,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Positor,
    EV.EV_AUD_Reliability,
    EV.EV_AUD_Assertion,
    EV.,
    EV.EV_AUD_Event_Audience,
    EV.EV_REV_EV_ID,
    EV.Metadata_EV_REV,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Positor,
    EV.EV_REV_Reliability,
    EV.EV_REV_Assertion,
    EV.,
    EV.EV_REV_Event_Revenue
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tEV_Event(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_Event AS
SELECT
    p.Positor,
     AS Reliability,
    EV.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tEV_Event(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
;
