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
-- PAT_Föräldratyp integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_PAT_Föräldratyp` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PAT_Föräldratyp',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PAT_ID` AS `PAT_ID`)),
    COUNT(*)
FROM
    knots.`PAT_Föräldratyp`
GROUP BY
    `PAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_Föräldratyp',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`PAT_Föräldratyp` AS `PAT_Föräldratyp`)),
    COUNT(*)
FROM
    knots.`PAT_Föräldratyp`
GROUP BY
    `PAT_Föräldratyp`
HAVING
    COUNT(*) > 1;
-- GEN_Kön integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_GEN_Kön` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'GEN_Kön',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`GEN_ID` AS `GEN_ID`)),
    COUNT(*)
FROM
    knots.`GEN_Kön`
GROUP BY
    `GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Kön',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`GEN_Checksum` AS `GEN_Checksum`)),
    COUNT(*)
FROM
    knots.`GEN_Kön`
GROUP BY
    `GEN_Checksum`
HAVING
    COUNT(*) > 1;
-- PLV_Yrkesnivå integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_PLV_Yrkesnivå` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PLV_Yrkesnivå',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PLV_ID` AS `PLV_ID`)),
    COUNT(*)
FROM
    knots.`PLV_Yrkesnivå`
GROUP BY
    `PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_Yrkesnivå',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`PLV_Checksum` AS `PLV_Checksum`)),
    COUNT(*)
FROM
    knots.`PLV_Yrkesnivå`
GROUP BY
    `PLV_Checksum`
HAVING
    COUNT(*) > 1;
-- UTL_Utnyttjande integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_UTL_Utnyttjande` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'UTL_Utnyttjande',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`UTL_ID` AS `UTL_ID`)),
    COUNT(*)
FROM
    knots.`UTL_Utnyttjande`
GROUP BY
    `UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utnyttjande',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`UTL_Utnyttjande` AS `UTL_Utnyttjande`)),
    COUNT(*)
FROM
    knots.`UTL_Utnyttjande`
GROUP BY
    `UTL_Utnyttjande`
HAVING
    COUNT(*) > 1;
-- ONG_Pågående integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_ONG_Pågående` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ONG_Pågående',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ONG_ID` AS `ONG_ID`)),
    COUNT(*)
FROM
    knots.`ONG_Pågående`
GROUP BY
    `ONG_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Pågående',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ONG_Pågående` AS `ONG_Pågående`)),
    COUNT(*)
FROM
    knots.`ONG_Pågående`
GROUP BY
    `ONG_Pågående`
HAVING
    COUNT(*) > 1;
-- RAT_Betyg integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_RAT_Betyg` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'RAT_Betyg',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`RAT_ID` AS `RAT_ID`)),
    COUNT(*)
FROM
    knots.`RAT_Betyg`
GROUP BY
    `RAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Betyg',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`RAT_Checksum` AS `RAT_Checksum`)),
    COUNT(*)
FROM
    knots.`RAT_Betyg`
GROUP BY
    `RAT_Checksum`
HAVING
    COUNT(*) > 1;
-- ETY_Händelsetyp integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_ETY_Händelsetyp` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ETY_Händelsetyp',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ETY_ID` AS `ETY_ID`)),
    COUNT(*)
FROM
    knots.`ETY_Händelsetyp`
GROUP BY
    `ETY_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_Händelsetyp',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ETY_Checksum` AS `ETY_Checksum`)),
    COUNT(*)
FROM
    knots.`ETY_Händelsetyp`
GROUP BY
    `ETY_Checksum`
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_PN_Person` (
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
    anchors.`PN_Person`
GROUP BY
    `PN_ID`
HAVING
    COUNT(*) > 1;
-- ST_Scen integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_ST_Scen` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_Scen',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    anchors.`ST_Scen`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- AC_Skådespelare integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_AC_Skådespelare` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_Skådespelare',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_ID` AS `AC_ID`)),
    COUNT(*)
FROM
    anchors.`AC_Skådespelare`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- PR_Föreställning integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_PR_Föreställning` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_Föreställning',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_ID` AS `PR_ID`)),
    COUNT(*)
FROM
    anchors.`PR_Föreställning`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- EV_Händelse integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`ic_EV_Händelse` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_Händelse',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_ID` AS `EV_ID`)),
    COUNT(*)
