-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Event (
    EV_ID,
    Metadata_EV,
    ST_ID_wasHeldAt COMMENT 'The stage at which the event was held.',
    PR_ID_wasPlayed COMMENT 'The program that was played at the event.',
    of_ETY_Checksum,
    of_ETY_EventType,
    of_ETY_EQ,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Event_Date COMMENT 'Date and time when the event took place.',
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_EQ,
    EV_AUD_Event_Audience COMMENT 'Number of people in the audience at the event.',
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_EQ,
    EV_REV_Event_Revenue COMMENT 'Revenue from ticket sales for the event.',
    EV_STA_EV_ID,
    Metadata_EV_STA,
    EV_STA_ChangedAt,
    EV_STA_EQ,
    EV_STA_Event_Status COMMENT 'Status of the event, which may change until it has taken place.',
    EV_UTL_EV_ID,
    Metadata_EV_UTL,
    EV_UTL_UTL_Utilization,
    EV_UTL_Metadata_UTL,
    EV_UTL_UTL_ID,
    EV_LVL_EV_ID,
    Metadata_EV_LVL,
    EV_LVL_ChangedAt,
    EV_LVL_PLV_Checksum,
    EV_LVL_PLV_EQ,
    EV_LVL_PLV_ProfessionalLevel COMMENT 'Professional level required for the event, over time.',
    EV_LVL_Metadata_PLV,
    EV_LVL_PLV_ID COMMENT 'Professional level required for the event, over time.'
) COPY GRANTS COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_Checksum AS of_ETY_Checksum,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.ETY_EQ AS of_ETY_EQ,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_EQ,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_EQ,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ChangedAt,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_EQ AS EV_LVL_PLV_EQ,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    TABLE(knots.eETY_EventType(0)) ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_AUD_Event_Audience(0)) AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_REV_Event_Revenue(0)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_STA_Event_Status(0)) STA
ON
    STA.EV_STA_EV_ID = EV.EV_ID
AND
    STA.EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            TABLE(attributes.eEV_STA_Event_Status(0)) sub 
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
   )
LEFT JOIN
    attributes.EV_UTL_Event_Utilization UTL
ON
    UTL.EV_UTL_EV_ID = EV.EV_ID
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    attributes.EV_LVL_Event_Level LVL
ON
    LVL.EV_LVL_EV_ID = EV.EV_ID
AND
    LVL.EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            attributes.EV_LVL_Event_Level sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(0)) kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_Checksum AS of_ETY_Checksum,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.ETY_EQ AS of_ETY_EQ,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_EQ,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_EQ,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ChangedAt,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_EQ AS EV_LVL_PLV_EQ,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    TABLE(knots.eETY_EventType(0)) ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_AUD_Event_Audience(0)) AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_REV_Event_Revenue(0)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.rEV_STA_Event_Status(0, changingTimepoint::datetime)) STA
ON
    STA.EV_STA_EV_ID = EV.EV_ID
AND
    STA.EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            TABLE(attributes.rEV_STA_Event_Status(0, changingTimepoint::datetime)) sub
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
   )
LEFT JOIN
    attributes.EV_UTL_Event_Utilization UTL
ON
    UTL.EV_UTL_EV_ID = EV.EV_ID
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint::date)) LVL
ON
    LVL.EV_LVL_EV_ID = EV.EV_ID
AND
    LVL.EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint::date)) sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(0)) kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Event COPY GRANTS AS
SELECT
    *
