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
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_PN_Person_1st" (
    "PN_ID",
    "subset_AC_NAM_Actor_Name"
) COPY GRANTS
AS
SELECT
    "PN"."PN_ID",
    "s2"."AC_NAM_Actor_Name"
FROM
    public."PN_Person" "PN"
LEFT JOIN
    public."lAC_subset_PN_of" "s1"
ON
    "s1"."PN_ID_of" = "PN"."PN_ID"
LEFT JOIN
    public."lAC_Actor" "s2"
ON
    "s2"."AC_ID" = "s1"."AC_ID_subset"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of PN_Person at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_PN_Person_1st" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PN_ID" int,
    "subset_AC_NAM_Actor_Name" varchar(42)
)
AS
$$
SELECT
    "PN"."PN_ID",
    "s2"."AC_NAM_Actor_Name"
FROM
    public."PN_Person" "PN"
LEFT JOIN
    TABLE(public."pAC_subset_PN_of"(changingTimepoint)) "s1"
ON
    "s1"."PN_ID_of" = "PN"."PN_ID"
LEFT JOIN
    TABLE(public."pAC_Actor"(changingTimepoint)) "s2"
ON
    "s2"."AC_ID" = "s1"."AC_ID_subset"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_PN_Person_1st" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_PN_Person_1st',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'subset_AC_NAM_Actor_Name', "subset_AC_NAM_Actor_Name"
    ),
    COUNT(DISTINCT "PN_ID")
FROM
    public."key_PN_Person_1st"
WHERE
    "subset_AC_NAM_Actor_Name" IS NOT NULL
GROUP BY
    "subset_AC_NAM_Actor_Name"
HAVING
    COUNT(DISTINCT "PN_ID") > 1
UNION ALL
SELECT
    'key_PN_Person_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'PN_ID', "PN_ID"
    ),
    COUNT(*)
FROM
    public."key_PN_Person_1st"
GROUP BY
    "PN_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_ST_Stage_1st" (
    "ST_ID",
    "ST_LOC_Stage_Location",
    "ST_LOC_Checksum"
) COPY GRANTS
AS
SELECT
    "ST"."ST_ID",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_LOC_Checksum"
FROM
    public."lST_Stage" "ST"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_ST_Stage_1st" (
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
        'ST_LOC_Checksum', "ST_LOC_Checksum"
    ),
    COUNT(DISTINCT "ST_ID")
FROM
    public."key_ST_Stage_1st"
WHERE
    "ST_LOC_Checksum" IS NOT NULL
GROUP BY
    "ST_LOC_Checksum"
HAVING
    COUNT(DISTINCT "ST_ID") > 1
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID"
    ),
    COUNT(*)
FROM
    public."key_ST_Stage_1st"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_ST_Stage_2nd" (
    "ST_ID",
    "ST_NAM_Stage_Name"
) COPY GRANTS
AS
SELECT
    "ST"."ST_ID",
    "ST"."ST_NAM_Stage_Name"
FROM
    public."lST_Stage" "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_ST_Stage_2nd" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_Stage_Name" varchar(42)
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."ST_NAM_Stage_Name"
FROM
    TABLE(public."pST_Stage"(changingTimepoint)) "ST"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_ST_Stage_2nd" (
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
        'ST_NAM_Stage_Name', "ST_NAM_Stage_Name"
    ),
    COUNT(DISTINCT "ST_ID")
FROM
    public."key_ST_Stage_2nd"
WHERE
    "ST_NAM_Stage_Name" IS NOT NULL
GROUP BY
    "ST_NAM_Stage_Name"
HAVING
    COUNT(DISTINCT "ST_ID") > 1
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID"
    ),
    COUNT(*)
FROM
    public."key_ST_Stage_2nd"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_ST_Stage_3rd" (
    "ST_ID",
    "ST_MIN_UTL_Utilization",
    "ST_NAM_Stage_Name"
) COPY GRANTS
AS
SELECT
    "ST"."ST_ID",
    "ST"."ST_MIN_UTL_Utilization",
    "ST"."ST_NAM_Stage_Name"
FROM
    public."lST_Stage" "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_ST_Stage_3rd" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_NAM_Stage_Name" varchar(42)
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."ST_MIN_UTL_Utilization",
    "ST"."ST_NAM_Stage_Name"
FROM
    TABLE(public."pST_Stage"(changingTimepoint)) "ST"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_ST_Stage_3rd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_ST_Stage_3rd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'ST_MIN_UTL_Utilization', "ST_MIN_UTL_Utilization",
        'ST_NAM_Stage_Name', "ST_NAM_Stage_Name"
    ),
    COUNT(DISTINCT "ST_ID")
FROM
    public."key_ST_Stage_3rd"
WHERE
    "ST_MIN_UTL_Utilization" IS NOT NULL
