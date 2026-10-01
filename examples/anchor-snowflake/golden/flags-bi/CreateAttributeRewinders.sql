-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_DAT,
    EV_DAT_ID,
    EV_DAT_PositedAt,
    EV_DAT_Reliability
FROM
    attributes.EV_DAT_Event_Date_Annex
WHERE
    EV_DAT_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_DAT int,
    EV_DAT_ID int,
    EV_DAT_PositedAt datetime,
    EV_DAT_Reliability decimal(5,2),
    EV_DAT_EV_ID numeric(12,0),
    EV_DAT_Event_Date datetime
)
AS
$$
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Reliability,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    attributes.EV_DAT_Event_Date_Posit p
JOIN
    TABLE(attributes.rEV_DAT_Event_Date_Annex(positingTimepoint)) a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_DAT_ID
        ORDER BY a.EV_DAT_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_AUD,
    EV_AUD_ID,
    EV_AUD_PositedAt,
    EV_AUD_Reliability
FROM
    attributes.EV_AUD_Event_Audience_Annex
WHERE
    EV_AUD_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_AUD int,
    EV_AUD_ID int,
    EV_AUD_PositedAt datetime,
    EV_AUD_Reliability decimal(5,2),
    EV_AUD_EV_ID numeric(12,0),
    EV_AUD_Event_Audience int
)
AS
$$
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Reliability,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    attributes.EV_AUD_Event_Audience_Posit p
JOIN
    TABLE(attributes.rEV_AUD_Event_Audience_Annex(positingTimepoint)) a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_AUD_ID
        ORDER BY a.EV_AUD_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_REV,
    EV_REV_ID,
    EV_REV_PositedAt,
    EV_REV_Reliability
FROM
    attributes.EV_REV_Event_Revenue_Annex
WHERE
    EV_REV_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_REV int,
    EV_REV_ID int,
    EV_REV_PositedAt datetime,
    EV_REV_Reliability decimal(5,2),
    EV_REV_EV_ID numeric(12,0),
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Reliability,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    attributes.EV_REV_Event_Revenue_Posit p
JOIN
    TABLE(attributes.rEV_REV_Event_Revenue_Annex(positingTimepoint)) a
ON
    a.EV_REV_ID = p.EV_REV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_REV_ID
        ORDER BY a.EV_REV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    EV_STA_ID int,
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    EV_STA_ID,
    EV_STA_EV_ID,
    EV_STA_Event_Status,
    EV_STA_ChangedAt
FROM
    attributes.EV_STA_Event_Status_Posit
WHERE
    EV_STA_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    EV_STA_ID int,
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    EV_STA_ID,
    EV_STA_EV_ID,
    EV_STA_Event_Status,
    EV_STA_ChangedAt
FROM
    attributes.EV_STA_Event_Status_Posit
WHERE
    EV_STA_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_STA int,
    EV_STA_ID int,
    EV_STA_PositedAt datetime,
    EV_STA_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_STA,
    EV_STA_ID,
    EV_STA_PositedAt,
    EV_STA_Reliability
FROM
    attributes.EV_STA_Event_Status_Annex
WHERE
    EV_STA_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_STA int,
    EV_STA_ID int,
    EV_STA_PositedAt datetime,
    EV_STA_Reliability decimal(5,2),
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Reliability,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status,
    p.EV_STA_ChangedAt
FROM
    TABLE(attributes.rEV_STA_Event_Status_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_STA_Event_Status_Annex(positingTimepoint)) a
ON
    a.EV_STA_ID = p.EV_STA_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_STA_ID
        ORDER BY a.EV_STA_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_STA int,
    EV_STA_ID int,
    EV_STA_PositedAt datetime,
    EV_STA_Reliability decimal(5,2),
    EV_STA_EV_ID numeric(12,0),
    EV_STA_Event_Status varchar(20),
    EV_STA_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Reliability,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status,
    p.EV_STA_ChangedAt
FROM
    TABLE(attributes.fEV_STA_Event_Status_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_STA_Event_Status_Annex(positingTimepoint)) a
