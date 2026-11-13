-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION public.`tST_Stage` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
FROM
    public.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rST_NAM_Stage_Name`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY
                r.`ST_NAM_ChangedAt` DESC,
                r.`ST_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rST_LOC_Stage_Location`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY
                r.`ST_LOC_PositedAt` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rST_AVG_Stage_Average`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_AVG_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY
                r.`ST_AVG_ChangedAt` DESC,
                r.`ST_AVG_PositedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rST_MIN_Stage_Minimum`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY
                r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`
)
;
CREATE OR REPLACE VIEW public.`lST_Stage` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    public.`tST_Stage`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION public.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.`ST_ID`,
    `ST`.`ST_NAM_ID`,
    `ST`.`ST_NAM_ChangedAt`,
    `ST`.`ST_NAM_PositedAt`,
    `ST`.`ST_NAM_Reliability`,
    `ST`.`ST_NAM_Stage_Name`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Reliability`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Stage_Location`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Reliability`,
    `ST`.`UTL_Utilization`,
    `ST`.`UTL_ID`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Reliability`,
    `ST`.`UTL_Utilization`,
    `ST`.`UTL_ID`
FROM
    public.`tST_Stage`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
)
;
CREATE OR REPLACE VIEW public.`nST_Stage` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    public.`tST_Stage`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION public.`dST_Stage` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
FROM (
    SELECT DISTINCT
        `ST_ID` AS `ST_ID`,
        CAST(`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.`ST_NAM_Stage_Name`
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        `ST_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `ST_ID` AS `ST_ID`,
        CAST(`ST_AVG_ChangedAt` AS datetime) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public.`ST_AVG_Stage_Average`
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        `ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`ST_Stage` `ST`
ON
    `ST`.`ST_ID` = timepoints.`ST_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`ST_NAM_ChangedAt`) OVER (
            PARTITION BY x.`ST_ID`
            ORDER BY x.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            public.`rST_NAM_Stage_Name`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_NAM_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_ID`, r.`ST_NAM_ChangedAt`
                ORDER BY r.`ST_NAM_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rST_LOC_Stage_Location`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY r.`ST_LOC_PositedAt` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY x.`ST_ID`
            ORDER BY x.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            public.`rST_AVG_Stage_Average`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_AVG_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_ID`, r.`ST_AVG_ChangedAt`
                ORDER BY r.`ST_AVG_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rST_MIN_Stage_Minimum`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_ID`
            ORDER BY r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION public.`tAC_Actor` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
FROM
    public.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rAC_NAM_Actor_Name`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_ID`
            ORDER BY
                r.`AC_NAM_ChangedAt` DESC,
                r.`AC_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rAC_GEN_Actor_Gender`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_ID`
            ORDER BY
                r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rAC_PLV_Actor_ProfessionalLevel`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_PLV_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_ID`
            ORDER BY
                r.`AC_PLV_ChangedAt` DESC,
                r.`AC_PLV_PositedAt` DESC
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
CREATE OR REPLACE VIEW public.`lAC_Actor` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    public.`tAC_Actor`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION public.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.`AC_ID`,
    `AC`.`AC_NAM_ID`,
    `AC`.`AC_NAM_ChangedAt`,
    `AC`.`AC_NAM_PositedAt`,
    `AC`.`AC_NAM_Reliability`,
    `AC`.`AC_NAM_Actor_Name`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Reliability`,
    `AC`.`GEN_Gender`,
    `AC`.`GEN_ID`,
    `AC`.`AC_PLV_ID`,
    `AC`.`AC_PLV_ChangedAt`,
    `AC`.`AC_PLV_PositedAt`,
    `AC`.`AC_PLV_Reliability`,
    `AC`.`PLV_Checksum`,
    `AC`.`PLV_ProfessionalLevel`,
    `AC`.`PLV_ID`
FROM
    public.`tAC_Actor`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
)
;
CREATE OR REPLACE VIEW public.`nAC_Actor` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    public.`tAC_Actor`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION public.`dAC_Actor` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
FROM (
    SELECT DISTINCT
        `AC_ID` AS `AC_ID`,
        CAST(`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.`AC_NAM_Actor_Name`
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        `AC_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `AC_ID` AS `AC_ID`,
        CAST(`AC_PLV_ChangedAt` AS datetime) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel`
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        `AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`AC_Actor` `AC`
ON
    `AC`.`AC_ID` = timepoints.`AC_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`AC_NAM_ChangedAt`) OVER (
            PARTITION BY x.`AC_ID`
            ORDER BY x.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            public.`rAC_NAM_Actor_Name`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_NAM_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_ID`, r.`AC_NAM_ChangedAt`
                ORDER BY r.`AC_NAM_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rAC_GEN_Actor_Gender`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_ID`
            ORDER BY r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY x.`AC_ID`
            ORDER BY x.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            public.`rAC_PLV_Actor_ProfessionalLevel`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_PLV_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_ID`, r.`AC_PLV_ChangedAt`
                ORDER BY r.`AC_PLV_PositedAt` DESC
            ) = 1
    ) x
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
CREATE OR REPLACE TABLE FUNCTION public.`tPR_Program` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rPR_NAM_Program_Name`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_ID`
            ORDER BY
                r.`PR_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rPR_LEN_Program_Length`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_LEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_ID`
            ORDER BY
                r.`PR_LEN_ChangedAt` DESC,
                r.`PR_LEN_PositedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`
)
;
CREATE OR REPLACE VIEW public.`lPR_Program` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    public.`tPR_Program`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION public.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.`PR_ID`,
    `PR`.`PR_NAM_ID`,
    `PR`.`PR_NAM_PositedAt`,
    `PR`.`PR_NAM_Reliability`,
    `PR`.`PR_NAM_Program_Name`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Reliability`,
    `PR`.`PR_LEN_Program_Length`
FROM
    public.`tPR_Program`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
)
;
CREATE OR REPLACE VIEW public.`nPR_Program` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    public.`tPR_Program`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION public.`dPR_Program` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Program_Length`
FROM (
    SELECT DISTINCT
        `PR_ID` AS `PR_ID`,
        CAST(`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public.`PR_LEN_Program_Length`
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        `PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rPR_NAM_Program_Name`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_ID`
            ORDER BY r.`PR_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY x.`PR_ID`
            ORDER BY x.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            public.`rPR_LEN_Program_Length`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_LEN_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`PR_ID`, r.`PR_LEN_ChangedAt`
                ORDER BY r.`PR_LEN_PositedAt` DESC
            ) = 1
    ) x
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