FROM
    nexuses.`EV_Händelse`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ST_Scen for ST_ID_hölls',
    TO_JSON_STRING(STRUCT(c.`ST_ID_hölls` AS `ST_ID_hölls`)),
    COUNT(*)
FROM
    nexuses.`EV_Händelse` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_ID_hölls`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_hölls`
UNION ALL
SELECT
    'EV_Händelse',
    'no row in PR_Föreställning for PR_ID_spelades',
    TO_JSON_STRING(STRUCT(c.`PR_ID_spelades` AS `PR_ID_spelades`)),
    COUNT(*)
FROM
    nexuses.`EV_Händelse` c
LEFT JOIN
    anchors.`PR_Föreställning` p
ON
    p.`PR_ID` = c.`PR_ID_spelades`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_spelades`
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ETY_Händelsetyp for ETY_ID_of',
    TO_JSON_STRING(STRUCT(c.`ETY_ID_of` AS `ETY_ID_of`)),
    COUNT(*)
FROM
    nexuses.`EV_Händelse` c
LEFT JOIN
    knots.`ETY_Händelsetyp` p
ON
    p.`ETY_ID` = c.`ETY_ID_of`
WHERE
    p.`ETY_ID` IS NULL
GROUP BY
    c.`ETY_ID_of`
;
-- EV_DAT_Händelse_Datum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_DAT_Händelse_Datum` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Händelse_Datum',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_DAT_Händelse_Datum`
GROUP BY
    `EV_DAT_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum',
    'no row in EV_Händelse for EV_DAT_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_DAT_EV_ID` AS `EV_DAT_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_DAT_Händelse_Datum` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_DAT_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_DAT_EV_ID`
;
-- EV_AUD_Händelse_Publik integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_AUD_Händelse_Publik` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Händelse_Publik',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_AUD_Händelse_Publik`
GROUP BY
    `EV_AUD_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik',
    'no row in EV_Händelse for EV_AUD_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_AUD_EV_ID` AS `EV_AUD_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_AUD_Händelse_Publik` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_AUD_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_AUD_EV_ID`
;
-- EV_REV_Händelse_Intäkt integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_REV_Händelse_Intäkt` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Händelse_Intäkt',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_REV_Händelse_Intäkt`
GROUP BY
    `EV_REV_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt',
    'no row in EV_Händelse for EV_REV_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_REV_EV_ID` AS `EV_REV_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_REV_Händelse_Intäkt` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_REV_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_REV_EV_ID`
;
-- EV_STA_Händelse_Status integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_STA_Händelse_Status` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_STA_Händelse_Status',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_STA_EV_ID` AS `EV_STA_EV_ID`,
        `EV_STA_ChangedAt` AS `EV_STA_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`EV_STA_Händelse_Status`
GROUP BY
    `EV_STA_EV_ID`,
    `EV_STA_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status',
    'no row in EV_Händelse for EV_STA_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_STA_EV_ID` AS `EV_STA_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_STA_Händelse_Status` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_STA_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_STA_EV_ID`
;
-- EV_UTL_Händelse_Utnyttjande integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_UTL_Händelse_Utnyttjande` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_UTL_Händelse_Utnyttjande',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_UTL_EV_ID` AS `EV_UTL_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande`
GROUP BY
    `EV_UTL_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande',
    'no row in EV_Händelse for EV_UTL_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_UTL_EV_ID` AS `EV_UTL_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_UTL_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_UTL_EV_ID`
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande',
    'no row in UTL_Utnyttjande for EV_UTL_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`EV_UTL_UTL_ID` AS `EV_UTL_UTL_ID`)),
    COUNT(*)
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande` c
LEFT JOIN
    knots.`UTL_Utnyttjande` p
ON
    p.`UTL_ID` = c.`EV_UTL_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`EV_UTL_UTL_ID`
;
-- EV_LVL_Händelse_Level integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_LVL_Händelse_Level` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_LVL_Händelse_Level',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_LVL_EV_ID` AS `EV_LVL_EV_ID`,
        `EV_LVL_ChangedAt` AS `EV_LVL_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`EV_LVL_Händelse_Level`
GROUP BY
    `EV_LVL_EV_ID`,
    `EV_LVL_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level',
    'no row in EV_Händelse for EV_LVL_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_LVL_EV_ID` AS `EV_LVL_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_LVL_Händelse_Level` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_LVL_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_LVL_EV_ID`