AND
    "ST_NAM_Stage_Name" IS NOT NULL
GROUP BY
    "ST_MIN_UTL_Utilization",
    "ST_NAM_Stage_Name"
HAVING
    COUNT(DISTINCT "ST_ID") > 1
UNION ALL
SELECT
    'key_ST_Stage_3rd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID"
    ),
    COUNT(*)
FROM
    public."key_ST_Stage_3rd"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-- Note: ST_Stage can be wasHeldAt in more than one EV_Event, so an identity can have more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_ST_Stage_4th" (
    "ST_ID",
    "wasHeldAt_EV_DAT_Event_Date"
) COPY GRANTS
AS
SELECT
    "ST"."ST_ID",
    "s1"."EV_DAT_Event_Date"
FROM
    public."lST_Stage" "ST"
LEFT JOIN
    public."lEV_Event" "s1"
ON
    "s1"."ST_ID_wasHeldAt" = "ST"."ST_ID"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_ST_Stage_4th" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_ST_Stage_4th',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'wasHeldAt_EV_DAT_Event_Date', "wasHeldAt_EV_DAT_Event_Date"
    ),
    COUNT(DISTINCT "ST_ID")
FROM
    public."key_ST_Stage_4th"
WHERE
    "wasHeldAt_EV_DAT_Event_Date" IS NOT NULL
GROUP BY
    "wasHeldAt_EV_DAT_Event_Date"
HAVING
    COUNT(DISTINCT "ST_ID") > 1
UNION ALL
SELECT
    'key_ST_Stage_4th',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'ST_ID', "ST_ID"
    ),
    COUNT(*)
FROM
    public."key_ST_Stage_4th"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- The 5th key of ST_Stage is not generated: more than one element is stop 1
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_AC_Actor_1st" (
    "AC_ID",
    "AC_NAM_Actor_Name"
) COPY GRANTS
AS
SELECT
    "AC"."AC_ID",
    "AC"."AC_NAM_Actor_Name"
FROM
    public."lAC_Actor" "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_AC_Actor_1st" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_Actor_Name" varchar(42)
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."AC_NAM_Actor_Name"
FROM
    TABLE(public."pAC_Actor"(changingTimepoint)) "AC"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_AC_Actor_1st" (
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
        'AC_NAM_Actor_Name', "AC_NAM_Actor_Name"
    ),
    COUNT(DISTINCT "AC_ID")
FROM
    public."key_AC_Actor_1st"
WHERE
    "AC_NAM_Actor_Name" IS NOT NULL
GROUP BY
    "AC_NAM_Actor_Name"
HAVING
    COUNT(DISTINCT "AC_ID") > 1
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID"
    ),
    COUNT(*)
FROM
    public."key_AC_Actor_1st"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_AC_Actor_2nd" (
    "AC_ID",
    "with_AC_NAM_Actor_Name"
) COPY GRANTS
AS
SELECT
    "AC"."AC_ID",
    "s2"."AC_NAM_Actor_Name"
FROM
    public."lAC_Actor" "AC"
LEFT JOIN
    public."lAC_partner_AC_with_ONG_currently" "s1"
ON
    "s1"."AC_ID_partner" = "AC"."AC_ID"
LEFT JOIN
    public."lAC_Actor" "s2"
ON
    "s2"."AC_ID" = "s1"."AC_ID_with"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_AC_Actor_2nd" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "with_AC_NAM_Actor_Name" varchar(42)
)
AS
$$
SELECT
    "AC"."AC_ID",
    "s2"."AC_NAM_Actor_Name"
FROM
    TABLE(public."pAC_Actor"(changingTimepoint)) "AC"
LEFT JOIN
    TABLE(public."pAC_partner_AC_with_ONG_currently"(changingTimepoint)) "s1"
ON
    "s1"."AC_ID_partner" = "AC"."AC_ID"
LEFT JOIN
    TABLE(public."pAC_Actor"(changingTimepoint)) "s2"
ON
    "s2"."AC_ID" = "s1"."AC_ID_with"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_AC_Actor_2nd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_AC_Actor_2nd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'with_AC_NAM_Actor_Name', "with_AC_NAM_Actor_Name"
    ),
    COUNT(DISTINCT "AC_ID")
FROM
    public."key_AC_Actor_2nd"
WHERE
    "with_AC_NAM_Actor_Name" IS NOT NULL
GROUP BY
    "with_AC_NAM_Actor_Name"
HAVING
    COUNT(DISTINCT "AC_ID") > 1
UNION ALL
SELECT
    'key_AC_Actor_2nd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID"
    ),
    COUNT(*)
FROM
    public."key_AC_Actor_2nd"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-- Note: AC_parent_AC_child_PAT_having has identifiers other than parent, so it can lead to more than one child and an identity to more than one key
