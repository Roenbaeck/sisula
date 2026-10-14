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
CREATE OR REPLACE FUNCTION public."rST_NAM_Stage_Name" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" datetime
)
AS
$$
    SELECT
        "ST_ID",
        "ST_NAM_Stage_Name",
        "ST_NAM_ChangedAt"
    FROM
        public."ST_NAM_Stage_Name"
    WHERE
        "ST_NAM_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_AVG_Stage_Average" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "UTL_ID" tinyint, 
    "ST_AVG_ChangedAt" datetime
)
AS
$$
    SELECT
        "ST_ID",
        "UTL_ID",
        "ST_AVG_ChangedAt"
    FROM
        public."ST_AVG_Stage_Average"
    WHERE
        "ST_AVG_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_NAM_Actor_Name" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" datetime
)
AS
$$
    SELECT
        "AC_ID",
        "AC_NAM_Actor_Name",
        "AC_NAM_ChangedAt"
    FROM
        public."AC_NAM_Actor_Name"
    WHERE
        "AC_NAM_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_PLV_Actor_ProfessionalLevel" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "PLV_ID" tinyint, 
    "AC_PLV_ChangedAt" datetime
)
AS
$$
    SELECT
        "AC_ID",
        "PLV_ID",
        "AC_PLV_ChangedAt"
    FROM
        public."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        "AC_PLV_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_LEN_Program_Length" (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
    SELECT
        "PR_ID",
        "PR_LEN_Program_Length",
        "PR_LEN_ChangedAt"
    FROM
        public."PR_LEN_Program_Length"
    WHERE
        "PR_LEN_ChangedAt" <= changingTimepoint
$$
;