FROM
    TABLE(nexuses.pEV_Event(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hSTA.EV_STA_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'STA' AS mnemonic,
    pEV.EV_ID,
    pEV.Metadata_EV,
    pEV.ST_ID_wasHeldAt,
    pEV.PR_ID_wasPlayed,
    pEV.of_ETY_Checksum,
    pEV.of_ETY_EventType,
    pEV.of_ETY_EQ,
    pEV.of_Metadata_ETY,
    pEV.ETY_ID_of,
    pEV.EV_DAT_EV_ID,
    pEV.Metadata_EV_DAT,
    pEV.EV_DAT_Event_Date,
    pEV.EV_AUD_EV_ID,
    pEV.Metadata_EV_AUD,
    pEV.EV_AUD_EQ,
    pEV.EV_AUD_Event_Audience,
    pEV.EV_REV_EV_ID,
    pEV.Metadata_EV_REV,
    pEV.EV_REV_EQ,
    pEV.EV_REV_Event_Revenue,
    pEV.EV_STA_EV_ID,
    pEV.Metadata_EV_STA,
    pEV.EV_STA_ChangedAt,
    pEV.EV_STA_EQ,
    pEV.EV_STA_Event_Status,
    pEV.EV_UTL_EV_ID,
    pEV.Metadata_EV_UTL,
    pEV.EV_UTL_UTL_Utilization,
    pEV.EV_UTL_Metadata_UTL,
    pEV.EV_UTL_UTL_ID,
    pEV.EV_LVL_EV_ID,
    pEV.Metadata_EV_LVL,
    pEV.EV_LVL_ChangedAt,
    pEV.EV_LVL_PLV_Checksum,
    pEV.EV_LVL_PLV_EQ,
    pEV.EV_LVL_PLV_ProfessionalLevel,
    pEV.EV_LVL_Metadata_PLV,
    pEV.EV_LVL_PLV_ID
FROM
    TABLE(attributes.eEV_STA_Event_Status(0)) hSTA, 
    TABLE(nexuses.pEV_Event(hSTA.EV_STA_ChangedAt::timestamp_ntz(9))) pEV
WHERE
    (selection IS NULL OR selection LIKE '%STA%')
AND
    hSTA.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pEV.EV_ID = hSTA.EV_STA_EV_ID
UNION
SELECT DISTINCT
    hLVL.EV_LVL_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LVL' AS mnemonic,
    pEV.EV_ID,
    pEV.Metadata_EV,
    pEV.ST_ID_wasHeldAt,
    pEV.PR_ID_wasPlayed,
    pEV.of_ETY_Checksum,
    pEV.of_ETY_EventType,
    pEV.of_ETY_EQ,
    pEV.of_Metadata_ETY,
    pEV.ETY_ID_of,
    pEV.EV_DAT_EV_ID,
    pEV.Metadata_EV_DAT,
    pEV.EV_DAT_Event_Date,
    pEV.EV_AUD_EV_ID,
    pEV.Metadata_EV_AUD,
    pEV.EV_AUD_EQ,
    pEV.EV_AUD_Event_Audience,
    pEV.EV_REV_EV_ID,
    pEV.Metadata_EV_REV,
    pEV.EV_REV_EQ,
    pEV.EV_REV_Event_Revenue,
    pEV.EV_STA_EV_ID,
    pEV.Metadata_EV_STA,
    pEV.EV_STA_ChangedAt,
    pEV.EV_STA_EQ,
    pEV.EV_STA_Event_Status,
    pEV.EV_UTL_EV_ID,
    pEV.Metadata_EV_UTL,
    pEV.EV_UTL_UTL_Utilization,
    pEV.EV_UTL_Metadata_UTL,
    pEV.EV_UTL_UTL_ID,
    pEV.EV_LVL_EV_ID,
    pEV.Metadata_EV_LVL,
    pEV.EV_LVL_ChangedAt,
    pEV.EV_LVL_PLV_Checksum,
    pEV.EV_LVL_PLV_EQ,
    pEV.EV_LVL_PLV_ProfessionalLevel,
    pEV.EV_LVL_Metadata_PLV,
    pEV.EV_LVL_PLV_ID
FROM
    attributes.EV_LVL_Event_Level hLVL,
    TABLE(nexuses.pEV_Event(hLVL.EV_LVL_ChangedAt::timestamp_ntz(9))) pEV
WHERE
    (selection IS NULL OR selection LIKE '%LVL%')
AND
    hLVL.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pEV.EV_ID = hLVL.EV_LVL_EV_ID
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.elEV_Event (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_Checksum AS of_ETY_Checksum,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.ETY_EQ AS of_ETY_EQ,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_EQ,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_EQ,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ChangedAt,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_EQ AS EV_LVL_PLV_EQ,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    TABLE(knots.eETY_EventType(equivalent)) ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_AUD_Event_Audience(equivalent)) AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_REV_Event_Revenue(equivalent)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_STA_Event_Status(equivalent)) STA
ON
    STA.EV_STA_EV_ID = EV.EV_ID
AND
    STA.EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            TABLE(attributes.eEV_STA_Event_Status(equivalent)) sub 
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
   )
LEFT JOIN
    attributes.EV_UTL_Event_Utilization UTL
ON
    UTL.EV_UTL_EV_ID = EV.EV_ID
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    attributes.EV_LVL_Event_Level LVL
ON
    LVL.EV_LVL_EV_ID = EV.EV_ID
