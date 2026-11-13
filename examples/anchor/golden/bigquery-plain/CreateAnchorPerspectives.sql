-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery anchor perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lST_Stage` (
    `ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_Stage_Name` OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.'),
    `ST_LOC_Checksum`,
    `ST_LOC_Stage_Location` OPTIONS(description='Geographic location of the stage as a geography point.'),
    `ST_AVG_ChangedAt`,
    `UTL_Utilization` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `UTL_ID` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `UTL_Utilization` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.'),
    `UTL_ID` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.')
)
OPTIONS(description='A stage or venue where programs are played and events are held.')
AS
SELECT
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
FROM
    public.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`ST_NAM_Stage_Name` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`ST_ID`
            ORDER BY t.`ST_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`ST_AVG_Stage_Average` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`ST_ID`
            ORDER BY t.`ST_AVG_ChangedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
FROM
    public.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rST_NAM_Stage_Name`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY r.`ST_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rST_AVG_Stage_Average`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY r.`ST_AVG_ChangedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nST_Stage`
AS
SELECT
    *
FROM
    public.`pST_Stage`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_Stage` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
FROM (
    SELECT DISTINCT
        h.`ST_ID` AS `ST_ID`,
        CAST(h.`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.`ST_NAM_Stage_Name` h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h.`ST_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`ST_ID` AS `ST_ID`,
        CAST(h.`ST_AVG_ChangedAt` AS datetime) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public.`ST_AVG_Stage_Average` h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h.`ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`ST_Stage` `ST`
ON
    `ST`.`ST_ID` = timepoints.`ST_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`ST_NAM_ChangedAt`) OVER (
            PARTITION BY h.`ST_ID`
            ORDER BY h.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM
        public.`ST_NAM_Stage_Name` h
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
AND
    `NAM`.`ST_NAM_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `NAM`.`until` IS NULL
OR
    `NAM`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY h.`ST_ID`
            ORDER BY h.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM
        public.`ST_AVG_Stage_Average` h
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
AND
    `AVG`.`ST_AVG_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `AVG`.`until` IS NULL
OR
    `AVG`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_Actor` (
    `AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Actor_Name` OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.'),
    `GEN_Gender` OPTIONS(description='Gender of the actor.'),
    `GEN_ID` OPTIONS(description='Gender of the actor.'),
    `AC_PLV_ChangedAt`,
    `PLV_Checksum`,
    `PLV_ProfessionalLevel` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.'),
    `PLV_ID` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.')
)
OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.')
AS
SELECT
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
FROM
    public.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`AC_NAM_Actor_Name` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`AC_ID`
            ORDER BY t.`AC_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`AC_ID`
            ORDER BY t.`AC_PLV_ChangedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
FROM
    public.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rAC_NAM_Actor_Name`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`AC_ID`
            ORDER BY r.`AC_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rAC_PLV_Actor_ProfessionalLevel`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`AC_ID`
            ORDER BY r.`AC_PLV_ChangedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`PLV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_Actor`
AS
SELECT
    *
FROM
    public.`pAC_Actor`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_Actor` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
FROM (
    SELECT DISTINCT
        h.`AC_ID` AS `AC_ID`,
        CAST(h.`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.`AC_NAM_Actor_Name` h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h.`AC_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`AC_ID` AS `AC_ID`,
        CAST(h.`AC_PLV_ChangedAt` AS datetime) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel` h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h.`AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`AC_Actor` `AC`
ON
    `AC`.`AC_ID` = timepoints.`AC_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`AC_NAM_ChangedAt`) OVER (
            PARTITION BY h.`AC_ID`
            ORDER BY h.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM
        public.`AC_NAM_Actor_Name` h
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
AND
    `NAM`.`AC_NAM_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `NAM`.`until` IS NULL
OR
    `NAM`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY h.`AC_ID`
            ORDER BY h.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel` h
) `PLV`
ON
    `PLV`.`AC_ID` = `AC`.`AC_ID`
AND
    `PLV`.`AC_PLV_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `PLV`.`until` IS NULL
OR
    `PLV`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`PLV_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_Program` (
    `PR_ID`,
    `PR_NAM_Program_Name` OPTIONS(description='Name or title of the program.'),
    `PR_LEN_ChangedAt`,
    `PR_LEN_Program_Length` OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.')
)
OPTIONS(description='A program, such as a play, show or concert, that can be played on stages.')
AS
SELECT
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`PR_LEN_Program_Length` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`PR_ID`
            ORDER BY t.`PR_LEN_ChangedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rPR_LEN_Program_Length`(CAST(changingTimepoint AS date)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`PR_ID`
            ORDER BY r.`PR_LEN_ChangedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nPR_Program`
AS
SELECT
    *
FROM
    public.`pPR_Program`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dPR_Program` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM (
    SELECT DISTINCT
        h.`PR_ID` AS `PR_ID`,
        CAST(h.`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public.`PR_LEN_Program_Length` h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h.`PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY h.`PR_ID`
            ORDER BY h.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM
        public.`PR_LEN_Program_Length` h
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`
AND
    `LEN`.`PR_LEN_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS date)
AND (
    `LEN`.`until` IS NULL
OR
    `LEN`.`until` > CAST(timepoints.inspectedTimepoint AS date)
)
)
;