UNION ALL
SELECT
    'EV_LVL_Händelse_Level',
    'no row in PLV_Yrkesnivå for EV_LVL_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_LVL_PLV_ID` AS `EV_LVL_PLV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_LVL_Händelse_Level` c
LEFT JOIN
    knots.`PLV_Yrkesnivå` p
ON
    p.`PLV_ID` = c.`EV_LVL_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`EV_LVL_PLV_ID`
;
-- ST_NAM_Scen_Namn integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_NAM_Scen_Namn` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Scen_Namn',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`ST_NAM_Scen_Namn`
GROUP BY
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn',
    'no row in ST_Scen for ST_NAM_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_NAM_ST_ID` AS `ST_NAM_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_NAM_Scen_Namn` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_NAM_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_NAM_ST_ID`
;
-- ST_LOC_Scen_Plats integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_LOC_Scen_Plats` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Scen_Plats',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`
    )),
    COUNT(*)
FROM
    attributes.`ST_LOC_Scen_Plats`
GROUP BY
    `ST_LOC_ST_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats',
    'no row in ST_Scen for ST_LOC_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_LOC_ST_ID` AS `ST_LOC_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_LOC_Scen_Plats` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_LOC_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_LOC_ST_ID`
;
-- ST_AVG_Scen_Medel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_AVG_Scen_Medel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Scen_Medel',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`ST_AVG_Scen_Medel`
GROUP BY
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel',
    'no row in ST_Scen for ST_AVG_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_ST_ID` AS `ST_AVG_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_AVG_Scen_Medel` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_AVG_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_AVG_ST_ID`
UNION ALL
SELECT
    'ST_AVG_Scen_Medel',
    'no row in UTL_Utnyttjande for ST_AVG_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`)),
    COUNT(*)
FROM
    attributes.`ST_AVG_Scen_Medel` c
LEFT JOIN
    knots.`UTL_Utnyttjande` p
ON
    p.`UTL_ID` = c.`ST_AVG_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_AVG_UTL_ID`
UNION ALL
SELECT
    'ST_AVG_Scen_Medel',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    1
FROM (
    SELECT
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`,
        `ST_AVG_UTL_ID` AS compared,
        LAG(`ST_AVG_UTL_ID`) OVER (
            PARTITION BY
                `ST_AVG_ST_ID`
            ORDER BY
                `ST_AVG_ChangedAt`
        ) AS previous
    FROM
        attributes.`ST_AVG_Scen_Medel`
)
WHERE
    compared = previous
;
-- ST_MIN_Scen_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_MIN_Scen_Minimum` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Scen_Minimum',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`
    )),
    COUNT(*)
FROM
    attributes.`ST_MIN_Scen_Minimum`
GROUP BY
    `ST_MIN_ST_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum',
    'no row in ST_Scen for ST_MIN_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_ST_ID` AS `ST_MIN_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_MIN_Scen_Minimum` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_MIN_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_MIN_ST_ID`
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum',
    'no row in UTL_Utnyttjande for ST_MIN_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`)),
    COUNT(*)
FROM
    attributes.`ST_MIN_Scen_Minimum` c
LEFT JOIN
    knots.`UTL_Utnyttjande` p
ON
    p.`UTL_ID` = c.`ST_MIN_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_MIN_UTL_ID`
;
-- AC_NAM_Skådespelare_Namn integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_AC_NAM_Skådespelare_Namn` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Skådespelare_Namn',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`AC_NAM_Skådespelare_Namn`
GROUP BY
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn',
    'no row in AC_Skådespelare for AC_NAM_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_NAM_AC_ID` AS `AC_NAM_AC_ID`)),
    COUNT(*)
FROM
    attributes.`AC_NAM_Skådespelare_Namn` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_NAM_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_NAM_AC_ID`
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    1
FROM (
    SELECT
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`,
        `AC_NAM_Skådespelare_Namn` AS compared,
        LAG(`AC_NAM_Skådespelare_Namn`) OVER (
            PARTITION BY
                `AC_NAM_AC_ID`
            ORDER BY
                `AC_NAM_ChangedAt`
        ) AS previous
    FROM
        attributes.`AC_NAM_Skådespelare_Namn`
)
WHERE
    compared = previous