AND
    LVL.EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            attributes.EV_LVL_Event_Level sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(equivalent)) kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.epEV_Event (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    EV.EV_ID,
    EV.Metadata_EV,
    EV.ST_ID_wasHeldAt,
    EV.PR_ID_wasPlayed,
    ETY_of.ETY_Checksum AS of_ETY_Checksum,
    ETY_of.ETY_EventType AS of_ETY_EventType,
    ETY_of.ETY_EQ AS of_ETY_EQ,
    ETY_of.Metadata_ETY AS of_Metadata_ETY,
    EV.ETY_ID_of,
    DAT.EV_DAT_EV_ID,
    DAT.Metadata_EV_DAT,
    DAT.EV_DAT_Event_Date,
    AUD.EV_AUD_EV_ID,
    AUD.Metadata_EV_AUD,
    AUD.EV_AUD_EQ,
    AUD.EV_AUD_Event_Audience,
    REV.EV_REV_EV_ID,
    REV.Metadata_EV_REV,
    REV.EV_REV_EQ,
    REV.EV_REV_Event_Revenue,
    STA.EV_STA_EV_ID,
    STA.Metadata_EV_STA,
    STA.EV_STA_ChangedAt,
    STA.EV_STA_EQ,
    STA.EV_STA_Event_Status,
    UTL.EV_UTL_EV_ID,
    UTL.Metadata_EV_UTL,
    kUTL.UTL_Utilization AS EV_UTL_UTL_Utilization,
    kUTL.Metadata_UTL AS EV_UTL_Metadata_UTL,
    UTL.EV_UTL_UTL_ID,
    LVL.EV_LVL_EV_ID,
    LVL.Metadata_EV_LVL,
    LVL.EV_LVL_ChangedAt,
    kLVL.PLV_Checksum AS EV_LVL_PLV_Checksum,
    kLVL.PLV_EQ AS EV_LVL_PLV_EQ,
    kLVL.PLV_ProfessionalLevel AS EV_LVL_PLV_ProfessionalLevel,
    kLVL.Metadata_PLV AS EV_LVL_Metadata_PLV,
    LVL.EV_LVL_PLV_ID
FROM
    nexuses.EV_Event EV
LEFT JOIN
    TABLE(knots.eETY_EventType(equivalent)) ETY_of
ON
    ETY_of.ETY_ID = EV.ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Event_Date DAT
ON
    DAT.EV_DAT_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_AUD_Event_Audience(equivalent)) AUD
ON
    AUD.EV_AUD_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.eEV_REV_Event_Revenue(equivalent)) REV
ON
    REV.EV_REV_EV_ID = EV.EV_ID
LEFT JOIN
    TABLE(attributes.rEV_STA_Event_Status(equivalent, changingTimepoint::datetime)) STA
ON
    STA.EV_STA_EV_ID = EV.EV_ID
AND
    STA.EV_STA_ChangedAt = (
        SELECT
            max(sub.EV_STA_ChangedAt)
        FROM
            TABLE(attributes.rEV_STA_Event_Status(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub.EV_STA_EV_ID = EV.EV_ID
   )
LEFT JOIN
    attributes.EV_UTL_Event_Utilization UTL
ON
    UTL.EV_UTL_EV_ID = EV.EV_ID
LEFT JOIN
    knots.UTL_Utilization kUTL
ON
    kUTL.UTL_ID = UTL.EV_UTL_UTL_ID
LEFT JOIN
    TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint::date)) LVL
ON
    LVL.EV_LVL_EV_ID = EV.EV_ID
AND
    LVL.EV_LVL_ChangedAt = (
        SELECT
            max(sub.EV_LVL_ChangedAt)
        FROM
            TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint::date)) sub
        WHERE
            sub.EV_LVL_EV_ID = EV.EV_ID
   )
LEFT JOIN
    TABLE(knots.ePLV_ProfessionalLevel(equivalent)) kLVL
