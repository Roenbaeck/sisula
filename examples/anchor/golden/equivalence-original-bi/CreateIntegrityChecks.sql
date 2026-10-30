-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--
-- In a bitemporal model an attribute and a tie are a posit table and an annex table, each with a view
-- (ic_<posit table>, ic_<annex table>), and a third view, ic_<attribute or tie>, for what the two say together:
--
--   temporal duplicate                            the unique key of the assembled view in SQL Server: two annex rows with the
--                                                 same entity (the identifiers of a tie, or all its roles), changing time,
--                                                 positing time and reliability
--   more than one posit asserted at a time        for the same entity (the identifiers of a tie) and changing time, more than
--                                                 one posit asserted at a positing time: a correction retracts what it corrects
--                                                 at its own positing time
--   restatement                                   in an attribute or a tie that may not store them, a value that is asserted at
--                                                 the changing time after the one that has it already
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
-- It also has the checks of the natural keys, ic_key_<anchor or nexus>_<route>, which are made with the keys: a key
-- that more than one identity has (duplicate natural key), and an identity with more than one key (more than one
-- natural key).
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a RELY foreign key cannot make the optimizer drop the join.
--
-- PAT_ParentalType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PAT_ParentalType" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_ParentalType',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_ID', "PAT_ID"),
    COUNT(*)
FROM
    knots."PAT_ParentalType"
GROUP BY
    "PAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_ParentalType',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PAT_ParentalType', "PAT_ParentalType"),
    COUNT(*)
FROM
    knots."PAT_ParentalType"
GROUP BY
    "PAT_ParentalType"
HAVING
    COUNT(*) > 1;
-- GEN_Gender integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_GEN_Gender" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Gender',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_ID', "GEN_ID"),
    COUNT(*)
FROM
    knots."GEN_Gender"
GROUP BY
    "GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender',
    'duplicate unique key',
    OBJECT_CONSTRUCT('GEN_Checksum', "GEN_Checksum"),
    COUNT(*)
FROM
    knots."GEN_Gender"
GROUP BY
    "GEN_Checksum"
HAVING
    COUNT(*) > 1;
-- PLV_ProfessionalLevel integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PLV_ProfessionalLevel" (
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
    OBJECT_CONSTRUCT('PLV_ID', "PLV_ID"),
    COUNT(*)
FROM
    knots."PLV_ProfessionalLevel"
GROUP BY
    "PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_ProfessionalLevel',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PLV_Checksum', "PLV_Checksum"),
    COUNT(*)
FROM
    knots."PLV_ProfessionalLevel"
GROUP BY
    "PLV_Checksum"
HAVING
    COUNT(*) > 1;
-- UTL_Utilization integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_UTL_Utilization" (
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
    OBJECT_CONSTRUCT('UTL_ID', "UTL_ID"),
    COUNT(*)
FROM
    knots."UTL_Utilization"
GROUP BY
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utilization',
    'duplicate unique key',
    OBJECT_CONSTRUCT('UTL_Utilization', "UTL_Utilization"),
    COUNT(*)
FROM
    knots."UTL_Utilization"
GROUP BY
    "UTL_Utilization"
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ONG_Ongoing" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Ongoing',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_ID', "ONG_ID"),
    COUNT(*)
FROM
    knots."ONG_Ongoing"
GROUP BY
    "ONG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Ongoing',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ONG_Ongoing', "ONG_Ongoing"),
    COUNT(*)
FROM
    knots."ONG_Ongoing"
GROUP BY
    "ONG_Ongoing"
HAVING
    COUNT(*) > 1;
-- RAT_Rating integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_RAT_Rating" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Rating',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_ID', "RAT_ID"),
    COUNT(*)
FROM
    knots."RAT_Rating"
GROUP BY
    "RAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating',
    'duplicate unique key',
    OBJECT_CONSTRUCT('RAT_Checksum', "RAT_Checksum"),
    COUNT(*)
FROM
    knots."RAT_Rating"
GROUP BY
    "RAT_Checksum"
HAVING
    COUNT(*) > 1;
-- ETY_EventType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ETY_EventType" (
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
    OBJECT_CONSTRUCT('ETY_ID', "ETY_ID"),
    COUNT(*)
FROM
    knots."ETY_EventType"
GROUP BY
    "ETY_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_EventType',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ETY_Checksum', "ETY_Checksum"),
    COUNT(*)
FROM
    knots."ETY_EventType"
GROUP BY
    "ETY_Checksum"
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PN_Person" (
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
    OBJECT_CONSTRUCT('PN_ID', "PN_ID"),
    COUNT(*)
FROM
    anchors."PN_Person"
GROUP BY
    "PN_ID"
HAVING
    COUNT(*) > 1;
-- ST_Stage integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_ST_Stage" (
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
    OBJECT_CONSTRUCT('ST_ID', "ST_ID"),
    COUNT(*)
FROM
    anchors."ST_Stage"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- AC_Actor integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_AC_Actor" (
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
    OBJECT_CONSTRUCT('AC_ID', "AC_ID"),
    COUNT(*)
FROM
    anchors."AC_Actor"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- PR_Program integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PR_Program" (
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
    OBJECT_CONSTRUCT('PR_ID', "PR_ID"),
    COUNT(*)
FROM
    anchors."PR_Program"
