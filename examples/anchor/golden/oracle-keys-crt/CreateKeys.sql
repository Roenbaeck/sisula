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
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_PN_Person_1st (
    Positor,
    PN_ID,
    subset_AC_NAM_Actor_Name
)
AS
SELECT
    p.Positor,
    "PN".PN_ID,
    "s2".AC_NAM_Actor_Name
FROM
    Positor_ p
CROSS JOIN
    PN_Person "PN"
LEFT JOIN
    lAC_subset_PN_of "s1"
ON
    "s1".PN_ID_of = "PN".PN_ID
AND
    "s1".Positor = p.Positor
LEFT JOIN
    lAC_Actor "s2"
ON
    "s2".AC_ID = "s1".AC_ID_subset
AND
    "s2".Positor = p.Positor
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of PN_Person at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_PN_Person_1st (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            p.Positor,
            "PN".PN_ID,
            "s2".AC_NAM_Actor_Name AS subset_AC_NAM_Actor_Name
        FROM
            Positor_ p
        CROSS JOIN
            PN_Person "PN"
        LEFT JOIN
            pAC_subset_PN_of(changingTimepoint) "s1"
        ON
            "s1".PN_ID_of = "PN".PN_ID
        AND
            "s1".Positor = p.Positor
        LEFT JOIN
            pAC_Actor(changingTimepoint) "s2"
        ON
            "s2".AC_ID = "s1".AC_ID_subset
        AND
            "s2".Positor = p.Positor
    ]';
END pkey_PN_Person_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_PN_Person_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PN_Person_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'subset_AC_NAM_Actor_Name' VALUE subset_AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT PN_ID)
FROM
    key_PN_Person_1st
WHERE
    subset_AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    Positor,
    subset_AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT PN_ID) > 1
UNION ALL
SELECT
    'key_PN_Person_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PN_ID' VALUE PN_ID
    ),
    COUNT(*)
FROM
    key_PN_Person_1st
GROUP BY
    Positor,
    PN_ID
HAVING
    COUNT(*) > 1;
-- The 1st key of ST_Stage is not generated: ST_LOC_Stage_Location is a nclob, which cannot be compared, and it has no checksum
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_ST_Stage_2nd (
    Positor,
    ST_ID,
    ST_NAM_Stage_Name
)
AS
SELECT
    "ST".Positor,
    "ST".ST_ID,
    "ST".ST_NAM_Stage_Name
FROM
    lST_Stage "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_ST_Stage_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".Positor,
            "ST".ST_ID,
            "ST".ST_NAM_Stage_Name AS ST_NAM_Stage_Name
        FROM
            pST_Stage(changingTimepoint) "ST"
    ]';
END pkey_ST_Stage_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_NAM_Stage_Name' VALUE ST_NAM_Stage_Name
    ),
    COUNT(DISTINCT ST_ID)
FROM
    key_ST_Stage_2nd
WHERE
    ST_NAM_Stage_Name IS NOT NULL
GROUP BY
    Positor,
    ST_NAM_Stage_Name
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    key_ST_Stage_2nd
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_ST_Stage_3rd (
    Positor,
    ST_ID,
    ST_MIN_UTL_Utilization,
    ST_NAM_Stage_Name
)
AS
SELECT
    "ST".Positor,
    "ST".ST_ID,
    "ST".ST_MIN_UTL_Utilization,
    "ST".ST_NAM_Stage_Name
FROM
    lST_Stage "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_ST_Stage_3rd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".Positor,
            "ST".ST_ID,
            "ST".ST_MIN_UTL_Utilization AS ST_MIN_UTL_Utilization,
            "ST".ST_NAM_Stage_Name AS ST_NAM_Stage_Name
        FROM
            pST_Stage(changingTimepoint) "ST"
    ]';