;
-- AC_GEN_Skådespelare_Kön integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_AC_GEN_Skådespelare_Kön` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Skådespelare_Kön',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`
    )),
    COUNT(*)
FROM
    attributes.`AC_GEN_Skådespelare_Kön`
GROUP BY
    `AC_GEN_AC_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön',
    'no row in AC_Skådespelare for AC_GEN_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_AC_ID` AS `AC_GEN_AC_ID`)),
    COUNT(*)
FROM
    attributes.`AC_GEN_Skådespelare_Kön` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_GEN_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_GEN_AC_ID`
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön',
    'no row in GEN_Kön for AC_GEN_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`)),
    COUNT(*)
FROM
    attributes.`AC_GEN_Skådespelare_Kön` c
LEFT JOIN
    knots.`GEN_Kön` p
ON
    p.`GEN_ID` = c.`AC_GEN_GEN_ID`
WHERE
    p.`GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_GEN_ID`
;
-- AC_PLV_Skådespelare_Yrkesnivå integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_AC_PLV_Skådespelare_Yrkesnivå` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`AC_PLV_Skådespelare_Yrkesnivå`
GROUP BY
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå',
    'no row in AC_Skådespelare for AC_PLV_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_AC_ID` AS `AC_PLV_AC_ID`)),
    COUNT(*)
FROM
    attributes.`AC_PLV_Skådespelare_Yrkesnivå` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_PLV_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_PLV_AC_ID`
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå',
    'no row in PLV_Yrkesnivå for AC_PLV_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`)),
    COUNT(*)
FROM
    attributes.`AC_PLV_Skådespelare_Yrkesnivå` c
LEFT JOIN
    knots.`PLV_Yrkesnivå` p
ON
    p.`PLV_ID` = c.`AC_PLV_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_PLV_ID`
;
-- PR_NAM_Föreställning_Namn integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_PR_NAM_Föreställning_Namn` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Föreställning_Namn',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`
    )),
    COUNT(*)
FROM
    attributes.`PR_NAM_Föreställning_Namn`
GROUP BY
    `PR_NAM_PR_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn',
    'no row in PR_Föreställning for PR_NAM_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_NAM_PR_ID` AS `PR_NAM_PR_ID`)),
    COUNT(*)
FROM
    attributes.`PR_NAM_Föreställning_Namn` c
LEFT JOIN
    anchors.`PR_Föreställning` p
ON
    p.`PR_ID` = c.`PR_NAM_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_NAM_PR_ID`
;
-- PR_LEN_Föreställning_Längd integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_PR_LEN_Föreställning_Längd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Föreställning_Längd',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`PR_LEN_Föreställning_Längd`
GROUP BY
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd',
    'no row in PR_Föreställning for PR_LEN_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_LEN_PR_ID` AS `PR_LEN_PR_ID`)),
    COUNT(*)
FROM
    attributes.`PR_LEN_Föreställning_Längd` c
LEFT JOIN
    anchors.`PR_Föreställning` p
ON
    p.`PR_ID` = c.`PR_LEN_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_LEN_PR_ID`
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_partner_AC_with_ONG_currently` (
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
    ties.`AC_partner_AC_with_ONG_currently`
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
    ties.`AC_partner_AC_with_ONG_currently`
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
    ties.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_with`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Skådespelare for AC_ID_partner',
    TO_JSON_STRING(STRUCT(c.`AC_ID_partner` AS `AC_ID_partner`)),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_ID_partner`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_partner`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Skådespelare for AC_ID_with',
    TO_JSON_STRING(STRUCT(c.`AC_ID_with` AS `AC_ID_with`)),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_ID_with`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_with`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Pågående for ONG_ID_currently',
    TO_JSON_STRING(STRUCT(c.`ONG_ID_currently` AS `ONG_ID_currently`)),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    knots.`ONG_Pågående` p
ON
    p.`ONG_ID` = c.`ONG_ID_currently`
WHERE
    p.`ONG_ID` IS NULL
