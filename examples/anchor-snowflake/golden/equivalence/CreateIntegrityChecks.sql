-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--   restatement                                   in an attribute or a tie that may not store them, a value
--                                                 that is the same as the one before it in changing time
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a RELY foreign key cannot make the optimizer drop the join.
--
-- PAT_ParentalType_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PAT_ParentalType_ID (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_ParentalType_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_ID', PAT_ID),
    COUNT(*)
FROM
    public.PAT_ParentalType_ID
GROUP BY
    PAT_ID
HAVING
    COUNT(*) > 1;
-- PAT_ParentalType_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PAT_ParentalType_EQ (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_ParentalType_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_EQ', PAT_EQ, 'PAT_ID', PAT_ID),
    COUNT(*)
FROM
    public.PAT_ParentalType_EQ
GROUP BY
    PAT_EQ,
    PAT_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_ParentalType_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PAT_EQ', PAT_EQ, 'PAT_ParentalType', PAT_ParentalType),
    COUNT(*)
FROM
    public.PAT_ParentalType_EQ
GROUP BY
    PAT_EQ,
    PAT_ParentalType
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_ParentalType_EQ',
    'no row in PAT_ParentalType_ID for PAT_ID',
    OBJECT_CONSTRUCT('PAT_ID', c.PAT_ID),
    COUNT(*)
FROM
    public.PAT_ParentalType_EQ c
LEFT JOIN
    public.PAT_ParentalType_ID p
ON
    p.PAT_ID = c.PAT_ID
WHERE
    p.PAT_ID IS NULL
GROUP BY
    c.PAT_ID;
-- GEN_Gender_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_GEN_Gender_ID (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Gender_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_ID', GEN_ID),
    COUNT(*)
FROM
    public.GEN_Gender_ID
GROUP BY
    GEN_ID
HAVING
    COUNT(*) > 1;
-- GEN_Gender_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_GEN_Gender_EQ (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Gender_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_EQ', GEN_EQ, 'GEN_ID', GEN_ID),
    COUNT(*)
FROM
    public.GEN_Gender_EQ
GROUP BY
    GEN_EQ,
    GEN_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('GEN_EQ', GEN_EQ, 'GEN_Gender', GEN_Gender),
    COUNT(*)
FROM
    public.GEN_Gender_EQ
GROUP BY
    GEN_EQ,
    GEN_Gender
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender_EQ',
    'no row in GEN_Gender_ID for GEN_ID',
    OBJECT_CONSTRUCT('GEN_ID', c.GEN_ID),
    COUNT(*)
FROM
    public.GEN_Gender_EQ c
LEFT JOIN
    public.GEN_Gender_ID p
ON
    p.GEN_ID = c.GEN_ID
WHERE
    p.GEN_ID IS NULL
GROUP BY
    c.GEN_ID;
-- PLV_ProfessionalLevel integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PLV_ProfessionalLevel (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PLV_ProfessionalLevel',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PLV_ID', PLV_ID),
    COUNT(*)
FROM
    public.PLV_ProfessionalLevel
GROUP BY
    PLV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_ProfessionalLevel',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PLV_Checksum', PLV_Checksum),
    COUNT(*)
FROM
    public.PLV_ProfessionalLevel
GROUP BY
    PLV_Checksum
HAVING
    COUNT(*) > 1;
-- UTL_Utilization integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_UTL_Utilization (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'UTL_Utilization',
    'duplicate primary key',
    OBJECT_CONSTRUCT('UTL_ID', UTL_ID),
    COUNT(*)
FROM
    public.UTL_Utilization
GROUP BY
    UTL_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utilization',
    'duplicate unique key',
    OBJECT_CONSTRUCT('UTL_Utilization', UTL_Utilization),
    COUNT(*)
FROM
    public.UTL_Utilization
GROUP BY
    UTL_Utilization
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ONG_Ongoing_ID (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Ongoing_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_ID', ONG_ID),
    COUNT(*)
FROM
    public.ONG_Ongoing_ID
GROUP BY
    ONG_ID
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ONG_Ongoing_EQ (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Ongoing_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_EQ', ONG_EQ, 'ONG_ID', ONG_ID),
    COUNT(*)
FROM
    public.ONG_Ongoing_EQ
GROUP BY
    ONG_EQ,
    ONG_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Ongoing_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ONG_EQ', ONG_EQ, 'ONG_Ongoing', ONG_Ongoing),
    COUNT(*)
FROM
    public.ONG_Ongoing_EQ
GROUP BY
    ONG_EQ,
    ONG_Ongoing
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Ongoing_EQ',
    'no row in ONG_Ongoing_ID for ONG_ID',
    OBJECT_CONSTRUCT('ONG_ID', c.ONG_ID),
    COUNT(*)
FROM
    public.ONG_Ongoing_EQ c
LEFT JOIN
    public.ONG_Ongoing_ID p
ON
    p.ONG_ID = c.ONG_ID
WHERE
    p.ONG_ID IS NULL
GROUP BY
    c.ONG_ID;
-- RAT_Rating_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_RAT_Rating_ID (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Rating_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_ID', RAT_ID),
    COUNT(*)
FROM
    public.RAT_Rating_ID
GROUP BY
    RAT_ID
HAVING
    COUNT(*) > 1;
-- RAT_Rating_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_RAT_Rating_EQ (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Rating_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_EQ', RAT_EQ, 'RAT_ID', RAT_ID),
    COUNT(*)
FROM
    public.RAT_Rating_EQ
GROUP BY
    RAT_EQ,
    RAT_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('RAT_EQ', RAT_EQ, 'RAT_Rating', RAT_Rating),
    COUNT(*)
FROM
    public.RAT_Rating_EQ
GROUP BY
    RAT_EQ,
    RAT_Rating
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating_EQ',
    'no row in RAT_Rating_ID for RAT_ID',
    OBJECT_CONSTRUCT('RAT_ID', c.RAT_ID),
    COUNT(*)
FROM
    public.RAT_Rating_EQ c
LEFT JOIN
    public.RAT_Rating_ID p
ON
    p.RAT_ID = c.RAT_ID
WHERE
    p.RAT_ID IS NULL
GROUP BY
    c.RAT_ID;
-- ETY_EventType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ETY_EventType (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ETY_EventType',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ETY_ID', ETY_ID),
    COUNT(*)
FROM
    public.ETY_EventType
GROUP BY
    ETY_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_EventType',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ETY_EventType', ETY_EventType),
    COUNT(*)
FROM
    public.ETY_EventType
GROUP BY
    ETY_EventType
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PN_Person (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PN_ID', PN_ID),
    COUNT(*)
FROM
    public.PN_Person
GROUP BY
    PN_ID
HAVING
    COUNT(*) > 1;
-- ST_Stage integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_Stage (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_Stage',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_ID', ST_ID),
    COUNT(*)
FROM
    public.ST_Stage
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- AC_Actor integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_Actor (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_Actor',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_ID', AC_ID),
    COUNT(*)
FROM
    public.AC_Actor
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- PR_Program integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_Program (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_Program',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_ID', PR_ID),
    COUNT(*)
FROM
    public.PR_Program
GROUP BY
    PR_ID
HAVING
    COUNT(*) > 1;
-- EV_Event integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_Event (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_Event',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_ID', EV_ID),
    COUNT(*)
FROM
    public.EV_Event
GROUP BY
    EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Event',
    'no row in ST_Stage for ST_ID_wasHeldAt',
    OBJECT_CONSTRUCT('ST_ID_wasHeldAt', c.ST_ID_wasHeldAt),
    COUNT(*)
FROM
    public.EV_Event c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_ID_wasHeldAt
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_ID_wasHeldAt
UNION ALL
SELECT
    'EV_Event',
    'no row in PR_Program for PR_ID_wasPlayed',
    OBJECT_CONSTRUCT('PR_ID_wasPlayed', c.PR_ID_wasPlayed),
    COUNT(*)
FROM
    public.EV_Event c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_wasPlayed
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_wasPlayed
UNION ALL
SELECT
    'EV_Event',
    'no row in ETY_EventType for ETY_ID_of',
    OBJECT_CONSTRUCT('ETY_ID_of', c.ETY_ID_of),
    COUNT(*)
FROM
    public.EV_Event c
LEFT JOIN
    public.ETY_EventType p
ON
    p.ETY_ID = c.ETY_ID_of
WHERE
    p.ETY_ID IS NULL
GROUP BY
    c.ETY_ID_of
;
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_DAT_Event_Date (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Event_Date',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_EQ', EV_DAT_EQ,
        'EV_DAT_EV_ID', EV_DAT_EV_ID
    ),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date
GROUP BY
    EV_DAT_EQ,
    EV_DAT_EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date',
    'no row in EV_Event for EV_DAT_EV_ID',
    OBJECT_CONSTRUCT('EV_DAT_EV_ID', c.EV_DAT_EV_ID),
    COUNT(*)
FROM
    public.EV_DAT_Event_Date c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_DAT_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_DAT_EV_ID
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_AUD_Event_Audience (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Event_Audience',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_EV_ID', EV_AUD_EV_ID
    ),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience
GROUP BY
    EV_AUD_EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience',
    'no row in EV_Event for EV_AUD_EV_ID',
    OBJECT_CONSTRUCT('EV_AUD_EV_ID', c.EV_AUD_EV_ID),
    COUNT(*)
FROM
    public.EV_AUD_Event_Audience c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_AUD_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_AUD_EV_ID
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_REV_Event_Revenue (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Event_Revenue',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_EQ', EV_REV_EQ,
        'EV_REV_EV_ID', EV_REV_EV_ID
    ),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue
GROUP BY
    EV_REV_EQ,
    EV_REV_EV_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue',
    'no row in EV_Event for EV_REV_EV_ID',
    OBJECT_CONSTRUCT('EV_REV_EV_ID', c.EV_REV_EV_ID),
    COUNT(*)
FROM
    public.EV_REV_Event_Revenue c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_REV_EV_ID
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_REV_EV_ID
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_NAM_Stage_Name (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Stage_Name',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_EQ', ST_NAM_EQ,
        'ST_NAM_ST_ID', ST_NAM_ST_ID,
        'ST_NAM_ChangedAt', ST_NAM_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name
GROUP BY
    ST_NAM_EQ,
    ST_NAM_ST_ID,
    ST_NAM_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name',
    'no row in ST_Stage for ST_NAM_ST_ID',
    OBJECT_CONSTRUCT('ST_NAM_ST_ID', c.ST_NAM_ST_ID),
    COUNT(*)
FROM
    public.ST_NAM_Stage_Name c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_NAM_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_NAM_ST_ID
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_LOC_Stage_Location (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Stage_Location',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_EQ', ST_LOC_EQ,
        'ST_LOC_ST_ID', ST_LOC_ST_ID
    ),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location
GROUP BY
    ST_LOC_EQ,
    ST_LOC_ST_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location',
    'no row in ST_Stage for ST_LOC_ST_ID',
    OBJECT_CONSTRUCT('ST_LOC_ST_ID', c.ST_LOC_ST_ID),
    COUNT(*)
FROM
    public.ST_LOC_Stage_Location c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_LOC_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_LOC_ST_ID
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_AVG_Stage_Average (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Stage_Average',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', ST_AVG_ST_ID,
        'ST_AVG_ChangedAt', ST_AVG_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average
GROUP BY
    ST_AVG_ST_ID,
    ST_AVG_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in ST_Stage for ST_AVG_ST_ID',
    OBJECT_CONSTRUCT('ST_AVG_ST_ID', c.ST_AVG_ST_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_AVG_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_AVG_ST_ID
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    OBJECT_CONSTRUCT('ST_AVG_UTL_ID', c.ST_AVG_UTL_ID),
    COUNT(*)
FROM
    public.ST_AVG_Stage_Average c
LEFT JOIN
    public.UTL_Utilization p
ON
    p.UTL_ID = c.ST_AVG_UTL_ID
WHERE
    p.UTL_ID IS NULL
GROUP BY
    c.ST_AVG_UTL_ID
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'restatement',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', ST_AVG_ST_ID,
        'ST_AVG_ChangedAt', ST_AVG_ChangedAt
    ),
    1
FROM (
    SELECT
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID AS compared,
        LAG(ST_AVG_UTL_ID) OVER (
            PARTITION BY
                ST_AVG_ST_ID
            ORDER BY
                ST_AVG_ChangedAt
        ) AS previous
    FROM
        public.ST_AVG_Stage_Average
)
WHERE
    compared = previous
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_MIN_Stage_Minimum (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Stage_Minimum',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ST_ID', ST_MIN_ST_ID
    ),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum
GROUP BY
    ST_MIN_ST_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in ST_Stage for ST_MIN_ST_ID',
    OBJECT_CONSTRUCT('ST_MIN_ST_ID', c.ST_MIN_ST_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_MIN_ST_ID
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_MIN_ST_ID
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    OBJECT_CONSTRUCT('ST_MIN_UTL_ID', c.ST_MIN_UTL_ID),
    COUNT(*)
FROM
    public.ST_MIN_Stage_Minimum c
LEFT JOIN
    public.UTL_Utilization p
ON
    p.UTL_ID = c.ST_MIN_UTL_ID
WHERE
    p.UTL_ID IS NULL
GROUP BY
    c.ST_MIN_UTL_ID
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_NAM_Actor_Name (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Actor_Name',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_EQ', AC_NAM_EQ,
        'AC_NAM_AC_ID', AC_NAM_AC_ID,
        'AC_NAM_ChangedAt', AC_NAM_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name
GROUP BY
    AC_NAM_EQ,
    AC_NAM_AC_ID,
    AC_NAM_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'no row in AC_Actor for AC_NAM_AC_ID',
    OBJECT_CONSTRUCT('AC_NAM_AC_ID', c.AC_NAM_AC_ID),
    COUNT(*)
FROM
    public.AC_NAM_Actor_Name c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_NAM_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_NAM_AC_ID
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'restatement',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', AC_NAM_AC_ID,
        'AC_NAM_EQ', AC_NAM_EQ,
        'AC_NAM_ChangedAt', AC_NAM_ChangedAt
    ),
    1
FROM (
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_EQ,
        AC_NAM_ChangedAt,
        AC_NAM_Checksum AS compared,
        LAG(AC_NAM_Checksum) OVER (
            PARTITION BY
                AC_NAM_AC_ID,
                AC_NAM_EQ
            ORDER BY
                AC_NAM_ChangedAt
        ) AS previous
    FROM
        public.AC_NAM_Actor_Name
)
WHERE
    compared = previous
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_GEN_Actor_Gender (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Actor_Gender',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_AC_ID', AC_GEN_AC_ID
    ),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender
GROUP BY
    AC_GEN_AC_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in AC_Actor for AC_GEN_AC_ID',
    OBJECT_CONSTRUCT('AC_GEN_AC_ID', c.AC_GEN_AC_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_GEN_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_GEN_AC_ID
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in GEN_Gender_ID for AC_GEN_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_GEN_ID', c.AC_GEN_GEN_ID),
    COUNT(*)
FROM
    public.AC_GEN_Actor_Gender c
LEFT JOIN
    public.GEN_Gender_ID p
ON
    p.GEN_ID = c.AC_GEN_GEN_ID
WHERE
    p.GEN_ID IS NULL
GROUP BY
    c.AC_GEN_GEN_ID
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_PLV_Actor_ProfessionalLevel (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_AC_ID', AC_PLV_AC_ID,
        'AC_PLV_ChangedAt', AC_PLV_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel
GROUP BY
    AC_PLV_AC_ID,
    AC_PLV_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in AC_Actor for AC_PLV_AC_ID',
    OBJECT_CONSTRUCT('AC_PLV_AC_ID', c.AC_PLV_AC_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_PLV_AC_ID
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_PLV_AC_ID
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_PLV_ID', c.AC_PLV_PLV_ID),
    COUNT(*)
FROM
    public.AC_PLV_Actor_ProfessionalLevel c
LEFT JOIN
    public.PLV_ProfessionalLevel p
ON
    p.PLV_ID = c.AC_PLV_PLV_ID
WHERE
    p.PLV_ID IS NULL
GROUP BY
    c.AC_PLV_PLV_ID
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_NAM_Program_Name (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Program_Name',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_PR_ID', PR_NAM_PR_ID
    ),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name
GROUP BY
    PR_NAM_PR_ID
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name',
    'no row in PR_Program for PR_NAM_PR_ID',
    OBJECT_CONSTRUCT('PR_NAM_PR_ID', c.PR_NAM_PR_ID),
    COUNT(*)
FROM
    public.PR_NAM_Program_Name c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_NAM_PR_ID
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_NAM_PR_ID
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_LEN_Program_Length (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Program_Length',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_PR_ID', PR_LEN_PR_ID,
        'PR_LEN_ChangedAt', PR_LEN_ChangedAt
    ),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length
GROUP BY
    PR_LEN_PR_ID,
    PR_LEN_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length',
    'no row in PR_Program for PR_LEN_PR_ID',
    OBJECT_CONSTRUCT('PR_LEN_PR_ID', c.PR_LEN_PR_ID),
    COUNT(*)
FROM
    public.PR_LEN_Program_Length c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_LEN_PR_ID
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_LEN_PR_ID
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_partner_AC_with_ONG_currently (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', AC_ID_partner,
        'AC_ID_with', AC_ID_with,
        'ONG_ID_currently', ONG_ID_currently,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently
GROUP BY
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', AC_ID_partner,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently
GROUP BY
    AC_ID_partner,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', AC_ID_with,
        'AC_partner_AC_with_ONG_currently_ChangedAt', AC_partner_AC_with_ONG_currently_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently
GROUP BY
    AC_ID_with,
    AC_partner_AC_with_ONG_currently_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c.AC_ID_partner),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_partner
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_partner
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c.AC_ID_with),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_with
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_with
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Ongoing_ID for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c.ONG_ID_currently),
    COUNT(*)
FROM
    public.AC_partner_AC_with_ONG_currently c
LEFT JOIN
    public.ONG_Ongoing_ID p
ON
    p.ONG_ID = c.ONG_ID_currently
WHERE
    p.ONG_ID IS NULL
GROUP BY
    c.ONG_ID_currently
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_subset_PN_of (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', AC_ID_subset,
        'PN_ID_of', PN_ID_of
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of
GROUP BY
    AC_ID_subset,
    PN_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', AC_ID_subset
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of
GROUP BY
    AC_ID_subset
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', PN_ID_of
    ),
    COUNT(*)
FROM
    public.AC_subset_PN_of
GROUP BY
    PN_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in AC_Actor for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c.AC_ID_subset),
    COUNT(*)
FROM
    public.AC_subset_PN_of c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_subset
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_subset
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c.PN_ID_of),
    COUNT(*)
FROM
    public.AC_subset_PN_of c
LEFT JOIN
    public.PN_Person p
ON
    p.PN_ID = c.PN_ID_of
WHERE
    p.PN_ID IS NULL
GROUP BY
    c.PN_ID_of
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_EV_in_AC_wasCast (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_wasCast',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', EV_ID_in,
        'AC_ID_wasCast', AC_ID_wasCast
    ),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast
GROUP BY
    EV_ID_in,
    AC_ID_wasCast
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast',
    'no row in EV_Event for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c.EV_ID_in),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_ID_in
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_ID_in
UNION ALL
SELECT
    'EV_in_AC_wasCast',
    'no row in AC_Actor for AC_ID_wasCast',
    OBJECT_CONSTRUCT('AC_ID_wasCast', c.AC_ID_wasCast),
    COUNT(*)
FROM
    public.EV_in_AC_wasCast c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_wasCast
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_wasCast
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_part_PR_in_RAT_got (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_part_PR_in_RAT_got',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_part', AC_ID_part,
        'PR_ID_in', PR_ID_in,
        'AC_part_PR_in_RAT_got_ChangedAt', AC_part_PR_in_RAT_got_ChangedAt
    ),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got
GROUP BY
    AC_ID_part,
    PR_ID_in,
    AC_part_PR_in_RAT_got_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in AC_Actor for AC_ID_part',
    OBJECT_CONSTRUCT('AC_ID_part', c.AC_ID_part),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_part
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_part
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in PR_Program for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c.PR_ID_in),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_in
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_in
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in RAT_Rating_ID for RAT_ID_got',
    OBJECT_CONSTRUCT('RAT_ID_got', c.RAT_ID_got),
    COUNT(*)
FROM
    public.AC_part_PR_in_RAT_got c
LEFT JOIN
    public.RAT_Rating_ID p
ON
    p.RAT_ID = c.RAT_ID_got
WHERE
    p.RAT_ID IS NULL
GROUP BY
    c.RAT_ID_got
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_ST_at_PR_isPlaying (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_isPlaying',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', ST_ID_at,
        'PR_ID_isPlaying', PR_ID_isPlaying,
        'ST_at_PR_isPlaying_ChangedAt', ST_at_PR_isPlaying_ChangedAt
    ),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying
GROUP BY
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying',
    'no row in ST_Stage for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c.ST_ID_at),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_ID_at
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_ID_at
UNION ALL
SELECT
    'ST_at_PR_isPlaying',
    'no row in PR_Program for PR_ID_isPlaying',
    OBJECT_CONSTRUCT('PR_ID_isPlaying', c.PR_ID_isPlaying),
    COUNT(*)
FROM
    public.ST_at_PR_isPlaying c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_isPlaying
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_isPlaying
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_AC_parent_AC_child_PAT_having (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_parent_AC_child_PAT_having',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_parent', AC_ID_parent,
        'AC_ID_child', AC_ID_child,
        'PAT_ID_having', PAT_ID_having
    ),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having
GROUP BY
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_parent',
    OBJECT_CONSTRUCT('AC_ID_parent', c.AC_ID_parent),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_parent
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_parent
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_child',
    OBJECT_CONSTRUCT('AC_ID_child', c.AC_ID_child),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having c
LEFT JOIN
    public.AC_Actor p
ON
    p.AC_ID = c.AC_ID_child
WHERE
    p.AC_ID IS NULL
GROUP BY
    c.AC_ID_child
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in PAT_ParentalType_ID for PAT_ID_having',
    OBJECT_CONSTRUCT('PAT_ID_having', c.PAT_ID_having),
    COUNT(*)
FROM
    public.AC_parent_AC_child_PAT_having c
LEFT JOIN
    public.PAT_ParentalType_ID p
ON
    p.PAT_ID = c.PAT_ID_having
WHERE
    p.PAT_ID IS NULL
GROUP BY
    c.PAT_ID_having
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.ic_PR_content_ST_location_EV_of (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_content_ST_location_EV_of',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_ID_of', EV_ID_of
    ),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of
GROUP BY
    EV_ID_of
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in PR_Program for PR_ID_content',
    OBJECT_CONSTRUCT('PR_ID_content', c.PR_ID_content),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of c
LEFT JOIN
    public.PR_Program p
ON
    p.PR_ID = c.PR_ID_content
WHERE
    p.PR_ID IS NULL
GROUP BY
    c.PR_ID_content
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in ST_Stage for ST_ID_location',
    OBJECT_CONSTRUCT('ST_ID_location', c.ST_ID_location),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of c
LEFT JOIN
    public.ST_Stage p
ON
    p.ST_ID = c.ST_ID_location
WHERE
    p.ST_ID IS NULL
GROUP BY
    c.ST_ID_location
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in EV_Event for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c.EV_ID_of),
    COUNT(*)
FROM
    public.PR_content_ST_location_EV_of c
LEFT JOIN
    public.EV_Event p
ON
    p.EV_ID = c.EV_ID_of
WHERE
    p.EV_ID IS NULL
GROUP BY
    c.EV_ID_of
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.IntegrityViolations (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM public.ic_PAT_ParentalType_ID
UNION ALL SELECT * FROM public.ic_PAT_ParentalType_EQ
UNION ALL SELECT * FROM public.ic_GEN_Gender_ID
UNION ALL SELECT * FROM public.ic_GEN_Gender_EQ
UNION ALL SELECT * FROM public.ic_PLV_ProfessionalLevel
UNION ALL SELECT * FROM public.ic_UTL_Utilization
UNION ALL SELECT * FROM public.ic_ONG_Ongoing_ID
UNION ALL SELECT * FROM public.ic_ONG_Ongoing_EQ
UNION ALL SELECT * FROM public.ic_RAT_Rating_ID
UNION ALL SELECT * FROM public.ic_RAT_Rating_EQ
UNION ALL SELECT * FROM public.ic_ETY_EventType
UNION ALL SELECT * FROM public.ic_PN_Person
UNION ALL SELECT * FROM public.ic_ST_Stage
UNION ALL SELECT * FROM public.ic_AC_Actor
UNION ALL SELECT * FROM public.ic_PR_Program
UNION ALL SELECT * FROM public.ic_EV_Event
UNION ALL SELECT * FROM public.ic_EV_DAT_Event_Date
UNION ALL SELECT * FROM public.ic_EV_AUD_Event_Audience
UNION ALL SELECT * FROM public.ic_EV_REV_Event_Revenue
UNION ALL SELECT * FROM public.ic_ST_NAM_Stage_Name
UNION ALL SELECT * FROM public.ic_ST_LOC_Stage_Location
UNION ALL SELECT * FROM public.ic_ST_AVG_Stage_Average
UNION ALL SELECT * FROM public.ic_ST_MIN_Stage_Minimum
UNION ALL SELECT * FROM public.ic_AC_NAM_Actor_Name
UNION ALL SELECT * FROM public.ic_AC_GEN_Actor_Gender
UNION ALL SELECT * FROM public.ic_AC_PLV_Actor_ProfessionalLevel
UNION ALL SELECT * FROM public.ic_PR_NAM_Program_Name
UNION ALL SELECT * FROM public.ic_PR_LEN_Program_Length
UNION ALL SELECT * FROM public.ic_AC_partner_AC_with_ONG_currently
UNION ALL SELECT * FROM public.ic_AC_subset_PN_of
UNION ALL SELECT * FROM public.ic_EV_in_AC_wasCast
UNION ALL SELECT * FROM public.ic_AC_part_PR_in_RAT_got
UNION ALL SELECT * FROM public.ic_ST_at_PR_isPlaying
UNION ALL SELECT * FROM public.ic_AC_parent_AC_child_PAT_having
UNION ALL SELECT * FROM public.ic_PR_content_ST_location_EV_of
;