END pkey_ST_Stage_3rd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_3rd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_3rd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_MIN_UTL_Utilization' VALUE ST_MIN_UTL_Utilization,
        'ST_NAM_Stage_Name' VALUE ST_NAM_Stage_Name
    ),
    COUNT(DISTINCT ST_ID)
FROM
    key_ST_Stage_3rd
WHERE
    ST_MIN_UTL_Utilization IS NOT NULL
AND
    ST_NAM_Stage_Name IS NOT NULL
GROUP BY
    Positor,
    ST_MIN_UTL_Utilization,
    ST_NAM_Stage_Name
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_3rd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    key_ST_Stage_3rd
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-- Note: ST_Stage can be wasHeldAt in more than one EV_Event, so an identity can have more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_ST_Stage_4th (
    Positor,
    ST_ID,
    wasHeldAt_EV_DAT_Event_Date
)
AS
SELECT
    "ST".Positor,
    "ST".ST_ID,
    "s1".EV_DAT_Event_Date
FROM
    lST_Stage "ST"
LEFT JOIN
    lEV_Event "s1"
ON
    "s1".ST_ID_wasHeldAt = "ST".ST_ID
AND
    "s1".Positor = "ST".Positor
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_ST_Stage_4th (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_4th',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'wasHeldAt_EV_DAT_Event_Date' VALUE wasHeldAt_EV_DAT_Event_Date
    ),
    COUNT(DISTINCT ST_ID)
FROM
    key_ST_Stage_4th
WHERE
    wasHeldAt_EV_DAT_Event_Date IS NOT NULL
GROUP BY
    Positor,
    wasHeldAt_EV_DAT_Event_Date
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Stage_4th',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    key_ST_Stage_4th
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- The 5th key of ST_Stage is not generated: more than one element is stop 1
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_AC_Actor_1st (
    Positor,
    AC_ID,
    AC_NAM_Actor_Name
)
AS
SELECT
    "AC".Positor,
    "AC".AC_ID,
    "AC".AC_NAM_Actor_Name
FROM
    lAC_Actor "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_AC_Actor_1st (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".Positor,
            "AC".AC_ID,
            "AC".AC_NAM_Actor_Name AS AC_NAM_Actor_Name
        FROM
            pAC_Actor(changingTimepoint) "AC"
    ]';
END pkey_AC_Actor_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_AC_Actor_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_NAM_Actor_Name' VALUE AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    key_AC_Actor_1st
WHERE
    AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    Positor,
    AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    key_AC_Actor_1st
GROUP BY
    Positor,
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_AC_Actor_2nd (
    Positor,
    AC_ID,
    with_AC_NAM_Actor_Name
)
AS
SELECT
    "AC".Positor,
    "AC".AC_ID,
    "s2".AC_NAM_Actor_Name
FROM
    lAC_Actor "AC"
LEFT JOIN
    lAC_partner_AC_with_ONG_currently "s1"
ON
    "s1".AC_ID_partner = "AC".AC_ID
AND
    "s1".Positor = "AC".Positor
LEFT JOIN
    lAC_Actor "s2"
ON
    "s2".AC_ID = "s1".AC_ID_with
AND
    "s2".Positor = "AC".Positor
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_AC_Actor_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".Positor,
            "AC".AC_ID,
            "s2".AC_NAM_Actor_Name AS with_AC_NAM_Actor_Name
        FROM
            pAC_Actor(changingTimepoint) "AC"
        LEFT JOIN
            pAC_partner_AC_with_ONG_currently(changingTimepoint) "s1"
        ON
            "s1".AC_ID_partner = "AC".AC_ID
        AND
            "s1".Positor = "AC".Positor
        LEFT JOIN
            pAC_Actor(changingTimepoint) "s2"
        ON
            "s2".AC_ID = "s1".AC_ID_with
        AND
            "s2".Positor = "AC".Positor
    ]';
