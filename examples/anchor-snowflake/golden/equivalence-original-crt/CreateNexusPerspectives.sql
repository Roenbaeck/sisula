-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.tEV_Event (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    ETY_Checksum numeric(19,0),
    ETY_EventType varchar(42),
    Metadata_ETY int,
    ETY_ID_of tinyint,
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int,
    EV_DAT_Event_Date datetime,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int,
    EV_AUD_Event_Audience int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int,
    EV_REV_Event_Revenue number(19,4),
    Metadata_EV_STA int,
    EV_STA_ID int,
    EV_STA_ChangedAt datetime,
    EV_STA_PositedAt datetime,
    EV_STA_Positor tinyint,
    EV_STA_Reliability decimal(5,2),
    EV_STA_Assertion string,
     int,
    EV_STA_Event_Status varchar(20),
    Metadata_EV_UTL int,
    EV_UTL_ID int,
    EV_UTL_PositedAt datetime,
    EV_UTL_Positor tinyint,
    EV_UTL_Reliability decimal(5,2),
    EV_UTL_Assertion string,
     int,
    UTL_Utilization tinyint,
    Metadata_UTL int,
    UTL_ID tinyint,
    Metadata_EV_LVL int,
    EV_LVL_ID int,
    EV_LVL_ChangedAt date,
    EV_LVL_PositedAt datetime,
    EV_LVL_Positor tinyint,
    EV_LVL_Reliability decimal(5,2),
    EV_LVL_Assertion string,
     int,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    Metadata_PLV int,
    PLV_ID tinyint
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    kETY_of.ETY_Checksum AS ETY_Checksum,
    kETY_of.ETY_EventType AS ETY_EventType,
    kETY_of.Metadata_ETY AS Metadata_ETY,
    EV.ETY_ID_of,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_ID,
    DAT.EV_DAT_PositedAt,
    DAT.EV_DAT_Positor,
    DAT.EV_DAT_Reliability,
    DAT.EV_DAT_Assertion,
    DAT.,
    DAT.EV_DAT_Event_Date,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_ID,
    AUD.EV_AUD_PositedAt,
    AUD.EV_AUD_Positor,
    AUD.EV_AUD_Reliability,
    AUD.EV_AUD_Assertion,
    AUD.,
    AUD.EV_AUD_Event_Audience,
    REV.Metadata_EV_REV,
    REV.EV_REV_ID,
    REV.EV_REV_PositedAt,
    REV.EV_REV_Positor,
    REV.EV_REV_Reliability,
    REV.EV_REV_Assertion,
    REV.,
    REV.EV_REV_Event_Revenue,
    STA.Metadata_EV_STA,
    STA.EV_STA_ID,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_PositedAt,
    STA.EV_STA_Positor,
    STA.EV_STA_Reliability,
    STA.EV_STA_Assertion,
    STA.,
    STA.EV_STA_Event_Status,
    UTL.Metadata_EV_UTL,
    UTL.EV_UTL_ID,
    UTL.EV_UTL_PositedAt,
    UTL.EV_UTL_Positor,
    UTL.EV_UTL_Reliability,
    UTL.EV_UTL_Assertion,
    UTL.,
    kUTL.UTL_Utilization AS UTL_Utilization,
    kUTL.Metadata_UTL AS Metadata_UTL,
    UTL.UTL_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ID,
    LVL.EV_LVL_ChangedAt,
    LVL.EV_LVL_PositedAt,
    LVL.EV_LVL_Positor,
    LVL.EV_LVL_Reliability,
    LVL.EV_LVL_Assertion,
    LVL.,
    kLVL.PLV_Checksum AS ,
    kLVL.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS Metadata_PLV,
    LVL.PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    knots.ETY_EventType kETY_of
ON
    kETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    TABLE(attributes.rEV_DAT_Event_Date(
        positor,
        :,
        positingTimepoint::datetime
    )) DAT
ON
    DAT.EV_DAT_ID = (
        SELECT
            sub.EV_DAT_ID
        FROM
            TABLE(attributes.rEV_DAT_Event_Date(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_DAT_Assertion = coalesce(assertion, sub.EV_DAT_Assertion)
        ORDER BY
            sub.EV_DAT_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_AUD_Event_Audience(
        positor,
        :,
        positingTimepoint::datetime
    )) AUD
ON
    AUD.EV_AUD_ID = (
        SELECT
            sub.EV_AUD_ID
        FROM
            TABLE(attributes.rEV_AUD_Event_Audience(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_AUD_Assertion = coalesce(assertion, sub.EV_AUD_Assertion)
        ORDER BY
            sub.EV_AUD_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_REV_Event_Revenue(
        positor,
        :,
        positingTimepoint::datetime
    )) REV
ON
    REV.EV_REV_ID = (
        SELECT
            sub.EV_REV_ID
        FROM
            TABLE(attributes.rEV_REV_Event_Revenue(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_REV_Assertion = coalesce(assertion, sub.EV_REV_Assertion)
        ORDER BY
            sub.EV_REV_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_STA_Event_Status(
        positor,
        changingTimepoint
        positingTimepoint::datetime
    )) STA
ON
    STA.EV_STA_ID = (
        SELECT
            sub.EV_STA_ID
        FROM
            TABLE(attributes.rEV_STA_Event_Status(
                positor,
                changingTimepoint
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_STA_Assertion = coalesce(assertion, sub.EV_STA_Assertion)
        ORDER BY
            sub.EV_STA_ChangedAt DESC,
            sub.EV_STA_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rEV_UTL_Event_Utilization(
        positor,
        :,
        positingTimepoint::datetime
    )) UTL
ON
    UTL.EV_UTL_ID = (
        SELECT
            sub.EV_UTL_ID
        FROM
            TABLE(attributes.rEV_UTL_Event_Utilization(
                positor,
                :,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_UTL_Assertion = coalesce(assertion, sub.EV_UTL_Assertion)
        ORDER BY
            sub.EV_UTL_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.UTL_ID
LEFT JOIN
    TABLE(attributes.rEV_LVL_Event_Level(
        positor,
        changingTimepoint
        positingTimepoint::datetime
    )) LVL
ON
    LVL.EV_LVL_ID = (
        SELECT
            sub.EV_LVL_ID
        FROM
            TABLE(attributes.rEV_LVL_Event_Level(
                positor,
                changingTimepoint
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID = EV.EV_ID
        AND
            sub.EV_LVL_Assertion = coalesce(assertion, sub.EV_LVL_Assertion)
        ORDER BY
            sub.EV_LVL_ChangedAt DESC,
            sub.EV_LVL_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.PLV_ProfessionalLevel kLVL
ON
    kLVL.PLV_ID = LVL.PLV_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Event AS
SELECT
    p.Positor,
     AS Reliability,
    EV.*
FROM
    dw._Positor p
CROSS JOIN LATERAL
    TABLE(nexuses.tEV_Event(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    ETY_Checksum numeric(19,0),
    ETY_EventType varchar(42),
    Metadata_ETY int,
    ETY_ID_of tinyint,
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int,
    EV_DAT_Event_Date datetime,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int,
    EV_AUD_Event_Audience int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int,
    EV_REV_Event_Revenue number(19,4),
    Metadata_EV_STA int,
    EV_STA_ID int,
    EV_STA_ChangedAt datetime,
    EV_STA_PositedAt datetime,
    EV_STA_Positor tinyint,
    EV_STA_Reliability decimal(5,2),
    EV_STA_Assertion string,
     int,
    EV_STA_Event_Status varchar(20),
    Metadata_EV_UTL int,
    EV_UTL_ID int,
    EV_UTL_PositedAt datetime,
    EV_UTL_Positor tinyint,
    EV_UTL_Reliability decimal(5,2),
    EV_UTL_Assertion string,
     int,
    UTL_Utilization tinyint,
    Metadata_UTL int,
    UTL_ID tinyint,
    Metadata_EV_LVL int,
    EV_LVL_ID int,
    EV_LVL_ChangedAt date,
    EV_LVL_PositedAt datetime,
    EV_LVL_Positor tinyint,
    EV_LVL_Reliability decimal(5,2),
    EV_LVL_Assertion string,
     int,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    Metadata_PLV int,
    PLV_ID tinyint
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
    EV.ETY_Checksum,
    EV.ETY_EventType,
    EV.Metadata_ETY,
    EV.ETY_ID_of,
    EV.Metadata_EV_DAT,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Positor,
    EV.EV_DAT_Reliability,
    EV.EV_DAT_Assertion,
    EV.,
    EV.EV_DAT_Event_Date,
    EV.Metadata_EV_AUD,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Positor,
    EV.EV_AUD_Reliability,
    EV.EV_AUD_Assertion,
    EV.,
    EV.EV_AUD_Event_Audience,
    EV.Metadata_EV_REV,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Positor,
    EV.EV_REV_Reliability,
    EV.EV_REV_Assertion,
    EV.,
    EV.EV_REV_Event_Revenue,
    EV.Metadata_EV_STA,
    EV.EV_STA_ID,
    EV.EV_STA_ChangedAt,
    EV.EV_STA_PositedAt,
    EV.EV_STA_Positor,
    EV.EV_STA_Reliability,
    EV.EV_STA_Assertion,
    EV.,
    EV.EV_STA_Event_Status,
    EV.Metadata_EV_UTL,
    EV.EV_UTL_ID,
    EV.EV_UTL_PositedAt,
    EV.EV_UTL_Positor,
    EV.EV_UTL_Reliability,
    EV.EV_UTL_Assertion,
    EV.,
    EV.UTL_Utilization,
    EV.Metadata_UTL,
    EV.UTL_ID,
    EV.Metadata_EV_LVL,
    EV.EV_LVL_ID,
    EV.EV_LVL_ChangedAt,
    EV.EV_LVL_PositedAt,
    EV.EV_LVL_Positor,
    EV.EV_LVL_Reliability,
    EV.EV_LVL_Assertion,
    EV.,
    EV.,
    EV.PLV_ProfessionalLevel,
    EV.Metadata_PLV,
    EV.PLV_ID
FROM
    dw._Positor p
CROSS JOIN LATERAL
    TABLE(nexuses.tEV_Event(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Event AS
SELECT
    p.Positor,
     AS Reliability,
    EV.*
FROM
    dw._Positor p
CROSS JOIN LATERAL
    TABLE(nexuses.tEV_Event(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    ETY_Checksum numeric(19,0),
    ETY_EventType varchar(42),
    Metadata_ETY int,
    ETY_ID_of tinyint,
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int,
    EV_DAT_Event_Date datetime,
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int,
    EV_AUD_Event_Audience int,
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int,
    EV_REV_Event_Revenue number(19,4),
    Metadata_EV_STA int,
    EV_STA_ID int,
    EV_STA_ChangedAt datetime,
    EV_STA_PositedAt datetime,
    EV_STA_Positor tinyint,
    EV_STA_Reliability decimal(5,2),
    EV_STA_Assertion string,
     int,
    EV_STA_Event_Status varchar(20),
    Metadata_EV_UTL int,
    EV_UTL_ID int,
    EV_UTL_PositedAt datetime,
    EV_UTL_Positor tinyint,
    EV_UTL_Reliability decimal(5,2),
    EV_UTL_Assertion string,
     int,
    UTL_Utilization tinyint,
    Metadata_UTL int,
    UTL_ID tinyint,
    Metadata_EV_LVL int,
    EV_LVL_ID int,
    EV_LVL_ChangedAt date,
    EV_LVL_PositedAt datetime,
    EV_LVL_Positor tinyint,
    EV_LVL_Reliability decimal(5,2),
    EV_LVL_Assertion string,
     int,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    Metadata_PLV int,
    PLV_ID tinyint
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    EV.ETY_Checksum,
    EV.ETY_EventType,
    EV.Metadata_ETY,
    EV.ETY_ID_of,
    EV.Metadata_EV_DAT,
    EV.EV_DAT_ID,
    EV.EV_DAT_PositedAt,
    EV.EV_DAT_Positor,
    EV.EV_DAT_Reliability,
    EV.EV_DAT_Assertion,
    EV.,
    EV.EV_DAT_Event_Date,
    EV.Metadata_EV_AUD,
    EV.EV_AUD_ID,
    EV.EV_AUD_PositedAt,
    EV.EV_AUD_Positor,
    EV.EV_AUD_Reliability,
    EV.EV_AUD_Assertion,
    EV.,
    EV.EV_AUD_Event_Audience,
    EV.Metadata_EV_REV,
    EV.EV_REV_ID,
    EV.EV_REV_PositedAt,
    EV.EV_REV_Positor,
    EV.EV_REV_Reliability,
    EV.EV_REV_Assertion,
    EV.,
    EV.EV_REV_Event_Revenue,
    EV.Metadata_EV_STA,
    EV.EV_STA_ID,
    EV.EV_STA_ChangedAt,
    EV.EV_STA_PositedAt,
    EV.EV_STA_Positor,
    EV.EV_STA_Reliability,
    EV.EV_STA_Assertion,
    EV.,
    EV.EV_STA_Event_Status,
    EV.Metadata_EV_UTL,
    EV.EV_UTL_ID,
    EV.EV_UTL_PositedAt,
    EV.EV_UTL_Positor,
    EV.EV_UTL_Reliability,
    EV.EV_UTL_Assertion,
    EV.,
    EV.UTL_Utilization,
    EV.Metadata_UTL,
    EV.UTL_ID,
    EV.Metadata_EV_LVL,
    EV.EV_LVL_ID,
    EV.EV_LVL_ChangedAt,
    EV.EV_LVL_PositedAt,
    EV.EV_LVL_Positor,
    EV.EV_LVL_Reliability,
    EV.EV_LVL_Assertion,
    EV.,
    EV.,
    EV.PLV_ProfessionalLevel,
    EV.Metadata_PLV,
    EV.PLV_ID
FROM
    dw._Positor p
JOIN (
    SELECT DISTINCT
        EV_STA_Positor AS positor,
        EV_ID AS EV_ID,
        EV_STA_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.EV_STA_Event_Status
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        EV_LVL_Positor AS positor,
        EV_ID AS EV_ID,
        EV_LVL_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.EV_LVL_Event_Level
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor
CROSS JOIN LATERAL
    TABLE(nexuses.tEV_Event(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) EV
WHERE
    EV.EV_ID = tp.EV_ID
$$
;
