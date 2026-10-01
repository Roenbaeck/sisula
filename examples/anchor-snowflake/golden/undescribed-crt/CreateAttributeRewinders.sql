-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_DAT_Event_Date_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_EV_DAT,
    EV_DAT_ID,
    EV_DAT_PositedAt,
    EV_DAT_Positor,
    EV_DAT_Reliability,
    EV_DAT_Assertion,
FROM
    public.EV_DAT_Event_Date_Annex
WHERE
    EV_DAT_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_DAT_Event_Date (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Positor tinyint,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_Assertion string,
     int,
    EV_DAT_EV_ID int,
    EV_DAT_Event_Date datetime
)
AS
$$
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion,
    a.,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    TABLE(public.rEV_DAT_Event_Date_Annex(positingTimepoint)) a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
AND
    a.EV_DAT_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_DAT_ID
        ORDER BY a.EV_DAT_PositedAt DESC
    ) = 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_AUD_Event_Audience_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_EV_AUD,
    EV_AUD_ID,
    EV_AUD_PositedAt,
    EV_AUD_Positor,
    EV_AUD_Reliability,
    EV_AUD_Assertion,
FROM
    public.EV_AUD_Event_Audience_Annex
WHERE
    EV_AUD_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_AUD_Event_Audience (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Positor tinyint,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_Assertion string,
     int,
    EV_AUD_EV_ID int,
    EV_AUD_Event_Audience int
)
AS
$$
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion,
    a.,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    TABLE(public.rEV_AUD_Event_Audience_Annex(positingTimepoint)) a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
AND
    a.EV_AUD_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_AUD_ID
        ORDER BY a.EV_AUD_PositedAt DESC
    ) = 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_REV_Event_Revenue_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_EV_REV,
    EV_REV_ID,
    EV_REV_PositedAt,
    EV_REV_Positor,
    EV_REV_Reliability,
    EV_REV_Assertion,
FROM
    public.EV_REV_Event_Revenue_Annex