END pkey_AC_Actor_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_AC_Actor_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'with_AC_NAM_Actor_Name' VALUE with_AC_NAM_Actor_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    key_AC_Actor_2nd
WHERE
    with_AC_NAM_Actor_Name IS NOT NULL
GROUP BY
    Positor,
    with_AC_NAM_Actor_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    key_AC_Actor_2nd
GROUP BY
    Positor,
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-- Note: AC_parent_AC_child_PAT_having has identifiers other than parent, so it can lead to more than one child and an identity to more than one key
-- Note: AC_part_PR_in_RAT_got has identifiers other than part, so it can lead to more than one in and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_AC_Actor_3rd (
    Positor,
    AC_ID,
    child_in_PR_NAM_Program_Name
)
AS
SELECT
    "AC".Positor,
    "AC".AC_ID,
    "s4".PR_NAM_Program_Name
FROM
    lAC_Actor "AC"
LEFT JOIN
    lAC_parent_AC_child_PAT_having "s1"
ON
    "s1".AC_ID_parent = "AC".AC_ID
AND
    "s1".Positor = "AC".Positor
LEFT JOIN
    lAC_part_PR_in_RAT_got "s3"
ON
    "s3".AC_ID_part = "s1".AC_ID_child
AND
    "s3".Positor = "AC".Positor
LEFT JOIN
    lPR_Program "s4"
ON
    "s4".PR_ID = "s3".PR_ID_in
AND
    "s4".Positor = "AC".Positor
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_AC_Actor_3rd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".Positor,
            "AC".AC_ID,
            "s4".PR_NAM_Program_Name AS child_in_PR_NAM_Program_Name
        FROM
            pAC_Actor(changingTimepoint) "AC"
        LEFT JOIN
            pAC_parent_AC_child_PAT_having(changingTimepoint) "s1"
        ON
            "s1".AC_ID_parent = "AC".AC_ID
        AND
            "s1".Positor = "AC".Positor
        LEFT JOIN
            pAC_part_PR_in_RAT_got(changingTimepoint) "s3"
        ON
            "s3".AC_ID_part = "s1".AC_ID_child
        AND
            "s3".Positor = "AC".Positor
        LEFT JOIN
            pPR_Program(changingTimepoint) "s4"
        ON
            "s4".PR_ID = "s3".PR_ID_in
        AND
            "s4".Positor = "AC".Positor
    ]';
END pkey_AC_Actor_3rd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_AC_Actor_3rd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_3rd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'child_in_PR_NAM_Program_Name' VALUE child_in_PR_NAM_Program_Name
    ),
    COUNT(DISTINCT AC_ID)
FROM
    key_AC_Actor_3rd
WHERE
    child_in_PR_NAM_Program_Name IS NOT NULL
GROUP BY
    Positor,
    child_in_PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Actor_3rd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    key_AC_Actor_3rd
GROUP BY
    Positor,
    AC_ID
HAVING
    COUNT(*) > 1;
-- The 4th key of AC_Actor is not generated: stop 1: ST_NAM_Stage_Name is not an attribute of AC_Actor
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_PR_Program_1st (
    Positor,
    PR_ID,
    PR_NAM_Program_Name
)
AS
SELECT
    "PR".Positor,
    "PR".PR_ID,
    "PR".PR_NAM_Program_Name
FROM
    lPR_Program "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_PR_Program_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Program_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PR_NAM_Program_Name' VALUE PR_NAM_Program_Name
    ),
    COUNT(DISTINCT PR_ID)
FROM
    key_PR_Program_1st
WHERE
    PR_NAM_Program_Name IS NOT NULL
GROUP BY
    Positor,
    PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    key_PR_Program_1st
GROUP BY
    Positor,
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-- Note: AC_part_PR_in_RAT_got has identifiers other than in, so it can lead to more than one got and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_PR_Program_2nd (
    Positor,
    PR_ID,
    got_RAT_Rating
)
AS
SELECT
    "PR".Positor,
    "PR".PR_ID,
    "s1".got_RAT_Rating
