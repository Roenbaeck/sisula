-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_NAM`,
        `ST_NAM_ST_ID`,
        `ST_NAM_Stage_Name`,
        `ST_NAM_ChangedAt`
    FROM
        public.`ST_NAM_Stage_Name`
    WHERE
        `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_AVG`,
        `ST_AVG_ST_ID`,
        `ST_AVG_UTL_ID`,
        `ST_AVG_ChangedAt`
    FROM
        public.`ST_AVG_Stage_Average`
    WHERE
        `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_NAM`,
        `AC_NAM_AC_ID`,
        `AC_NAM_Actor_Name`,
        `AC_NAM_ChangedAt`
    FROM
        public.`AC_NAM_Actor_Name`
    WHERE
        `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_PLV`,
        `AC_PLV_AC_ID`,
        `AC_PLV_PLV_ID`,
        `AC_PLV_ChangedAt`
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel`
    WHERE
        `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_PR_LEN`,
        `PR_LEN_PR_ID`,
        `PR_LEN_Program_Length`,
        `PR_LEN_ChangedAt`
    FROM
        public.`PR_LEN_Program_Length`
    WHERE
        `PR_LEN_ChangedAt` <= changingTimepoint
)
;