GROUP BY
    c.`ONG_ID_currently`
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_subset_PN_of` (
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
    ties.`AC_subset_PN_of`
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
    ties.`AC_subset_PN_of`
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
    ties.`AC_subset_PN_of`
GROUP BY
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in AC_Skådespelare for AC_ID_subset',
    TO_JSON_STRING(STRUCT(c.`AC_ID_subset` AS `AC_ID_subset`)),
    COUNT(*)
FROM
    ties.`AC_subset_PN_of` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
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
    ties.`AC_subset_PN_of` c
LEFT JOIN
    anchors.`PN_Person` p
ON
    p.`PN_ID` = c.`PN_ID_of`
WHERE
    p.`PN_ID` IS NULL
GROUP BY
    c.`PN_ID_of`
;
-- EV_in_AC_rollsattes integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_EV_in_AC_rollsattes` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_rollsattes',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_rollsattes` AS `AC_ID_rollsattes`
    )),
    COUNT(*)
FROM
    ties.`EV_in_AC_rollsattes`
GROUP BY
    `EV_ID_in`,
    `AC_ID_rollsattes`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes',
    'no row in EV_Händelse for EV_ID_in',
    TO_JSON_STRING(STRUCT(c.`EV_ID_in` AS `EV_ID_in`)),
    COUNT(*)
FROM
    ties.`EV_in_AC_rollsattes` c
LEFT JOIN
    nexuses.`EV_Händelse` p
ON
    p.`EV_ID` = c.`EV_ID_in`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_in`
UNION ALL
SELECT
    'EV_in_AC_rollsattes',
    'no row in AC_Skådespelare for AC_ID_rollsattes',
    TO_JSON_STRING(STRUCT(c.`AC_ID_rollsattes` AS `AC_ID_rollsattes`)),
    COUNT(*)
FROM
    ties.`EV_in_AC_rollsattes` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_ID_rollsattes`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_rollsattes`
;
-- AC_deltar_PR_in_RAT_fick integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_deltar_PR_in_RAT_fick` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_deltar` AS `AC_ID_deltar`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_deltar_PR_in_RAT_fick_ChangedAt` AS `AC_deltar_PR_in_RAT_fick_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`AC_deltar_PR_in_RAT_fick`
GROUP BY
    `AC_ID_deltar`,
    `PR_ID_in`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'no row in AC_Skådespelare for AC_ID_deltar',
    TO_JSON_STRING(STRUCT(c.`AC_ID_deltar` AS `AC_ID_deltar`)),
    COUNT(*)
FROM
    ties.`AC_deltar_PR_in_RAT_fick` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_ID_deltar`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_deltar`
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'no row in PR_Föreställning for PR_ID_in',
    TO_JSON_STRING(STRUCT(c.`PR_ID_in` AS `PR_ID_in`)),
    COUNT(*)
FROM
    ties.`AC_deltar_PR_in_RAT_fick` c
LEFT JOIN
    anchors.`PR_Föreställning` p
ON
    p.`PR_ID` = c.`PR_ID_in`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_in`
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'no row in RAT_Betyg for RAT_ID_fick',
    TO_JSON_STRING(STRUCT(c.`RAT_ID_fick` AS `RAT_ID_fick`)),
    COUNT(*)
FROM
    ties.`AC_deltar_PR_in_RAT_fick` c
LEFT JOIN
    knots.`RAT_Betyg` p
ON
    p.`RAT_ID` = c.`RAT_ID_fick`
WHERE
    p.`RAT_ID` IS NULL
GROUP BY
    c.`RAT_ID_fick`
;
-- ST_at_PR_spelas integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_ST_at_PR_spelas` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_spelas',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_spelas` AS `PR_ID_spelas`,
        `ST_at_PR_spelas_ChangedAt` AS `ST_at_PR_spelas_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`ST_at_PR_spelas`
GROUP BY
    `ST_ID_at`,
    `PR_ID_spelas`,
    `ST_at_PR_spelas_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas',
    'no row in ST_Scen for ST_ID_at',
    TO_JSON_STRING(STRUCT(c.`ST_ID_at` AS `ST_ID_at`)),
    COUNT(*)
FROM
    ties.`ST_at_PR_spelas` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_ID_at`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_at`
