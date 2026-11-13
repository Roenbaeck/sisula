-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- BigQuery does not enforce primary or foreign keys, and it has no unique constraints. The primary and foreign keys are declared,
-- which tells the optimizer to trust them; a unique key is only a rule of the model. A violation is therefore not an error, but
-- wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--   restatement                                   in an attribute or a tie that may not store them, a value
--                                                 that is the same as the one before it in changing time
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
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Event_Date',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID` AS `EV_ID`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date',
    'no row in EV_Event for EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_ID` AS `EV_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID`
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Event_Audience',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID` AS `EV_ID`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience',
    'no row in EV_Event for EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_ID` AS `EV_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID`
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Event_Revenue',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID` AS `EV_ID`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue',
    'no row in EV_Event for EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_ID` AS `EV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID`
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Stage_Name',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name`
GROUP BY
    `ST_ID`,
    `ST_NAM_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name',
    'no row in ST_Stage for ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID`
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Stage_Location',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location',
    'no row in ST_Stage for ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID`
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Stage_Average',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average`
GROUP BY
    `ST_ID`,
    `ST_AVG_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in ST_Stage for ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID`
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in UTL_Utilization for UTL_ID',
    TO_JSON_STRING(STRUCT(c.`UTL_ID` AS `UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`UTL_ID`
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    1
FROM (
    SELECT
        `ST_ID`,
        `ST_AVG_ChangedAt`,
        `UTL_ID` AS compared,
        LAG(`UTL_ID`) OVER (
            PARTITION BY
                `ST_ID`
            ORDER BY
                `ST_AVG_ChangedAt`
        ) AS previous
    FROM
        public.`ST_AVG_Stage_Average`
)
WHERE
    compared = previous
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Stage_Minimum',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in ST_Stage for ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID`
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in UTL_Utilization for UTL_ID',
    TO_JSON_STRING(STRUCT(c.`UTL_ID` AS `UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`UTL_ID`
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Actor_Name',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name`
GROUP BY
    `AC_ID`,
    `AC_NAM_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'no row in AC_Actor for AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_ID` AS `AC_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID`
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    1
FROM (
    SELECT
        `AC_ID`,
        `AC_NAM_ChangedAt`,
        `AC_NAM_Actor_Name` AS compared,
        LAG(`AC_NAM_Actor_Name`) OVER (
            PARTITION BY
                `AC_ID`
            ORDER BY
                `AC_NAM_ChangedAt`
        ) AS previous
    FROM
        public.`AC_NAM_Actor_Name`
)
WHERE
    compared = previous
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Actor_Gender',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in AC_Actor for AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_ID` AS `AC_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID`
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in GEN_Gender for GEN_ID',
    TO_JSON_STRING(STRUCT(c.`GEN_ID` AS `GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender` c
LEFT JOIN
    public.`GEN_Gender` p
ON
    p.`GEN_ID` = c.`GEN_ID`
WHERE
    p.`GEN_ID` IS NULL
GROUP BY
    c.`GEN_ID`
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel`
GROUP BY
    `AC_ID`,
    `AC_PLV_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in AC_Actor for AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_ID` AS `AC_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID`
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in PLV_ProfessionalLevel for PLV_ID',
    TO_JSON_STRING(STRUCT(c.`PLV_ID` AS `PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel` c
LEFT JOIN
    public.`PLV_ProfessionalLevel` p
ON
    p.`PLV_ID` = c.`PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`PLV_ID`
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Program_Name',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_ID` AS `PR_ID`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name',
    'no row in PR_Program for PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_ID` AS `PR_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID`
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Program_Length',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_ID` AS `PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length`
GROUP BY
    `PR_ID`,
    `PR_LEN_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length',
    'no row in PR_Program for PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_ID` AS `PR_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID`
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_partner)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_partner`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_with)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_with` AS `AC_ID_with`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_with`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_partner',
    TO_JSON_STRING(STRUCT(c.`AC_ID_partner` AS `AC_ID_partner`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently` c
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
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_with',
    TO_JSON_STRING(STRUCT(c.`AC_ID_with` AS `AC_ID_with`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently` c
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
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Ongoing for ONG_ID_currently',
    TO_JSON_STRING(STRUCT(c.`ONG_ID_currently` AS `ONG_ID_currently`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    public.`ONG_Ongoing` p
ON
    p.`ONG_ID` = c.`ONG_ID_currently`
WHERE
    p.`ONG_ID` IS NULL
GROUP BY
    c.`ONG_ID_currently`
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_subset_PN_of',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of`
GROUP BY
    `AC_ID_subset`,
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (AC_subset)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of`
GROUP BY
    `AC_ID_subset`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (PN_of)',
    TO_JSON_STRING(STRUCT(
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of`
GROUP BY
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in AC_Actor for AC_ID_subset',
    TO_JSON_STRING(STRUCT(c.`AC_ID_subset` AS `AC_ID_subset`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of` c
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
    'AC_subset_PN_of',
    'no row in PN_Person for PN_ID_of',
    TO_JSON_STRING(STRUCT(c.`PN_ID_of` AS `PN_ID_of`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of` c
LEFT JOIN
    public.`PN_Person` p
ON
    p.`PN_ID` = c.`PN_ID_of`
WHERE
    p.`PN_ID` IS NULL
GROUP BY
    c.`PN_ID_of`
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_wasCast',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast`
GROUP BY
    `EV_ID_in`,
    `AC_ID_wasCast`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast',
    'no row in EV_Event for EV_ID_in',
    TO_JSON_STRING(STRUCT(c.`EV_ID_in` AS `EV_ID_in`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast` c
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
    'EV_in_AC_wasCast',
    'no row in AC_Actor for AC_ID_wasCast',
    TO_JSON_STRING(STRUCT(c.`AC_ID_wasCast` AS `AC_ID_wasCast`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_wasCast`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_wasCast`
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_part_PR_in_RAT_got',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got`
GROUP BY
    `AC_ID_part`,
    `PR_ID_in`,
    `AC_part_PR_in_RAT_got_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in AC_Actor for AC_ID_part',
    TO_JSON_STRING(STRUCT(c.`AC_ID_part` AS `AC_ID_part`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got` c
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
    'AC_part_PR_in_RAT_got',
    'no row in PR_Program for PR_ID_in',
    TO_JSON_STRING(STRUCT(c.`PR_ID_in` AS `PR_ID_in`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got` c
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
    'AC_part_PR_in_RAT_got',
    'no row in RAT_Rating for RAT_ID_got',
    TO_JSON_STRING(STRUCT(c.`RAT_ID_got` AS `RAT_ID_got`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got` c
LEFT JOIN
    public.`RAT_Rating` p
ON
    p.`RAT_ID` = c.`RAT_ID_got`
WHERE
    p.`RAT_ID` IS NULL
GROUP BY
    c.`RAT_ID_got`
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_isPlaying',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying`
GROUP BY
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying',
    'no row in ST_Stage for ST_ID_at',
    TO_JSON_STRING(STRUCT(c.`ST_ID_at` AS `ST_ID_at`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying` c
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
    'ST_at_PR_isPlaying',
    'no row in PR_Program for PR_ID_isPlaying',
    TO_JSON_STRING(STRUCT(c.`PR_ID_isPlaying` AS `PR_ID_isPlaying`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_isPlaying`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_isPlaying`
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_parent_AC_child_PAT_having',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having`
GROUP BY
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_parent',
    TO_JSON_STRING(STRUCT(c.`AC_ID_parent` AS `AC_ID_parent`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having` c
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
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_child',
    TO_JSON_STRING(STRUCT(c.`AC_ID_child` AS `AC_ID_child`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having` c
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
    'AC_parent_AC_child_PAT_having',
    'no row in PAT_ParentalType for PAT_ID_having',
    TO_JSON_STRING(STRUCT(c.`PAT_ID_having` AS `PAT_ID_having`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having` c
LEFT JOIN
    public.`PAT_ParentalType` p
ON
    p.`PAT_ID` = c.`PAT_ID_having`
WHERE
    p.`PAT_ID` IS NULL
GROUP BY
    c.`PAT_ID_having`
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_content_ST_location_EV_of',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID_of` AS `EV_ID_of`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of`
GROUP BY
    `EV_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in PR_Program for PR_ID_content',
    TO_JSON_STRING(STRUCT(c.`PR_ID_content` AS `PR_ID_content`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of` c
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
    'PR_content_ST_location_EV_of',
    'no row in ST_Stage for ST_ID_location',
    TO_JSON_STRING(STRUCT(c.`ST_ID_location` AS `ST_ID_location`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of` c
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
    'PR_content_ST_location_EV_of',
    'no row in EV_Event for EV_ID_of',
    TO_JSON_STRING(STRUCT(c.`EV_ID_of` AS `EV_ID_of`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_of`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_of`
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
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_1st`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_2nd`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_1st`
UNION ALL SELECT * FROM public.`ic_key_PR_Program_1st`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_1st`
;
