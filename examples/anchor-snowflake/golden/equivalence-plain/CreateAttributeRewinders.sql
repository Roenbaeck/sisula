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
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name (
    equivalent tinyint,
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_NAM_ST_ID int,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Checksum,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        TABLE(public.eST_NAM_Stage_Name(equivalent)) 
    WHERE
        ST_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_AVG_ST_ID int,
    ST_AVG_EQ tinyint,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
    SELECT
        ST_AVG_ST_ID,
        ST_AVG_EQ,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        public.ST_AVG_Stage_Average
    WHERE
        ST_AVG_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name (
    equivalent tinyint,
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_NAM_AC_ID int,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_EQ,
        AC_NAM_Checksum,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        TABLE(public.eAC_NAM_Actor_Name(equivalent)) 
    WHERE
        AC_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_PLV_AC_ID int,
    AC_PLV_EQ tinyint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
    SELECT
        AC_PLV_AC_ID,
        AC_PLV_EQ,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        public.AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_ChangedAt <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length (
    changingTimepoint date
)
RETURNS TABLE (
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
    SELECT
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        public.PR_LEN_Program_Length
    WHERE
        PR_LEN_ChangedAt <= changingTimepoint
$$
;