UNION ALL
SELECT
    'ST_at_PR_spelas',
    'no row in PR_Föreställning for PR_ID_spelas',
    TO_JSON_STRING(STRUCT(c.`PR_ID_spelas` AS `PR_ID_spelas`)),
    COUNT(*)
FROM
    ties.`ST_at_PR_spelas` c
LEFT JOIN
    anchors.`PR_Föreställning` p
ON
    p.`PR_ID` = c.`PR_ID_spelas`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_spelas`
;
-- AC_förälder_AC_barn_PAT_har integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_förälder_AC_barn_PAT_har` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_förälder` AS `AC_ID_förälder`,
        `AC_ID_barn` AS `AC_ID_barn`,
        `PAT_ID_har` AS `PAT_ID_har`
    )),
    COUNT(*)
FROM
    ties.`AC_förälder_AC_barn_PAT_har`
GROUP BY
    `AC_ID_förälder`,
    `AC_ID_barn`,
    `PAT_ID_har`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'no row in AC_Skådespelare for AC_ID_förälder',
    TO_JSON_STRING(STRUCT(c.`AC_ID_förälder` AS `AC_ID_förälder`)),
    COUNT(*)
FROM
    ties.`AC_förälder_AC_barn_PAT_har` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_ID_förälder`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_förälder`
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'no row in AC_Skådespelare for AC_ID_barn',
    TO_JSON_STRING(STRUCT(c.`AC_ID_barn` AS `AC_ID_barn`)),
    COUNT(*)
FROM
    ties.`AC_förälder_AC_barn_PAT_har` c
LEFT JOIN
    anchors.`AC_Skådespelare` p
ON
    p.`AC_ID` = c.`AC_ID_barn`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_barn`
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'no row in PAT_Föräldratyp for PAT_ID_har',
    TO_JSON_STRING(STRUCT(c.`PAT_ID_har` AS `PAT_ID_har`)),
    COUNT(*)
FROM
    ties.`AC_förälder_AC_barn_PAT_har` c
LEFT JOIN
    knots.`PAT_Föräldratyp` p
ON
    p.`PAT_ID` = c.`PAT_ID_har`
WHERE
    p.`PAT_ID` IS NULL
GROUP BY
    c.`PAT_ID_har`
;
-- PR_innehåll_ST_plats_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_PR_innehåll_ST_plats_EV_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_ID_innehåll` AS `PR_ID_innehåll`,
        `ST_ID_plats` AS `ST_ID_plats`,
        `EV_ID_of` AS `EV_ID_of`,
        `PR_innehåll_ST_plats_EV_of_ChangedAt` AS `PR_innehåll_ST_plats_EV_of_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`PR_innehåll_ST_plats_EV_of`
GROUP BY
    `PR_ID_innehåll`,
    `ST_ID_plats`,
    `EV_ID_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'duplicate unique key (PR_innehåll)',
    TO_JSON_STRING(STRUCT(
        `PR_ID_innehåll` AS `PR_ID_innehåll`,
        `PR_innehåll_ST_plats_EV_of_ChangedAt` AS `PR_innehåll_ST_plats_EV_of_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`PR_innehåll_ST_plats_EV_of`