-- Note: AC_part_PR_in_RAT_got has identifiers other than part, so it can lead to more than one in and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_AC_Actor_3rd" (
    "AC_ID",
    "child_in_PR_NAM_Program_Name"
) COPY GRANTS
AS
SELECT
    "AC"."AC_ID",
    "s4"."PR_NAM_Program_Name"
FROM
    public."lAC_Actor" "AC"
LEFT JOIN
    public."lAC_parent_AC_child_PAT_having" "s1"
ON
    "s1"."AC_ID_parent" = "AC"."AC_ID"
LEFT JOIN
    public."lAC_part_PR_in_RAT_got" "s3"
ON
    "s3"."AC_ID_part" = "s1"."AC_ID_child"
LEFT JOIN
    public."lPR_Program" "s4"
ON
    "s4"."PR_ID" = "s3"."PR_ID_in"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_AC_Actor_3rd" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "child_in_PR_NAM_Program_Name" varchar(42)
)
AS
$$
SELECT
    "AC"."AC_ID",
    "s4"."PR_NAM_Program_Name"
FROM
    TABLE(public."pAC_Actor"(changingTimepoint)) "AC"
LEFT JOIN
    TABLE(public."pAC_parent_AC_child_PAT_having"(changingTimepoint)) "s1"
ON
    "s1"."AC_ID_parent" = "AC"."AC_ID"
LEFT JOIN
    TABLE(public."pAC_part_PR_in_RAT_got"(changingTimepoint)) "s3"
ON
    "s3"."AC_ID_part" = "s1"."AC_ID_child"
LEFT JOIN
    TABLE(public."pPR_Program"(changingTimepoint)) "s4"
ON
    "s4"."PR_ID" = "s3"."PR_ID_in"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_AC_Actor_3rd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_AC_Actor_3rd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'child_in_PR_NAM_Program_Name', "child_in_PR_NAM_Program_Name"
    ),
    COUNT(DISTINCT "AC_ID")
FROM
    public."key_AC_Actor_3rd"
WHERE
    "child_in_PR_NAM_Program_Name" IS NOT NULL
GROUP BY
    "child_in_PR_NAM_Program_Name"
HAVING
    COUNT(DISTINCT "AC_ID") > 1
UNION ALL
SELECT
    'key_AC_Actor_3rd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'AC_ID', "AC_ID"
    ),
    COUNT(*)
FROM
    public."key_AC_Actor_3rd"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- The 4th key of AC_Actor is not generated: stop 1: ST_NAM_Stage_Name is not an attribute of AC_Actor
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_PR_Program_1st" (
    "PR_ID",
    "PR_NAM_Program_Name"
) COPY GRANTS
AS
SELECT
    "PR"."PR_ID",
    "PR"."PR_NAM_Program_Name"
FROM
    public."lPR_Program" "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_PR_Program_1st" (
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
        'PR_NAM_Program_Name', "PR_NAM_Program_Name"
    ),
    COUNT(DISTINCT "PR_ID")
FROM
    public."key_PR_Program_1st"
WHERE
    "PR_NAM_Program_Name" IS NOT NULL
GROUP BY
    "PR_NAM_Program_Name"
HAVING
    COUNT(DISTINCT "PR_ID") > 1
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID"
    ),
    COUNT(*)
FROM
    public."key_PR_Program_1st"
GROUP BY
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-- Note: AC_part_PR_in_RAT_got has identifiers other than in, so it can lead to more than one got and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_PR_Program_2nd" (
    "PR_ID",
    "got_RAT_Rating"
) COPY GRANTS
AS
SELECT
    "PR"."PR_ID",
    "s1"."got_RAT_Rating"
FROM
    public."lPR_Program" "PR"
LEFT JOIN
    public."lAC_part_PR_in_RAT_got" "s1"
ON
    "s1"."PR_ID_in" = "PR"."PR_ID"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pkey_PR_Program_2nd" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "got_RAT_Rating" varchar(42)
)
AS
$$
SELECT
    "PR"."PR_ID",
    "s1"."got_RAT_Rating"
FROM
    TABLE(public."pPR_Program"(changingTimepoint)) "PR"
LEFT JOIN
    TABLE(public."pAC_part_PR_in_RAT_got"(changingTimepoint)) "s1"
ON
    "s1"."PR_ID_in" = "PR"."PR_ID"
$$
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_PR_Program_2nd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_PR_Program_2nd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'got_RAT_Rating', "got_RAT_Rating"
    ),
    COUNT(DISTINCT "PR_ID")
FROM
    public."key_PR_Program_2nd"
WHERE
    "got_RAT_Rating" IS NOT NULL
GROUP BY
    "got_RAT_Rating"
HAVING
    COUNT(DISTINCT "PR_ID") > 1
