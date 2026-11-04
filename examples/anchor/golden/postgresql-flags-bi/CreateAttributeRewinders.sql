-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Event_Date_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_DAT",
    "EV_DAT_ID",
    "EV_DAT_PositedAt",
    "EV_DAT_Reliability"
FROM
    attributes."EV_DAT_Event_Date_Annex"
WHERE
    "EV_DAT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Event_Date" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_EV_ID" numeric(12,0),
    "EV_DAT_Event_Date" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_DAT_ID")
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Reliability",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date"
FROM
    attributes."EV_DAT_Event_Date_Posit" p
JOIN
    attributes."rEV_DAT_Event_Date_Annex"(positingTimepoint) a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
ORDER BY
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Event_Audience_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_AUD",
    "EV_AUD_ID",
    "EV_AUD_PositedAt",
    "EV_AUD_Reliability"
FROM
    attributes."EV_AUD_Event_Audience_Annex"
WHERE
    "EV_AUD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Event_Audience" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_Event_Audience" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_AUD_ID")
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Reliability",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    attributes."EV_AUD_Event_Audience_Posit" p
JOIN
    attributes."rEV_AUD_Event_Audience_Annex"(positingTimepoint) a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
ORDER BY
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Event_Revenue_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_REV",
    "EV_REV_ID",
    "EV_REV_PositedAt",
    "EV_REV_Reliability"
FROM
    attributes."EV_REV_Event_Revenue_Annex"
WHERE
    "EV_REV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Event_Revenue" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT DISTINCT ON (p."EV_REV_ID")
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Reliability",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    attributes."EV_REV_Event_Revenue_Posit" p
JOIN
    attributes."rEV_REV_Event_Revenue_Annex"(positingTimepoint) a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
ORDER BY
    p."EV_REV_ID",
    a."EV_REV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" integer,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_STA_ID",
    "EV_STA_EV_ID",
    "EV_STA_Event_Status",
    "EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Event_Status_Posit"
WHERE
    "EV_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Event_Status_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" integer,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_STA_ID",
    "EV_STA_EV_ID",
    "EV_STA_Event_Status",
    "EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Event_Status_Posit"
WHERE
    "EV_STA_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_STA",
    "EV_STA_ID",
    "EV_STA_PositedAt",
    "EV_STA_Reliability"
FROM
    attributes."EV_STA_Event_Status_Annex"
WHERE
    "EV_STA_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."rEV_STA_Event_Status_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Event_Status_Annex"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
ORDER BY
    p."EV_STA_ID",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Event_Status" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."fEV_STA_Event_Status_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Event_Status_Annex"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
ORDER BY
    p."EV_STA_ID",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preEV_STA_Event_Status" (
    id numeric(12,0),
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(20)
AS
$$
SELECT
    pre."EV_STA_Event_Status"
FROM
    attributes."rEV_STA_Event_Status"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_STA_EV_ID" = id
AND
    pre."EV_STA_ChangedAt" < changingTimepoint
AND
    pre."EV_STA_Reliability" = 1
