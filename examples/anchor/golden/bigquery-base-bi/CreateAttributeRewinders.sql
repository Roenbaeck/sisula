-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION public.`rEV_DAT_Event_Date_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_DAT`,
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Reliability`
FROM
    public.`EV_DAT_Event_Date_Annex`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_DAT_Event_Date` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Reliability`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`
FROM
    public.`EV_DAT_Event_Date_Posit` p
JOIN
    public.`rEV_DAT_Event_Date_Annex`(positingTimepoint) a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_DAT_ID`
        ORDER BY a.`EV_DAT_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_AUD_Event_Audience_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_AUD`,
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Reliability`
FROM
    public.`EV_AUD_Event_Audience_Annex`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_AUD_Event_Audience` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Reliability`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`
FROM
    public.`EV_AUD_Event_Audience_Posit` p
JOIN
    public.`rEV_AUD_Event_Audience_Annex`(positingTimepoint) a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_AUD_ID`
        ORDER BY a.`EV_AUD_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_REV_Event_Revenue_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_REV`,
    `EV_REV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Reliability`
FROM
    public.`EV_REV_Event_Revenue_Annex`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_REV_Event_Revenue` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Reliability`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`
FROM
    public.`EV_REV_Event_Revenue_Posit` p
JOIN
    public.`rEV_REV_Event_Revenue_Annex`(positingTimepoint) a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_REV_ID`
        ORDER BY a.`EV_REV_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    public.`ST_NAM_Stage_Name_Posit`
WHERE
    `ST_NAM_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_NAM_Stage_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    public.`ST_NAM_Stage_Name_Posit`
WHERE
    `ST_NAM_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_NAM`,
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Reliability`
FROM
    public.`ST_NAM_Stage_Name_Annex`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Reliability`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    public.`rST_NAM_Stage_Name_Posit`(changingTimepoint) p
JOIN
    public.`rST_NAM_Stage_Name_Annex`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_NAM_Stage_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Reliability`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    public.`fST_NAM_Stage_Name_Posit`(changingTimepoint) p
JOIN
    public.`rST_NAM_Stage_Name_Annex`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`preST_NAM_Stage_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_NAM_Stage_Name`
FROM
    public.`rST_NAM_Stage_Name`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_NAM_ST_ID` = id
AND
    pre.`ST_NAM_ChangedAt` < changingTimepoint
AND
    pre.`ST_NAM_Reliability` = 1
ORDER BY
    pre.`ST_NAM_ChangedAt` DESC,
    pre.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folST_NAM_Stage_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_NAM_Stage_Name`
FROM
    public.`fST_NAM_Stage_Name`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_NAM_ST_ID` = id
AND
    fol.`ST_NAM_ChangedAt` > changingTimepoint
AND
    fol.`ST_NAM_Reliability` = 1
ORDER BY
    fol.`ST_NAM_ChangedAt` ASC,
    fol.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_LOC_Stage_Location_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_LOC`,
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Reliability`
FROM
    public.`ST_LOC_Stage_Location_Annex`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_LOC_Stage_Location` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Reliability`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`
FROM
    public.`ST_LOC_Stage_Location_Posit` p
JOIN
    public.`rST_LOC_Stage_Location_Annex`(positingTimepoint) a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_LOC_ID`
        ORDER BY a.`ST_LOC_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    public.`ST_AVG_Stage_Average_Posit`
WHERE
    `ST_AVG_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_AVG_Stage_Average_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    public.`ST_AVG_Stage_Average_Posit`
WHERE
    `ST_AVG_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_AVG`,
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Reliability`
FROM
    public.`ST_AVG_Stage_Average_Annex`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Reliability`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    public.`rST_AVG_Stage_Average_Posit`(changingTimepoint) p
JOIN
    public.`rST_AVG_Stage_Average_Annex`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_AVG_Stage_Average` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Reliability`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    public.`fST_AVG_Stage_Average_Posit`(changingTimepoint) p
JOIN
    public.`rST_AVG_Stage_Average_Annex`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`preST_AVG_Stage_Average` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_AVG_UTL_ID`
FROM
    public.`rST_AVG_Stage_Average`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_AVG_ST_ID` = id
AND
    pre.`ST_AVG_ChangedAt` < changingTimepoint
AND
    pre.`ST_AVG_Reliability` = 1
ORDER BY
    pre.`ST_AVG_ChangedAt` DESC,
    pre.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folST_AVG_Stage_Average` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_AVG_UTL_ID`
FROM
    public.`fST_AVG_Stage_Average`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_AVG_ST_ID` = id
AND
    fol.`ST_AVG_ChangedAt` > changingTimepoint
AND
    fol.`ST_AVG_Reliability` = 1
ORDER BY
    fol.`ST_AVG_ChangedAt` ASC,
    fol.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_MIN_Stage_Minimum_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_MIN`,
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Reliability`
FROM
    public.`ST_MIN_Stage_Minimum_Annex`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_MIN_Stage_Minimum` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Reliability`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`
FROM
    public.`ST_MIN_Stage_Minimum_Posit` p
JOIN
    public.`rST_MIN_Stage_Minimum_Annex`(positingTimepoint) a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_MIN_ID`
        ORDER BY a.`ST_MIN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    public.`AC_NAM_Actor_Name_Posit`