ON
    a.EV_STA_ID = p.EV_STA_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_STA_ID
        ORDER BY a.EV_STA_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preEV_STA_Event_Status (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS varchar(20)
AS
$$
SELECT
    pre.EV_STA_Event_Status
FROM
    TABLE(attributes.rEV_STA_Event_Status(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.EV_STA_EV_ID = id
AND
    pre.EV_STA_ChangedAt < changingTimepoint
AND
    pre.EV_STA_Reliability = 1
ORDER BY
    pre.EV_STA_ChangedAt DESC,
    pre.EV_STA_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folEV_STA_Event_Status (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS varchar(20)
AS
$$
SELECT
    fol.EV_STA_Event_Status
FROM
    TABLE(attributes.fEV_STA_Event_Status(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.EV_STA_EV_ID = id
AND
    fol.EV_STA_ChangedAt > changingTimepoint
AND
    fol.EV_STA_Reliability = 1
ORDER BY
    fol.EV_STA_ChangedAt ASC,
    fol.EV_STA_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_UTL int,
    EV_UTL_ID int,
    EV_UTL_PositedAt datetime,
    EV_UTL_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_UTL,
    EV_UTL_ID,
    EV_UTL_PositedAt,
    EV_UTL_Reliability
FROM
    attributes.EV_UTL_Event_Utilization_Annex
WHERE
    EV_UTL_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_UTL int,
    EV_UTL_ID int,
    EV_UTL_PositedAt datetime,
    EV_UTL_Reliability decimal(5,2),
    EV_UTL_EV_ID numeric(12,0),
    EV_UTL_UTL_ID tinyint 
)
AS
$$
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Reliability,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID
FROM
    attributes.EV_UTL_Event_Utilization_Posit p
JOIN
    TABLE(attributes.rEV_UTL_Event_Utilization_Annex(positingTimepoint)) a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_UTL_ID
        ORDER BY a.EV_UTL_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Posit (
    changingTimepoint date
)
RETURNS TABLE (
    EV_LVL_ID int,
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    EV_LVL_ID,
    EV_LVL_EV_ID,
    EV_LVL_PLV_ID,
    EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Event_Level_Posit
WHERE
    EV_LVL_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level_Posit (
    changingTimepoint date
)
RETURNS TABLE (
    EV_LVL_ID int,
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    EV_LVL_ID,
    EV_LVL_EV_ID,
    EV_LVL_PLV_ID,
    EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Event_Level_Posit
WHERE
    EV_LVL_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_LVL int,
    EV_LVL_ID int,
    EV_LVL_PositedAt datetime,
    EV_LVL_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_LVL,
    EV_LVL_ID,
    EV_LVL_PositedAt,
    EV_LVL_Reliability
FROM
    attributes.EV_LVL_Event_Level_Annex
WHERE
    EV_LVL_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level (
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_LVL int,
    EV_LVL_ID int,
    EV_LVL_PositedAt datetime,
    EV_LVL_Reliability decimal(5,2),
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Reliability,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt
FROM
    TABLE(attributes.rEV_LVL_Event_Level_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_LVL_Event_Level_Annex(positingTimepoint)) a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_LVL_ID
        ORDER BY a.EV_LVL_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level (
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_EV_LVL int,
    EV_LVL_ID int,
    EV_LVL_PositedAt datetime,
    EV_LVL_Reliability decimal(5,2),
    EV_LVL_EV_ID numeric(12,0),
    EV_LVL_PLV_ID tinyint, 
    EV_LVL_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Reliability,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt
FROM
    TABLE(attributes.fEV_LVL_Event_Level_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rEV_LVL_Event_Level_Annex(positingTimepoint)) a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_LVL_ID
        ORDER BY a.EV_LVL_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preEV_LVL_Event_Level (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS tinyint
AS
$$
SELECT
    pre.EV_LVL_PLV_ID
FROM
    TABLE(attributes.rEV_LVL_Event_Level(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.EV_LVL_EV_ID = id
AND
    pre.EV_LVL_ChangedAt < changingTimepoint
AND
    pre.EV_LVL_Reliability = 1
ORDER BY
    pre.EV_LVL_ChangedAt DESC,
    pre.EV_LVL_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folEV_LVL_Event_Level (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS tinyint
AS
$$
SELECT
    fol.EV_LVL_PLV_ID
FROM
    TABLE(attributes.fEV_LVL_Event_Level(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.EV_LVL_EV_ID = id
AND
    fol.EV_LVL_ChangedAt > changingTimepoint
AND
    fol.EV_LVL_Reliability = 1
ORDER BY
    fol.EV_LVL_ChangedAt ASC,
    fol.EV_LVL_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Posit (
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
    attributes.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name_Posit (
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
    attributes.ST_NAM_Stage_Name_Posit
WHERE
    ST_NAM_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_ST_NAM,
    ST_NAM_ID,
    ST_NAM_PositedAt,
    ST_NAM_Reliability
FROM
    attributes.ST_NAM_Stage_Name_Annex
WHERE
    ST_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
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
    a.ST_NAM_Reliability,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(attributes.rST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_NAM int,
    ST_NAM_ID int,
    ST_NAM_PositedAt datetime,
    ST_NAM_Reliability decimal(5,2),
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
    a.ST_NAM_Reliability,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt
FROM
    TABLE(attributes.fST_NAM_Stage_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_NAM_Stage_Name_Annex(positingTimepoint)) a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_NAM_ID
        ORDER BY a.ST_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preST_NAM_Stage_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS varchar(42)
AS
$$
SELECT
    pre.ST_NAM_Stage_Name
FROM
    TABLE(attributes.rST_NAM_Stage_Name(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_NAM_ST_ID = id
AND
    pre.ST_NAM_ChangedAt < changingTimepoint
AND
    pre.ST_NAM_Reliability = 1
ORDER BY
    pre.ST_NAM_ChangedAt DESC,
    pre.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folST_NAM_Stage_Name (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS varchar(42)
AS
$$
SELECT
    fol.ST_NAM_Stage_Name
FROM
    TABLE(attributes.fST_NAM_Stage_Name(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_NAM_ST_ID = id
AND
    fol.ST_NAM_ChangedAt > changingTimepoint
AND
    fol.ST_NAM_Reliability = 1
ORDER BY
    fol.ST_NAM_ChangedAt ASC,
    fol.ST_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_ST_LOC,
    ST_LOC_ID,
    ST_LOC_PositedAt,
    ST_LOC_Reliability
FROM
    attributes.ST_LOC_Stage_Location_Annex
WHERE
    ST_LOC_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_LOC int,
    ST_LOC_ID int,
    ST_LOC_PositedAt datetime,
    ST_LOC_Reliability decimal(5,2),
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
    a.ST_LOC_Reliability,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    attributes.ST_LOC_Stage_Location_Posit p
JOIN
    TABLE(attributes.rST_LOC_Stage_Location_Annex(positingTimepoint)) a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_LOC_ID
        ORDER BY a.ST_LOC_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Posit (
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
    attributes.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average_Posit (
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
    attributes.ST_AVG_Stage_Average_Posit
WHERE
    ST_AVG_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_ST_AVG,
    ST_AVG_ID,
    ST_AVG_PositedAt,
    ST_AVG_Reliability
FROM
    attributes.ST_AVG_Stage_Average_Annex
WHERE
    ST_AVG_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
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
    a.ST_AVG_Reliability,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(attributes.rST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_AVG int,
    ST_AVG_ID int,
    ST_AVG_PositedAt datetime,
    ST_AVG_Reliability decimal(5,2),
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
    a.ST_AVG_Reliability,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt
FROM
    TABLE(attributes.fST_AVG_Stage_Average_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rST_AVG_Stage_Average_Annex(positingTimepoint)) a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_AVG_ID
        ORDER BY a.ST_AVG_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preST_AVG_Stage_Average (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS tinyint
AS
$$
SELECT
    pre.ST_AVG_UTL_ID
FROM
    TABLE(attributes.rST_AVG_Stage_Average(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.ST_AVG_ST_ID = id
AND
    pre.ST_AVG_ChangedAt < changingTimepoint
AND
    pre.ST_AVG_Reliability = 1
ORDER BY
    pre.ST_AVG_ChangedAt DESC,
    pre.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folST_AVG_Stage_Average (
    id int,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS tinyint
AS
$$
SELECT
    fol.ST_AVG_UTL_ID
FROM
    TABLE(attributes.fST_AVG_Stage_Average(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.ST_AVG_ST_ID = id
AND
    fol.ST_AVG_ChangedAt > changingTimepoint
AND
    fol.ST_AVG_Reliability = 1
ORDER BY
    fol.ST_AVG_ChangedAt ASC,
    fol.ST_AVG_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_ST_MIN,
    ST_MIN_ID,
    ST_MIN_PositedAt,
    ST_MIN_Reliability
FROM
    attributes.ST_MIN_Stage_Minimum_Annex
WHERE
    ST_MIN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_ST_MIN int,
    ST_MIN_ID int,
    ST_MIN_PositedAt datetime,
    ST_MIN_Reliability decimal(5,2),
    ST_MIN_ST_ID int,
    ST_MIN_UTL_ID tinyint 
)
AS
$$
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Reliability,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    attributes.ST_MIN_Stage_Minimum_Posit p
JOIN
    TABLE(attributes.rST_MIN_Stage_Minimum_Annex(positingTimepoint)) a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_MIN_ID
        ORDER BY a.ST_MIN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
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
    attributes.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_NAM_ID int,
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
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
    attributes.AC_NAM_Actor_Name_Posit
WHERE
    AC_NAM_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_NAM,
    AC_NAM_ID,
    AC_NAM_PositedAt,
    AC_NAM_Reliability
FROM
    attributes.AC_NAM_Actor_Name_Annex
WHERE
    AC_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Reliability,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(attributes.rAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_NAM int,
    AC_NAM_ID int,
    AC_NAM_PositedAt datetime,
    AC_NAM_Reliability decimal(5,2),
    AC_NAM_AC_ID smallint,
    AC_NAM_Actor_Name varbinary(max),
    AC_NAM_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Reliability,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt
FROM
    TABLE(attributes.fAC_NAM_Actor_Name_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_NAM_Actor_Name_Annex(positingTimepoint)) a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_NAM_ID
        ORDER BY a.AC_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preAC_NAM_Actor_Name (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS varbinary(max)
AS
$$
SELECT
    pre.AC_NAM_Actor_Name
FROM
    TABLE(attributes.rAC_NAM_Actor_Name(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_NAM_AC_ID = id
AND
    pre.AC_NAM_ChangedAt < changingTimepoint
AND
    pre.AC_NAM_Reliability = 1
ORDER BY
    pre.AC_NAM_ChangedAt DESC,
    pre.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folAC_NAM_Actor_Name (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS varbinary(max)
AS
$$
SELECT
    fol.AC_NAM_Actor_Name
FROM
    TABLE(attributes.fAC_NAM_Actor_Name(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_NAM_AC_ID = id
AND
    fol.AC_NAM_ChangedAt > changingTimepoint
AND
    fol.AC_NAM_Reliability = 1
ORDER BY
    fol.AC_NAM_ChangedAt ASC,
    fol.AC_NAM_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_GEN,
    AC_GEN_ID,
    AC_GEN_PositedAt,
    AC_GEN_Reliability
FROM
    attributes.AC_GEN_Actor_Gender_Annex
WHERE
    AC_GEN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_GEN int,
    AC_GEN_ID int,
    AC_GEN_PositedAt datetime,
    AC_GEN_Reliability decimal(5,2),
    AC_GEN_AC_ID smallint,
    AC_GEN_GEN_ID number(1,0) 
)
AS
$$
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Reliability,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    attributes.AC_GEN_Actor_Gender_Posit p
JOIN
    TABLE(attributes.rAC_GEN_Actor_Gender_Annex(positingTimepoint)) a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_GEN_ID
        ORDER BY a.AC_GEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_AC_ID smallint,
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
    attributes.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_PLV_ID int,
    AC_PLV_AC_ID smallint,
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
    attributes.AC_PLV_Actor_ProfessionalLevel_Posit
WHERE
    AC_PLV_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_PLV,
    AC_PLV_ID,
    AC_PLV_PositedAt,
    AC_PLV_Reliability
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Annex
WHERE
    AC_PLV_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_AC_ID smallint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Reliability,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel (
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_AC_PLV int,
    AC_PLV_ID int,
    AC_PLV_PositedAt datetime,
    AC_PLV_Reliability decimal(5,2),
    AC_PLV_AC_ID smallint,
    AC_PLV_PLV_ID tinyint, 
    AC_PLV_ChangedAt datetime
)
AS
$$
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Reliability,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt
FROM
    TABLE(attributes.fAC_PLV_Actor_ProfessionalLevel_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel_Annex(positingTimepoint)) a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_PLV_ID
        ORDER BY a.AC_PLV_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.preAC_PLV_Actor_ProfessionalLevel (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS tinyint
AS
$$
SELECT
    pre.AC_PLV_PLV_ID
FROM
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.AC_PLV_AC_ID = id
AND
    pre.AC_PLV_ChangedAt < changingTimepoint
AND
    pre.AC_PLV_Reliability = 1
ORDER BY
    pre.AC_PLV_ChangedAt DESC,
    pre.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folAC_PLV_Actor_ProfessionalLevel (
    id smallint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
RETURNS tinyint
AS
$$
SELECT
    fol.AC_PLV_PLV_ID
FROM
    TABLE(attributes.fAC_PLV_Actor_ProfessionalLevel(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.AC_PLV_AC_ID = id
AND
    fol.AC_PLV_ChangedAt > changingTimepoint
AND
    fol.AC_PLV_Reliability = 1
ORDER BY
    fol.AC_PLV_ChangedAt ASC,
    fol.AC_PLV_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_PR_NAM,
    PR_NAM_ID,
    PR_NAM_PositedAt,
    PR_NAM_Reliability
FROM
    attributes.PR_NAM_Program_Name_Annex
WHERE
    PR_NAM_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_NAM int,
    PR_NAM_ID int,
    PR_NAM_PositedAt datetime,
    PR_NAM_Reliability decimal(5,2),
    PR_NAM_PR_ID number(10,0),
    PR_NAM_Program_Name varchar(42)
)
AS
$$
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Reliability,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    attributes.PR_NAM_Program_Name_Posit p
JOIN
    TABLE(attributes.rPR_NAM_Program_Name_Annex(positingTimepoint)) a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_NAM_ID
        ORDER BY a.PR_NAM_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PR_ID number(10,0),
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
    attributes.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length_Posit (
    changingTimepoint date
)
RETURNS TABLE (
    PR_LEN_ID int,
    PR_LEN_PR_ID number(10,0),
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
    attributes.PR_LEN_Program_Length_Posit
WHERE
    PR_LEN_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Annex (
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_PR_LEN,
    PR_LEN_ID,
    PR_LEN_PositedAt,
    PR_LEN_Reliability
FROM
    attributes.PR_LEN_Program_Length_Annex
WHERE
    PR_LEN_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length (
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_PR_ID number(10,0),
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Reliability,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(attributes.rPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length (
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS TABLE (
    Metadata_PR_LEN int,
    PR_LEN_ID int,
    PR_LEN_PositedAt datetime,
    PR_LEN_Reliability decimal(5,2),
    PR_LEN_PR_ID number(10,0),
    PR_LEN_Program_Length time,
    PR_LEN_ChangedAt date
)
AS
$$
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Reliability,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt
FROM
    TABLE(attributes.fPR_LEN_Program_Length_Posit(changingTimepoint)) p
JOIN
    TABLE(attributes.rPR_LEN_Program_Length_Annex(positingTimepoint)) a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_LEN_ID
        ORDER BY a.PR_LEN_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION attributes.prePR_LEN_Program_Length (
    id number(10,0),
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS time
AS
$$
SELECT
    pre.PR_LEN_Program_Length
FROM
    TABLE(attributes.rPR_LEN_Program_Length(changingTimepoint, positingTimepoint)) pre
WHERE
    pre.PR_LEN_PR_ID = id
AND
    pre.PR_LEN_ChangedAt < changingTimepoint
AND
    pre.PR_LEN_Reliability = 1
ORDER BY
    pre.PR_LEN_ChangedAt DESC,
    pre.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
CREATE OR REPLACE FUNCTION attributes.folPR_LEN_Program_Length (
    id number(10,0),
    changingTimepoint date,
    positingTimepoint datetime
)
RETURNS time
AS
$$
SELECT
    fol.PR_LEN_Program_Length
FROM
    TABLE(attributes.fPR_LEN_Program_Length(changingTimepoint, positingTimepoint)) fol
WHERE
    fol.PR_LEN_PR_ID = id
AND
    fol.PR_LEN_ChangedAt > changingTimepoint
AND
    fol.PR_LEN_Reliability = 1
ORDER BY
    fol.PR_LEN_ChangedAt ASC,
    fol.PR_LEN_PositedAt DESC
LIMIT 1
$$
;
