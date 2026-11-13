-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          the checksum, a hash of the value, which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change (a SQL table macro)
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; a violation is a row with the construct, what is wrong, the key as JSON
--
-- Oracle does not enforce that a key is unique (the primary keys are the identities), so a lookup through a key
-- view can find more than one identity when ic_key_ is not empty.
-- Every key is per positor, as the perspectives are.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Scen_1st (
    Positor,
    ST_ID,
    ST_LOC_Scen_Plats,
    ST_LOC_Checksum
)
AS
SELECT
    "ST".Positor,
    "ST".ST_ID,
    "ST".ST_LOC_Scen_Plats,
    "ST".ST_LOC_Checksum
FROM
    anchors.lST_Scen "ST"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_ST_Scen_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Scen_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_LOC_Checksum' VALUE ST_LOC_Checksum
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Scen_1st
WHERE
    ST_LOC_Checksum IS NOT NULL
GROUP BY
    Positor,
    ST_LOC_Checksum
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Scen_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Scen_1st
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Scen_2nd (
    Positor,
    ST_ID,
    ST_NAM_Scen_Namn
)
AS
SELECT
    "ST".Positor,
    "ST".ST_ID,
    "ST".ST_NAM_Scen_Namn
FROM
    anchors.lST_Scen "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pkey_ST_Scen_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".Positor,
            "ST".ST_ID,
            "ST".ST_NAM_Scen_Namn AS ST_NAM_Scen_Namn
        FROM
            anchors.pST_Scen(changingTimepoint) "ST"
    ]';
END pkey_ST_Scen_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_ST_Scen_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Scen_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_NAM_Scen_Namn' VALUE ST_NAM_Scen_Namn
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Scen_2nd
WHERE
    ST_NAM_Scen_Namn IS NOT NULL
GROUP BY
    Positor,
    ST_NAM_Scen_Namn
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Scen_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Scen_2nd
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_AC_Skådespelare_1st (
    Positor,
    AC_ID,
    AC_NAM_Skådespelare_Namn
)
AS
SELECT
    "AC".Positor,
    "AC".AC_ID,
    "AC".AC_NAM_Skådespelare_Namn
FROM
    anchors.lAC_Skådespelare "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pkey_AC_Skådespelare_1st (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".Positor,
            "AC".AC_ID,
            "AC".AC_NAM_Skådespelare_Namn AS AC_NAM_Skådespelare_Namn
        FROM
            anchors.pAC_Skådespelare(changingTimepoint) "AC"
    ]';
END pkey_AC_Skådespelare_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_AC_Skådespelare_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Skådespelare_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_NAM_Skådespelare_Namn' VALUE AC_NAM_Skådespelare_Namn
    ),
    COUNT(DISTINCT AC_ID)
FROM
    anchors.key_AC_Skådespelare_1st
WHERE
    AC_NAM_Skådespelare_Namn IS NOT NULL
GROUP BY
    Positor,
    AC_NAM_Skådespelare_Namn
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Skådespelare_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    anchors.key_AC_Skådespelare_1st
GROUP BY
    Positor,
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_PR_Föreställning_1st (
    Positor,
    PR_ID,
    PR_NAM_Föreställning_Namn
)
AS
SELECT
    "PR".Positor,
    "PR".PR_ID,
    "PR".PR_NAM_Föreställning_Namn
FROM
    anchors.lPR_Föreställning "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_PR_Föreställning_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Föreställning_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PR_NAM_Föreställning_Namn' VALUE PR_NAM_Föreställning_Namn
    ),
    COUNT(DISTINCT PR_ID)
FROM
    anchors.key_PR_Föreställning_1st
WHERE
    PR_NAM_Föreställning_Namn IS NOT NULL
GROUP BY
    Positor,
    PR_NAM_Föreställning_Namn
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Föreställning_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    anchors.key_PR_Föreställning_1st
GROUP BY
    Positor,
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.key_EV_Händelse_1st (
    Positor,
    EV_ID,
    EV_DAT_Händelse_Datum,
    hölls_ST_LOC_Scen_Plats,
    hölls_ST_LOC_Checksum,
    spelades_PR_NAM_Föreställning_Namn
)
AS
SELECT
    "EV".Positor,
    "EV".EV_ID,
    "EV".EV_DAT_Händelse_Datum,
    "s2".ST_LOC_Scen_Plats,
    "s2".ST_LOC_Checksum,
    "s4".PR_NAM_Föreställning_Namn
FROM
    nexuses.lEV_Händelse "EV"
LEFT JOIN
    anchors.lST_Scen "s2"
ON
    "s2".ST_ID = "EV".ST_ID_hölls
AND
    "s2".Positor = "EV".Positor
LEFT JOIN
    anchors.lPR_Föreställning "s4"
ON
    "s4".PR_ID = "EV".PR_ID_spelades
AND
    "s4".Positor = "EV".Positor
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.ic_key_EV_Händelse_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Händelse_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'EV_DAT_Händelse_Datum' VALUE EV_DAT_Händelse_Datum,
        'hölls_ST_LOC_Checksum' VALUE hölls_ST_LOC_Checksum,
        'spelades_PR_NAM_Föreställning_Namn' VALUE spelades_PR_NAM_Föreställning_Namn
    ),
    COUNT(DISTINCT EV_ID)
FROM
    nexuses.key_EV_Händelse_1st
WHERE
    EV_DAT_Händelse_Datum IS NOT NULL
AND
    hölls_ST_LOC_Checksum IS NOT NULL
AND
    spelades_PR_NAM_Föreställning_Namn IS NOT NULL
GROUP BY
    Positor,
    EV_DAT_Händelse_Datum,
    hölls_ST_LOC_Checksum,
    spelades_PR_NAM_Föreställning_Namn
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Händelse_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    nexuses.key_EV_Händelse_1st
GROUP BY
    Positor,
    EV_ID
HAVING
    COUNT(*) > 1;