ON
    kLVL.PLV_ID = LVL.EV_LVL_PLV_ID
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.enEV_Event (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(nexuses.epEV_Event(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.edEV_Event (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    EV_ID numeric(12,0),
    Metadata_EV int,
    ST_ID_wasHeldAt int,
    PR_ID_wasPlayed number(10,0),
    of_ETY_Checksum numeric(19,0),
    of_ETY_EventType varchar(42),
    of_ETY_EQ tinyint,
    of_Metadata_ETY int,
    ETY_ID_of tinyint,
    EV_DAT_EV_ID numeric(12,0),
    Metadata_EV_DAT int,
    EV_DAT_Event_Date datetime,
    EV_AUD_EV_ID numeric(12,0),
    Metadata_EV_AUD int,
    EV_AUD_EQ tinyint,
    EV_AUD_Event_Audience int,
    EV_REV_EV_ID numeric(12,0),
    Metadata_EV_REV int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4),
    EV_STA_EV_ID numeric(12,0),
    Metadata_EV_STA int,
    EV_STA_ChangedAt datetime,
    EV_STA_EQ tinyint,
    EV_STA_Event_Status varchar(20),
    EV_UTL_EV_ID numeric(12,0),
    Metadata_EV_UTL int,
    EV_UTL_UTL_Utilization tinyint,
    EV_UTL_Metadata_UTL int,
    EV_UTL_UTL_ID tinyint,
    EV_LVL_EV_ID numeric(12,0),
    Metadata_EV_LVL int,
    EV_LVL_ChangedAt date,
    EV_LVL_PLV_Checksum numeric(19,0),
    EV_LVL_PLV_EQ tinyint,
    EV_LVL_PLV_ProfessionalLevel string,
    EV_LVL_Metadata_PLV int,
    EV_LVL_PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hSTA.EV_STA_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'STA' AS mnemonic,
    pEV.EV_ID,
    pEV.Metadata_EV,
    pEV.ST_ID_wasHeldAt,
    pEV.PR_ID_wasPlayed,
    pEV.of_ETY_Checksum,
    pEV.of_ETY_EventType,
    pEV.of_ETY_EQ,
    pEV.of_Metadata_ETY,
    pEV.ETY_ID_of,
    pEV.EV_DAT_EV_ID,
    pEV.Metadata_EV_DAT,
    pEV.EV_DAT_Event_Date,
    pEV.EV_AUD_EV_ID,
    pEV.Metadata_EV_AUD,
    pEV.EV_AUD_EQ,
    pEV.EV_AUD_Event_Audience,
    pEV.EV_REV_EV_ID,
    pEV.Metadata_EV_REV,
    pEV.EV_REV_EQ,
    pEV.EV_REV_Event_Revenue,
    pEV.EV_STA_EV_ID,
    pEV.Metadata_EV_STA,
    pEV.EV_STA_ChangedAt,
    pEV.EV_STA_EQ,
    pEV.EV_STA_Event_Status,
    pEV.EV_UTL_EV_ID,
    pEV.Metadata_EV_UTL,
    pEV.EV_UTL_UTL_Utilization,
    pEV.EV_UTL_Metadata_UTL,
    pEV.EV_UTL_UTL_ID,
    pEV.EV_LVL_EV_ID,
    pEV.Metadata_EV_LVL,
    pEV.EV_LVL_ChangedAt,
    pEV.EV_LVL_PLV_Checksum,
    pEV.EV_LVL_PLV_EQ,
    pEV.EV_LVL_PLV_ProfessionalLevel,
    pEV.EV_LVL_Metadata_PLV,
    pEV.EV_LVL_PLV_ID
FROM
    TABLE(attributes.eEV_STA_Event_Status(equivalent)) hSTA, 
    TABLE(nexuses.epEV_Event(equivalent, hSTA.EV_STA_ChangedAt::timestamp_ntz(9))) pEV
WHERE
    (selection IS NULL OR selection LIKE '%STA%')
AND
    hSTA.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pEV.EV_ID = hSTA.EV_STA_EV_ID
UNION
SELECT DISTINCT
    hLVL.EV_LVL_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LVL' AS mnemonic,
    pEV.EV_ID,
    pEV.Metadata_EV,
    pEV.ST_ID_wasHeldAt,
    pEV.PR_ID_wasPlayed,
    pEV.of_ETY_Checksum,
    pEV.of_ETY_EventType,
    pEV.of_ETY_EQ,
    pEV.of_Metadata_ETY,
    pEV.ETY_ID_of,
    pEV.EV_DAT_EV_ID,
    pEV.Metadata_EV_DAT,
    pEV.EV_DAT_Event_Date,
    pEV.EV_AUD_EV_ID,
    pEV.Metadata_EV_AUD,
    pEV.EV_AUD_EQ,
    pEV.EV_AUD_Event_Audience,
    pEV.EV_REV_EV_ID,
    pEV.Metadata_EV_REV,
    pEV.EV_REV_EQ,
    pEV.EV_REV_Event_Revenue,
    pEV.EV_STA_EV_ID,
    pEV.Metadata_EV_STA,
    pEV.EV_STA_ChangedAt,
    pEV.EV_STA_EQ,
    pEV.EV_STA_Event_Status,
    pEV.EV_UTL_EV_ID,
    pEV.Metadata_EV_UTL,
    pEV.EV_UTL_UTL_Utilization,
    pEV.EV_UTL_Metadata_UTL,
    pEV.EV_UTL_UTL_ID,
    pEV.EV_LVL_EV_ID,
    pEV.Metadata_EV_LVL,
    pEV.EV_LVL_ChangedAt,
    pEV.EV_LVL_PLV_Checksum,
    pEV.EV_LVL_PLV_EQ,
    pEV.EV_LVL_PLV_ProfessionalLevel,
    pEV.EV_LVL_Metadata_PLV,
    pEV.EV_LVL_PLV_ID
FROM
    attributes.EV_LVL_Event_Level hLVL,
    TABLE(nexuses.epEV_Event(equivalent, hLVL.EV_LVL_ChangedAt::timestamp_ntz(9))) pEV
WHERE
    (selection IS NULL OR selection LIKE '%LVL%')
AND
    hLVL.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pEV.EV_ID = hLVL.EV_LVL_EV_ID
$$
;