WHERE
    `AC_NAM_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_NAM_Actor_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    public.`AC_NAM_Actor_Name_Posit`
WHERE
    `AC_NAM_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_NAM`,
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Reliability`
FROM
    public.`AC_NAM_Actor_Name_Annex`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Reliability`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    public.`rAC_NAM_Actor_Name_Posit`(changingTimepoint) p
JOIN
    public.`rAC_NAM_Actor_Name_Annex`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_NAM_Actor_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Reliability`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    public.`fAC_NAM_Actor_Name_Posit`(changingTimepoint) p
JOIN
    public.`rAC_NAM_Actor_Name_Annex`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`preAC_NAM_Actor_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_NAM_Actor_Name`
FROM
    public.`rAC_NAM_Actor_Name`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_NAM_AC_ID` = id
AND
    pre.`AC_NAM_ChangedAt` < changingTimepoint
AND
    pre.`AC_NAM_Reliability` = 1
ORDER BY
    pre.`AC_NAM_ChangedAt` DESC,
    pre.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folAC_NAM_Actor_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_NAM_Actor_Name`
FROM
    public.`fAC_NAM_Actor_Name`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_NAM_AC_ID` = id
AND
    fol.`AC_NAM_ChangedAt` > changingTimepoint
AND
    fol.`AC_NAM_Reliability` = 1
ORDER BY
    fol.`AC_NAM_ChangedAt` ASC,
    fol.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_GEN_Actor_Gender_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_GEN`,
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Reliability`
FROM
    public.`AC_GEN_Actor_Gender_Annex`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_GEN_Actor_Gender` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Reliability`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`
FROM
    public.`AC_GEN_Actor_Gender_Posit` p
JOIN
    public.`rAC_GEN_Actor_Gender_Annex`(positingTimepoint) a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_GEN_ID`
        ORDER BY a.`AC_GEN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
WHERE
    `AC_PLV_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_PLV_Actor_ProfessionalLevel_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
WHERE
    `AC_PLV_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_PLV`,
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Reliability`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Reliability`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    public.`rAC_PLV_Actor_ProfessionalLevel_Posit`(changingTimepoint) p
JOIN
    public.`rAC_PLV_Actor_ProfessionalLevel_Annex`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Reliability`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    public.`fAC_PLV_Actor_ProfessionalLevel_Posit`(changingTimepoint) p
JOIN
    public.`rAC_PLV_Actor_ProfessionalLevel_Annex`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`preAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_PLV_PLV_ID`
FROM
    public.`rAC_PLV_Actor_ProfessionalLevel`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_PLV_AC_ID` = id
AND
    pre.`AC_PLV_ChangedAt` < changingTimepoint
AND
    pre.`AC_PLV_Reliability` = 1
ORDER BY
    pre.`AC_PLV_ChangedAt` DESC,
    pre.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_PLV_PLV_ID`
FROM
    public.`fAC_PLV_Actor_ProfessionalLevel`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_PLV_AC_ID` = id
AND
    fol.`AC_PLV_ChangedAt` > changingTimepoint
AND
    fol.`AC_PLV_Reliability` = 1
ORDER BY
    fol.`AC_PLV_ChangedAt` ASC,
    fol.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_NAM_Program_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_NAM`,
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Reliability`
FROM
    public.`PR_NAM_Program_Name_Annex`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_NAM_Program_Name` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Reliability`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`
FROM
    public.`PR_NAM_Program_Name_Posit` p
JOIN
    public.`rPR_NAM_Program_Name_Annex`(positingTimepoint) a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_NAM_ID`
        ORDER BY a.`PR_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    public.`PR_LEN_Program_Length_Posit`
WHERE
    `PR_LEN_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fPR_LEN_Program_Length_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    public.`PR_LEN_Program_Length_Posit`
WHERE
    `PR_LEN_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_LEN`,
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Reliability`
FROM
    public.`PR_LEN_Program_Length_Annex`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Reliability`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    public.`rPR_LEN_Program_Length_Posit`(changingTimepoint) p
JOIN
    public.`rPR_LEN_Program_Length_Annex`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fPR_LEN_Program_Length` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Reliability`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    public.`fPR_LEN_Program_Length_Posit`(changingTimepoint) p
JOIN
    public.`rPR_LEN_Program_Length_Annex`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`prePR_LEN_Program_Length` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`PR_LEN_Program_Length`
FROM
    public.`rPR_LEN_Program_Length`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`PR_LEN_PR_ID` = id
AND
    pre.`PR_LEN_ChangedAt` < changingTimepoint
AND
    pre.`PR_LEN_Reliability` = 1
ORDER BY
    pre.`PR_LEN_ChangedAt` DESC,
    pre.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folPR_LEN_Program_Length` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`PR_LEN_Program_Length`
FROM
    public.`fPR_LEN_Program_Length`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`PR_LEN_PR_ID` = id
AND
    fol.`PR_LEN_ChangedAt` > changingTimepoint
AND
    fol.`PR_LEN_Reliability` = 1
ORDER BY
    fol.`PR_LEN_ChangedAt` ASC,
    fol.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
