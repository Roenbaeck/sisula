-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_DAT_Event_Date parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eEV_DAT_Event_Date (
    equivalent tinyint
)
RETURNS TABLE (
    EV_DAT_EV_ID int,
    EV_DAT_EQ tinyint,
    EV_DAT_Event_Date datetime
)
AS
$$
    SELECT
        EV_DAT_EV_ID,
        EV_DAT_EQ,
        EV_DAT_Event_Date
    FROM
        public.EV_DAT_Event_Date
    WHERE
        EV_DAT_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eEV_REV_Event_Revenue (
    equivalent tinyint
)
RETURNS TABLE (
    EV_REV_EV_ID int,
    EV_REV_EQ tinyint,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
    SELECT
        EV_REV_EV_ID,
        EV_REV_EQ,
        EV_REV_Event_Revenue
    FROM
        public.EV_REV_Event_Revenue
    WHERE
        EV_REV_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eST_NAM_Stage_Name (
    equivalent tinyint
)
RETURNS TABLE (
    ST_NAM_ST_ID int,
    ST_NAM_EQ tinyint,
    ST_NAM_Checksum numeric(19,0),
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42)
)
AS
$$
    SELECT
        ST_NAM_ST_ID,
        ST_NAM_EQ,
        ST_NAM_Checksum,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        public.ST_NAM_Stage_Name
    WHERE
        ST_NAM_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eST_LOC_Stage_Location (
    equivalent tinyint
)
RETURNS TABLE (
    ST_LOC_ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography
)
AS
$$
    SELECT
        ST_LOC_ST_ID,
        ST_LOC_EQ,
        ST_LOC_Checksum,
        ST_LOC_Stage_Location
    FROM
        public.ST_LOC_Stage_Location
    WHERE
        ST_LOC_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.eAC_NAM_Actor_Name (
    equivalent tinyint
)
RETURNS TABLE (
    AC_NAM_AC_ID int,
    AC_NAM_EQ tinyint,
    AC_NAM_Checksum numeric(19,0),
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42)
)
AS
$$
    SELECT
        AC_NAM_AC_ID,
        AC_NAM_EQ,
        AC_NAM_Checksum,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        public.AC_NAM_Actor_Name
    WHERE
        AC_NAM_EQ = equivalent
$$
;