ORDER BY
    pre."EV_STA_ChangedAt" DESC,
    pre."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folEV_STA_Event_Status" (
    id numeric(12,0),
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(20)
AS
$$
SELECT
    fol."EV_STA_Event_Status"
FROM
    attributes."fEV_STA_Event_Status"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_STA_EV_ID" = id
AND
    fol."EV_STA_ChangedAt" > changingTimepoint
AND
    fol."EV_STA_Reliability" = 1
ORDER BY
    fol."EV_STA_ChangedAt" ASC,
    fol."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Event_Utilization_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_UTL",
    "EV_UTL_ID",
    "EV_UTL_PositedAt",
    "EV_UTL_Reliability"
FROM
    attributes."EV_UTL_Event_Utilization_Annex"
WHERE
    "EV_UTL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Event_Utilization" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_EV_ID" numeric(12,0),
    "EV_UTL_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."EV_UTL_ID")
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Reliability",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Event_Utilization_Posit" p
JOIN
    attributes."rEV_UTL_Event_Utilization_Annex"(positingTimepoint) a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
ORDER BY
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" integer,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT
    "EV_LVL_ID",
    "EV_LVL_EV_ID",
    "EV_LVL_PLV_ID",
    "EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Event_Level_Posit"
WHERE
    "EV_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Event_Level_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" integer,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT
    "EV_LVL_ID",
    "EV_LVL_EV_ID",
    "EV_LVL_PLV_ID",
    "EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Event_Level_Posit"
WHERE
    "EV_LVL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_LVL",
    "EV_LVL_ID",
    "EV_LVL_PositedAt",
    "EV_LVL_Reliability"
FROM
    attributes."EV_LVL_Event_Level_Annex"
WHERE
    "EV_LVL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."rEV_LVL_Event_Level_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Event_Level_Annex"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
ORDER BY
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Event_Level" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."fEV_LVL_Event_Level_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Event_Level_Annex"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
ORDER BY
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preEV_LVL_Event_Level" (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."EV_LVL_PLV_ID"
FROM
    attributes."rEV_LVL_Event_Level"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_LVL_EV_ID" = id
AND
    pre."EV_LVL_ChangedAt" < changingTimepoint
AND
    pre."EV_LVL_Reliability" = 1
ORDER BY
    pre."EV_LVL_ChangedAt" DESC,
    pre."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folEV_LVL_Event_Level" (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."EV_LVL_PLV_ID"
FROM
    attributes."fEV_LVL_Event_Level"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_LVL_EV_ID" = id
AND
    fol."EV_LVL_ChangedAt" > changingTimepoint
AND
    fol."EV_LVL_Reliability" = 1
ORDER BY
    fol."EV_LVL_ChangedAt" ASC,
    fol."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_NAM_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_Stage_Name",
    "ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Stage_Name_Posit"
WHERE
    "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Stage_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_NAM_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_Stage_Name",
    "ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Stage_Name_Posit"
WHERE
    "ST_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_NAM",
    "ST_NAM_ID",
    "ST_NAM_PositedAt",
    "ST_NAM_Reliability"
FROM
    attributes."ST_NAM_Stage_Name_Annex"
WHERE
    "ST_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."rST_NAM_Stage_Name_Posit"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Stage_Name_Annex"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
ORDER BY
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Stage_Name" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."fST_NAM_Stage_Name_Posit"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Stage_Name_Annex"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
ORDER BY
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preST_NAM_Stage_Name" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."ST_NAM_Stage_Name"
FROM
    attributes."rST_NAM_Stage_Name"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_NAM_ST_ID" = id
AND
    pre."ST_NAM_ChangedAt" < changingTimepoint
AND
    pre."ST_NAM_Reliability" = 1
ORDER BY
    pre."ST_NAM_ChangedAt" DESC,
    pre."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folST_NAM_Stage_Name" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."ST_NAM_Stage_Name"
FROM
    attributes."fST_NAM_Stage_Name"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_NAM_ST_ID" = id
AND
    fol."ST_NAM_ChangedAt" > changingTimepoint
AND
    fol."ST_NAM_Reliability" = 1
ORDER BY
    fol."ST_NAM_ChangedAt" ASC,
    fol."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Stage_Location_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_LOC",
    "ST_LOC_ID",
    "ST_LOC_PositedAt",
    "ST_LOC_Reliability"
FROM
    attributes."ST_LOC_Stage_Location_Annex"
WHERE
    "ST_LOC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Stage_Location" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_ST_ID" integer,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text
)
AS
$$
SELECT DISTINCT ON (p."ST_LOC_ID")
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Reliability",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    attributes."ST_LOC_Stage_Location_Posit" p
JOIN
    attributes."rST_LOC_Stage_Location_Annex"(positingTimepoint) a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
ORDER BY
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" integer,
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_AVG_ID",
    "ST_AVG_ST_ID",
    "ST_AVG_UTL_ID",
    "ST_AVG_ChangedAt"
FROM
    attributes."ST_AVG_Stage_Average_Posit"
WHERE
    "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Stage_Average_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" integer,
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_AVG_ID",
    "ST_AVG_ST_ID",
    "ST_AVG_UTL_ID",
    "ST_AVG_ChangedAt"
FROM
    attributes."ST_AVG_Stage_Average_Posit"
WHERE
    "ST_AVG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_AVG",
    "ST_AVG_ID",
    "ST_AVG_PositedAt",
    "ST_AVG_Reliability"
FROM
    attributes."ST_AVG_Stage_Average_Annex"
WHERE
    "ST_AVG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."rST_AVG_Stage_Average_Posit"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Stage_Average_Annex"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
ORDER BY
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Stage_Average" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."fST_AVG_Stage_Average_Posit"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Stage_Average_Annex"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
ORDER BY
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preST_AVG_Stage_Average" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."ST_AVG_UTL_ID"
FROM
    attributes."rST_AVG_Stage_Average"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_AVG_ST_ID" = id
AND
    pre."ST_AVG_ChangedAt" < changingTimepoint
AND
    pre."ST_AVG_Reliability" = 1
ORDER BY
    pre."ST_AVG_ChangedAt" DESC,
    pre."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folST_AVG_Stage_Average" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."ST_AVG_UTL_ID"
FROM
    attributes."fST_AVG_Stage_Average"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_AVG_ST_ID" = id
AND
    fol."ST_AVG_ChangedAt" > changingTimepoint
AND
    fol."ST_AVG_Reliability" = 1
ORDER BY
    fol."ST_AVG_ChangedAt" ASC,
    fol."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Stage_Minimum_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_MIN",
    "ST_MIN_ID",
    "ST_MIN_PositedAt",
    "ST_MIN_Reliability"
FROM
    attributes."ST_MIN_Stage_Minimum_Annex"
WHERE
    "ST_MIN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Stage_Minimum" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_ST_ID" integer,
    "ST_MIN_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."ST_MIN_ID")
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Reliability",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Stage_Minimum_Posit" p
JOIN
    attributes."rST_MIN_Stage_Minimum_Annex"(positingTimepoint) a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
ORDER BY
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" integer,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_NAM_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_Actor_Name",
    "AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Actor_Name_Posit"
WHERE
    "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Actor_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" integer,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_NAM_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_Actor_Name",
    "AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Actor_Name_Posit"
WHERE
    "AC_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_NAM",
    "AC_NAM_ID",
    "AC_NAM_PositedAt",
    "AC_NAM_Reliability"
FROM
    attributes."AC_NAM_Actor_Name_Annex"
WHERE
    "AC_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."rAC_NAM_Actor_Name_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Actor_Name_Annex"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
ORDER BY
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Actor_Name" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."fAC_NAM_Actor_Name_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Actor_Name_Annex"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
ORDER BY
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preAC_NAM_Actor_Name" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."AC_NAM_Actor_Name"
FROM
    attributes."rAC_NAM_Actor_Name"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_NAM_AC_ID" = id
AND
    pre."AC_NAM_ChangedAt" < changingTimepoint
AND
    pre."AC_NAM_Reliability" = 1
ORDER BY
    pre."AC_NAM_ChangedAt" DESC,
    pre."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folAC_NAM_Actor_Name" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."AC_NAM_Actor_Name"
FROM
    attributes."fAC_NAM_Actor_Name"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_NAM_AC_ID" = id
AND
    fol."AC_NAM_ChangedAt" > changingTimepoint
AND
    fol."AC_NAM_Reliability" = 1
ORDER BY
    fol."AC_NAM_ChangedAt" ASC,
    fol."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Actor_Gender_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_GEN",
    "AC_GEN_ID",
    "AC_GEN_PositedAt",
    "AC_GEN_Reliability"
FROM
    attributes."AC_GEN_Actor_Gender_Annex"
WHERE
    "AC_GEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Actor_Gender" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_AC_ID" smallint,
    "AC_GEN_GEN_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."AC_GEN_ID")
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Reliability",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Actor_Gender_Posit" p
JOIN
    attributes."rAC_GEN_Actor_Gender_Annex"(positingTimepoint) a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
ORDER BY
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" integer,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_PLV_ID",
    "AC_PLV_AC_ID",
    "AC_PLV_PLV_ID",
    "AC_PLV_ChangedAt"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit"
WHERE
    "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Actor_ProfessionalLevel_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" integer,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_PLV_ID",
    "AC_PLV_AC_ID",
    "AC_PLV_PLV_ID",
    "AC_PLV_ChangedAt"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit"
WHERE
    "AC_PLV_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_PLV",
    "AC_PLV_ID",
    "AC_PLV_PositedAt",
    "AC_PLV_Reliability"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Annex"
WHERE
    "AC_PLV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."rAC_PLV_Actor_ProfessionalLevel_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel_Annex"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
ORDER BY
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Actor_ProfessionalLevel" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."fAC_PLV_Actor_ProfessionalLevel_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel_Annex"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
ORDER BY
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preAC_PLV_Actor_ProfessionalLevel" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."AC_PLV_PLV_ID"
FROM
    attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_PLV_AC_ID" = id
AND
    pre."AC_PLV_ChangedAt" < changingTimepoint
AND
    pre."AC_PLV_Reliability" = 1
ORDER BY
    pre."AC_PLV_ChangedAt" DESC,
    pre."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folAC_PLV_Actor_ProfessionalLevel" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."AC_PLV_PLV_ID"
FROM
    attributes."fAC_PLV_Actor_ProfessionalLevel"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_PLV_AC_ID" = id
AND
    fol."AC_PLV_ChangedAt" > changingTimepoint
AND
    fol."AC_PLV_Reliability" = 1
ORDER BY
    fol."AC_PLV_ChangedAt" ASC,
    fol."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Program_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_PR_NAM",
    "PR_NAM_ID",
    "PR_NAM_PositedAt",
    "PR_NAM_Reliability"
FROM
    attributes."PR_NAM_Program_Name_Annex"
WHERE
    "PR_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Program_Name" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_PR_ID" bigint,
    "PR_NAM_Program_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."PR_NAM_ID")
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Reliability",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name"
FROM
    attributes."PR_NAM_Program_Name_Posit" p
JOIN
    attributes."rPR_NAM_Program_Name_Annex"(positingTimepoint) a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
ORDER BY
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" integer,
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    "PR_LEN_ID",
    "PR_LEN_PR_ID",
    "PR_LEN_Program_Length",
    "PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Program_Length_Posit"
WHERE
    "PR_LEN_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Program_Length_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" integer,
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    "PR_LEN_ID",
    "PR_LEN_PR_ID",
    "PR_LEN_Program_Length",
    "PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Program_Length_Posit"
WHERE
    "PR_LEN_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_PR_LEN",
    "PR_LEN_ID",
    "PR_LEN_PositedAt",
    "PR_LEN_Reliability"
FROM
    attributes."PR_LEN_Program_Length_Annex"
WHERE
    "PR_LEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."rPR_LEN_Program_Length_Posit"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Program_Length_Annex"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
ORDER BY
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Program_Length" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."fPR_LEN_Program_Length_Posit"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Program_Length_Annex"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
ORDER BY
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."prePR_LEN_Program_Length" (
    id bigint,
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS time
AS
$$
SELECT
    pre."PR_LEN_Program_Length"
FROM
    attributes."rPR_LEN_Program_Length"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."PR_LEN_PR_ID" = id
AND
    pre."PR_LEN_ChangedAt" < changingTimepoint
AND
    pre."PR_LEN_Reliability" = 1
ORDER BY
    pre."PR_LEN_ChangedAt" DESC,
    pre."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folPR_LEN_Program_Length" (
    id bigint,
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS time
AS
$$
SELECT
    fol."PR_LEN_Program_Length"
FROM
    attributes."fPR_LEN_Program_Length"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."PR_LEN_PR_ID" = id
AND
    fol."PR_LEN_ChangedAt" > changingTimepoint
AND
    fol."PR_LEN_Reliability" = 1
ORDER BY
    fol."PR_LEN_ChangedAt" ASC,
    fol."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
