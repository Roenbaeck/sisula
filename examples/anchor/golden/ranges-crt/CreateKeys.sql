-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          the checksum, hash(value), which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; part of IntegrityViolations
--
-- Snowflake does not enforce that a key is unique, so a lookup through a key view can find more than one identity
-- when ic_key_ is not empty.
-- Every key is per positor, as the perspectives are.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."key_ST_Stage_1st" (
    "Who",
    "ST_ID",
    "ST_LOC_Stage_Location",
    "ST_LOC_Checksum"
) COPY GRANTS
AS
SELECT
    "ST"."Who",
    "ST"."ST_ID",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_LOC_Checksum"
FROM
    anchors."lST_Stage" "ST"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_key_ST_Stage_1st" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_ST_Stage_1st',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'ST_LOC_Checksum', "ST_LOC_Checksum"
    ),
    COUNT(DISTINCT "ST_ID")
FROM
    anchors."key_ST_Stage_1st"
WHERE
    "ST_LOC_Checksum" IS NOT NULL
GROUP BY
    "Who",
    "ST_LOC_Checksum"
HAVING
    COUNT(DISTINCT "ST_ID") > 1
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'ST_ID', "ST_ID"
    ),
    COUNT(*)
FROM
    anchors."key_ST_Stage_1st"
GROUP BY
    "Who",
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."key_ST_Stage_2nd" (
    "Who",
    "ST_ID",
    "ST_NAM_Stage_Name"
) COPY GRANTS
AS
SELECT
    "ST"."Who",
    "ST"."ST_ID",
    "ST"."ST_NAM_Stage_Name"
FROM
    anchors."lST_Stage" "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pkey_ST_Stage_2nd" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Who" smallint,
    "ST_ID" int,
    "ST_NAM_Stage_Name" varchar(42)
)
AS
$$
SELECT
    "ST"."Who",
    "ST"."ST_ID",
    "ST"."ST_NAM_Stage_Name"
FROM
    TABLE(anchors."pST_Stage"(changingTimepoint)) "ST"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_key_ST_Stage_2nd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_ST_Stage_2nd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'ST_NAM_Stage_Name', "ST_NAM_Stage_Name"
    ),
    COUNT(DISTINCT "ST_ID")
FROM
    anchors."key_ST_Stage_2nd"
WHERE
    "ST_NAM_Stage_Name" IS NOT NULL
GROUP BY
    "Who",
    "ST_NAM_Stage_Name"
HAVING
    COUNT(DISTINCT "ST_ID") > 1
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'ST_ID', "ST_ID"
    ),
    COUNT(*)
FROM
    anchors."key_ST_Stage_2nd"
GROUP BY
    "Who",
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."key_AC_Actor_1st" (
    "Who",
    "AC_ID",
    "AC_NAM_Actor_Name"
) COPY GRANTS
AS
SELECT
    "AC"."Who",
    "AC"."AC_ID",
    "AC"."AC_NAM_Actor_Name"
FROM
    anchors."lAC_Actor" "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pkey_AC_Actor_1st" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Who" smallint,
    "AC_ID" smallint,
    "AC_NAM_Actor_Name" varbinary(max)
)
AS
$$
SELECT
    "AC"."Who",
    "AC"."AC_ID",
    "AC"."AC_NAM_Actor_Name"
FROM
    TABLE(anchors."pAC_Actor"(changingTimepoint)) "AC"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_key_AC_Actor_1st" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_AC_Actor_1st',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'AC_NAM_Actor_Name', "AC_NAM_Actor_Name"
    ),
    COUNT(DISTINCT "AC_ID")
FROM
    anchors."key_AC_Actor_1st"
WHERE
    "AC_NAM_Actor_Name" IS NOT NULL
GROUP BY
    "Who",
    "AC_NAM_Actor_Name"
HAVING
    COUNT(DISTINCT "AC_ID") > 1
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'AC_ID', "AC_ID"
    ),
    COUNT(*)
FROM
    anchors."key_AC_Actor_1st"
GROUP BY
    "Who",
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."key_PR_Program_1st" (
    "Who",
    "PR_ID",
    "PR_NAM_Program_Name"
) COPY GRANTS
AS
SELECT
    "PR"."Who",
    "PR"."PR_ID",
    "PR"."PR_NAM_Program_Name"
FROM
    anchors."lPR_Program" "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_key_PR_Program_1st" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_PR_Program_1st',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'PR_NAM_Program_Name', "PR_NAM_Program_Name"
    ),
    COUNT(DISTINCT "PR_ID")
FROM
    anchors."key_PR_Program_1st"
WHERE
    "PR_NAM_Program_Name" IS NOT NULL
GROUP BY
    "Who",
    "PR_NAM_Program_Name"
HAVING
    COUNT(DISTINCT "PR_ID") > 1
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'PR_ID', "PR_ID"
    ),
    COUNT(*)
FROM
    anchors."key_PR_Program_1st"
GROUP BY
    "Who",
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."key_EV_Event_1st" (
    "Who",
    "EV_ID",
    "EV_DAT_Event_Date",
    "wasHeldAt_ST_LOC_Stage_Location",
    "wasHeldAt_ST_LOC_Checksum",
    "wasPlayed_PR_NAM_Program_Name"
) COPY GRANTS
AS
SELECT
    "EV"."Who",
    "EV"."EV_ID",
    "EV"."EV_DAT_Event_Date",
    "s2"."ST_LOC_Stage_Location",
    "s2"."ST_LOC_Checksum",
    "s4"."PR_NAM_Program_Name"
FROM
    nexuses."lEV_Event" "EV"
LEFT JOIN
    anchors."lST_Stage" "s2"
ON
    "s2"."ST_ID" = "EV"."ST_ID_wasHeldAt"
AND
    "s2"."Who" = "EV"."Who"
LEFT JOIN
    anchors."lPR_Program" "s4"
ON
    "s4"."PR_ID" = "EV"."PR_ID_wasPlayed"
AND
    "s4"."Who" = "EV"."Who"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."ic_key_EV_Event_1st" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_EV_Event_1st',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'EV_DAT_Event_Date', "EV_DAT_Event_Date",
        'wasHeldAt_ST_LOC_Checksum', "wasHeldAt_ST_LOC_Checksum",
        'wasPlayed_PR_NAM_Program_Name', "wasPlayed_PR_NAM_Program_Name"
    ),
    COUNT(DISTINCT "EV_ID")
FROM
    nexuses."key_EV_Event_1st"
WHERE
    "EV_DAT_Event_Date" IS NOT NULL
AND
    "wasHeldAt_ST_LOC_Checksum" IS NOT NULL
AND
    "wasPlayed_PR_NAM_Program_Name" IS NOT NULL
GROUP BY
    "Who",
    "EV_DAT_Event_Date",
    "wasHeldAt_ST_LOC_Checksum",
    "wasPlayed_PR_NAM_Program_Name"
HAVING
    COUNT(DISTINCT "EV_ID") > 1
UNION ALL
SELECT
    'key_EV_Event_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'Who', "Who",
        'EV_ID', "EV_ID"
    ),
    COUNT(*)
FROM
    nexuses."key_EV_Event_1st"
GROUP BY
    "Who",
    "EV_ID"
HAVING
    COUNT(*) > 1;