FROM
    lPR_Program "PR"
LEFT JOIN
    lAC_part_PR_in_RAT_got "s1"
ON
    "s1".PR_ID_in = "PR".PR_ID
AND
    "s1".Positor = "PR".Positor
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pkey_PR_Program_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "PR".Positor,
            "PR".PR_ID,
            "s1".got_RAT_Rating AS got_RAT_Rating
        FROM
            pPR_Program(changingTimepoint) "PR"
        LEFT JOIN
            pAC_part_PR_in_RAT_got(changingTimepoint) "s1"
        ON
            "s1".PR_ID_in = "PR".PR_ID
        AND
            "s1".Positor = "PR".Positor
    ]';
END pkey_PR_Program_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_PR_Program_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Program_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'got_RAT_Rating' VALUE got_RAT_Rating
    ),
    COUNT(DISTINCT PR_ID)
FROM
    key_PR_Program_2nd
WHERE
    got_RAT_Rating IS NOT NULL
GROUP BY
    Positor,
    got_RAT_Rating
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Program_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    key_PR_Program_2nd
GROUP BY
    Positor,
    PR_ID
HAVING
    COUNT(*) > 1;
-- The 3rd key of PR_Program is not generated: branch 1 does not end in a value, an attribute or a knot
-- The 1st key of EV_Event is not generated: wasHeldAt_ST_LOC_Stage_Location is a nclob, which cannot be compared, and it has no checksum
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_EV_Event_2nd (
    Positor,
    EV_ID,
    of_ETY_EventType,
    EV_DAT_Event_Date
)
AS
SELECT
    "EV".Positor,
    "EV".EV_ID,
    "EV".of_ETY_EventType,
    "EV".EV_DAT_Event_Date
FROM
    lEV_Event "EV"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_EV_Event_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'of_ETY_EventType' VALUE of_ETY_EventType,
        'EV_DAT_Event_Date' VALUE EV_DAT_Event_Date
    ),
    COUNT(DISTINCT EV_ID)
FROM
    key_EV_Event_2nd
WHERE
    of_ETY_EventType IS NOT NULL
AND
    EV_DAT_Event_Date IS NOT NULL
GROUP BY
    Positor,
    of_ETY_EventType,
    EV_DAT_Event_Date
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Event_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    key_EV_Event_2nd
GROUP BY
    Positor,
    EV_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW key_EV_Event_3rd (
    Positor,
    EV_ID,
    content_PR_NAM_Program_Name
)
AS
SELECT
    "EV".Positor,
    "EV".EV_ID,
    "s2".PR_NAM_Program_Name
FROM
    lEV_Event "EV"
LEFT JOIN
    lPR_content_ST_location_EV_of "s1"
ON
    "s1".EV_ID_of = "EV".EV_ID
AND
    "s1".Positor = "EV".Positor
LEFT JOIN
    lPR_Program "s2"
ON
    "s2".PR_ID = "s1".PR_ID_content
AND
    "s2".Positor = "EV".Positor
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ic_key_EV_Event_3rd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_3rd',
    'duplicate natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'content_PR_NAM_Program_Name' VALUE content_PR_NAM_Program_Name
    ),
    COUNT(DISTINCT EV_ID)
FROM
    key_EV_Event_3rd
WHERE
    content_PR_NAM_Program_Name IS NOT NULL
GROUP BY
    Positor,
    content_PR_NAM_Program_Name
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Event_3rd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    key_EV_Event_3rd
GROUP BY
    Positor,
    EV_ID
HAVING
    COUNT(*) > 1;
-- The 4th key of EV_Event is not generated: stop 1: a tie takes two stops in a row in one branch, the role it is entered by and the role it is left by
-- The 5th key of EV_Event is not generated: stop 1 is on the knot ETY_EventType, which a route reaches through a knotted attribute or a knot role instead