GROUP BY
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- EV_Event integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."ic_EV_Event" (
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
    OBJECT_CONSTRUCT('EV_ID', "EV_ID"),
    COUNT(*)
FROM
    nexuses."EV_Event"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Event',
    'no row in ST_Stage for ST_ID_wasHeldAt',
    OBJECT_CONSTRUCT('ST_ID_wasHeldAt', c."ST_ID_wasHeldAt"),
    COUNT(*)
FROM
    nexuses."EV_Event" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID_wasHeldAt"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_wasHeldAt"
UNION ALL
SELECT
    'EV_Event',
    'no row in PR_Program for PR_ID_wasPlayed',
    OBJECT_CONSTRUCT('PR_ID_wasPlayed', c."PR_ID_wasPlayed"),
    COUNT(*)
FROM
    nexuses."EV_Event" c
LEFT JOIN
    anchors."PR_Program" p
ON
    p."PR_ID" = c."PR_ID_wasPlayed"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_wasPlayed"
UNION ALL
SELECT
    'EV_Event',
    'no row in ETY_EventType for ETY_ID_of',
    OBJECT_CONSTRUCT('ETY_ID_of', c."ETY_ID_of"),
    COUNT(*)
FROM
    nexuses."EV_Event" c
LEFT JOIN
    knots."ETY_EventType" p
ON
    p."ETY_ID" = c."ETY_ID_of"
WHERE
    p."ETY_ID" IS NULL
GROUP BY
    c."ETY_ID_of"
;
-- EV_DAT_Event_Date_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Event_Date_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_DAT_ID', "EV_DAT_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Event_Date_Posit"
GROUP BY
    "EV_DAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_DAT_Event_Date', "EV_DAT_Event_Date"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Event_Date_Posit"
GROUP BY
    "EV_ID",
    "EV_DAT_Event_Date"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'no row in EV_Event for EV_ID',
    OBJECT_CONSTRUCT('EV_ID', c."EV_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Event_Date_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID"
;
-- EV_DAT_Event_Date_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Event_Date_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Event_Date_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_ID', "EV_DAT_ID",
        'EV_DAT_PositedAt', "EV_DAT_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Event_Date_Annex"
GROUP BY
    "EV_DAT_ID",
    "EV_DAT_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Annex',
    'no row in EV_DAT_Event_Date_Posit for EV_DAT_ID',
    OBJECT_CONSTRUCT('EV_DAT_ID', c."EV_DAT_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Event_Date_Annex" c
LEFT JOIN
    attributes."EV_DAT_Event_Date_Posit" p
ON
    p."EV_DAT_ID" = c."EV_DAT_ID"
WHERE
    p."EV_DAT_ID" IS NULL
GROUP BY
    c."EV_DAT_ID"
;
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Event_Date" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_DAT_Event_Date',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_DAT_PositedAt', "EV_DAT_PositedAt",
        'EV_DAT_Reliability', "EV_DAT_Reliability"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Event_Date"
GROUP BY
    "EV_ID",
    "EV_DAT_PositedAt",
    "EV_DAT_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_DAT_Event_Date',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_DAT_PositedAt', "EV_DAT_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID",
        "EV_DAT_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID"
            ORDER BY
                "EV_DAT_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID",
            "EV_DAT_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_DAT_ID" ORDER BY "EV_DAT_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_DAT_ID",
                "EV_ID",
                "EV_DAT_PositedAt",
                IFF("EV_DAT_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."EV_DAT_Event_Date"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID",
    "EV_DAT_PositedAt",
    asserted
;
-- EV_AUD_Event_Audience_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Event_Audience_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_AUD_ID', "EV_AUD_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Event_Audience_Posit"
GROUP BY
    "EV_AUD_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_AUD_Event_Audience', "EV_AUD_Event_Audience"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Event_Audience_Posit"
GROUP BY
    "EV_ID",
    "EV_AUD_Event_Audience"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'no row in EV_Event for EV_ID',
    OBJECT_CONSTRUCT('EV_ID', c."EV_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Event_Audience_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID"
;
-- EV_AUD_Event_Audience_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Event_Audience_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Event_Audience_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_ID', "EV_AUD_ID",
        'EV_AUD_PositedAt', "EV_AUD_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Event_Audience_Annex"
GROUP BY
    "EV_AUD_ID",
    "EV_AUD_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Annex',
    'no row in EV_AUD_Event_Audience_Posit for EV_AUD_ID',
    OBJECT_CONSTRUCT('EV_AUD_ID', c."EV_AUD_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Event_Audience_Annex" c
LEFT JOIN
    attributes."EV_AUD_Event_Audience_Posit" p
ON
    p."EV_AUD_ID" = c."EV_AUD_ID"
WHERE
    p."EV_AUD_ID" IS NULL
GROUP BY
    c."EV_AUD_ID"
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Event_Audience" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_AUD_Event_Audience',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_AUD_PositedAt', "EV_AUD_PositedAt",
        'EV_AUD_Reliability', "EV_AUD_Reliability"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Event_Audience"
GROUP BY
    "EV_ID",
    "EV_AUD_PositedAt",
    "EV_AUD_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_AUD_Event_Audience',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_AUD_PositedAt', "EV_AUD_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID",
        "EV_AUD_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID"
            ORDER BY
                "EV_AUD_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID",
            "EV_AUD_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_AUD_ID" ORDER BY "EV_AUD_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_AUD_ID",
                "EV_ID",
                "EV_AUD_PositedAt",
                IFF("EV_AUD_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."EV_AUD_Event_Audience"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID",
    "EV_AUD_PositedAt",
    asserted
;
-- EV_REV_Event_Revenue_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Event_Revenue_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_REV_ID', "EV_REV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Event_Revenue_Posit"
GROUP BY
    "EV_REV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_REV_Event_Revenue', "EV_REV_Event_Revenue"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Event_Revenue_Posit"
GROUP BY
    "EV_ID",
    "EV_REV_Event_Revenue"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'no row in EV_Event for EV_ID',
    OBJECT_CONSTRUCT('EV_ID', c."EV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Event_Revenue_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID"
;
-- EV_REV_Event_Revenue_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Event_Revenue_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Event_Revenue_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_ID', "EV_REV_ID",
        'EV_REV_PositedAt', "EV_REV_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Event_Revenue_Annex"
GROUP BY
    "EV_REV_ID",
    "EV_REV_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Annex',
    'no row in EV_REV_Event_Revenue_Posit for EV_REV_ID',
    OBJECT_CONSTRUCT('EV_REV_ID', c."EV_REV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Event_Revenue_Annex" c
LEFT JOIN
    attributes."EV_REV_Event_Revenue_Posit" p
ON
    p."EV_REV_ID" = c."EV_REV_ID"
WHERE
    p."EV_REV_ID" IS NULL
GROUP BY
    c."EV_REV_ID"
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Event_Revenue" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_REV_Event_Revenue',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_REV_PositedAt', "EV_REV_PositedAt",
        'EV_REV_Reliability', "EV_REV_Reliability"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Event_Revenue"
GROUP BY
    "EV_ID",
    "EV_REV_PositedAt",
    "EV_REV_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_REV_Event_Revenue',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_REV_PositedAt', "EV_REV_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID",
        "EV_REV_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID"
            ORDER BY
                "EV_REV_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID",
            "EV_REV_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_REV_ID" ORDER BY "EV_REV_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_REV_ID",
                "EV_ID",
                "EV_REV_PositedAt",
                IFF("EV_REV_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."EV_REV_Event_Revenue"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID",
    "EV_REV_PositedAt",
    asserted
;
-- EV_STA_Event_Status_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Event_Status_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Event_Status_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_STA_ID', "EV_STA_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Event_Status_Posit"
GROUP BY
    "EV_STA_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Event_Status_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_STA_ChangedAt', "EV_STA_ChangedAt",
        'EV_STA_Event_Status', "EV_STA_Event_Status"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Event_Status_Posit"
GROUP BY
    "EV_ID",
    "EV_STA_ChangedAt",
    "EV_STA_Event_Status"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Event_Status_Posit',
    'no row in EV_Event for EV_ID',
    OBJECT_CONSTRUCT('EV_ID', c."EV_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Event_Status_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID"
;
-- EV_STA_Event_Status_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Event_Status_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Event_Status_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_STA_ID', "EV_STA_ID",
        'EV_STA_PositedAt', "EV_STA_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Event_Status_Annex"
GROUP BY
    "EV_STA_ID",
    "EV_STA_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Event_Status_Annex',
    'no row in EV_STA_Event_Status_Posit for EV_STA_ID',
    OBJECT_CONSTRUCT('EV_STA_ID', c."EV_STA_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Event_Status_Annex" c
LEFT JOIN
    attributes."EV_STA_Event_Status_Posit" p
ON
    p."EV_STA_ID" = c."EV_STA_ID"
WHERE
    p."EV_STA_ID" IS NULL
GROUP BY
    c."EV_STA_ID"
;
-- EV_STA_Event_Status integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Event_Status" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_STA_Event_Status',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_STA_ChangedAt', "EV_STA_ChangedAt",
        'EV_STA_PositedAt', "EV_STA_PositedAt",
        'EV_STA_Reliability', "EV_STA_Reliability"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Event_Status"
GROUP BY
    "EV_ID",
    "EV_STA_ChangedAt",
    "EV_STA_PositedAt",
    "EV_STA_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_STA_Event_Status',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_STA_ChangedAt', "EV_STA_ChangedAt",
        'EV_STA_PositedAt', "EV_STA_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID",
                "EV_STA_ChangedAt"
            ORDER BY
                "EV_STA_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID",
            "EV_STA_ChangedAt",
            "EV_STA_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_STA_ID" ORDER BY "EV_STA_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_STA_ID",
                "EV_ID",
                "EV_STA_ChangedAt",
                "EV_STA_PositedAt",
                IFF("EV_STA_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."EV_STA_Event_Status"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID",
    "EV_STA_ChangedAt",
    "EV_STA_PositedAt",
    asserted
;
-- EV_UTL_Event_Utilization_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Event_Utilization_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Event_Utilization_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_UTL_ID', "EV_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization_Posit"
GROUP BY
    "EV_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Event_Utilization_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'UTL_ID', "UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization_Posit"
GROUP BY
    "EV_ID",
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Event_Utilization_Posit',
    'no row in EV_Event for EV_ID',
    OBJECT_CONSTRUCT('EV_ID', c."EV_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID"
UNION ALL
SELECT
    'EV_UTL_Event_Utilization_Posit',
    'no row in UTL_Utilization for UTL_ID',
    OBJECT_CONSTRUCT('UTL_ID', c."UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization_Posit" c
LEFT JOIN
    knots."UTL_Utilization" p
ON
    p."UTL_ID" = c."UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."UTL_ID"
;
-- EV_UTL_Event_Utilization_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Event_Utilization_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Event_Utilization_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_UTL_ID', "EV_UTL_ID",
        'EV_UTL_PositedAt', "EV_UTL_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization_Annex"
GROUP BY
    "EV_UTL_ID",
    "EV_UTL_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Event_Utilization_Annex',
    'no row in EV_UTL_Event_Utilization_Posit for EV_UTL_ID',
    OBJECT_CONSTRUCT('EV_UTL_ID', c."EV_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization_Annex" c
LEFT JOIN
    attributes."EV_UTL_Event_Utilization_Posit" p
ON
    p."EV_UTL_ID" = c."EV_UTL_ID"
WHERE
    p."EV_UTL_ID" IS NULL
GROUP BY
    c."EV_UTL_ID"
;
-- EV_UTL_Event_Utilization integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Event_Utilization" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_UTL_Event_Utilization',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_UTL_PositedAt', "EV_UTL_PositedAt",
        'EV_UTL_Reliability', "EV_UTL_Reliability"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Event_Utilization"
GROUP BY
    "EV_ID",
    "EV_UTL_PositedAt",
    "EV_UTL_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_UTL_Event_Utilization',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_UTL_PositedAt', "EV_UTL_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID",
        "EV_UTL_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID"
            ORDER BY
                "EV_UTL_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID",
            "EV_UTL_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_UTL_ID" ORDER BY "EV_UTL_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_UTL_ID",
                "EV_ID",
                "EV_UTL_PositedAt",
                IFF("EV_UTL_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."EV_UTL_Event_Utilization"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID",
    "EV_UTL_PositedAt",
    asserted
;
-- EV_LVL_Event_Level_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Event_Level_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Event_Level_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_LVL_ID', "EV_LVL_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level_Posit"
GROUP BY
    "EV_LVL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Event_Level_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_LVL_ChangedAt', "EV_LVL_ChangedAt",
        'PLV_ID', "PLV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level_Posit"
GROUP BY
    "EV_ID",
    "EV_LVL_ChangedAt",
    "PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Event_Level_Posit',
    'no row in EV_Event for EV_ID',
    OBJECT_CONSTRUCT('EV_ID', c."EV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID"
UNION ALL
SELECT
    'EV_LVL_Event_Level_Posit',
    'no row in PLV_ProfessionalLevel for PLV_ID',
    OBJECT_CONSTRUCT('PLV_ID', c."PLV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level_Posit" c
LEFT JOIN
    knots."PLV_ProfessionalLevel" p
ON
    p."PLV_ID" = c."PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."PLV_ID"
;
-- EV_LVL_Event_Level_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Event_Level_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Event_Level_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_LVL_ID', "EV_LVL_ID",
        'EV_LVL_PositedAt', "EV_LVL_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level_Annex"
GROUP BY
    "EV_LVL_ID",
    "EV_LVL_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Event_Level_Annex',
    'no row in EV_LVL_Event_Level_Posit for EV_LVL_ID',
    OBJECT_CONSTRUCT('EV_LVL_ID', c."EV_LVL_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level_Annex" c
LEFT JOIN
    attributes."EV_LVL_Event_Level_Posit" p
ON
    p."EV_LVL_ID" = c."EV_LVL_ID"
WHERE
    p."EV_LVL_ID" IS NULL
GROUP BY
    c."EV_LVL_ID"
;
-- EV_LVL_Event_Level integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Event_Level" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_LVL_Event_Level',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_LVL_ChangedAt', "EV_LVL_ChangedAt",
        'EV_LVL_PositedAt', "EV_LVL_PositedAt",
        'EV_LVL_Reliability', "EV_LVL_Reliability"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Event_Level"
GROUP BY
    "EV_ID",
    "EV_LVL_ChangedAt",
    "EV_LVL_PositedAt",
    "EV_LVL_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_LVL_Event_Level',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID",
        'EV_LVL_ChangedAt', "EV_LVL_ChangedAt",
        'EV_LVL_PositedAt', "EV_LVL_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID",
        "EV_LVL_ChangedAt",
        "EV_LVL_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID",
                "EV_LVL_ChangedAt"
            ORDER BY
                "EV_LVL_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID",
            "EV_LVL_ChangedAt",
            "EV_LVL_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_LVL_ID" ORDER BY "EV_LVL_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_LVL_ID",
                "EV_ID",
                "EV_LVL_ChangedAt",
                "EV_LVL_PositedAt",
                IFF("EV_LVL_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."EV_LVL_Event_Level"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID",
    "EV_LVL_ChangedAt",
    "EV_LVL_PositedAt",
    asserted
;
-- ST_NAM_Stage_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Stage_Name_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_NAM_ID', "ST_NAM_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Stage_Name_Posit"
GROUP BY
    "ST_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_NAM_ChangedAt', "ST_NAM_ChangedAt",
        'ST_NAM_Stage_Name', "ST_NAM_Stage_Name"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Stage_Name_Posit"
GROUP BY
    "ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_Stage_Name"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'no row in ST_Stage for ST_ID',
    OBJECT_CONSTRUCT('ST_ID', c."ST_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Stage_Name_Posit" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID"
;
-- ST_NAM_Stage_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Stage_Name_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Stage_Name_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ID', "ST_NAM_ID",
        'ST_NAM_PositedAt', "ST_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Stage_Name_Annex"
GROUP BY
    "ST_NAM_ID",
    "ST_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Annex',
    'no row in ST_NAM_Stage_Name_Posit for ST_NAM_ID',
    OBJECT_CONSTRUCT('ST_NAM_ID', c."ST_NAM_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Stage_Name_Annex" c
LEFT JOIN
    attributes."ST_NAM_Stage_Name_Posit" p
ON
    p."ST_NAM_ID" = c."ST_NAM_ID"
WHERE
    p."ST_NAM_ID" IS NULL
GROUP BY
    c."ST_NAM_ID"
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Stage_Name" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_NAM_Stage_Name',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_NAM_ChangedAt', "ST_NAM_ChangedAt",
        'ST_NAM_PositedAt', "ST_NAM_PositedAt",
        'ST_NAM_Reliability', "ST_NAM_Reliability"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Stage_Name"
GROUP BY
    "ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_PositedAt",
    "ST_NAM_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_NAM_Stage_Name',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_NAM_ChangedAt', "ST_NAM_ChangedAt",
        'ST_NAM_PositedAt', "ST_NAM_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "ST_ID",
                "ST_NAM_ChangedAt"
            ORDER BY
                "ST_NAM_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "ST_ID",
            "ST_NAM_ChangedAt",
            "ST_NAM_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "ST_NAM_ID" ORDER BY "ST_NAM_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "ST_NAM_ID",
                "ST_ID",
                "ST_NAM_ChangedAt",
                "ST_NAM_PositedAt",
                IFF("ST_NAM_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."ST_NAM_Stage_Name"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_PositedAt",
    asserted
;
-- ST_LOC_Stage_Location_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Stage_Location_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_LOC_ID', "ST_LOC_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Stage_Location_Posit"
GROUP BY
    "ST_LOC_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_LOC_Checksum', "ST_LOC_Checksum"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Stage_Location_Posit"
GROUP BY
    "ST_ID",
    "ST_LOC_Checksum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'no row in ST_Stage for ST_ID',
    OBJECT_CONSTRUCT('ST_ID', c."ST_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Stage_Location_Posit" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID"
;
-- ST_LOC_Stage_Location_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Stage_Location_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Stage_Location_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ID', "ST_LOC_ID",
        'ST_LOC_PositedAt', "ST_LOC_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Stage_Location_Annex"
GROUP BY
    "ST_LOC_ID",
    "ST_LOC_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Annex',
    'no row in ST_LOC_Stage_Location_Posit for ST_LOC_ID',
    OBJECT_CONSTRUCT('ST_LOC_ID', c."ST_LOC_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Stage_Location_Annex" c
LEFT JOIN
    attributes."ST_LOC_Stage_Location_Posit" p
ON
    p."ST_LOC_ID" = c."ST_LOC_ID"
WHERE
    p."ST_LOC_ID" IS NULL
GROUP BY
    c."ST_LOC_ID"
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Stage_Location" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_LOC_Stage_Location',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_LOC_PositedAt', "ST_LOC_PositedAt",
        'ST_LOC_Reliability', "ST_LOC_Reliability"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Stage_Location"
GROUP BY
    "ST_ID",
    "ST_LOC_PositedAt",
    "ST_LOC_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_LOC_Stage_Location',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_LOC_PositedAt', "ST_LOC_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "ST_ID",
        "ST_LOC_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "ST_ID"
            ORDER BY
                "ST_LOC_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "ST_ID",
            "ST_LOC_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "ST_LOC_ID" ORDER BY "ST_LOC_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "ST_LOC_ID",
                "ST_ID",
                "ST_LOC_PositedAt",
                IFF("ST_LOC_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."ST_LOC_Stage_Location"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "ST_ID",
    "ST_LOC_PositedAt",
    asserted
;
-- ST_AVG_Stage_Average_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Stage_Average_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_AVG_ID', "ST_AVG_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average_Posit"
GROUP BY
    "ST_AVG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt",
        'UTL_ID', "UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average_Posit"
GROUP BY
    "ST_ID",
    "ST_AVG_ChangedAt",
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in ST_Stage for ST_ID',
    OBJECT_CONSTRUCT('ST_ID', c."ST_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average_Posit" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID"
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in UTL_Utilization for UTL_ID',
    OBJECT_CONSTRUCT('UTL_ID', c."UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average_Posit" c
LEFT JOIN
    knots."UTL_Utilization" p
ON
    p."UTL_ID" = c."UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."UTL_ID"
;
-- ST_AVG_Stage_Average_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Stage_Average_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Stage_Average_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ID', "ST_AVG_ID",
        'ST_AVG_PositedAt', "ST_AVG_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average_Annex"
GROUP BY
    "ST_AVG_ID",
    "ST_AVG_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Annex',
    'no row in ST_AVG_Stage_Average_Posit for ST_AVG_ID',
    OBJECT_CONSTRUCT('ST_AVG_ID', c."ST_AVG_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average_Annex" c
LEFT JOIN
    attributes."ST_AVG_Stage_Average_Posit" p
ON
    p."ST_AVG_ID" = c."ST_AVG_ID"
WHERE
    p."ST_AVG_ID" IS NULL
GROUP BY
    c."ST_AVG_ID"
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Stage_Average" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_AVG_Stage_Average',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt",
        'ST_AVG_PositedAt', "ST_AVG_PositedAt",
        'ST_AVG_Reliability', "ST_AVG_Reliability"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Stage_Average"
GROUP BY
    "ST_ID",
    "ST_AVG_ChangedAt",
    "ST_AVG_PositedAt",
    "ST_AVG_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_AVG_Stage_Average',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt",
        'ST_AVG_PositedAt', "ST_AVG_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "ST_ID",
                "ST_AVG_ChangedAt"
            ORDER BY
                "ST_AVG_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "ST_ID",
            "ST_AVG_ChangedAt",
            "ST_AVG_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "ST_AVG_ID" ORDER BY "ST_AVG_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "ST_AVG_ID",
                "ST_ID",
                "ST_AVG_ChangedAt",
                "ST_AVG_PositedAt",
                IFF("ST_AVG_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."ST_AVG_Stage_Average"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "ST_ID",
    "ST_AVG_ChangedAt",
    "ST_AVG_PositedAt",
    asserted
UNION ALL
-- restatement in what is in effect: the latest annex row of each posit, when it asserts the posit
SELECT
    'ST_AVG_Stage_Average',
    'restatement',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt"
    ),
    1
FROM (
    SELECT
        "ST_ID",
        "ST_AVG_ChangedAt",
        "UTL_ID" AS compared,
        LAG("UTL_ID") OVER (
            PARTITION BY "ST_ID"
            ORDER BY "ST_AVG_ChangedAt", "ST_AVG_ID"
        ) AS previous,
        LAG("ST_AVG_ChangedAt") OVER (
            PARTITION BY "ST_ID"
            ORDER BY "ST_AVG_ChangedAt", "ST_AVG_ID"
        ) AS previous_changing
    FROM (
        SELECT
            "ST_AVG_ID",
            "ST_ID",
            "ST_AVG_ChangedAt",
            "UTL_ID",
            "ST_AVG_Reliability"
        FROM
            attributes."ST_AVG_Stage_Average"
        QUALIFY
            ROW_NUMBER() OVER (
                PARTITION BY "ST_AVG_ID"
                ORDER BY "ST_AVG_PositedAt" DESC
            ) = 1
    )
    WHERE
        "ST_AVG_Reliability" = 1
)
WHERE
    compared = previous
AND
    previous_changing < "ST_AVG_ChangedAt"
;
-- ST_MIN_Stage_Minimum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Stage_Minimum_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_MIN_ID', "ST_MIN_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum_Posit"
GROUP BY
    "ST_MIN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'UTL_ID', "UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum_Posit"
GROUP BY
    "ST_ID",
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in ST_Stage for ST_ID',
    OBJECT_CONSTRUCT('ST_ID', c."ST_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum_Posit" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID"
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in UTL_Utilization for UTL_ID',
    OBJECT_CONSTRUCT('UTL_ID', c."UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum_Posit" c
LEFT JOIN
    knots."UTL_Utilization" p
ON
    p."UTL_ID" = c."UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."UTL_ID"
;
-- ST_MIN_Stage_Minimum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Stage_Minimum_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ID', "ST_MIN_ID",
        'ST_MIN_PositedAt', "ST_MIN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum_Annex"
GROUP BY
    "ST_MIN_ID",
    "ST_MIN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'no row in ST_MIN_Stage_Minimum_Posit for ST_MIN_ID',
    OBJECT_CONSTRUCT('ST_MIN_ID', c."ST_MIN_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum_Annex" c
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum_Posit" p
ON
    p."ST_MIN_ID" = c."ST_MIN_ID"
WHERE
    p."ST_MIN_ID" IS NULL
GROUP BY
    c."ST_MIN_ID"
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Stage_Minimum" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_MIN_Stage_Minimum',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_MIN_PositedAt', "ST_MIN_PositedAt",
        'ST_MIN_Reliability', "ST_MIN_Reliability"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Stage_Minimum"
GROUP BY
    "ST_ID",
    "ST_MIN_PositedAt",
    "ST_MIN_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_MIN_Stage_Minimum',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID",
        'ST_MIN_PositedAt', "ST_MIN_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "ST_ID",
        "ST_MIN_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "ST_ID"
            ORDER BY
                "ST_MIN_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "ST_ID",
            "ST_MIN_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "ST_MIN_ID" ORDER BY "ST_MIN_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "ST_MIN_ID",
                "ST_ID",
                "ST_MIN_PositedAt",
                IFF("ST_MIN_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."ST_MIN_Stage_Minimum"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "ST_ID",
    "ST_MIN_PositedAt",
    asserted
;
-- AC_NAM_Actor_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Actor_Name_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_NAM_ID', "AC_NAM_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Actor_Name_Posit"
GROUP BY
    "AC_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt",
        'AC_NAM_Actor_Name', "AC_NAM_Actor_Name"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Actor_Name_Posit"
GROUP BY
    "AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_Actor_Name"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'no row in AC_Actor for AC_ID',
    OBJECT_CONSTRUCT('AC_ID', c."AC_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Actor_Name_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID"
;
-- AC_NAM_Actor_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Actor_Name_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Actor_Name_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_ID', "AC_NAM_ID",
        'AC_NAM_PositedAt', "AC_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Actor_Name_Annex"
GROUP BY
    "AC_NAM_ID",
    "AC_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Annex',
    'no row in AC_NAM_Actor_Name_Posit for AC_NAM_ID',
    OBJECT_CONSTRUCT('AC_NAM_ID', c."AC_NAM_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Actor_Name_Annex" c
LEFT JOIN
    attributes."AC_NAM_Actor_Name_Posit" p
ON
    p."AC_NAM_ID" = c."AC_NAM_ID"
WHERE
    p."AC_NAM_ID" IS NULL
GROUP BY
    c."AC_NAM_ID"
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Actor_Name" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_NAM_Actor_Name',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt",
        'AC_NAM_PositedAt', "AC_NAM_PositedAt",
        'AC_NAM_Reliability', "AC_NAM_Reliability"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Actor_Name"
GROUP BY
    "AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_PositedAt",
    "AC_NAM_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_NAM_Actor_Name',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt",
        'AC_NAM_PositedAt', "AC_NAM_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID",
                "AC_NAM_ChangedAt"
            ORDER BY
                "AC_NAM_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_NAM_ID" ORDER BY "AC_NAM_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_NAM_ID",
                "AC_ID",
                "AC_NAM_ChangedAt",
                "AC_NAM_PositedAt",
                IFF("AC_NAM_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."AC_NAM_Actor_Name"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_PositedAt",
    asserted
UNION ALL
-- restatement in what is in effect: the latest annex row of each posit, when it asserts the posit
SELECT
    'AC_NAM_Actor_Name',
    'restatement',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt"
    ),
    1
FROM (
    SELECT
        "AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name" AS compared,
        LAG("AC_NAM_Actor_Name") OVER (
            PARTITION BY "AC_ID"
            ORDER BY "AC_NAM_ChangedAt", "AC_NAM_ID"
        ) AS previous,
        LAG("AC_NAM_ChangedAt") OVER (
            PARTITION BY "AC_ID"
            ORDER BY "AC_NAM_ChangedAt", "AC_NAM_ID"
        ) AS previous_changing
    FROM (
        SELECT
            "AC_NAM_ID",
            "AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Actor_Name",
            "AC_NAM_Reliability"
        FROM
            attributes."AC_NAM_Actor_Name"
        QUALIFY
            ROW_NUMBER() OVER (
                PARTITION BY "AC_NAM_ID"
                ORDER BY "AC_NAM_PositedAt" DESC
            ) = 1
    )
    WHERE
        "AC_NAM_Reliability" = 1
)
WHERE
    compared = previous
AND
    previous_changing < "AC_NAM_ChangedAt"
;
-- AC_GEN_Actor_Gender_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Actor_Gender_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_GEN_ID', "AC_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender_Posit"
GROUP BY
    "AC_GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'GEN_ID', "GEN_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender_Posit"
GROUP BY
    "AC_ID",
    "GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in AC_Actor for AC_ID',
    OBJECT_CONSTRUCT('AC_ID', c."AC_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID"
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in GEN_Gender for GEN_ID',
    OBJECT_CONSTRUCT('GEN_ID', c."GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender_Posit" c
LEFT JOIN
    knots."GEN_Gender" p
ON
    p."GEN_ID" = c."GEN_ID"
WHERE
    p."GEN_ID" IS NULL
GROUP BY
    c."GEN_ID"
;
-- AC_GEN_Actor_Gender_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Actor_Gender_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_ID', "AC_GEN_ID",
        'AC_GEN_PositedAt', "AC_GEN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender_Annex"
GROUP BY
    "AC_GEN_ID",
    "AC_GEN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'no row in AC_GEN_Actor_Gender_Posit for AC_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_ID', c."AC_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender_Annex" c
LEFT JOIN
    attributes."AC_GEN_Actor_Gender_Posit" p
ON
    p."AC_GEN_ID" = c."AC_GEN_ID"
WHERE
    p."AC_GEN_ID" IS NULL
GROUP BY
    c."AC_GEN_ID"
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Actor_Gender" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_GEN_Actor_Gender',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_GEN_PositedAt', "AC_GEN_PositedAt",
        'AC_GEN_Reliability', "AC_GEN_Reliability"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Actor_Gender"
GROUP BY
    "AC_ID",
    "AC_GEN_PositedAt",
    "AC_GEN_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_GEN_Actor_Gender',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_GEN_PositedAt', "AC_GEN_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID",
        "AC_GEN_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID"
            ORDER BY
                "AC_GEN_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID",
            "AC_GEN_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_GEN_ID" ORDER BY "AC_GEN_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_GEN_ID",
                "AC_ID",
                "AC_GEN_PositedAt",
                IFF("AC_GEN_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."AC_GEN_Actor_Gender"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID",
    "AC_GEN_PositedAt",
    asserted
;
-- AC_PLV_Actor_ProfessionalLevel_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Actor_ProfessionalLevel_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_PLV_ID', "AC_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit"
GROUP BY
    "AC_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_PLV_ChangedAt', "AC_PLV_ChangedAt",
        'PLV_ID', "PLV_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit"
GROUP BY
    "AC_ID",
    "AC_PLV_ChangedAt",
    "PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in AC_Actor for AC_ID',
    OBJECT_CONSTRUCT('AC_ID', c."AC_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID"
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in PLV_ProfessionalLevel for PLV_ID',
    OBJECT_CONSTRUCT('PLV_ID', c."PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit" c
LEFT JOIN
    knots."PLV_ProfessionalLevel" p
ON
    p."PLV_ID" = c."PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."PLV_ID"
;
-- AC_PLV_Actor_ProfessionalLevel_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Actor_ProfessionalLevel_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_ID', "AC_PLV_ID",
        'AC_PLV_PositedAt', "AC_PLV_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Annex"
GROUP BY
    "AC_PLV_ID",
    "AC_PLV_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'no row in AC_PLV_Actor_ProfessionalLevel_Posit for AC_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_ID', c."AC_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Annex" c
LEFT JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit" p
ON
    p."AC_PLV_ID" = c."AC_PLV_ID"
WHERE
    p."AC_PLV_ID" IS NULL
GROUP BY
    c."AC_PLV_ID"
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Actor_ProfessionalLevel" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_PLV_ChangedAt', "AC_PLV_ChangedAt",
        'AC_PLV_PositedAt', "AC_PLV_PositedAt",
        'AC_PLV_Reliability', "AC_PLV_Reliability"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel"
GROUP BY
    "AC_ID",
    "AC_PLV_ChangedAt",
    "AC_PLV_PositedAt",
    "AC_PLV_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID",
        'AC_PLV_ChangedAt', "AC_PLV_ChangedAt",
        'AC_PLV_PositedAt', "AC_PLV_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID",
                "AC_PLV_ChangedAt"
            ORDER BY
                "AC_PLV_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID",
            "AC_PLV_ChangedAt",
            "AC_PLV_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_PLV_ID" ORDER BY "AC_PLV_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_PLV_ID",
                "AC_ID",
                "AC_PLV_ChangedAt",
                "AC_PLV_PositedAt",
                IFF("AC_PLV_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."AC_PLV_Actor_ProfessionalLevel"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID",
    "AC_PLV_ChangedAt",
    "AC_PLV_PositedAt",
    asserted
;
-- PR_NAM_Program_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Program_Name_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_NAM_ID', "PR_NAM_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Program_Name_Posit"
GROUP BY
    "PR_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID",
        'PR_NAM_Program_Name', "PR_NAM_Program_Name"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Program_Name_Posit"
GROUP BY
    "PR_ID",
    "PR_NAM_Program_Name"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'no row in PR_Program for PR_ID',
    OBJECT_CONSTRUCT('PR_ID', c."PR_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Program_Name_Posit" c
LEFT JOIN
    anchors."PR_Program" p
ON
    p."PR_ID" = c."PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID"
;
-- PR_NAM_Program_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Program_Name_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Program_Name_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_ID', "PR_NAM_ID",
        'PR_NAM_PositedAt', "PR_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Program_Name_Annex"
GROUP BY
    "PR_NAM_ID",
    "PR_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Annex',
    'no row in PR_NAM_Program_Name_Posit for PR_NAM_ID',
    OBJECT_CONSTRUCT('PR_NAM_ID', c."PR_NAM_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Program_Name_Annex" c
LEFT JOIN
    attributes."PR_NAM_Program_Name_Posit" p
ON
    p."PR_NAM_ID" = c."PR_NAM_ID"
WHERE
    p."PR_NAM_ID" IS NULL
GROUP BY
    c."PR_NAM_ID"
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Program_Name" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_NAM_Program_Name',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID",
        'PR_NAM_PositedAt', "PR_NAM_PositedAt",
        'PR_NAM_Reliability', "PR_NAM_Reliability"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Program_Name"
GROUP BY
    "PR_ID",
    "PR_NAM_PositedAt",
    "PR_NAM_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'PR_NAM_Program_Name',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID",
        'PR_NAM_PositedAt', "PR_NAM_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "PR_ID",
        "PR_NAM_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "PR_ID"
            ORDER BY
                "PR_NAM_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "PR_ID",
            "PR_NAM_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "PR_NAM_ID" ORDER BY "PR_NAM_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "PR_NAM_ID",
                "PR_ID",
                "PR_NAM_PositedAt",
                IFF("PR_NAM_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."PR_NAM_Program_Name"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "PR_ID",
    "PR_NAM_PositedAt",
    asserted
;
-- PR_LEN_Program_Length_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Program_Length_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_LEN_ID', "PR_LEN_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Program_Length_Posit"
GROUP BY
    "PR_LEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID",
        'PR_LEN_ChangedAt', "PR_LEN_ChangedAt",
        'PR_LEN_Program_Length', "PR_LEN_Program_Length"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Program_Length_Posit"
GROUP BY
    "PR_ID",
    "PR_LEN_ChangedAt",
    "PR_LEN_Program_Length"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'no row in PR_Program for PR_ID',
    OBJECT_CONSTRUCT('PR_ID', c."PR_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Program_Length_Posit" c
LEFT JOIN
    anchors."PR_Program" p
ON
    p."PR_ID" = c."PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID"
;
-- PR_LEN_Program_Length_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Program_Length_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Program_Length_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_ID', "PR_LEN_ID",
        'PR_LEN_PositedAt', "PR_LEN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Program_Length_Annex"
GROUP BY
    "PR_LEN_ID",
    "PR_LEN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Annex',
    'no row in PR_LEN_Program_Length_Posit for PR_LEN_ID',
    OBJECT_CONSTRUCT('PR_LEN_ID', c."PR_LEN_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Program_Length_Annex" c
LEFT JOIN
    attributes."PR_LEN_Program_Length_Posit" p
ON
    p."PR_LEN_ID" = c."PR_LEN_ID"
WHERE
    p."PR_LEN_ID" IS NULL
GROUP BY
    c."PR_LEN_ID"
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Program_Length" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_LEN_Program_Length',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID",
        'PR_LEN_ChangedAt', "PR_LEN_ChangedAt",
        'PR_LEN_PositedAt', "PR_LEN_PositedAt",
        'PR_LEN_Reliability', "PR_LEN_Reliability"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Program_Length"
GROUP BY
    "PR_ID",
    "PR_LEN_ChangedAt",
    "PR_LEN_PositedAt",
    "PR_LEN_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'PR_LEN_Program_Length',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID",
        'PR_LEN_ChangedAt', "PR_LEN_ChangedAt",
        'PR_LEN_PositedAt', "PR_LEN_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "PR_ID",
                "PR_LEN_ChangedAt"
            ORDER BY
                "PR_LEN_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "PR_ID",
            "PR_LEN_ChangedAt",
            "PR_LEN_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "PR_LEN_ID" ORDER BY "PR_LEN_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "PR_LEN_ID",
                "PR_ID",
                "PR_LEN_ChangedAt",
                "PR_LEN_PositedAt",
                IFF("PR_LEN_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                attributes."PR_LEN_Program_Length"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "PR_ID",
    "PR_LEN_ChangedAt",
    "PR_LEN_PositedAt",
    asserted
;
-- AC_partner_AC_with_ONG_currently_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', "AC_partner_AC_with_ONG_currently_ID"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_partner_AC_with_ONG_currently_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_ID_with', "AC_ID_with",
        'ONG_ID_currently', "ONG_ID_currently",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_partner",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', "AC_ID_with",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_with",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c."AC_ID_partner"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_partner"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_partner"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c."AC_ID_with"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_with"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_with"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in ONG_Ongoing for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c."ONG_ID_currently"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    knots."ONG_Ongoing" p
ON
    p."ONG_ID" = c."ONG_ID_currently"
WHERE
    p."ONG_ID" IS NULL
GROUP BY
    c."ONG_ID_currently"
;
-- AC_partner_AC_with_ONG_currently_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_partner_AC_with_ONG_currently_ID', "AC_partner_AC_with_ONG_currently_ID",
        'AC_partner_AC_with_ONG_currently_PositedAt', "AC_partner_AC_with_ONG_currently_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex"
GROUP BY
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'no row in AC_partner_AC_with_ONG_currently_Posit for AC_partner_AC_with_ONG_currently_ID',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', c."AC_partner_AC_with_ONG_currently_ID"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex" c
LEFT JOIN
    ties."AC_partner_AC_with_ONG_currently_Posit" p
ON
    p."AC_partner_AC_with_ONG_currently_ID" = c."AC_partner_AC_with_ONG_currently_ID"
WHERE
    p."AC_partner_AC_with_ONG_currently_ID" IS NULL
GROUP BY
    c."AC_partner_AC_with_ONG_currently_ID"
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_partner_AC_with_ONG_currently',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_ID_with', "AC_ID_with",
        'ONG_ID_currently', "ONG_ID_currently",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt",
        'AC_partner_AC_with_ONG_currently_PositedAt', "AC_partner_AC_with_ONG_currently_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently"
GROUP BY
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_partner_AC_with_ONG_currently_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_partner_AC_with_ONG_currently',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_ID_with', "AC_ID_with",
        'ONG_ID_currently', "ONG_ID_currently",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt",
        'AC_partner_AC_with_ONG_currently_PositedAt', "AC_partner_AC_with_ONG_currently_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID_partner",
                "AC_ID_with",
                "ONG_ID_currently",
                "AC_partner_AC_with_ONG_currently_ChangedAt"
            ORDER BY
                "AC_partner_AC_with_ONG_currently_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID_partner",
            "AC_ID_with",
            "ONG_ID_currently",
            "AC_partner_AC_with_ONG_currently_ChangedAt",
            "AC_partner_AC_with_ONG_currently_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_partner_AC_with_ONG_currently_ID" ORDER BY "AC_partner_AC_with_ONG_currently_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_partner_AC_with_ONG_currently_ID",
                "AC_ID_partner",
                "AC_ID_with",
                "ONG_ID_currently",
                "AC_partner_AC_with_ONG_currently_ChangedAt",
                "AC_partner_AC_with_ONG_currently_PositedAt",
                IFF("AC_partner_AC_with_ONG_currently_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."AC_partner_AC_with_ONG_currently"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_partner_AC_with_ONG_currently_PositedAt",
    asserted
;
-- AC_subset_PN_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', "AC_subset_PN_of_ID"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_subset_PN_of_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset",
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_ID_subset",
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_ID_subset"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in AC_Actor for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c."AC_ID_subset"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_subset"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_subset"
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c."PN_ID_of"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit" c
LEFT JOIN
    anchors."PN_Person" p
ON
    p."PN_ID" = c."PN_ID_of"
WHERE
    p."PN_ID" IS NULL
GROUP BY
    c."PN_ID_of"
;
-- AC_subset_PN_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_subset_PN_of_ID', "AC_subset_PN_of_ID",
        'AC_subset_PN_of_PositedAt', "AC_subset_PN_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Annex"
GROUP BY
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Annex',
    'no row in AC_subset_PN_of_Posit for AC_subset_PN_of_ID',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', c."AC_subset_PN_of_ID"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Annex" c
LEFT JOIN
    ties."AC_subset_PN_of_Posit" p
ON
    p."AC_subset_PN_of_ID" = c."AC_subset_PN_of_ID"
WHERE
    p."AC_subset_PN_of_ID" IS NULL
GROUP BY
    c."AC_subset_PN_of_ID"
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_subset_PN_of',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset",
        'PN_ID_of', "PN_ID_of",
        'AC_subset_PN_of_PositedAt', "AC_subset_PN_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of"
GROUP BY
    "AC_ID_subset",
    "PN_ID_of",
    "AC_subset_PN_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_subset_PN_of',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset",
        'PN_ID_of', "PN_ID_of",
        'AC_subset_PN_of_PositedAt', "AC_subset_PN_of_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID_subset",
        "PN_ID_of",
        "AC_subset_PN_of_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID_subset",
                "PN_ID_of"
            ORDER BY
                "AC_subset_PN_of_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID_subset",
            "PN_ID_of",
            "AC_subset_PN_of_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_subset_PN_of_ID" ORDER BY "AC_subset_PN_of_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_subset_PN_of_ID",
                "AC_ID_subset",
                "PN_ID_of",
                "AC_subset_PN_of_PositedAt",
                IFF("AC_subset_PN_of_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."AC_subset_PN_of"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID_subset",
    "PN_ID_of",
    "AC_subset_PN_of_PositedAt",
    asserted
;
-- EV_in_AC_wasCast_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_wasCast_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_in_AC_wasCast_ID', "EV_in_AC_wasCast_ID"),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast_Posit"
GROUP BY
    "EV_in_AC_wasCast_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', "EV_ID_in",
        'AC_ID_wasCast', "AC_ID_wasCast"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast_Posit"
GROUP BY
    "EV_ID_in",
    "AC_ID_wasCast"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in EV_Event for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c."EV_ID_in"),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID_in"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_in"
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in AC_Actor for AC_ID_wasCast',
    OBJECT_CONSTRUCT('AC_ID_wasCast', c."AC_ID_wasCast"),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_wasCast"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_wasCast"
;
-- EV_in_AC_wasCast_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_wasCast_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_wasCast_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_in_AC_wasCast_ID', "EV_in_AC_wasCast_ID",
        'EV_in_AC_wasCast_PositedAt', "EV_in_AC_wasCast_PositedAt"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast_Annex"
GROUP BY
    "EV_in_AC_wasCast_ID",
    "EV_in_AC_wasCast_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Annex',
    'no row in EV_in_AC_wasCast_Posit for EV_in_AC_wasCast_ID',
    OBJECT_CONSTRUCT('EV_in_AC_wasCast_ID', c."EV_in_AC_wasCast_ID"),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast_Annex" c
LEFT JOIN
    ties."EV_in_AC_wasCast_Posit" p
ON
    p."EV_in_AC_wasCast_ID" = c."EV_in_AC_wasCast_ID"
WHERE
    p."EV_in_AC_wasCast_ID" IS NULL
GROUP BY
    c."EV_in_AC_wasCast_ID"
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_wasCast" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_in_AC_wasCast',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'EV_ID_in', "EV_ID_in",
        'AC_ID_wasCast', "AC_ID_wasCast",
        'EV_in_AC_wasCast_PositedAt', "EV_in_AC_wasCast_PositedAt"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_wasCast"
GROUP BY
    "EV_ID_in",
    "AC_ID_wasCast",
    "EV_in_AC_wasCast_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'EV_in_AC_wasCast',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'EV_ID_in', "EV_ID_in",
        'AC_ID_wasCast', "AC_ID_wasCast",
        'EV_in_AC_wasCast_PositedAt', "EV_in_AC_wasCast_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "EV_ID_in",
        "AC_ID_wasCast",
        "EV_in_AC_wasCast_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "EV_ID_in",
                "AC_ID_wasCast"
            ORDER BY
                "EV_in_AC_wasCast_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "EV_ID_in",
            "AC_ID_wasCast",
            "EV_in_AC_wasCast_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "EV_in_AC_wasCast_ID" ORDER BY "EV_in_AC_wasCast_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "EV_in_AC_wasCast_ID",
                "EV_ID_in",
                "AC_ID_wasCast",
                "EV_in_AC_wasCast_PositedAt",
                IFF("EV_in_AC_wasCast_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."EV_in_AC_wasCast"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "EV_ID_in",
    "AC_ID_wasCast",
    "EV_in_AC_wasCast_PositedAt",
    asserted
;
-- AC_part_PR_in_RAT_got_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_part_PR_in_RAT_got_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_part_PR_in_RAT_got_ID', "AC_part_PR_in_RAT_got_ID"),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Posit"
GROUP BY
    "AC_part_PR_in_RAT_got_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_part', "AC_ID_part",
        'PR_ID_in', "PR_ID_in",
        'RAT_ID_got', "RAT_ID_got",
        'AC_part_PR_in_RAT_got_ChangedAt', "AC_part_PR_in_RAT_got_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Posit"
GROUP BY
    "AC_ID_part",
    "PR_ID_in",
    "RAT_ID_got",
    "AC_part_PR_in_RAT_got_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in AC_Actor for AC_ID_part',
    OBJECT_CONSTRUCT('AC_ID_part', c."AC_ID_part"),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_part"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_part"
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in PR_Program for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c."PR_ID_in"),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Posit" c
LEFT JOIN
    anchors."PR_Program" p
ON
    p."PR_ID" = c."PR_ID_in"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_in"
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in RAT_Rating for RAT_ID_got',
    OBJECT_CONSTRUCT('RAT_ID_got', c."RAT_ID_got"),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Posit" c
LEFT JOIN
    knots."RAT_Rating" p
ON
    p."RAT_ID" = c."RAT_ID_got"
WHERE
    p."RAT_ID" IS NULL
GROUP BY
    c."RAT_ID_got"
;
-- AC_part_PR_in_RAT_got_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_part_PR_in_RAT_got_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_part_PR_in_RAT_got_ID', "AC_part_PR_in_RAT_got_ID",
        'AC_part_PR_in_RAT_got_PositedAt', "AC_part_PR_in_RAT_got_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Annex"
GROUP BY
    "AC_part_PR_in_RAT_got_ID",
    "AC_part_PR_in_RAT_got_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'no row in AC_part_PR_in_RAT_got_Posit for AC_part_PR_in_RAT_got_ID',
    OBJECT_CONSTRUCT('AC_part_PR_in_RAT_got_ID', c."AC_part_PR_in_RAT_got_ID"),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got_Annex" c
LEFT JOIN
    ties."AC_part_PR_in_RAT_got_Posit" p
ON
    p."AC_part_PR_in_RAT_got_ID" = c."AC_part_PR_in_RAT_got_ID"
WHERE
    p."AC_part_PR_in_RAT_got_ID" IS NULL
GROUP BY
    c."AC_part_PR_in_RAT_got_ID"
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_AC_part_PR_in_RAT_got" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_part_PR_in_RAT_got',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID_part', "AC_ID_part",
        'PR_ID_in', "PR_ID_in",
        'AC_part_PR_in_RAT_got_ChangedAt', "AC_part_PR_in_RAT_got_ChangedAt",
        'AC_part_PR_in_RAT_got_PositedAt', "AC_part_PR_in_RAT_got_PositedAt",
        'AC_part_PR_in_RAT_got_Reliability', "AC_part_PR_in_RAT_got_Reliability"
    ),
    COUNT(*)
FROM
    ties."AC_part_PR_in_RAT_got"
GROUP BY
    "AC_ID_part",
    "PR_ID_in",
    "AC_part_PR_in_RAT_got_ChangedAt",
    "AC_part_PR_in_RAT_got_PositedAt",
    "AC_part_PR_in_RAT_got_Reliability"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_part_PR_in_RAT_got',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID_part', "AC_ID_part",
        'PR_ID_in', "PR_ID_in",
        'AC_part_PR_in_RAT_got_ChangedAt', "AC_part_PR_in_RAT_got_ChangedAt",
        'AC_part_PR_in_RAT_got_PositedAt', "AC_part_PR_in_RAT_got_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "AC_part_PR_in_RAT_got_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID_part",
                "PR_ID_in",
                "AC_part_PR_in_RAT_got_ChangedAt"
            ORDER BY
                "AC_part_PR_in_RAT_got_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID_part",
            "PR_ID_in",
            "AC_part_PR_in_RAT_got_ChangedAt",
            "AC_part_PR_in_RAT_got_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_part_PR_in_RAT_got_ID" ORDER BY "AC_part_PR_in_RAT_got_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_part_PR_in_RAT_got_ID",
                "AC_ID_part",
                "PR_ID_in",
                "AC_part_PR_in_RAT_got_ChangedAt",
                "AC_part_PR_in_RAT_got_PositedAt",
                IFF("AC_part_PR_in_RAT_got_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."AC_part_PR_in_RAT_got"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID_part",
    "PR_ID_in",
    "AC_part_PR_in_RAT_got_ChangedAt",
    "AC_part_PR_in_RAT_got_PositedAt",
    asserted
;
-- ST_at_PR_isPlaying_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_isPlaying_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_at_PR_isPlaying_ID', "ST_at_PR_isPlaying_ID"),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying_Posit"
GROUP BY
    "ST_at_PR_isPlaying_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', "ST_ID_at",
        'PR_ID_isPlaying', "PR_ID_isPlaying",
        'ST_at_PR_isPlaying_ChangedAt', "ST_at_PR_isPlaying_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying_Posit"
GROUP BY
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in ST_Stage for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c."ST_ID_at"),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying_Posit" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID_at"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_at"
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in PR_Program for PR_ID_isPlaying',
    OBJECT_CONSTRUCT('PR_ID_isPlaying', c."PR_ID_isPlaying"),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying_Posit" c
LEFT JOIN
    anchors."PR_Program" p
ON
    p."PR_ID" = c."PR_ID_isPlaying"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_isPlaying"
;
-- ST_at_PR_isPlaying_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_isPlaying_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_isPlaying_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_at_PR_isPlaying_ID', "ST_at_PR_isPlaying_ID",
        'ST_at_PR_isPlaying_PositedAt', "ST_at_PR_isPlaying_PositedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying_Annex"
GROUP BY
    "ST_at_PR_isPlaying_ID",
    "ST_at_PR_isPlaying_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Annex',
    'no row in ST_at_PR_isPlaying_Posit for ST_at_PR_isPlaying_ID',
    OBJECT_CONSTRUCT('ST_at_PR_isPlaying_ID', c."ST_at_PR_isPlaying_ID"),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying_Annex" c
LEFT JOIN
    ties."ST_at_PR_isPlaying_Posit" p
ON
    p."ST_at_PR_isPlaying_ID" = c."ST_at_PR_isPlaying_ID"
WHERE
    p."ST_at_PR_isPlaying_ID" IS NULL
GROUP BY
    c."ST_at_PR_isPlaying_ID"
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_isPlaying" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_at_PR_isPlaying',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'ST_ID_at', "ST_ID_at",
        'PR_ID_isPlaying', "PR_ID_isPlaying",
        'ST_at_PR_isPlaying_ChangedAt', "ST_at_PR_isPlaying_ChangedAt",
        'ST_at_PR_isPlaying_PositedAt', "ST_at_PR_isPlaying_PositedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_isPlaying"
GROUP BY
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt",
    "ST_at_PR_isPlaying_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'ST_at_PR_isPlaying',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'ST_ID_at', "ST_ID_at",
        'PR_ID_isPlaying', "PR_ID_isPlaying",
        'ST_at_PR_isPlaying_ChangedAt', "ST_at_PR_isPlaying_ChangedAt",
        'ST_at_PR_isPlaying_PositedAt', "ST_at_PR_isPlaying_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt",
        "ST_at_PR_isPlaying_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "ST_ID_at",
                "PR_ID_isPlaying",
                "ST_at_PR_isPlaying_ChangedAt"
            ORDER BY
                "ST_at_PR_isPlaying_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "ST_ID_at",
            "PR_ID_isPlaying",
            "ST_at_PR_isPlaying_ChangedAt",
            "ST_at_PR_isPlaying_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "ST_at_PR_isPlaying_ID" ORDER BY "ST_at_PR_isPlaying_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "ST_at_PR_isPlaying_ID",
                "ST_ID_at",
                "PR_ID_isPlaying",
                "ST_at_PR_isPlaying_ChangedAt",
                "ST_at_PR_isPlaying_PositedAt",
                IFF("ST_at_PR_isPlaying_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."ST_at_PR_isPlaying"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt",
    "ST_at_PR_isPlaying_PositedAt",
    asserted
;
-- AC_parent_AC_child_PAT_having_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_parent_AC_child_PAT_having_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_parent_AC_child_PAT_having_ID', "AC_parent_AC_child_PAT_having_ID"),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Posit"
GROUP BY
    "AC_parent_AC_child_PAT_having_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_parent', "AC_ID_parent",
        'AC_ID_child', "AC_ID_child",
        'PAT_ID_having', "PAT_ID_having"
    ),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Posit"
GROUP BY
    "AC_ID_parent",
    "AC_ID_child",
    "PAT_ID_having"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_parent',
    OBJECT_CONSTRUCT('AC_ID_parent', c."AC_ID_parent"),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_parent"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_parent"
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_child',
    OBJECT_CONSTRUCT('AC_ID_child', c."AC_ID_child"),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Posit" c
LEFT JOIN
    anchors."AC_Actor" p
ON
    p."AC_ID" = c."AC_ID_child"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_child"
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in PAT_ParentalType for PAT_ID_having',
    OBJECT_CONSTRUCT('PAT_ID_having', c."PAT_ID_having"),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Posit" c
LEFT JOIN
    knots."PAT_ParentalType" p
ON
    p."PAT_ID" = c."PAT_ID_having"
WHERE
    p."PAT_ID" IS NULL
GROUP BY
    c."PAT_ID_having"
;
-- AC_parent_AC_child_PAT_having_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_parent_AC_child_PAT_having_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_parent_AC_child_PAT_having_ID', "AC_parent_AC_child_PAT_having_ID",
        'AC_parent_AC_child_PAT_having_PositedAt', "AC_parent_AC_child_PAT_having_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Annex"
GROUP BY
    "AC_parent_AC_child_PAT_having_ID",
    "AC_parent_AC_child_PAT_having_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'no row in AC_parent_AC_child_PAT_having_Posit for AC_parent_AC_child_PAT_having_ID',
    OBJECT_CONSTRUCT('AC_parent_AC_child_PAT_having_ID', c."AC_parent_AC_child_PAT_having_ID"),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having_Annex" c
LEFT JOIN
    ties."AC_parent_AC_child_PAT_having_Posit" p
ON
    p."AC_parent_AC_child_PAT_having_ID" = c."AC_parent_AC_child_PAT_having_ID"
WHERE
    p."AC_parent_AC_child_PAT_having_ID" IS NULL
GROUP BY
    c."AC_parent_AC_child_PAT_having_ID"
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_AC_parent_AC_child_PAT_having" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_parent_AC_child_PAT_having',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'AC_ID_parent', "AC_ID_parent",
        'AC_ID_child', "AC_ID_child",
        'PAT_ID_having', "PAT_ID_having",
        'AC_parent_AC_child_PAT_having_PositedAt', "AC_parent_AC_child_PAT_having_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_parent_AC_child_PAT_having"
GROUP BY
    "AC_ID_parent",
    "AC_ID_child",
    "PAT_ID_having",
    "AC_parent_AC_child_PAT_having_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_parent_AC_child_PAT_having',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'AC_ID_parent', "AC_ID_parent",
        'AC_ID_child', "AC_ID_child",
        'PAT_ID_having', "PAT_ID_having",
        'AC_parent_AC_child_PAT_having_PositedAt', "AC_parent_AC_child_PAT_having_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having",
        "AC_parent_AC_child_PAT_having_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "AC_ID_parent",
                "AC_ID_child",
                "PAT_ID_having"
            ORDER BY
                "AC_parent_AC_child_PAT_having_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "AC_ID_parent",
            "AC_ID_child",
            "PAT_ID_having",
            "AC_parent_AC_child_PAT_having_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "AC_parent_AC_child_PAT_having_ID" ORDER BY "AC_parent_AC_child_PAT_having_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "AC_parent_AC_child_PAT_having_ID",
                "AC_ID_parent",
                "AC_ID_child",
                "PAT_ID_having",
                "AC_parent_AC_child_PAT_having_PositedAt",
                IFF("AC_parent_AC_child_PAT_having_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."AC_parent_AC_child_PAT_having"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "AC_ID_parent",
    "AC_ID_child",
    "PAT_ID_having",
    "AC_parent_AC_child_PAT_having_PositedAt",
    asserted
;
-- PR_content_ST_location_EV_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_content_ST_location_EV_of_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_content_ST_location_EV_of_ID', "PR_content_ST_location_EV_of_ID"),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit"
GROUP BY
    "PR_content_ST_location_EV_of_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_ID_content', "PR_ID_content",
        'ST_ID_location', "ST_ID_location",
        'EV_ID_of', "EV_ID_of",
        'PR_content_ST_location_EV_of_ChangedAt', "PR_content_ST_location_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit"
GROUP BY
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of",
    "PR_content_ST_location_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate unique key (PR_content)',
    OBJECT_CONSTRUCT(
        'PR_ID_content', "PR_ID_content",
        'PR_content_ST_location_EV_of_ChangedAt', "PR_content_ST_location_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit"
GROUP BY
    "PR_ID_content",
    "PR_content_ST_location_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate unique key (ST_location)',
    OBJECT_CONSTRUCT(
        'ST_ID_location', "ST_ID_location",
        'PR_content_ST_location_EV_of_ChangedAt', "PR_content_ST_location_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit"
GROUP BY
    "ST_ID_location",
    "PR_content_ST_location_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in PR_Program for PR_ID_content',
    OBJECT_CONSTRUCT('PR_ID_content', c."PR_ID_content"),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit" c
LEFT JOIN
    anchors."PR_Program" p
ON
    p."PR_ID" = c."PR_ID_content"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_content"
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in ST_Stage for ST_ID_location',
    OBJECT_CONSTRUCT('ST_ID_location', c."ST_ID_location"),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit" c
LEFT JOIN
    anchors."ST_Stage" p
ON
    p."ST_ID" = c."ST_ID_location"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_location"
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in EV_Event for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c."EV_ID_of"),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Posit" c
LEFT JOIN
    nexuses."EV_Event" p
ON
    p."EV_ID" = c."EV_ID_of"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_of"
;
-- PR_content_ST_location_EV_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_content_ST_location_EV_of_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_content_ST_location_EV_of_ID', "PR_content_ST_location_EV_of_ID",
        'PR_content_ST_location_EV_of_PositedAt', "PR_content_ST_location_EV_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Annex"
GROUP BY
    "PR_content_ST_location_EV_of_ID",
    "PR_content_ST_location_EV_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'no row in PR_content_ST_location_EV_of_Posit for PR_content_ST_location_EV_of_ID',
    OBJECT_CONSTRUCT('PR_content_ST_location_EV_of_ID', c."PR_content_ST_location_EV_of_ID"),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of_Annex" c
LEFT JOIN
    ties."PR_content_ST_location_EV_of_Posit" p
ON
    p."PR_content_ST_location_EV_of_ID" = c."PR_content_ST_location_EV_of_ID"
WHERE
    p."PR_content_ST_location_EV_of_ID" IS NULL
GROUP BY
    c."PR_content_ST_location_EV_of_ID"
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in Snowflake.
CREATE OR REPLACE VIEW ties."ic_PR_content_ST_location_EV_of" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_content_ST_location_EV_of',
    'temporal duplicate',
    OBJECT_CONSTRUCT(
        'PR_ID_content', "PR_ID_content",
        'ST_ID_location', "ST_ID_location",
        'EV_ID_of', "EV_ID_of",
        'PR_content_ST_location_EV_of_ChangedAt', "PR_content_ST_location_EV_of_ChangedAt",
        'PR_content_ST_location_EV_of_PositedAt', "PR_content_ST_location_EV_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."PR_content_ST_location_EV_of"
GROUP BY
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of",
    "PR_content_ST_location_EV_of_ChangedAt",
    "PR_content_ST_location_EV_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'PR_content_ST_location_EV_of',
    'more than one posit asserted at a time',
    OBJECT_CONSTRUCT(
        'PR_ID_content', "PR_ID_content",
        'ST_ID_location', "ST_ID_location",
        'EV_ID_of', "EV_ID_of",
        'PR_content_ST_location_EV_of_ChangedAt', "PR_content_ST_location_EV_of_ChangedAt",
        'PR_content_ST_location_EV_of_PositedAt', "PR_content_ST_location_EV_of_PositedAt"
    ),
    asserted
FROM (
    SELECT
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of",
        "PR_content_ST_location_EV_of_ChangedAt",
        "PR_content_ST_location_EV_of_PositedAt",
        SUM(asserted_change) OVER (
            PARTITION BY
                "PR_ID_content",
                "ST_ID_location",
                "EV_ID_of",
                "PR_content_ST_location_EV_of_ChangedAt"
            ORDER BY
                "PR_content_ST_location_EV_of_PositedAt"
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            "PR_ID_content",
            "ST_ID_location",
            "EV_ID_of",
            "PR_content_ST_location_EV_of_ChangedAt",
            "PR_content_ST_location_EV_of_PositedAt",
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY "PR_content_ST_location_EV_of_ID" ORDER BY "PR_content_ST_location_EV_of_PositedAt"
            ), 0) AS asserted_change
        FROM (
            SELECT
                "PR_content_ST_location_EV_of_ID",
                "PR_ID_content",
                "ST_ID_location",
                "EV_ID_of",
                "PR_content_ST_location_EV_of_ChangedAt",
                "PR_content_ST_location_EV_of_PositedAt",
                IFF("PR_content_ST_location_EV_of_Reliability" = 1, 1, 0) AS is_asserted
            FROM
                ties."PR_content_ST_location_EV_of"
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of",
    "PR_content_ST_location_EV_of_ChangedAt",
    "PR_content_ST_location_EV_of_PositedAt",
    asserted
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW dw.IntegrityViolations (
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
UNION ALL SELECT * FROM knots."ic_PAT_ParentalType"
UNION ALL SELECT * FROM knots."ic_GEN_Gender"
UNION ALL SELECT * FROM knots."ic_PLV_ProfessionalLevel"
UNION ALL SELECT * FROM knots."ic_UTL_Utilization"
UNION ALL SELECT * FROM knots."ic_ONG_Ongoing"
UNION ALL SELECT * FROM knots."ic_RAT_Rating"
UNION ALL SELECT * FROM knots."ic_ETY_EventType"
UNION ALL SELECT * FROM anchors."ic_PN_Person"
UNION ALL SELECT * FROM anchors."ic_ST_Stage"
UNION ALL SELECT * FROM anchors."ic_AC_Actor"
UNION ALL SELECT * FROM anchors."ic_PR_Program"
UNION ALL SELECT * FROM nexuses."ic_EV_Event"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Event_Date_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Event_Date_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Event_Date"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Event_Audience_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Event_Audience_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Event_Audience"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Event_Revenue_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Event_Revenue_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Event_Revenue"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Event_Status_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Event_Status_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Event_Status"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Event_Utilization_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Event_Utilization_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Event_Utilization"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Event_Level_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Event_Level_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Event_Level"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Stage_Name_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Stage_Name_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Stage_Name"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Stage_Location_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Stage_Location_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Stage_Location"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Stage_Average_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Stage_Average_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Stage_Average"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Stage_Minimum_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Stage_Minimum_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Stage_Minimum"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Actor_Name_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Actor_Name_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Actor_Name"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Actor_Gender_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Actor_Gender_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Actor_Gender"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Actor_ProfessionalLevel_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Actor_ProfessionalLevel_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Actor_ProfessionalLevel"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Program_Name_Posit"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Program_Name_Annex"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Program_Name"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Program_Length_Posit"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Program_Length_Annex"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Program_Length"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently_Posit"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently_Annex"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of_Posit"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of_Annex"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_wasCast_Posit"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_wasCast_Annex"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_wasCast"
UNION ALL SELECT * FROM ties."ic_AC_part_PR_in_RAT_got_Posit"
UNION ALL SELECT * FROM ties."ic_AC_part_PR_in_RAT_got_Annex"
UNION ALL SELECT * FROM ties."ic_AC_part_PR_in_RAT_got"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_isPlaying_Posit"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_isPlaying_Annex"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_isPlaying"
UNION ALL SELECT * FROM ties."ic_AC_parent_AC_child_PAT_having_Posit"
UNION ALL SELECT * FROM ties."ic_AC_parent_AC_child_PAT_having_Annex"
UNION ALL SELECT * FROM ties."ic_AC_parent_AC_child_PAT_having"
UNION ALL SELECT * FROM ties."ic_PR_content_ST_location_EV_of_Posit"
UNION ALL SELECT * FROM ties."ic_PR_content_ST_location_EV_of_Annex"
UNION ALL SELECT * FROM ties."ic_PR_content_ST_location_EV_of"
UNION ALL SELECT * FROM anchors."ic_key_ST_Stage_1st"
UNION ALL SELECT * FROM anchors."ic_key_ST_Stage_2nd"
UNION ALL SELECT * FROM anchors."ic_key_AC_Actor_1st"
UNION ALL SELECT * FROM anchors."ic_key_PR_Program_1st"
UNION ALL SELECT * FROM nexuses."ic_key_EV_Event_1st"
;