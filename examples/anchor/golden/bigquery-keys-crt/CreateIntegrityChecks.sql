-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- BigQuery does not enforce primary or foreign keys, and it has no unique constraints. The primary and foreign keys are declared,
-- which tells the optimizer to trust them; a unique key is only a rule of the model. A violation is therefore not an error, but
-- wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--
-- In a concurrent reliance temporal model an attribute and a tie are a posit table and an annex table, each with a view
-- (ic_<posit table>, ic_<annex table>), and a third view, ic_<attribute or tie>, for what the two say together:
--
--   temporal duplicate                            the unique key of the assembled view in SQL Server: two annex rows of the same
--                                                 assertion for the same entity, changing time, positing time and positor
--                                                 (in a model with decisiveness and entity integrity)
--   more than one assertion at a time             a positor that has asserted more than one posit for the same entity (the
--                                                 identifiers of a tie) and changing time at a positing time, positive or
--                                                 negative, where decisiveness says one
--   assertions that contradict at a time          the same without decisiveness: the reliabilities of what a positor asserts
--                                                 add up to more than one, a positive one as it is and a negative one as one
--                                                 plus it, which is the non-contradiction of transitional modeling
--   restatement                                   in an attribute or a tie that may not store them, a value that the positor
--                                                 asserts at the changing time after the one that has it already
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
-- column of the referred table in the WHERE clause, so a foreign key cannot make the optimizer drop the join.
--
-- PAT_ParentalType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PAT_ParentalType` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PAT_ParentalType',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PAT_ID` AS `PAT_ID`)),
    COUNT(*)
FROM
    public.`PAT_ParentalType`
GROUP BY
    `PAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_ParentalType',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`PAT_ParentalType` AS `PAT_ParentalType`)),
    COUNT(*)
FROM
    public.`PAT_ParentalType`
GROUP BY
    `PAT_ParentalType`
HAVING
    COUNT(*) > 1;
-- GEN_Gender integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_GEN_Gender` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'GEN_Gender',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`GEN_ID` AS `GEN_ID`)),
    COUNT(*)
FROM
    public.`GEN_Gender`
GROUP BY
    `GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`GEN_Gender` AS `GEN_Gender`)),
    COUNT(*)
FROM
    public.`GEN_Gender`
GROUP BY
    `GEN_Gender`
HAVING
    COUNT(*) > 1;
-- PLV_ProfessionalLevel integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PLV_ProfessionalLevel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PLV_ProfessionalLevel',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PLV_ID` AS `PLV_ID`)),
    COUNT(*)
FROM
    public.`PLV_ProfessionalLevel`
GROUP BY
    `PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_ProfessionalLevel',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`PLV_Checksum` AS `PLV_Checksum`)),
    COUNT(*)
FROM
    public.`PLV_ProfessionalLevel`
GROUP BY
    `PLV_Checksum`
HAVING
    COUNT(*) > 1;
-- UTL_Utilization integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_UTL_Utilization` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'UTL_Utilization',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`UTL_ID` AS `UTL_ID`)),
    COUNT(*)
FROM
    public.`UTL_Utilization`
GROUP BY
    `UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utilization',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`UTL_Utilization` AS `UTL_Utilization`)),
    COUNT(*)
FROM
    public.`UTL_Utilization`
GROUP BY
    `UTL_Utilization`
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ONG_Ongoing` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ONG_Ongoing',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ONG_ID` AS `ONG_ID`)),
    COUNT(*)
FROM
    public.`ONG_Ongoing`
GROUP BY
    `ONG_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Ongoing',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ONG_Ongoing` AS `ONG_Ongoing`)),
    COUNT(*)
FROM
    public.`ONG_Ongoing`
GROUP BY
    `ONG_Ongoing`
HAVING
    COUNT(*) > 1;
-- RAT_Rating integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_RAT_Rating` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'RAT_Rating',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`RAT_ID` AS `RAT_ID`)),
    COUNT(*)
FROM
    public.`RAT_Rating`
GROUP BY
    `RAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`RAT_Rating` AS `RAT_Rating`)),
    COUNT(*)
FROM
    public.`RAT_Rating`
GROUP BY
    `RAT_Rating`
HAVING
    COUNT(*) > 1;
-- ETY_EventType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ETY_EventType` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ETY_EventType',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ETY_ID` AS `ETY_ID`)),
    COUNT(*)
FROM
    public.`ETY_EventType`
GROUP BY
    `ETY_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_EventType',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ETY_EventType` AS `ETY_EventType`)),
    COUNT(*)
FROM
    public.`ETY_EventType`
GROUP BY
    `ETY_EventType`
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PN_Person` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PN_ID` AS `PN_ID`)),
    COUNT(*)
FROM
    public.`PN_Person`
GROUP BY
    `PN_ID`
HAVING
    COUNT(*) > 1;
-- ST_Stage integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_Stage` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_Stage',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    public.`ST_Stage`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- AC_Actor integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_Actor` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_Actor',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_ID` AS `AC_ID`)),
    COUNT(*)
FROM
    public.`AC_Actor`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- PR_Program integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_Program` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_Program',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_ID` AS `PR_ID`)),
    COUNT(*)
FROM
    public.`PR_Program`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- EV_Event integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_Event` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_Event',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_ID` AS `EV_ID`)),
    COUNT(*)
FROM
    public.`EV_Event`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Event',
    'no row in ST_Stage for ST_ID_wasHeldAt',
    TO_JSON_STRING(STRUCT(c.`ST_ID_wasHeldAt` AS `ST_ID_wasHeldAt`)),
    COUNT(*)
FROM
    public.`EV_Event` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_wasHeldAt`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_wasHeldAt`
UNION ALL
SELECT
    'EV_Event',
    'no row in PR_Program for PR_ID_wasPlayed',
    TO_JSON_STRING(STRUCT(c.`PR_ID_wasPlayed` AS `PR_ID_wasPlayed`)),
    COUNT(*)
FROM
    public.`EV_Event` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_wasPlayed`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_wasPlayed`
UNION ALL
SELECT
    'EV_Event',
    'no row in ETY_EventType for ETY_ID_of',
    TO_JSON_STRING(STRUCT(c.`ETY_ID_of` AS `ETY_ID_of`)),
    COUNT(*)
FROM
    public.`EV_Event` c
LEFT JOIN
    public.`ETY_EventType` p
ON
    p.`ETY_ID` = c.`ETY_ID_of`
WHERE
    p.`ETY_ID` IS NULL
GROUP BY
    c.`ETY_ID_of`
;
-- EV_DAT_Event_Date_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_DAT_ID` AS `EV_DAT_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Posit`
GROUP BY
    `EV_DAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`,
        `EV_DAT_Event_Date` AS `EV_DAT_Event_Date`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Posit`
GROUP BY
    `EV_DAT_EV_ID`,
    `EV_DAT_Event_Date`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'no row in EV_Event for EV_DAT_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_DAT_EV_ID` AS `EV_DAT_EV_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_DAT_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_DAT_EV_ID`