WHERE
    EV_REV_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rEV_REV_Event_Revenue (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Positor tinyint,
    EV_REV_Reliability decimal(5,2),
    EV_REV_Assertion string,
     int,
    EV_REV_EV_ID int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion,
    a.,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    TABLE(public.rEV_REV_Event_Revenue_Annex(positingTimepoint)) a
ON
    a.EV_REV_ID = p.EV_REV_ID
AND
    a.EV_REV_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_REV_ID
        ORDER BY a.EV_REV_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_NAM_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_NAM_ST_ID,
    ST_NAM_Stage_Name,
    ST_NAM_ChangedAt
FROM
    public.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_NAM_Stage_Name_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_NAM_ID int,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    ST_NAM_ID,
    ST_NAM_ST_ID,
    ST_NAM_Stage_Name,
    ST_NAM_ChangedAt
FROM
    public.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_ST_NAM,
    ST_NAM_ID,
    ST_NAM_PositedAt,
    ST_NAM_Positor,
    ST_NAM_Reliability,
    ST_NAM_Assertion,
FROM
    public.ST_NAM_Stage_Name_Annex
WHERE
    ST_NAM_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_NAM_Stage_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
     int,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(public.rST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
AND
    a.ST_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_NAM_Stage_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Positor tinyint,
    ST_NAM_Reliability decimal(5,2),
    ST_NAM_Assertion string,
     int,
    ST_NAM_ST_ID int,
    ST_NAM_Stage_Name varchar(42),
    ST_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(public.fST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
AND
    a.ST_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preST_NAM_Stage_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS varchar(42)
AS
$$
SELECT
    pre.ST_NAM_Stage_Name
FROM
    TABLE(public.rST_NAM_Stage_Name(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_NAM_ST_ID = id
AND
    pre.ST_NAM_ChangedAt < changingTimepoint
AND
    pre.ST_NAM_Assertion = coalesce(assertion, pre.ST_NAM_Assertion)
ORDER BY
    pre.ST_NAM_ChangedAt DESC,
    pre.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folST_NAM_Stage_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS varchar(42)
AS
$$
SELECT
    fol.ST_NAM_Stage_Name
FROM
    TABLE(public.fST_NAM_Stage_Name(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_NAM_ST_ID = id
AND
    fol.ST_NAM_ChangedAt > changingTimepoint
AND
    fol.ST_NAM_Assertion = coalesce(assertion, fol.ST_NAM_Assertion)
ORDER BY
    fol.ST_NAM_ChangedAt ASC,
    fol.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_LOC_Stage_Location_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_ST_LOC,
    ST_LOC_ID,
    ST_LOC_PositedAt,
    ST_LOC_Positor,
    ST_LOC_Reliability,
    ST_LOC_Assertion,
FROM
    public.ST_LOC_Stage_Location_Annex
WHERE
    ST_LOC_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_LOC_Stage_Location (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Positor tinyint,
    ST_LOC_Reliability decimal(5,2),
    ST_LOC_Assertion string,
     int,
    ST_LOC_ST_ID int,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography
)
AS
$$
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion,
    a.,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    TABLE(public.rST_LOC_Stage_Location_Annex(positingTimepoint)) a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
AND
    a.ST_LOC_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_LOC_ID
        ORDER BY a.ST_LOC_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_AVG_ID int,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_AVG_ST_ID,
    ST_AVG_UTL_ID,
    ST_AVG_ChangedAt
FROM
    public.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_AVG_Stage_Average_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_AVG_ID int,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    ST_AVG_ID,
    ST_AVG_ST_ID,
    ST_AVG_UTL_ID,
    ST_AVG_ChangedAt
FROM
    public.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_ST_AVG,
    ST_AVG_ID,
    ST_AVG_PositedAt,
    ST_AVG_Positor,
    ST_AVG_Reliability,
    ST_AVG_Assertion,
FROM
    public.ST_AVG_Stage_Average_Annex
WHERE
    ST_AVG_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_AVG_Stage_Average (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
     int,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(public.rST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
AND
    a.ST_AVG_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fST_AVG_Stage_Average (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Positor tinyint,
    ST_AVG_Reliability decimal(5,2),
    ST_AVG_Assertion string,
     int,
    ST_AVG_ST_ID int,
    ST_AVG_UTL_ID tinyint, 
    ST_AVG_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(public.fST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
AND
    a.ST_AVG_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preST_AVG_Stage_Average (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS tinyint
AS
$$
SELECT
    pre.ST_AVG_UTL_ID
FROM
    TABLE(public.rST_AVG_Stage_Average(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_AVG_ST_ID = id
AND
    pre.ST_AVG_ChangedAt < changingTimepoint
AND
    pre.ST_AVG_Assertion = coalesce(assertion, pre.ST_AVG_Assertion)
ORDER BY
    pre.ST_AVG_ChangedAt DESC,
    pre.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folST_AVG_Stage_Average (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS tinyint
AS
$$
SELECT
    fol.ST_AVG_UTL_ID
FROM
    TABLE(public.fST_AVG_Stage_Average(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_AVG_ST_ID = id
AND
    fol.ST_AVG_ChangedAt > changingTimepoint
AND
    fol.ST_AVG_Assertion = coalesce(assertion, fol.ST_AVG_Assertion)
ORDER BY
    fol.ST_AVG_ChangedAt ASC,
    fol.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_MIN_Stage_Minimum_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_ST_MIN,
    ST_MIN_ID,
    ST_MIN_PositedAt,
    ST_MIN_Positor,
    ST_MIN_Reliability,
    ST_MIN_Assertion,
FROM
    public.ST_MIN_Stage_Minimum_Annex
WHERE
    ST_MIN_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rST_MIN_Stage_Minimum (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Positor tinyint,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_Assertion string,
     int,
    ST_MIN_ST_ID int,
    ST_MIN_UTL_ID tinyint 
)
AS
$$
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion,
    a.,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    TABLE(public.rST_MIN_Stage_Minimum_Annex(positingTimepoint)) a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
AND
    a.ST_MIN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_MIN_ID
        ORDER BY a.ST_MIN_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_NAM_AC_ID,
    AC_NAM_Actor_Name,
    AC_NAM_ChangedAt
FROM
    public.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    AC_NAM_ID,
    AC_NAM_AC_ID,
    AC_NAM_Actor_Name,
    AC_NAM_ChangedAt
FROM
    public.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_AC_NAM,
    AC_NAM_ID,
    AC_NAM_PositedAt,
    AC_NAM_Positor,
    AC_NAM_Reliability,
    AC_NAM_Assertion,
FROM
    public.AC_NAM_Actor_Name_Annex
WHERE
    AC_NAM_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_NAM_Actor_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
     int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(public.rAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
AND
    a.AC_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_NAM_Actor_Name (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Positor tinyint,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_Assertion string,
     int,
    AC_NAM_AC_ID int,
    AC_NAM_Actor_Name varchar(42),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(public.fAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
AND
    a.AC_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preAC_NAM_Actor_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS varchar(42)
AS
$$
SELECT
    pre.AC_NAM_Actor_Name
FROM
    TABLE(public.rAC_NAM_Actor_Name(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_NAM_AC_ID = id
AND
    pre.AC_NAM_ChangedAt < changingTimepoint
AND
    pre.AC_NAM_Assertion = coalesce(assertion, pre.AC_NAM_Assertion)
ORDER BY
    pre.AC_NAM_ChangedAt DESC,
    pre.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folAC_NAM_Actor_Name (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS varchar(42)
AS
$$
SELECT
    fol.AC_NAM_Actor_Name
FROM
    TABLE(public.fAC_NAM_Actor_Name(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_NAM_AC_ID = id
AND
    fol.AC_NAM_ChangedAt > changingTimepoint
AND
    fol.AC_NAM_Assertion = coalesce(assertion, fol.AC_NAM_Assertion)
ORDER BY
    fol.AC_NAM_ChangedAt ASC,
    fol.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_GEN_Actor_Gender_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_AC_GEN,
    AC_GEN_ID,
    AC_GEN_PositedAt,
    AC_GEN_Positor,
    AC_GEN_Reliability,
    AC_GEN_Assertion,
FROM
    public.AC_GEN_Actor_Gender_Annex
WHERE
    AC_GEN_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_GEN_Actor_Gender (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Positor tinyint,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_Assertion string,
     int,
    AC_GEN_AC_ID int,
    AC_GEN_GEN_ID number(1,0) 
)
AS
$$
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion,
    a.,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    TABLE(public.rAC_GEN_Actor_Gender_Annex(positingTimepoint)) a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
AND
    a.AC_GEN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_GEN_ID
        ORDER BY a.AC_GEN_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_PLV_AC_ID,
    AC_PLV_PLV_ID,
    AC_PLV_ChangedAt
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    AC_PLV_ID,
    AC_PLV_AC_ID,
    AC_PLV_PLV_ID,
    AC_PLV_ChangedAt
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_AC_PLV,
    AC_PLV_ID,
    AC_PLV_PositedAt,
    AC_PLV_Positor,
    AC_PLV_Reliability,
    AC_PLV_Assertion,
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Annex
WHERE
    AC_PLV_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rAC_PLV_Actor_ProfessionalLevel (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
     int,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
AND
    a.AC_PLV_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fAC_PLV_Actor_ProfessionalLevel (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Positor tinyint,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_Assertion string,
     int,
    AC_PLV_AC_ID int,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(public.fAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
AND
    a.AC_PLV_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.preAC_PLV_Actor_ProfessionalLevel (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS tinyint
AS
$$
SELECT
    pre.AC_PLV_PLV_ID
FROM
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_PLV_AC_ID = id
AND
    pre.AC_PLV_ChangedAt < changingTimepoint
AND
    pre.AC_PLV_Assertion = coalesce(assertion, pre.AC_PLV_Assertion)
ORDER BY
    pre.AC_PLV_ChangedAt DESC,
    pre.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folAC_PLV_Actor_ProfessionalLevel (
    id int,
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
RETURNS tinyint
AS
$$
SELECT
    fol.AC_PLV_PLV_ID
FROM
    TABLE(public.fAC_PLV_Actor_ProfessionalLevel(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_PLV_AC_ID = id
AND
    fol.AC_PLV_ChangedAt > changingTimepoint
AND
    fol.AC_PLV_Assertion = coalesce(assertion, fol.AC_PLV_Assertion)
ORDER BY
    fol.AC_PLV_ChangedAt ASC,
    fol.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_NAM_Program_Name_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_PR_NAM,
    PR_NAM_ID,
    PR_NAM_PositedAt,
    PR_NAM_Positor,
    PR_NAM_Reliability,
    PR_NAM_Assertion,
FROM
    public.PR_NAM_Program_Name_Annex
WHERE
    PR_NAM_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_NAM_Program_Name (
    positor tinyint,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Positor tinyint,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_Assertion string,
     int,
    PR_NAM_PR_ID int,
    PR_NAM_Program_Name varchar(42)
)
AS
$$
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion,
    a.,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    TABLE(public.rPR_NAM_Program_Name_Annex(positingTimepoint)) a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
AND
    a.PR_NAM_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_NAM_ID
        ORDER BY a.PR_NAM_PositedAt DESC
    ) = 1
$$
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_LEN_PR_ID,
    PR_LEN_Program_Length,
    PR_LEN_ChangedAt
FROM
    public.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt <= changingTimepoint
$$
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    PR_LEN_ID,
    PR_LEN_PR_ID,
    PR_LEN_Program_Length,
    PR_LEN_ChangedAt
FROM
    public.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt > changingTimepoint
$$
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
     int
)
AS
$$
SELECT
    Metadata_PR_LEN,
    PR_LEN_ID,
    PR_LEN_PositedAt,
    PR_LEN_Positor,
    PR_LEN_Reliability,
    PR_LEN_Assertion,
FROM
    public.PR_LEN_Program_Length_Annex
WHERE
    PR_LEN_PositedAt <= positingTimepoint
$$
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rPR_LEN_Program_Length (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
     int,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(public.rPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
AND
    a.PR_LEN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fPR_LEN_Program_Length (
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Positor tinyint,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_Assertion string,
     int,
    PR_LEN_PR_ID int,
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(public.fPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(public.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
AND
    a.PR_LEN_Positor = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.prePR_LEN_Program_Length (
    id int,
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
RETURNS time
AS
$$
SELECT
    pre.PR_LEN_Program_Length
FROM
    TABLE(public.rPR_LEN_Program_Length(positor, changingTimepoint, positingTimepoint)) pre
WHERE
    pre.PR_LEN_PR_ID = id
AND
    pre.PR_LEN_ChangedAt < changingTimepoint
AND
    pre.PR_LEN_Assertion = coalesce(assertion, pre.PR_LEN_Assertion)
ORDER BY
    pre.PR_LEN_ChangedAt DESC,
    pre.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.folPR_LEN_Program_Length (
    id int,
    positor tinyint,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
RETURNS time
AS
$$
SELECT
    fol.PR_LEN_Program_Length
FROM
    TABLE(public.fPR_LEN_Program_Length(positor, changingTimepoint, positingTimepoint)) fol
WHERE
    fol.PR_LEN_PR_ID = id
AND
    fol.PR_LEN_ChangedAt > changingTimepoint
AND
    fol.PR_LEN_Assertion = coalesce(assertion, fol.PR_LEN_Assertion)
ORDER BY
    fol.PR_LEN_ChangedAt ASC,
    fol.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