UNION ALL
SELECT
    'key_PR_Program_2nd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'PR_ID', "PR_ID"
    ),
    COUNT(*)
FROM
    public."key_PR_Program_2nd"
GROUP BY
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- The 3rd key of PR_Program is not generated: branch 1 does not end in a value, an attribute or a knot
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_EV_Event_1st" (
    "EV_ID",
    "EV_DAT_Event_Date",
    "wasHeldAt_ST_LOC_Stage_Location",
    "wasHeldAt_ST_LOC_Checksum",
    "wasPlayed_PR_NAM_Program_Name"
) COPY GRANTS
AS
SELECT
    "EV"."EV_ID",
    "EV"."EV_DAT_Event_Date",
    "s2"."ST_LOC_Stage_Location",
    "s2"."ST_LOC_Checksum",
    "s4"."PR_NAM_Program_Name"
FROM
    public."lEV_Event" "EV"
LEFT JOIN
    public."lST_Stage" "s2"
ON
    "s2"."ST_ID" = "EV"."ST_ID_wasHeldAt"
LEFT JOIN
    public."lPR_Program" "s4"
ON
    "s4"."PR_ID" = "EV"."PR_ID_wasPlayed"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_EV_Event_1st" (
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
        'EV_DAT_Event_Date', "EV_DAT_Event_Date",
        'wasHeldAt_ST_LOC_Checksum', "wasHeldAt_ST_LOC_Checksum",
        'wasPlayed_PR_NAM_Program_Name', "wasPlayed_PR_NAM_Program_Name"
    ),
    COUNT(DISTINCT "EV_ID")
FROM
    public."key_EV_Event_1st"
WHERE
    "EV_DAT_Event_Date" IS NOT NULL
AND
    "wasHeldAt_ST_LOC_Checksum" IS NOT NULL
AND
    "wasPlayed_PR_NAM_Program_Name" IS NOT NULL
GROUP BY
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
        'EV_ID', "EV_ID"
    ),
    COUNT(*)
FROM
    public."key_EV_Event_1st"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_EV_Event_2nd" (
    "EV_ID",
    "of_ETY_EventType",
    "EV_DAT_Event_Date"
) COPY GRANTS
AS
SELECT
    "EV"."EV_ID",
    "EV"."of_ETY_EventType",
    "EV"."EV_DAT_Event_Date"
FROM
    public."lEV_Event" "EV"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_EV_Event_2nd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_EV_Event_2nd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'of_ETY_EventType', "of_ETY_EventType",
        'EV_DAT_Event_Date', "EV_DAT_Event_Date"
    ),
    COUNT(DISTINCT "EV_ID")
FROM
    public."key_EV_Event_2nd"
WHERE
    "of_ETY_EventType" IS NOT NULL
AND
    "EV_DAT_Event_Date" IS NOT NULL
GROUP BY
    "of_ETY_EventType",
    "EV_DAT_Event_Date"
HAVING
    COUNT(DISTINCT "EV_ID") > 1
UNION ALL
SELECT
    'key_EV_Event_2nd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID"
    ),
    COUNT(*)
FROM
    public."key_EV_Event_2nd"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."key_EV_Event_3rd" (
    "EV_ID",
    "content_PR_NAM_Program_Name"
) COPY GRANTS
AS
SELECT
    "EV"."EV_ID",
    "s2"."PR_NAM_Program_Name"
FROM
    public."lEV_Event" "EV"
LEFT JOIN
    public."lPR_content_ST_location_EV_of" "s1"
ON
    "s1"."EV_ID_of" = "EV"."EV_ID"
LEFT JOIN
    public."lPR_Program" "s2"
ON
    "s2"."PR_ID" = "s1"."PR_ID_content"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ic_key_EV_Event_3rd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'key_EV_Event_3rd',
    'duplicate natural key',
    OBJECT_CONSTRUCT(
        'content_PR_NAM_Program_Name', "content_PR_NAM_Program_Name"
    ),
    COUNT(DISTINCT "EV_ID")
FROM
    public."key_EV_Event_3rd"
WHERE
    "content_PR_NAM_Program_Name" IS NOT NULL
GROUP BY
    "content_PR_NAM_Program_Name"
HAVING
    COUNT(DISTINCT "EV_ID") > 1
UNION ALL
SELECT
    'key_EV_Event_3rd',
    'more than one natural key',
    OBJECT_CONSTRUCT(
        'EV_ID', "EV_ID"
    ),
    COUNT(*)
FROM
    public."key_EV_Event_3rd"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1;
-- The 4th key of EV_Event is not generated: stop 1: a tie takes two stops in a row in one branch, the role it is entered by and the role it is left by
-- The 5th key of EV_Event is not generated: stop 1 is on the knot ETY_EventType, which a route reaches through a knotted attribute or a knot role instead