;
-- EV_DAT_Event_Date_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Event_Date_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_ID` AS `EV_DAT_ID`,
        `EV_DAT_Positor` AS `EV_DAT_Positor`,
        `EV_DAT_PositedAt` AS `EV_DAT_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Annex`
GROUP BY
    `EV_DAT_ID`,
    `EV_DAT_Positor`,
    `EV_DAT_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Annex',
    'no row in EV_DAT_Event_Date_Posit for EV_DAT_ID',
    TO_JSON_STRING(STRUCT(c.`EV_DAT_ID` AS `EV_DAT_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Annex` c
LEFT JOIN
    public.`EV_DAT_Event_Date_Posit` p
ON
    p.`EV_DAT_ID` = c.`EV_DAT_ID`
WHERE
    p.`EV_DAT_ID` IS NULL
GROUP BY
    c.`EV_DAT_ID`
;
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_DAT_Event_Date',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_Assertion` AS `EV_DAT_Assertion`,
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`,
        `EV_DAT_PositedAt` AS `EV_DAT_PositedAt`,
        `EV_DAT_Positor` AS `EV_DAT_Positor`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date`
GROUP BY
    `EV_DAT_Assertion`,
    `EV_DAT_EV_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_DAT_Event_Date',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_Positor` AS `EV_DAT_Positor`,
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`,
        `EV_DAT_PositedAt` AS `EV_DAT_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_DAT_Positor`,
        `EV_DAT_EV_ID`,
        `EV_DAT_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_DAT_Positor`,
                `EV_DAT_EV_ID`
            ORDER BY
                `EV_DAT_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `EV_DAT_Positor`,
                `EV_DAT_EV_ID`
            ORDER BY
                `EV_DAT_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `EV_DAT_Positor`,
            `EV_DAT_EV_ID`,
            `EV_DAT_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_DAT_ID`, `EV_DAT_Positor` ORDER BY `EV_DAT_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `EV_DAT_ID`, `EV_DAT_Positor` ORDER BY `EV_DAT_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `EV_DAT_ID`,
                `EV_DAT_Positor`,
                `EV_DAT_EV_ID`,
                `EV_DAT_PositedAt`,
                IF(`EV_DAT_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `EV_DAT_Assertion`
                    WHEN '+' THEN `EV_DAT_Reliability`
                    WHEN '-' THEN 1 + `EV_DAT_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`EV_DAT_Event_Date`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_DAT_Positor`,
    `EV_DAT_EV_ID`,
    `EV_DAT_PositedAt`,
    asserted
;
-- EV_AUD_Event_Audience_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_AUD_ID` AS `EV_AUD_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Posit`
GROUP BY
    `EV_AUD_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`,
        `EV_AUD_Event_Audience` AS `EV_AUD_Event_Audience`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Posit`
GROUP BY
    `EV_AUD_EV_ID`,
    `EV_AUD_Event_Audience`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'no row in EV_Event for EV_AUD_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_AUD_EV_ID` AS `EV_AUD_EV_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_AUD_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_AUD_EV_ID`
;
-- EV_AUD_Event_Audience_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Event_Audience_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_ID` AS `EV_AUD_ID`,
        `EV_AUD_Positor` AS `EV_AUD_Positor`,
        `EV_AUD_PositedAt` AS `EV_AUD_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Annex`
GROUP BY
    `EV_AUD_ID`,
    `EV_AUD_Positor`,
    `EV_AUD_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Annex',
    'no row in EV_AUD_Event_Audience_Posit for EV_AUD_ID',
    TO_JSON_STRING(STRUCT(c.`EV_AUD_ID` AS `EV_AUD_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Annex` c
LEFT JOIN
    public.`EV_AUD_Event_Audience_Posit` p
ON
    p.`EV_AUD_ID` = c.`EV_AUD_ID`
WHERE
    p.`EV_AUD_ID` IS NULL
GROUP BY
    c.`EV_AUD_ID`
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_AUD_Event_Audience',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_Assertion` AS `EV_AUD_Assertion`,
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`,
        `EV_AUD_PositedAt` AS `EV_AUD_PositedAt`,
        `EV_AUD_Positor` AS `EV_AUD_Positor`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience`
GROUP BY
    `EV_AUD_Assertion`,
    `EV_AUD_EV_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_AUD_Event_Audience',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_Positor` AS `EV_AUD_Positor`,
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`,
        `EV_AUD_PositedAt` AS `EV_AUD_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_AUD_Positor`,
        `EV_AUD_EV_ID`,
        `EV_AUD_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_AUD_Positor`,
                `EV_AUD_EV_ID`
            ORDER BY
                `EV_AUD_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `EV_AUD_Positor`,
                `EV_AUD_EV_ID`
            ORDER BY
                `EV_AUD_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `EV_AUD_Positor`,
            `EV_AUD_EV_ID`,
            `EV_AUD_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_AUD_ID`, `EV_AUD_Positor` ORDER BY `EV_AUD_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `EV_AUD_ID`, `EV_AUD_Positor` ORDER BY `EV_AUD_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `EV_AUD_ID`,
                `EV_AUD_Positor`,
                `EV_AUD_EV_ID`,
                `EV_AUD_PositedAt`,
                IF(`EV_AUD_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `EV_AUD_Assertion`
                    WHEN '+' THEN `EV_AUD_Reliability`
                    WHEN '-' THEN 1 + `EV_AUD_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`EV_AUD_Event_Audience`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_AUD_Positor`,
    `EV_AUD_EV_ID`,
    `EV_AUD_PositedAt`,
    asserted
;
-- EV_REV_Event_Revenue_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_REV_ID` AS `EV_REV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Posit`
GROUP BY
    `EV_REV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`,
        `EV_REV_Event_Revenue` AS `EV_REV_Event_Revenue`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Posit`
GROUP BY
    `EV_REV_EV_ID`,
    `EV_REV_Event_Revenue`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'no row in EV_Event for EV_REV_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_REV_EV_ID` AS `EV_REV_EV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_REV_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_REV_EV_ID`
;
-- EV_REV_Event_Revenue_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Event_Revenue_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_REV_ID` AS `EV_REV_ID`,
        `EV_REV_Positor` AS `EV_REV_Positor`,
        `EV_REV_PositedAt` AS `EV_REV_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Annex`
GROUP BY
    `EV_REV_ID`,
    `EV_REV_Positor`,
    `EV_REV_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Annex',
    'no row in EV_REV_Event_Revenue_Posit for EV_REV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_REV_ID` AS `EV_REV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Annex` c
LEFT JOIN
    public.`EV_REV_Event_Revenue_Posit` p
ON
    p.`EV_REV_ID` = c.`EV_REV_ID`
WHERE
    p.`EV_REV_ID` IS NULL
GROUP BY
    c.`EV_REV_ID`
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_REV_Event_Revenue',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_REV_Assertion` AS `EV_REV_Assertion`,
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`,
        `EV_REV_PositedAt` AS `EV_REV_PositedAt`,
        `EV_REV_Positor` AS `EV_REV_Positor`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue`
GROUP BY
    `EV_REV_Assertion`,
    `EV_REV_EV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_REV_Event_Revenue',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `EV_REV_Positor` AS `EV_REV_Positor`,
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`,
        `EV_REV_PositedAt` AS `EV_REV_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_REV_Positor`,
        `EV_REV_EV_ID`,
        `EV_REV_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_REV_Positor`,
                `EV_REV_EV_ID`
            ORDER BY
                `EV_REV_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `EV_REV_Positor`,
                `EV_REV_EV_ID`
            ORDER BY
                `EV_REV_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `EV_REV_Positor`,
            `EV_REV_EV_ID`,
            `EV_REV_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_REV_ID`, `EV_REV_Positor` ORDER BY `EV_REV_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `EV_REV_ID`, `EV_REV_Positor` ORDER BY `EV_REV_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `EV_REV_ID`,
                `EV_REV_Positor`,
                `EV_REV_EV_ID`,
                `EV_REV_PositedAt`,
                IF(`EV_REV_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `EV_REV_Assertion`
                    WHEN '+' THEN `EV_REV_Reliability`
                    WHEN '-' THEN 1 + `EV_REV_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`EV_REV_Event_Revenue`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_REV_Positor`,
    `EV_REV_EV_ID`,
    `EV_REV_PositedAt`,
    asserted
;
-- ST_NAM_Stage_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_NAM_ID` AS `ST_NAM_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Posit`
GROUP BY
    `ST_NAM_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`,
        `ST_NAM_Stage_Name` AS `ST_NAM_Stage_Name`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Posit`
GROUP BY
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_Stage_Name`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'no row in ST_Stage for ST_NAM_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_NAM_ST_ID` AS `ST_NAM_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_NAM_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_NAM_ST_ID`
;
-- ST_NAM_Stage_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Stage_Name_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ID` AS `ST_NAM_ID`,
        `ST_NAM_Positor` AS `ST_NAM_Positor`,
        `ST_NAM_PositedAt` AS `ST_NAM_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Annex`
GROUP BY
    `ST_NAM_ID`,
    `ST_NAM_Positor`,
    `ST_NAM_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Annex',
    'no row in ST_NAM_Stage_Name_Posit for ST_NAM_ID',
    TO_JSON_STRING(STRUCT(c.`ST_NAM_ID` AS `ST_NAM_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Annex` c
LEFT JOIN
    public.`ST_NAM_Stage_Name_Posit` p
ON
    p.`ST_NAM_ID` = c.`ST_NAM_ID`
WHERE
    p.`ST_NAM_ID` IS NULL
GROUP BY
    c.`ST_NAM_ID`
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_NAM_Stage_Name',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_Assertion` AS `ST_NAM_Assertion`,
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`,
        `ST_NAM_PositedAt` AS `ST_NAM_PositedAt`,
        `ST_NAM_Positor` AS `ST_NAM_Positor`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name`
GROUP BY
    `ST_NAM_Assertion`,
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_NAM_Stage_Name',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_Positor` AS `ST_NAM_Positor`,
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`,
        `ST_NAM_PositedAt` AS `ST_NAM_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_NAM_Positor`,
        `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt`,
        `ST_NAM_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_NAM_Positor`,
                `ST_NAM_ST_ID`,
                `ST_NAM_ChangedAt`
            ORDER BY
                `ST_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `ST_NAM_Positor`,
                `ST_NAM_ST_ID`,
                `ST_NAM_ChangedAt`
            ORDER BY
                `ST_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `ST_NAM_Positor`,
            `ST_NAM_ST_ID`,
            `ST_NAM_ChangedAt`,
            `ST_NAM_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_NAM_ID`, `ST_NAM_Positor` ORDER BY `ST_NAM_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `ST_NAM_ID`, `ST_NAM_Positor` ORDER BY `ST_NAM_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `ST_NAM_ID`,
                `ST_NAM_Positor`,
                `ST_NAM_ST_ID`,
                `ST_NAM_ChangedAt`,
                `ST_NAM_PositedAt`,
                IF(`ST_NAM_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `ST_NAM_Assertion`
                    WHEN '+' THEN `ST_NAM_Reliability`
                    WHEN '-' THEN 1 + `ST_NAM_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`ST_NAM_Stage_Name`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_NAM_Positor`,
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_PositedAt`,
    asserted
;
-- ST_LOC_Stage_Location_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_LOC_ID` AS `ST_LOC_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Posit`
GROUP BY
    `ST_LOC_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`,
        `ST_LOC_Checksum` AS `ST_LOC_Checksum`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Posit`
GROUP BY
    `ST_LOC_ST_ID`,
    `ST_LOC_Checksum`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'no row in ST_Stage for ST_LOC_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_LOC_ST_ID` AS `ST_LOC_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_LOC_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_LOC_ST_ID`
;
-- ST_LOC_Stage_Location_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Stage_Location_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ID` AS `ST_LOC_ID`,
        `ST_LOC_Positor` AS `ST_LOC_Positor`,
        `ST_LOC_PositedAt` AS `ST_LOC_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Annex`
GROUP BY
    `ST_LOC_ID`,
    `ST_LOC_Positor`,
    `ST_LOC_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Annex',
    'no row in ST_LOC_Stage_Location_Posit for ST_LOC_ID',
    TO_JSON_STRING(STRUCT(c.`ST_LOC_ID` AS `ST_LOC_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Annex` c
LEFT JOIN
    public.`ST_LOC_Stage_Location_Posit` p
ON
    p.`ST_LOC_ID` = c.`ST_LOC_ID`
WHERE
    p.`ST_LOC_ID` IS NULL
GROUP BY
    c.`ST_LOC_ID`
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_LOC_Stage_Location',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_Assertion` AS `ST_LOC_Assertion`,
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`,
        `ST_LOC_PositedAt` AS `ST_LOC_PositedAt`,
        `ST_LOC_Positor` AS `ST_LOC_Positor`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location`
GROUP BY
    `ST_LOC_Assertion`,
    `ST_LOC_ST_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_LOC_Stage_Location',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_Positor` AS `ST_LOC_Positor`,
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`,
        `ST_LOC_PositedAt` AS `ST_LOC_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_LOC_Positor`,
        `ST_LOC_ST_ID`,
        `ST_LOC_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_LOC_Positor`,
                `ST_LOC_ST_ID`
            ORDER BY
                `ST_LOC_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `ST_LOC_Positor`,
                `ST_LOC_ST_ID`
            ORDER BY
                `ST_LOC_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `ST_LOC_Positor`,
            `ST_LOC_ST_ID`,
            `ST_LOC_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_LOC_ID`, `ST_LOC_Positor` ORDER BY `ST_LOC_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `ST_LOC_ID`, `ST_LOC_Positor` ORDER BY `ST_LOC_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `ST_LOC_ID`,
                `ST_LOC_Positor`,
                `ST_LOC_ST_ID`,
                `ST_LOC_PositedAt`,
                IF(`ST_LOC_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `ST_LOC_Assertion`
                    WHEN '+' THEN `ST_LOC_Reliability`
                    WHEN '-' THEN 1 + `ST_LOC_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`ST_LOC_Stage_Location`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_LOC_Positor`,
    `ST_LOC_ST_ID`,
    `ST_LOC_PositedAt`,
    asserted
;
-- ST_AVG_Stage_Average_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_AVG_ID` AS `ST_AVG_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit`
GROUP BY
    `ST_AVG_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`,
        `ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit`
GROUP BY
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in ST_Stage for ST_AVG_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_ST_ID` AS `ST_AVG_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_AVG_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_AVG_ST_ID`
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_AVG_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_AVG_UTL_ID`
;
-- ST_AVG_Stage_Average_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Stage_Average_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ID` AS `ST_AVG_ID`,
        `ST_AVG_Positor` AS `ST_AVG_Positor`,
        `ST_AVG_PositedAt` AS `ST_AVG_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Annex`
GROUP BY
    `ST_AVG_ID`,
    `ST_AVG_Positor`,
    `ST_AVG_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Annex',
    'no row in ST_AVG_Stage_Average_Posit for ST_AVG_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_ID` AS `ST_AVG_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Annex` c
LEFT JOIN
    public.`ST_AVG_Stage_Average_Posit` p
ON
    p.`ST_AVG_ID` = c.`ST_AVG_ID`
WHERE
    p.`ST_AVG_ID` IS NULL
GROUP BY
    c.`ST_AVG_ID`
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_AVG_Stage_Average',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_Assertion` AS `ST_AVG_Assertion`,
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`,
        `ST_AVG_PositedAt` AS `ST_AVG_PositedAt`,
        `ST_AVG_Positor` AS `ST_AVG_Positor`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average`
GROUP BY
    `ST_AVG_Assertion`,
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_AVG_Stage_Average',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_Positor` AS `ST_AVG_Positor`,
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`,
        `ST_AVG_PositedAt` AS `ST_AVG_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_AVG_Positor`,
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`,
        `ST_AVG_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_AVG_Positor`,
                `ST_AVG_ST_ID`,
                `ST_AVG_ChangedAt`
            ORDER BY
                `ST_AVG_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `ST_AVG_Positor`,
                `ST_AVG_ST_ID`,
                `ST_AVG_ChangedAt`
            ORDER BY
                `ST_AVG_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `ST_AVG_Positor`,
            `ST_AVG_ST_ID`,
            `ST_AVG_ChangedAt`,
            `ST_AVG_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_AVG_ID`, `ST_AVG_Positor` ORDER BY `ST_AVG_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `ST_AVG_ID`, `ST_AVG_Positor` ORDER BY `ST_AVG_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `ST_AVG_ID`,
                `ST_AVG_Positor`,
                `ST_AVG_ST_ID`,
                `ST_AVG_ChangedAt`,
                `ST_AVG_PositedAt`,
                IF(`ST_AVG_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `ST_AVG_Assertion`
                    WHEN '+' THEN `ST_AVG_Reliability`
                    WHEN '-' THEN 1 + `ST_AVG_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`ST_AVG_Stage_Average`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_AVG_Positor`,
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_PositedAt`,
    asserted
UNION ALL
-- restatement in what is in effect: the latest annex row of each posit of a positor, when it asserts the posit
SELECT
    'ST_AVG_Stage_Average',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_Positor` AS `ST_AVG_Positor`,
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    1
FROM (
    SELECT
        `ST_AVG_Positor`,
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`,
        `ST_AVG_UTL_ID` AS compared,
        LAG(`ST_AVG_UTL_ID`) OVER (
            PARTITION BY `ST_AVG_Positor`, `ST_AVG_ST_ID`
            ORDER BY `ST_AVG_ChangedAt`, `ST_AVG_ID`
        ) AS previous,
        LAG(`ST_AVG_ChangedAt`) OVER (
            PARTITION BY `ST_AVG_Positor`, `ST_AVG_ST_ID`
            ORDER BY `ST_AVG_ChangedAt`, `ST_AVG_ID`
        ) AS previous_changing
    FROM (
        SELECT
            `ST_AVG_ID`,
            `ST_AVG_Positor`,
            `ST_AVG_ST_ID`,
            `ST_AVG_ChangedAt`,
            `ST_AVG_UTL_ID`,
            `ST_AVG_Assertion`
        FROM
            public.`ST_AVG_Stage_Average`
        WHERE
            TRUE
        QUALIFY
            ROW_NUMBER() OVER (
                PARTITION BY `ST_AVG_ID`, `ST_AVG_Positor`
                ORDER BY `ST_AVG_PositedAt` DESC
            ) = 1
    )
    WHERE
        `ST_AVG_Assertion` = '+'
)
WHERE
    compared = previous
AND
    previous_changing < `ST_AVG_ChangedAt`
;
-- ST_MIN_Stage_Minimum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_MIN_ID` AS `ST_MIN_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit`
GROUP BY
    `ST_MIN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`,
        `ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit`
GROUP BY
    `ST_MIN_ST_ID`,
    `ST_MIN_UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in ST_Stage for ST_MIN_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_ST_ID` AS `ST_MIN_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_MIN_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_MIN_ST_ID`
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_MIN_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_MIN_UTL_ID`
;
-- ST_MIN_Stage_Minimum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ID` AS `ST_MIN_ID`,
        `ST_MIN_Positor` AS `ST_MIN_Positor`,
        `ST_MIN_PositedAt` AS `ST_MIN_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Annex`
GROUP BY
    `ST_MIN_ID`,
    `ST_MIN_Positor`,
    `ST_MIN_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'no row in ST_MIN_Stage_Minimum_Posit for ST_MIN_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_ID` AS `ST_MIN_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Annex` c
LEFT JOIN
    public.`ST_MIN_Stage_Minimum_Posit` p
ON
    p.`ST_MIN_ID` = c.`ST_MIN_ID`
WHERE
    p.`ST_MIN_ID` IS NULL
GROUP BY
    c.`ST_MIN_ID`
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_MIN_Stage_Minimum',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_Assertion` AS `ST_MIN_Assertion`,
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`,
        `ST_MIN_PositedAt` AS `ST_MIN_PositedAt`,
        `ST_MIN_Positor` AS `ST_MIN_Positor`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum`
GROUP BY
    `ST_MIN_Assertion`,
    `ST_MIN_ST_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_MIN_Stage_Minimum',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_Positor` AS `ST_MIN_Positor`,
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`,
        `ST_MIN_PositedAt` AS `ST_MIN_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_MIN_Positor`,
        `ST_MIN_ST_ID`,
        `ST_MIN_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_MIN_Positor`,
                `ST_MIN_ST_ID`
            ORDER BY
                `ST_MIN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `ST_MIN_Positor`,
                `ST_MIN_ST_ID`
            ORDER BY
                `ST_MIN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `ST_MIN_Positor`,
            `ST_MIN_ST_ID`,
            `ST_MIN_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_MIN_ID`, `ST_MIN_Positor` ORDER BY `ST_MIN_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `ST_MIN_ID`, `ST_MIN_Positor` ORDER BY `ST_MIN_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `ST_MIN_ID`,
                `ST_MIN_Positor`,
                `ST_MIN_ST_ID`,
                `ST_MIN_PositedAt`,
                IF(`ST_MIN_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `ST_MIN_Assertion`
                    WHEN '+' THEN `ST_MIN_Reliability`
                    WHEN '-' THEN 1 + `ST_MIN_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`ST_MIN_Stage_Minimum`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_MIN_Positor`,
    `ST_MIN_ST_ID`,
    `ST_MIN_PositedAt`,
    asserted
;
-- AC_NAM_Actor_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_NAM_ID` AS `AC_NAM_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Posit`
GROUP BY
    `AC_NAM_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`,
        `AC_NAM_Actor_Name` AS `AC_NAM_Actor_Name`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Posit`
GROUP BY
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Actor_Name`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'no row in AC_Actor for AC_NAM_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_NAM_AC_ID` AS `AC_NAM_AC_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_NAM_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_NAM_AC_ID`
;
-- AC_NAM_Actor_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Actor_Name_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_ID` AS `AC_NAM_ID`,
        `AC_NAM_Positor` AS `AC_NAM_Positor`,
        `AC_NAM_PositedAt` AS `AC_NAM_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Annex`
GROUP BY
    `AC_NAM_ID`,
    `AC_NAM_Positor`,
    `AC_NAM_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Annex',
    'no row in AC_NAM_Actor_Name_Posit for AC_NAM_ID',
    TO_JSON_STRING(STRUCT(c.`AC_NAM_ID` AS `AC_NAM_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Annex` c
LEFT JOIN
    public.`AC_NAM_Actor_Name_Posit` p
ON
    p.`AC_NAM_ID` = c.`AC_NAM_ID`
WHERE
    p.`AC_NAM_ID` IS NULL
GROUP BY
    c.`AC_NAM_ID`
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_NAM_Actor_Name',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_Assertion` AS `AC_NAM_Assertion`,
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`,
        `AC_NAM_PositedAt` AS `AC_NAM_PositedAt`,
        `AC_NAM_Positor` AS `AC_NAM_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name`
GROUP BY
    `AC_NAM_Assertion`,
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_NAM_Actor_Name',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_Positor` AS `AC_NAM_Positor`,
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`,
        `AC_NAM_PositedAt` AS `AC_NAM_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_NAM_Positor`,
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`,
        `AC_NAM_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_NAM_Positor`,
                `AC_NAM_AC_ID`,
                `AC_NAM_ChangedAt`
            ORDER BY
                `AC_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_NAM_Positor`,
                `AC_NAM_AC_ID`,
                `AC_NAM_ChangedAt`
            ORDER BY
                `AC_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_NAM_Positor`,
            `AC_NAM_AC_ID`,
            `AC_NAM_ChangedAt`,
            `AC_NAM_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_NAM_ID`, `AC_NAM_Positor` ORDER BY `AC_NAM_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_NAM_ID`, `AC_NAM_Positor` ORDER BY `AC_NAM_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_NAM_ID`,
                `AC_NAM_Positor`,
                `AC_NAM_AC_ID`,
                `AC_NAM_ChangedAt`,
                `AC_NAM_PositedAt`,
                IF(`AC_NAM_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_NAM_Assertion`
                    WHEN '+' THEN `AC_NAM_Reliability`
                    WHEN '-' THEN 1 + `AC_NAM_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_NAM_Actor_Name`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_NAM_Positor`,
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_PositedAt`,
    asserted
UNION ALL
-- restatement in what is in effect: the latest annex row of each posit of a positor, when it asserts the posit
SELECT
    'AC_NAM_Actor_Name',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_Positor` AS `AC_NAM_Positor`,
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    1
FROM (
    SELECT
        `AC_NAM_Positor`,
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`,
        `AC_NAM_Actor_Name` AS compared,
        LAG(`AC_NAM_Actor_Name`) OVER (
            PARTITION BY `AC_NAM_Positor`, `AC_NAM_AC_ID`
            ORDER BY `AC_NAM_ChangedAt`, `AC_NAM_ID`
        ) AS previous,
        LAG(`AC_NAM_ChangedAt`) OVER (
            PARTITION BY `AC_NAM_Positor`, `AC_NAM_AC_ID`
            ORDER BY `AC_NAM_ChangedAt`, `AC_NAM_ID`
        ) AS previous_changing
    FROM (
        SELECT
            `AC_NAM_ID`,
            `AC_NAM_Positor`,
            `AC_NAM_AC_ID`,
            `AC_NAM_ChangedAt`,
            `AC_NAM_Actor_Name`,
            `AC_NAM_Assertion`
        FROM
            public.`AC_NAM_Actor_Name`
        WHERE
            TRUE
        QUALIFY
            ROW_NUMBER() OVER (
                PARTITION BY `AC_NAM_ID`, `AC_NAM_Positor`
                ORDER BY `AC_NAM_PositedAt` DESC
            ) = 1
    )
    WHERE
        `AC_NAM_Assertion` = '+'
)
WHERE
    compared = previous
AND
    previous_changing < `AC_NAM_ChangedAt`
;
-- AC_GEN_Actor_Gender_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_GEN_ID` AS `AC_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit`
GROUP BY
    `AC_GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`,
        `AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit`
GROUP BY
    `AC_GEN_AC_ID`,
    `AC_GEN_GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in AC_Actor for AC_GEN_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_AC_ID` AS `AC_GEN_AC_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_GEN_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_GEN_AC_ID`
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in GEN_Gender for AC_GEN_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit` c
LEFT JOIN
    public.`GEN_Gender` p
ON
    p.`GEN_ID` = c.`AC_GEN_GEN_ID`
WHERE
    p.`GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_GEN_ID`
;
-- AC_GEN_Actor_Gender_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_ID` AS `AC_GEN_ID`,
        `AC_GEN_Positor` AS `AC_GEN_Positor`,
        `AC_GEN_PositedAt` AS `AC_GEN_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Annex`
GROUP BY
    `AC_GEN_ID`,
    `AC_GEN_Positor`,
    `AC_GEN_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'no row in AC_GEN_Actor_Gender_Posit for AC_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_ID` AS `AC_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Annex` c
LEFT JOIN
    public.`AC_GEN_Actor_Gender_Posit` p
ON
    p.`AC_GEN_ID` = c.`AC_GEN_ID`
WHERE
    p.`AC_GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_ID`
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_GEN_Actor_Gender',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_Assertion` AS `AC_GEN_Assertion`,
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`,
        `AC_GEN_PositedAt` AS `AC_GEN_PositedAt`,
        `AC_GEN_Positor` AS `AC_GEN_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender`
GROUP BY
    `AC_GEN_Assertion`,
    `AC_GEN_AC_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_GEN_Actor_Gender',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_Positor` AS `AC_GEN_Positor`,
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`,
        `AC_GEN_PositedAt` AS `AC_GEN_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_GEN_Positor`,
        `AC_GEN_AC_ID`,
        `AC_GEN_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_GEN_Positor`,
                `AC_GEN_AC_ID`
            ORDER BY
                `AC_GEN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_GEN_Positor`,
                `AC_GEN_AC_ID`
            ORDER BY
                `AC_GEN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_GEN_Positor`,
            `AC_GEN_AC_ID`,
            `AC_GEN_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_GEN_ID`, `AC_GEN_Positor` ORDER BY `AC_GEN_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_GEN_ID`, `AC_GEN_Positor` ORDER BY `AC_GEN_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_GEN_ID`,
                `AC_GEN_Positor`,
                `AC_GEN_AC_ID`,
                `AC_GEN_PositedAt`,
                IF(`AC_GEN_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_GEN_Assertion`
                    WHEN '+' THEN `AC_GEN_Reliability`
                    WHEN '-' THEN 1 + `AC_GEN_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_GEN_Actor_Gender`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_GEN_Positor`,
    `AC_GEN_AC_ID`,
    `AC_GEN_PositedAt`,
    asserted
;
-- AC_PLV_Actor_ProfessionalLevel_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_PLV_ID` AS `AC_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
GROUP BY
    `AC_PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`,
        `AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
GROUP BY
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in AC_Actor for AC_PLV_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_AC_ID` AS `AC_PLV_AC_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_PLV_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_PLV_AC_ID`
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` c
LEFT JOIN
    public.`PLV_ProfessionalLevel` p
ON
    p.`PLV_ID` = c.`AC_PLV_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_PLV_ID`
;
-- AC_PLV_Actor_ProfessionalLevel_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_ID` AS `AC_PLV_ID`,
        `AC_PLV_Positor` AS `AC_PLV_Positor`,
        `AC_PLV_PositedAt` AS `AC_PLV_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex`
GROUP BY
    `AC_PLV_ID`,
    `AC_PLV_Positor`,
    `AC_PLV_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'no row in AC_PLV_Actor_ProfessionalLevel_Posit for AC_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_ID` AS `AC_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex` c
LEFT JOIN
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` p
ON
    p.`AC_PLV_ID` = c.`AC_PLV_ID`
WHERE
    p.`AC_PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_ID`
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_Assertion` AS `AC_PLV_Assertion`,
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`,
        `AC_PLV_PositedAt` AS `AC_PLV_PositedAt`,
        `AC_PLV_Positor` AS `AC_PLV_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel`
GROUP BY
    `AC_PLV_Assertion`,
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_Positor` AS `AC_PLV_Positor`,
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`,
        `AC_PLV_PositedAt` AS `AC_PLV_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_PLV_Positor`,
        `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt`,
        `AC_PLV_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_PLV_Positor`,
                `AC_PLV_AC_ID`,
                `AC_PLV_ChangedAt`
            ORDER BY
                `AC_PLV_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_PLV_Positor`,
                `AC_PLV_AC_ID`,
                `AC_PLV_ChangedAt`
            ORDER BY
                `AC_PLV_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_PLV_Positor`,
            `AC_PLV_AC_ID`,
            `AC_PLV_ChangedAt`,
            `AC_PLV_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_PLV_ID`, `AC_PLV_Positor` ORDER BY `AC_PLV_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_PLV_ID`, `AC_PLV_Positor` ORDER BY `AC_PLV_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_PLV_ID`,
                `AC_PLV_Positor`,
                `AC_PLV_AC_ID`,
                `AC_PLV_ChangedAt`,
                `AC_PLV_PositedAt`,
                IF(`AC_PLV_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_PLV_Assertion`
                    WHEN '+' THEN `AC_PLV_Reliability`
                    WHEN '-' THEN 1 + `AC_PLV_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_PLV_Actor_ProfessionalLevel`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_PLV_Positor`,
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PositedAt`,
    asserted
;
-- PR_NAM_Program_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_NAM_ID` AS `PR_NAM_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Posit`
GROUP BY
    `PR_NAM_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`,
        `PR_NAM_Program_Name` AS `PR_NAM_Program_Name`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Posit`
GROUP BY
    `PR_NAM_PR_ID`,
    `PR_NAM_Program_Name`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'no row in PR_Program for PR_NAM_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_NAM_PR_ID` AS `PR_NAM_PR_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_NAM_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_NAM_PR_ID`
;
-- PR_NAM_Program_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Program_Name_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_ID` AS `PR_NAM_ID`,
        `PR_NAM_Positor` AS `PR_NAM_Positor`,
        `PR_NAM_PositedAt` AS `PR_NAM_PositedAt`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Annex`
GROUP BY
    `PR_NAM_ID`,
    `PR_NAM_Positor`,
    `PR_NAM_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Annex',
    'no row in PR_NAM_Program_Name_Posit for PR_NAM_ID',
    TO_JSON_STRING(STRUCT(c.`PR_NAM_ID` AS `PR_NAM_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Annex` c
LEFT JOIN
    public.`PR_NAM_Program_Name_Posit` p
ON
    p.`PR_NAM_ID` = c.`PR_NAM_ID`
WHERE
    p.`PR_NAM_ID` IS NULL
GROUP BY
    c.`PR_NAM_ID`
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_NAM_Program_Name',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_Assertion` AS `PR_NAM_Assertion`,
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`,
        `PR_NAM_PositedAt` AS `PR_NAM_PositedAt`,
        `PR_NAM_Positor` AS `PR_NAM_Positor`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name`
GROUP BY
    `PR_NAM_Assertion`,
    `PR_NAM_PR_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'PR_NAM_Program_Name',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_Positor` AS `PR_NAM_Positor`,
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`,
        `PR_NAM_PositedAt` AS `PR_NAM_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `PR_NAM_Positor`,
        `PR_NAM_PR_ID`,
        `PR_NAM_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `PR_NAM_Positor`,
                `PR_NAM_PR_ID`
            ORDER BY
                `PR_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `PR_NAM_Positor`,
                `PR_NAM_PR_ID`
            ORDER BY
                `PR_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `PR_NAM_Positor`,
            `PR_NAM_PR_ID`,
            `PR_NAM_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `PR_NAM_ID`, `PR_NAM_Positor` ORDER BY `PR_NAM_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `PR_NAM_ID`, `PR_NAM_Positor` ORDER BY `PR_NAM_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `PR_NAM_ID`,
                `PR_NAM_Positor`,
                `PR_NAM_PR_ID`,
                `PR_NAM_PositedAt`,
                IF(`PR_NAM_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `PR_NAM_Assertion`
                    WHEN '+' THEN `PR_NAM_Reliability`
                    WHEN '-' THEN 1 + `PR_NAM_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`PR_NAM_Program_Name`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `PR_NAM_Positor`,
    `PR_NAM_PR_ID`,
    `PR_NAM_PositedAt`,
    asserted
;
-- PR_LEN_Program_Length_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_LEN_ID` AS `PR_LEN_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Posit`
GROUP BY
    `PR_LEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`,
        `PR_LEN_Program_Length` AS `PR_LEN_Program_Length`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Posit`
GROUP BY
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_Program_Length`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'no row in PR_Program for PR_LEN_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_LEN_PR_ID` AS `PR_LEN_PR_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_LEN_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_LEN_PR_ID`
;
-- PR_LEN_Program_Length_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Program_Length_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_ID` AS `PR_LEN_ID`,
        `PR_LEN_Positor` AS `PR_LEN_Positor`,
        `PR_LEN_PositedAt` AS `PR_LEN_PositedAt`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Annex`
GROUP BY
    `PR_LEN_ID`,
    `PR_LEN_Positor`,
    `PR_LEN_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Annex',
    'no row in PR_LEN_Program_Length_Posit for PR_LEN_ID',
    TO_JSON_STRING(STRUCT(c.`PR_LEN_ID` AS `PR_LEN_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Annex` c
LEFT JOIN
    public.`PR_LEN_Program_Length_Posit` p
ON
    p.`PR_LEN_ID` = c.`PR_LEN_ID`
WHERE
    p.`PR_LEN_ID` IS NULL
GROUP BY
    c.`PR_LEN_ID`
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_LEN_Program_Length',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_Assertion` AS `PR_LEN_Assertion`,
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`,
        `PR_LEN_PositedAt` AS `PR_LEN_PositedAt`,
        `PR_LEN_Positor` AS `PR_LEN_Positor`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length`
GROUP BY
    `PR_LEN_Assertion`,
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same entity and changing time: a posit is asserted from its annex row until the
-- next annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'PR_LEN_Program_Length',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_Positor` AS `PR_LEN_Positor`,
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`,
        `PR_LEN_PositedAt` AS `PR_LEN_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `PR_LEN_Positor`,
        `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt`,
        `PR_LEN_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `PR_LEN_Positor`,
                `PR_LEN_PR_ID`,
                `PR_LEN_ChangedAt`
            ORDER BY
                `PR_LEN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `PR_LEN_Positor`,
                `PR_LEN_PR_ID`,
                `PR_LEN_ChangedAt`
            ORDER BY
                `PR_LEN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `PR_LEN_Positor`,
            `PR_LEN_PR_ID`,
            `PR_LEN_ChangedAt`,
            `PR_LEN_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `PR_LEN_ID`, `PR_LEN_Positor` ORDER BY `PR_LEN_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `PR_LEN_ID`, `PR_LEN_Positor` ORDER BY `PR_LEN_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `PR_LEN_ID`,
                `PR_LEN_Positor`,
                `PR_LEN_PR_ID`,
                `PR_LEN_ChangedAt`,
                `PR_LEN_PositedAt`,
                IF(`PR_LEN_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `PR_LEN_Assertion`
                    WHEN '+' THEN `PR_LEN_Reliability`
                    WHEN '-' THEN 1 + `PR_LEN_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`PR_LEN_Program_Length`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `PR_LEN_Positor`,
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_PositedAt`,
    asserted
;
-- AC_partner_AC_with_ONG_currently_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_partner_AC_with_ONG_currently_ID` AS `AC_partner_AC_with_ONG_currently_ID`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_partner_AC_with_ONG_currently_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_partner)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_ID_partner`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_with)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_with` AS `AC_ID_with`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_ID_with`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_partner',
    TO_JSON_STRING(STRUCT(c.`AC_ID_partner` AS `AC_ID_partner`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_partner`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_partner`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_with',
    TO_JSON_STRING(STRUCT(c.`AC_ID_with` AS `AC_ID_with`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_with`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_with`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in ONG_Ongoing for ONG_ID_currently',
    TO_JSON_STRING(STRUCT(c.`ONG_ID_currently` AS `ONG_ID_currently`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` c
LEFT JOIN
    public.`ONG_Ongoing` p
ON
    p.`ONG_ID` = c.`ONG_ID_currently`
WHERE
    p.`ONG_ID` IS NULL
GROUP BY
    c.`ONG_ID_currently`
;
-- AC_partner_AC_with_ONG_currently_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_partner_AC_with_ONG_currently_ID` AS `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_Positor` AS `AC_partner_AC_with_ONG_currently_Positor`,
        `AC_partner_AC_with_ONG_currently_PositedAt` AS `AC_partner_AC_with_ONG_currently_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex`
GROUP BY
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_Positor`,
    `AC_partner_AC_with_ONG_currently_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'no row in AC_partner_AC_with_ONG_currently_Posit for AC_partner_AC_with_ONG_currently_ID',
    TO_JSON_STRING(STRUCT(c.`AC_partner_AC_with_ONG_currently_ID` AS `AC_partner_AC_with_ONG_currently_ID`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex` c
LEFT JOIN
    public.`AC_partner_AC_with_ONG_currently_Posit` p
ON
    p.`AC_partner_AC_with_ONG_currently_ID` = c.`AC_partner_AC_with_ONG_currently_ID`
WHERE
    p.`AC_partner_AC_with_ONG_currently_ID` IS NULL
GROUP BY
    c.`AC_partner_AC_with_ONG_currently_ID`
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_partner_AC_with_ONG_currently',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_partner_AC_with_ONG_currently_Assertion` AS `AC_partner_AC_with_ONG_currently_Assertion`,
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`,
        `AC_partner_AC_with_ONG_currently_PositedAt` AS `AC_partner_AC_with_ONG_currently_PositedAt`,
        `AC_partner_AC_with_ONG_currently_Positor` AS `AC_partner_AC_with_ONG_currently_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_partner_AC_with_ONG_currently_Assertion`,
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    `AC_partner_AC_with_ONG_currently_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'AC_partner_AC_with_ONG_currently',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_partner_AC_with_ONG_currently_Positor` AS `AC_partner_AC_with_ONG_currently_Positor`,
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`,
        `AC_partner_AC_with_ONG_currently_PositedAt` AS `AC_partner_AC_with_ONG_currently_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_partner_AC_with_ONG_currently_Positor`,
        `AC_ID_partner`,
        `AC_ID_with`,
        `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt`,
        `AC_partner_AC_with_ONG_currently_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_partner_AC_with_ONG_currently_Positor`,
                `AC_ID_partner`,
                `AC_ID_with`,
                `ONG_ID_currently`,
                `AC_partner_AC_with_ONG_currently_ChangedAt`
            ORDER BY
                `AC_partner_AC_with_ONG_currently_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_partner_AC_with_ONG_currently_Positor`,
                `AC_ID_partner`,
                `AC_ID_with`,
                `ONG_ID_currently`,
                `AC_partner_AC_with_ONG_currently_ChangedAt`
            ORDER BY
                `AC_partner_AC_with_ONG_currently_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_partner_AC_with_ONG_currently_Positor`,
            `AC_ID_partner`,
            `AC_ID_with`,
            `ONG_ID_currently`,
            `AC_partner_AC_with_ONG_currently_ChangedAt`,
            `AC_partner_AC_with_ONG_currently_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_Positor` ORDER BY `AC_partner_AC_with_ONG_currently_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_Positor` ORDER BY `AC_partner_AC_with_ONG_currently_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_partner_AC_with_ONG_currently_ID`,
                `AC_partner_AC_with_ONG_currently_Positor`,
                `AC_ID_partner`,
                `AC_ID_with`,
                `ONG_ID_currently`,
                `AC_partner_AC_with_ONG_currently_ChangedAt`,
                `AC_partner_AC_with_ONG_currently_PositedAt`,
                IF(`AC_partner_AC_with_ONG_currently_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_partner_AC_with_ONG_currently_Assertion`
                    WHEN '+' THEN `AC_partner_AC_with_ONG_currently_Reliability`
                    WHEN '-' THEN 1 + `AC_partner_AC_with_ONG_currently_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_partner_AC_with_ONG_currently`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_partner_AC_with_ONG_currently_Positor`,
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    asserted
;
-- AC_subset_PN_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_subset_PN_of_ID` AS `AC_subset_PN_of_ID`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `AC_subset_PN_of_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `AC_ID_subset`,
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (AC_subset)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `AC_ID_subset`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (PN_of)',
    TO_JSON_STRING(STRUCT(
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in AC_Actor for AC_ID_subset',
    TO_JSON_STRING(STRUCT(c.`AC_ID_subset` AS `AC_ID_subset`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_subset`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_subset`
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in PN_Person for PN_ID_of',
    TO_JSON_STRING(STRUCT(c.`PN_ID_of` AS `PN_ID_of`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit` c
LEFT JOIN
    public.`PN_Person` p
ON
    p.`PN_ID` = c.`PN_ID_of`
WHERE
    p.`PN_ID` IS NULL
GROUP BY
    c.`PN_ID_of`
;
-- AC_subset_PN_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_subset_PN_of_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_subset_PN_of_ID` AS `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_Positor` AS `AC_subset_PN_of_Positor`,
        `AC_subset_PN_of_PositedAt` AS `AC_subset_PN_of_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Annex`
GROUP BY
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_Positor`,
    `AC_subset_PN_of_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Annex',
    'no row in AC_subset_PN_of_Posit for AC_subset_PN_of_ID',
    TO_JSON_STRING(STRUCT(c.`AC_subset_PN_of_ID` AS `AC_subset_PN_of_ID`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Annex` c
LEFT JOIN
    public.`AC_subset_PN_of_Posit` p
ON
    p.`AC_subset_PN_of_ID` = c.`AC_subset_PN_of_ID`
WHERE
    p.`AC_subset_PN_of_ID` IS NULL
GROUP BY
    c.`AC_subset_PN_of_ID`
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_subset_PN_of',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_subset_PN_of_Assertion` AS `AC_subset_PN_of_Assertion`,
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`,
        `AC_subset_PN_of_PositedAt` AS `AC_subset_PN_of_PositedAt`,
        `AC_subset_PN_of_Positor` AS `AC_subset_PN_of_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of`
GROUP BY
    `AC_subset_PN_of_Assertion`,
    `AC_ID_subset`,
    `PN_ID_of`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'AC_subset_PN_of',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_subset_PN_of_Positor` AS `AC_subset_PN_of_Positor`,
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`,
        `AC_subset_PN_of_PositedAt` AS `AC_subset_PN_of_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_subset_PN_of_Positor`,
        `AC_ID_subset`,
        `PN_ID_of`,
        `AC_subset_PN_of_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_subset_PN_of_Positor`,
                `AC_ID_subset`,
                `PN_ID_of`
            ORDER BY
                `AC_subset_PN_of_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_subset_PN_of_Positor`,
                `AC_ID_subset`,
                `PN_ID_of`
            ORDER BY
                `AC_subset_PN_of_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_subset_PN_of_Positor`,
            `AC_ID_subset`,
            `PN_ID_of`,
            `AC_subset_PN_of_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_Positor` ORDER BY `AC_subset_PN_of_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_Positor` ORDER BY `AC_subset_PN_of_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_subset_PN_of_ID`,
                `AC_subset_PN_of_Positor`,
                `AC_ID_subset`,
                `PN_ID_of`,
                `AC_subset_PN_of_PositedAt`,
                IF(`AC_subset_PN_of_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_subset_PN_of_Assertion`
                    WHEN '+' THEN `AC_subset_PN_of_Reliability`
                    WHEN '-' THEN 1 + `AC_subset_PN_of_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_subset_PN_of`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_subset_PN_of_Positor`,
    `AC_ID_subset`,
    `PN_ID_of`,
    `AC_subset_PN_of_PositedAt`,
    asserted
;
-- EV_in_AC_wasCast_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_in_AC_wasCast_ID` AS `EV_in_AC_wasCast_ID`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit`
GROUP BY
    `EV_in_AC_wasCast_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit`
GROUP BY
    `EV_ID_in`,
    `AC_ID_wasCast`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in EV_Event for EV_ID_in',
    TO_JSON_STRING(STRUCT(c.`EV_ID_in` AS `EV_ID_in`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_in`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_in`
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in AC_Actor for AC_ID_wasCast',
    TO_JSON_STRING(STRUCT(c.`AC_ID_wasCast` AS `AC_ID_wasCast`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_wasCast`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_wasCast`
;
-- EV_in_AC_wasCast_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_wasCast_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_in_AC_wasCast_ID` AS `EV_in_AC_wasCast_ID`,
        `EV_in_AC_wasCast_Positor` AS `EV_in_AC_wasCast_Positor`,
        `EV_in_AC_wasCast_PositedAt` AS `EV_in_AC_wasCast_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Annex`
GROUP BY
    `EV_in_AC_wasCast_ID`,
    `EV_in_AC_wasCast_Positor`,
    `EV_in_AC_wasCast_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Annex',
    'no row in EV_in_AC_wasCast_Posit for EV_in_AC_wasCast_ID',
    TO_JSON_STRING(STRUCT(c.`EV_in_AC_wasCast_ID` AS `EV_in_AC_wasCast_ID`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Annex` c
LEFT JOIN
    public.`EV_in_AC_wasCast_Posit` p
ON
    p.`EV_in_AC_wasCast_ID` = c.`EV_in_AC_wasCast_ID`
WHERE
    p.`EV_in_AC_wasCast_ID` IS NULL
GROUP BY
    c.`EV_in_AC_wasCast_ID`
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_in_AC_wasCast',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_in_AC_wasCast_Assertion` AS `EV_in_AC_wasCast_Assertion`,
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`,
        `EV_in_AC_wasCast_PositedAt` AS `EV_in_AC_wasCast_PositedAt`,
        `EV_in_AC_wasCast_Positor` AS `EV_in_AC_wasCast_Positor`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast`
GROUP BY
    `EV_in_AC_wasCast_Assertion`,
    `EV_ID_in`,
    `AC_ID_wasCast`,
    `EV_in_AC_wasCast_PositedAt`,
    `EV_in_AC_wasCast_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'EV_in_AC_wasCast',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `EV_in_AC_wasCast_Positor` AS `EV_in_AC_wasCast_Positor`,
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`,
        `EV_in_AC_wasCast_PositedAt` AS `EV_in_AC_wasCast_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_in_AC_wasCast_Positor`,
        `EV_ID_in`,
        `AC_ID_wasCast`,
        `EV_in_AC_wasCast_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_in_AC_wasCast_Positor`,
                `EV_ID_in`,
                `AC_ID_wasCast`
            ORDER BY
                `EV_in_AC_wasCast_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `EV_in_AC_wasCast_Positor`,
                `EV_ID_in`,
                `AC_ID_wasCast`
            ORDER BY
                `EV_in_AC_wasCast_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `EV_in_AC_wasCast_Positor`,
            `EV_ID_in`,
            `AC_ID_wasCast`,
            `EV_in_AC_wasCast_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_in_AC_wasCast_ID`, `EV_in_AC_wasCast_Positor` ORDER BY `EV_in_AC_wasCast_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `EV_in_AC_wasCast_ID`, `EV_in_AC_wasCast_Positor` ORDER BY `EV_in_AC_wasCast_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `EV_in_AC_wasCast_ID`,
                `EV_in_AC_wasCast_Positor`,
                `EV_ID_in`,
                `AC_ID_wasCast`,
                `EV_in_AC_wasCast_PositedAt`,
                IF(`EV_in_AC_wasCast_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `EV_in_AC_wasCast_Assertion`
                    WHEN '+' THEN `EV_in_AC_wasCast_Reliability`
                    WHEN '-' THEN 1 + `EV_in_AC_wasCast_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`EV_in_AC_wasCast`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_in_AC_wasCast_Positor`,
    `EV_ID_in`,
    `AC_ID_wasCast`,
    `EV_in_AC_wasCast_PositedAt`,
    asserted
;
-- AC_part_PR_in_RAT_got_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_part_PR_in_RAT_got_ID` AS `AC_part_PR_in_RAT_got_ID`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit`
GROUP BY
    `AC_part_PR_in_RAT_got_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `RAT_ID_got` AS `RAT_ID_got`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit`
GROUP BY
    `AC_ID_part`,
    `PR_ID_in`,
    `RAT_ID_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in AC_Actor for AC_ID_part',
    TO_JSON_STRING(STRUCT(c.`AC_ID_part` AS `AC_ID_part`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_part`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_part`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in PR_Program for PR_ID_in',
    TO_JSON_STRING(STRUCT(c.`PR_ID_in` AS `PR_ID_in`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_in`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_in`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in RAT_Rating for RAT_ID_got',
    TO_JSON_STRING(STRUCT(c.`RAT_ID_got` AS `RAT_ID_got`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit` c
LEFT JOIN
    public.`RAT_Rating` p
ON
    p.`RAT_ID` = c.`RAT_ID_got`
WHERE
    p.`RAT_ID` IS NULL
GROUP BY
    c.`RAT_ID_got`
;
-- AC_part_PR_in_RAT_got_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_part_PR_in_RAT_got_ID` AS `AC_part_PR_in_RAT_got_ID`,
        `AC_part_PR_in_RAT_got_Positor` AS `AC_part_PR_in_RAT_got_Positor`,
        `AC_part_PR_in_RAT_got_PositedAt` AS `AC_part_PR_in_RAT_got_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Annex`
GROUP BY
    `AC_part_PR_in_RAT_got_ID`,
    `AC_part_PR_in_RAT_got_Positor`,
    `AC_part_PR_in_RAT_got_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'no row in AC_part_PR_in_RAT_got_Posit for AC_part_PR_in_RAT_got_ID',
    TO_JSON_STRING(STRUCT(c.`AC_part_PR_in_RAT_got_ID` AS `AC_part_PR_in_RAT_got_ID`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Annex` c
LEFT JOIN
    public.`AC_part_PR_in_RAT_got_Posit` p
ON
    p.`AC_part_PR_in_RAT_got_ID` = c.`AC_part_PR_in_RAT_got_ID`
WHERE
    p.`AC_part_PR_in_RAT_got_ID` IS NULL
GROUP BY
    c.`AC_part_PR_in_RAT_got_ID`
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_part_PR_in_RAT_got',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_part_PR_in_RAT_got_Assertion` AS `AC_part_PR_in_RAT_got_Assertion`,
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`,
        `AC_part_PR_in_RAT_got_PositedAt` AS `AC_part_PR_in_RAT_got_PositedAt`,
        `AC_part_PR_in_RAT_got_Positor` AS `AC_part_PR_in_RAT_got_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got`
GROUP BY
    `AC_part_PR_in_RAT_got_Assertion`,
    `AC_ID_part`,
    `PR_ID_in`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    `AC_part_PR_in_RAT_got_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'AC_part_PR_in_RAT_got',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_part_PR_in_RAT_got_Positor` AS `AC_part_PR_in_RAT_got_Positor`,
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`,
        `AC_part_PR_in_RAT_got_PositedAt` AS `AC_part_PR_in_RAT_got_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_part_PR_in_RAT_got_Positor`,
        `AC_ID_part`,
        `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt`,
        `AC_part_PR_in_RAT_got_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_part_PR_in_RAT_got_Positor`,
                `AC_ID_part`,
                `PR_ID_in`,
                `AC_part_PR_in_RAT_got_ChangedAt`
            ORDER BY
                `AC_part_PR_in_RAT_got_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_part_PR_in_RAT_got_Positor`,
                `AC_ID_part`,
                `PR_ID_in`,
                `AC_part_PR_in_RAT_got_ChangedAt`
            ORDER BY
                `AC_part_PR_in_RAT_got_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_part_PR_in_RAT_got_Positor`,
            `AC_ID_part`,
            `PR_ID_in`,
            `AC_part_PR_in_RAT_got_ChangedAt`,
            `AC_part_PR_in_RAT_got_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_part_PR_in_RAT_got_ID`, `AC_part_PR_in_RAT_got_Positor` ORDER BY `AC_part_PR_in_RAT_got_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_part_PR_in_RAT_got_ID`, `AC_part_PR_in_RAT_got_Positor` ORDER BY `AC_part_PR_in_RAT_got_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_part_PR_in_RAT_got_ID`,
                `AC_part_PR_in_RAT_got_Positor`,
                `AC_ID_part`,
                `PR_ID_in`,
                `AC_part_PR_in_RAT_got_ChangedAt`,
                `AC_part_PR_in_RAT_got_PositedAt`,
                IF(`AC_part_PR_in_RAT_got_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_part_PR_in_RAT_got_Assertion`
                    WHEN '+' THEN `AC_part_PR_in_RAT_got_Reliability`
                    WHEN '-' THEN 1 + `AC_part_PR_in_RAT_got_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_part_PR_in_RAT_got`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_part_PR_in_RAT_got_Positor`,
    `AC_ID_part`,
    `PR_ID_in`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    asserted
;
-- ST_at_PR_isPlaying_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_at_PR_isPlaying_ID` AS `ST_at_PR_isPlaying_ID`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit`
GROUP BY
    `ST_at_PR_isPlaying_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit`
GROUP BY
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in ST_Stage for ST_ID_at',
    TO_JSON_STRING(STRUCT(c.`ST_ID_at` AS `ST_ID_at`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_at`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_at`
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in PR_Program for PR_ID_isPlaying',
    TO_JSON_STRING(STRUCT(c.`PR_ID_isPlaying` AS `PR_ID_isPlaying`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_isPlaying`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_isPlaying`
;
-- ST_at_PR_isPlaying_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_isPlaying_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_at_PR_isPlaying_ID` AS `ST_at_PR_isPlaying_ID`,
        `ST_at_PR_isPlaying_Positor` AS `ST_at_PR_isPlaying_Positor`,
        `ST_at_PR_isPlaying_PositedAt` AS `ST_at_PR_isPlaying_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Annex`
GROUP BY
    `ST_at_PR_isPlaying_ID`,
    `ST_at_PR_isPlaying_Positor`,
    `ST_at_PR_isPlaying_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Annex',
    'no row in ST_at_PR_isPlaying_Posit for ST_at_PR_isPlaying_ID',
    TO_JSON_STRING(STRUCT(c.`ST_at_PR_isPlaying_ID` AS `ST_at_PR_isPlaying_ID`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Annex` c
LEFT JOIN
    public.`ST_at_PR_isPlaying_Posit` p
ON
    p.`ST_at_PR_isPlaying_ID` = c.`ST_at_PR_isPlaying_ID`
WHERE
    p.`ST_at_PR_isPlaying_ID` IS NULL
GROUP BY
    c.`ST_at_PR_isPlaying_ID`
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_at_PR_isPlaying',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_at_PR_isPlaying_Assertion` AS `ST_at_PR_isPlaying_Assertion`,
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`,
        `ST_at_PR_isPlaying_PositedAt` AS `ST_at_PR_isPlaying_PositedAt`,
        `ST_at_PR_isPlaying_Positor` AS `ST_at_PR_isPlaying_Positor`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying`
GROUP BY
    `ST_at_PR_isPlaying_Assertion`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_at_PR_isPlaying_PositedAt`,
    `ST_at_PR_isPlaying_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'ST_at_PR_isPlaying',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `ST_at_PR_isPlaying_Positor` AS `ST_at_PR_isPlaying_Positor`,
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`,
        `ST_at_PR_isPlaying_PositedAt` AS `ST_at_PR_isPlaying_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_at_PR_isPlaying_Positor`,
        `ST_ID_at`,
        `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt`,
        `ST_at_PR_isPlaying_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_at_PR_isPlaying_Positor`,
                `ST_ID_at`,
                `PR_ID_isPlaying`,
                `ST_at_PR_isPlaying_ChangedAt`
            ORDER BY
                `ST_at_PR_isPlaying_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `ST_at_PR_isPlaying_Positor`,
                `ST_ID_at`,
                `PR_ID_isPlaying`,
                `ST_at_PR_isPlaying_ChangedAt`
            ORDER BY
                `ST_at_PR_isPlaying_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `ST_at_PR_isPlaying_Positor`,
            `ST_ID_at`,
            `PR_ID_isPlaying`,
            `ST_at_PR_isPlaying_ChangedAt`,
            `ST_at_PR_isPlaying_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_at_PR_isPlaying_ID`, `ST_at_PR_isPlaying_Positor` ORDER BY `ST_at_PR_isPlaying_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `ST_at_PR_isPlaying_ID`, `ST_at_PR_isPlaying_Positor` ORDER BY `ST_at_PR_isPlaying_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `ST_at_PR_isPlaying_ID`,
                `ST_at_PR_isPlaying_Positor`,
                `ST_ID_at`,
                `PR_ID_isPlaying`,
                `ST_at_PR_isPlaying_ChangedAt`,
                `ST_at_PR_isPlaying_PositedAt`,
                IF(`ST_at_PR_isPlaying_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `ST_at_PR_isPlaying_Assertion`
                    WHEN '+' THEN `ST_at_PR_isPlaying_Reliability`
                    WHEN '-' THEN 1 + `ST_at_PR_isPlaying_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`ST_at_PR_isPlaying`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_at_PR_isPlaying_Positor`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_at_PR_isPlaying_PositedAt`,
    asserted
;
-- AC_parent_AC_child_PAT_having_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_parent_AC_child_PAT_having_ID` AS `AC_parent_AC_child_PAT_having_ID`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit`
GROUP BY
    `AC_parent_AC_child_PAT_having_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit`
GROUP BY
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_parent',
    TO_JSON_STRING(STRUCT(c.`AC_ID_parent` AS `AC_ID_parent`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_parent`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_parent`
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_child',
    TO_JSON_STRING(STRUCT(c.`AC_ID_child` AS `AC_ID_child`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_child`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_child`
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in PAT_ParentalType for PAT_ID_having',
    TO_JSON_STRING(STRUCT(c.`PAT_ID_having` AS `PAT_ID_having`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` c
LEFT JOIN
    public.`PAT_ParentalType` p
ON
    p.`PAT_ID` = c.`PAT_ID_having`
WHERE
    p.`PAT_ID` IS NULL
GROUP BY
    c.`PAT_ID_having`
;
-- AC_parent_AC_child_PAT_having_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_parent_AC_child_PAT_having_ID` AS `AC_parent_AC_child_PAT_having_ID`,
        `AC_parent_AC_child_PAT_having_Positor` AS `AC_parent_AC_child_PAT_having_Positor`,
        `AC_parent_AC_child_PAT_having_PositedAt` AS `AC_parent_AC_child_PAT_having_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Annex`
GROUP BY
    `AC_parent_AC_child_PAT_having_ID`,
    `AC_parent_AC_child_PAT_having_Positor`,
    `AC_parent_AC_child_PAT_having_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'no row in AC_parent_AC_child_PAT_having_Posit for AC_parent_AC_child_PAT_having_ID',
    TO_JSON_STRING(STRUCT(c.`AC_parent_AC_child_PAT_having_ID` AS `AC_parent_AC_child_PAT_having_ID`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Annex` c
LEFT JOIN
    public.`AC_parent_AC_child_PAT_having_Posit` p
ON
    p.`AC_parent_AC_child_PAT_having_ID` = c.`AC_parent_AC_child_PAT_having_ID`
WHERE
    p.`AC_parent_AC_child_PAT_having_ID` IS NULL
GROUP BY
    c.`AC_parent_AC_child_PAT_having_ID`
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_parent_AC_child_PAT_having',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_parent_AC_child_PAT_having_Assertion` AS `AC_parent_AC_child_PAT_having_Assertion`,
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`,
        `AC_parent_AC_child_PAT_having_PositedAt` AS `AC_parent_AC_child_PAT_having_PositedAt`,
        `AC_parent_AC_child_PAT_having_Positor` AS `AC_parent_AC_child_PAT_having_Positor`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having`
GROUP BY
    `AC_parent_AC_child_PAT_having_Assertion`,
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    `AC_parent_AC_child_PAT_having_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'AC_parent_AC_child_PAT_having',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `AC_parent_AC_child_PAT_having_Positor` AS `AC_parent_AC_child_PAT_having_Positor`,
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`,
        `AC_parent_AC_child_PAT_having_PositedAt` AS `AC_parent_AC_child_PAT_having_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_parent_AC_child_PAT_having_Positor`,
        `AC_ID_parent`,
        `AC_ID_child`,
        `PAT_ID_having`,
        `AC_parent_AC_child_PAT_having_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_parent_AC_child_PAT_having_Positor`,
                `AC_ID_parent`,
                `AC_ID_child`,
                `PAT_ID_having`
            ORDER BY
                `AC_parent_AC_child_PAT_having_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `AC_parent_AC_child_PAT_having_Positor`,
                `AC_ID_parent`,
                `AC_ID_child`,
                `PAT_ID_having`
            ORDER BY
                `AC_parent_AC_child_PAT_having_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `AC_parent_AC_child_PAT_having_Positor`,
            `AC_ID_parent`,
            `AC_ID_child`,
            `PAT_ID_having`,
            `AC_parent_AC_child_PAT_having_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_parent_AC_child_PAT_having_ID`, `AC_parent_AC_child_PAT_having_Positor` ORDER BY `AC_parent_AC_child_PAT_having_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `AC_parent_AC_child_PAT_having_ID`, `AC_parent_AC_child_PAT_having_Positor` ORDER BY `AC_parent_AC_child_PAT_having_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `AC_parent_AC_child_PAT_having_ID`,
                `AC_parent_AC_child_PAT_having_Positor`,
                `AC_ID_parent`,
                `AC_ID_child`,
                `PAT_ID_having`,
                `AC_parent_AC_child_PAT_having_PositedAt`,
                IF(`AC_parent_AC_child_PAT_having_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `AC_parent_AC_child_PAT_having_Assertion`
                    WHEN '+' THEN `AC_parent_AC_child_PAT_having_Reliability`
                    WHEN '-' THEN 1 + `AC_parent_AC_child_PAT_having_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`AC_parent_AC_child_PAT_having`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_parent_AC_child_PAT_having_Positor`,
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    asserted
;
-- PR_content_ST_location_EV_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_content_ST_location_EV_of_ID` AS `PR_content_ST_location_EV_of_ID`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit`
GROUP BY
    `PR_content_ST_location_EV_of_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `PR_ID_content` AS `PR_ID_content`,
        `ST_ID_location` AS `ST_ID_location`,
        `EV_ID_of` AS `EV_ID_of`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit`
GROUP BY
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in PR_Program for PR_ID_content',
    TO_JSON_STRING(STRUCT(c.`PR_ID_content` AS `PR_ID_content`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_content`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_content`
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in ST_Stage for ST_ID_location',
    TO_JSON_STRING(STRUCT(c.`ST_ID_location` AS `ST_ID_location`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_location`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_location`
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in EV_Event for EV_ID_of',
    TO_JSON_STRING(STRUCT(c.`EV_ID_of` AS `EV_ID_of`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_of`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_of`
;
-- PR_content_ST_location_EV_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_content_ST_location_EV_of_ID` AS `PR_content_ST_location_EV_of_ID`,
        `PR_content_ST_location_EV_of_Positor` AS `PR_content_ST_location_EV_of_Positor`,
        `PR_content_ST_location_EV_of_PositedAt` AS `PR_content_ST_location_EV_of_PositedAt`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Annex`
GROUP BY
    `PR_content_ST_location_EV_of_ID`,
    `PR_content_ST_location_EV_of_Positor`,
    `PR_content_ST_location_EV_of_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'no row in PR_content_ST_location_EV_of_Posit for PR_content_ST_location_EV_of_ID',
    TO_JSON_STRING(STRUCT(c.`PR_content_ST_location_EV_of_ID` AS `PR_content_ST_location_EV_of_ID`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Annex` c
LEFT JOIN
    public.`PR_content_ST_location_EV_of_Posit` p
ON
    p.`PR_content_ST_location_EV_of_ID` = c.`PR_content_ST_location_EV_of_ID`
WHERE
    p.`PR_content_ST_location_EV_of_ID` IS NULL
GROUP BY
    c.`PR_content_ST_location_EV_of_ID`
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_content_ST_location_EV_of',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `PR_content_ST_location_EV_of_Assertion` AS `PR_content_ST_location_EV_of_Assertion`,
        `EV_ID_of` AS `EV_ID_of`,
        `PR_content_ST_location_EV_of_PositedAt` AS `PR_content_ST_location_EV_of_PositedAt`,
        `PR_content_ST_location_EV_of_Positor` AS `PR_content_ST_location_EV_of_Positor`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of`
GROUP BY
    `PR_content_ST_location_EV_of_Assertion`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_PositedAt`,
    `PR_content_ST_location_EV_of_Positor`
HAVING
    COUNT(*) > 1
UNION ALL
-- what a positor asserts at one time for the same identifiers (all the roles, if there are none) and changing time: a posit
-- is asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the
-- running sum of the changes up to it
SELECT
    'PR_content_ST_location_EV_of',
    'more than one assertion at a time',
    TO_JSON_STRING(STRUCT(
        `PR_content_ST_location_EV_of_Positor` AS `PR_content_ST_location_EV_of_Positor`,
        `EV_ID_of` AS `EV_ID_of`,
        `PR_content_ST_location_EV_of_PositedAt` AS `PR_content_ST_location_EV_of_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `PR_content_ST_location_EV_of_Positor`,
        `EV_ID_of`,
        `PR_content_ST_location_EV_of_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `PR_content_ST_location_EV_of_Positor`,
                `EV_ID_of`
            ORDER BY
                `PR_content_ST_location_EV_of_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted,
        SUM(weight_change) OVER (
            PARTITION BY
                `PR_content_ST_location_EV_of_Positor`,
                `EV_ID_of`
            ORDER BY
                `PR_content_ST_location_EV_of_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS weight
    FROM (
        SELECT
            `PR_content_ST_location_EV_of_Positor`,
            `EV_ID_of`,
            `PR_content_ST_location_EV_of_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `PR_content_ST_location_EV_of_ID`, `PR_content_ST_location_EV_of_Positor` ORDER BY `PR_content_ST_location_EV_of_PositedAt`
            ), 0) AS asserted_change,
            weight_of - COALESCE(LAG(weight_of) OVER (
                PARTITION BY `PR_content_ST_location_EV_of_ID`, `PR_content_ST_location_EV_of_Positor` ORDER BY `PR_content_ST_location_EV_of_PositedAt`
            ), 0) AS weight_change
        FROM (
            SELECT
                `PR_content_ST_location_EV_of_ID`,
                `PR_content_ST_location_EV_of_Positor`,
                `EV_ID_of`,
                `PR_content_ST_location_EV_of_PositedAt`,
                IF(`PR_content_ST_location_EV_of_Assertion` <> '?', 1, 0) AS is_asserted,
                CASE `PR_content_ST_location_EV_of_Assertion`
                    WHEN '+' THEN `PR_content_ST_location_EV_of_Reliability`
                    WHEN '-' THEN 1 + `PR_content_ST_location_EV_of_Reliability`
                    ELSE 0
                END AS weight_of
            FROM
                public.`PR_content_ST_location_EV_of`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `PR_content_ST_location_EV_of_Positor`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_PositedAt`,
    asserted
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
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM public.`ic_PAT_ParentalType`
UNION ALL SELECT * FROM public.`ic_GEN_Gender`
UNION ALL SELECT * FROM public.`ic_PLV_ProfessionalLevel`
UNION ALL SELECT * FROM public.`ic_UTL_Utilization`
UNION ALL SELECT * FROM public.`ic_ONG_Ongoing`
UNION ALL SELECT * FROM public.`ic_RAT_Rating`
UNION ALL SELECT * FROM public.`ic_ETY_EventType`
UNION ALL SELECT * FROM public.`ic_PN_Person`
UNION ALL SELECT * FROM public.`ic_ST_Stage`
UNION ALL SELECT * FROM public.`ic_AC_Actor`
UNION ALL SELECT * FROM public.`ic_PR_Program`
UNION ALL SELECT * FROM public.`ic_EV_Event`
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date_Posit`
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date_Annex`
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience_Posit`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience_Annex`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue_Posit`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue_Annex`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name_Posit`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name_Annex`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location_Posit`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location_Annex`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average_Posit`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average_Annex`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum_Posit`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum_Annex`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name_Posit`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name_Annex`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender_Posit`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender_Annex`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel_Posit`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel_Annex`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name_Posit`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name_Annex`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length_Posit`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length_Annex`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently_Posit`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently_Annex`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of_Posit`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of_Annex`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast_Posit`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast_Annex`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got_Posit`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got_Annex`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying_Posit`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying_Annex`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having_Posit`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having_Annex`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of_Posit`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of_Annex`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of`
UNION ALL SELECT * FROM public.`ic_key_PN_Person_1st`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_1st`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_2nd`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_3rd`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_4th`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_1st`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_2nd`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_3rd`
UNION ALL SELECT * FROM public.`ic_key_PR_Program_1st`
UNION ALL SELECT * FROM public.`ic_key_PR_Program_2nd`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_1st`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_2nd`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_3rd`
;