GROUP BY
    `PR_ID_innehåll`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'duplicate unique key (ST_plats)',
    TO_JSON_STRING(STRUCT(
        `ST_ID_plats` AS `ST_ID_plats`,
        `PR_innehåll_ST_plats_EV_of_ChangedAt` AS `PR_innehåll_ST_plats_EV_of_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`PR_innehåll_ST_plats_EV_of`
GROUP BY
    `ST_ID_plats`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'no row in PR_Föreställning for PR_ID_innehåll',
    TO_JSON_STRING(STRUCT(c.`PR_ID_innehåll` AS `PR_ID_innehåll`)),
    COUNT(*)
FROM
    ties.`PR_innehåll_ST_plats_EV_of` c
LEFT JOIN
    anchors.`PR_Föreställning` p
ON
    p.`PR_ID` = c.`PR_ID_innehåll`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_innehåll`
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'no row in ST_Scen for ST_ID_plats',
    TO_JSON_STRING(STRUCT(c.`ST_ID_plats` AS `ST_ID_plats`)),
    COUNT(*)
FROM
    ties.`PR_innehåll_ST_plats_EV_of` c
LEFT JOIN
    anchors.`ST_Scen` p
ON
    p.`ST_ID` = c.`ST_ID_plats`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_plats`
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'no row in EV_Händelse for EV_ID_of',
    TO_JSON_STRING(STRUCT(c.`EV_ID_of` AS `EV_ID_of`)),
    COUNT(*)
FROM
    ties.`PR_innehåll_ST_plats_EV_of` c
LEFT JOIN
    nexuses.`EV_Händelse` p
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
CREATE OR REPLACE VIEW dw.IntegrityViolations (
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
UNION ALL SELECT * FROM knots.`ic_PAT_Föräldratyp`
UNION ALL SELECT * FROM knots.`ic_GEN_Kön`
UNION ALL SELECT * FROM knots.`ic_PLV_Yrkesnivå`
UNION ALL SELECT * FROM knots.`ic_UTL_Utnyttjande`
UNION ALL SELECT * FROM knots.`ic_ONG_Pågående`
UNION ALL SELECT * FROM knots.`ic_RAT_Betyg`
UNION ALL SELECT * FROM knots.`ic_ETY_Händelsetyp`
UNION ALL SELECT * FROM anchors.`ic_PN_Person`
UNION ALL SELECT * FROM anchors.`ic_ST_Scen`
UNION ALL SELECT * FROM anchors.`ic_AC_Skådespelare`
UNION ALL SELECT * FROM anchors.`ic_PR_Föreställning`
UNION ALL SELECT * FROM nexuses.`ic_EV_Händelse`
UNION ALL SELECT * FROM attributes.`ic_EV_DAT_Händelse_Datum`
UNION ALL SELECT * FROM attributes.`ic_EV_AUD_Händelse_Publik`
UNION ALL SELECT * FROM attributes.`ic_EV_REV_Händelse_Intäkt`
UNION ALL SELECT * FROM attributes.`ic_EV_STA_Händelse_Status`
UNION ALL SELECT * FROM attributes.`ic_EV_UTL_Händelse_Utnyttjande`
UNION ALL SELECT * FROM attributes.`ic_EV_LVL_Händelse_Level`
UNION ALL SELECT * FROM attributes.`ic_ST_NAM_Scen_Namn`
UNION ALL SELECT * FROM attributes.`ic_ST_LOC_Scen_Plats`
UNION ALL SELECT * FROM attributes.`ic_ST_AVG_Scen_Medel`
UNION ALL SELECT * FROM attributes.`ic_ST_MIN_Scen_Minimum`
UNION ALL SELECT * FROM attributes.`ic_AC_NAM_Skådespelare_Namn`
UNION ALL SELECT * FROM attributes.`ic_AC_GEN_Skådespelare_Kön`
UNION ALL SELECT * FROM attributes.`ic_AC_PLV_Skådespelare_Yrkesnivå`
UNION ALL SELECT * FROM attributes.`ic_PR_NAM_Föreställning_Namn`
UNION ALL SELECT * FROM attributes.`ic_PR_LEN_Föreställning_Längd`
UNION ALL SELECT * FROM ties.`ic_AC_partner_AC_with_ONG_currently`
UNION ALL SELECT * FROM ties.`ic_AC_subset_PN_of`
UNION ALL SELECT * FROM ties.`ic_EV_in_AC_rollsattes`
UNION ALL SELECT * FROM ties.`ic_AC_deltar_PR_in_RAT_fick`
UNION ALL SELECT * FROM ties.`ic_ST_at_PR_spelas`
UNION ALL SELECT * FROM ties.`ic_AC_förälder_AC_barn_PAT_har`
UNION ALL SELECT * FROM ties.`ic_PR_innehåll_ST_plats_EV_of`
UNION ALL SELECT * FROM anchors.`ic_key_ST_Scen_1st`
UNION ALL SELECT * FROM anchors.`ic_key_ST_Scen_2nd`
UNION ALL SELECT * FROM anchors.`ic_key_AC_Skådespelare_1st`
UNION ALL SELECT * FROM anchors.`ic_key_PR_Föreställning_1st`
UNION ALL SELECT * FROM nexuses.`ic_key_EV_Händelse_1st`
;
