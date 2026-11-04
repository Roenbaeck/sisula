-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Event_Date_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_DAT",
    "EV_DAT_ID",
    "EV_DAT_PositedAt",
    "EV_DAT_Who",
    "EV_DAT_Confidence",
    "EV_DAT_Stance"
FROM
    attributes."EV_DAT_Event_Date_Meta"
WHERE
    "EV_DAT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Event_Date" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1),
    "EV_DAT_EV_ID" numeric(12,0),
    "EV_DAT_Event_Date" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_DAT_ID", a."EV_DAT_Who")
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Who",
    a."EV_DAT_Confidence",
    a."EV_DAT_Stance",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date"
FROM
    attributes."EV_DAT_Event_Date_Fact" p
JOIN
    attributes."rEV_DAT_Event_Date_Meta"(positingTimepoint) a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
AND
    a."EV_DAT_Who" = coalesce(positor, a."EV_DAT_Who")
ORDER BY
    p."EV_DAT_ID", a."EV_DAT_Who",
    a."EV_DAT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Event_Audience_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_AUD",
    "EV_AUD_ID",
    "EV_AUD_PositedAt",
    "EV_AUD_Who",
    "EV_AUD_Confidence",
    "EV_AUD_Stance"
FROM
    attributes."EV_AUD_Event_Audience_Meta"
WHERE
    "EV_AUD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Event_Audience" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1),
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_Event_Audience" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_AUD_ID", a."EV_AUD_Who")
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Who",
    a."EV_AUD_Confidence",
    a."EV_AUD_Stance",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    attributes."EV_AUD_Event_Audience_Fact" p
JOIN
    attributes."rEV_AUD_Event_Audience_Meta"(positingTimepoint) a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
AND
    a."EV_AUD_Who" = coalesce(positor, a."EV_AUD_Who")
ORDER BY
    p."EV_AUD_ID", a."EV_AUD_Who",
    a."EV_AUD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Event_Revenue_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_REV",
    "EV_REV_ID",
    "EV_REV_PositedAt",
    "EV_REV_Who",
    "EV_REV_Confidence",
    "EV_REV_Stance"
FROM
    attributes."EV_REV_Event_Revenue_Meta"
WHERE
    "EV_REV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Event_Revenue" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1),
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT DISTINCT ON (p."EV_REV_ID", a."EV_REV_Who")
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Who",
    a."EV_REV_Confidence",
    a."EV_REV_Stance",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    attributes."EV_REV_Event_Revenue_Fact" p
JOIN
    attributes."rEV_REV_Event_Revenue_Meta"(positingTimepoint) a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
AND
    a."EV_REV_Who" = coalesce(positor, a."EV_REV_Who")
ORDER BY
    p."EV_REV_ID", a."EV_REV_Who",
    a."EV_REV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" bigint,
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
    attributes."EV_STA_Event_Status_Fact"
WHERE
    "EV_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Event_Status_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" bigint,
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
    attributes."EV_STA_Event_Status_Fact"
WHERE
    "EV_STA_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_STA",
    "EV_STA_ID",
    "EV_STA_PositedAt",
    "EV_STA_Who",
    "EV_STA_Confidence",
    "EV_STA_Stance"
FROM
    attributes."EV_STA_Event_Status_Meta"
WHERE
    "EV_STA_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID", a."EV_STA_Who")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Who",
    a."EV_STA_Confidence",
    a."EV_STA_Stance",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."rEV_STA_Event_Status_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Event_Status_Meta"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
AND
    a."EV_STA_Who" = coalesce(positor, a."EV_STA_Who")
ORDER BY
    p."EV_STA_ID", a."EV_STA_Who",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Event_Status" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID", a."EV_STA_Who")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Who",
    a."EV_STA_Confidence",
    a."EV_STA_Stance",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."fEV_STA_Event_Status_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Event_Status_Meta"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
AND
    a."EV_STA_Who" = coalesce(positor, a."EV_STA_Who")
ORDER BY
    p."EV_STA_ID", a."EV_STA_Who",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preEV_STA_Event_Status" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(20)
AS
$$
SELECT
    pre."EV_STA_Event_Status"
FROM
    attributes."rEV_STA_Event_Status"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_STA_EV_ID" = id
AND
    pre."EV_STA_ChangedAt" < changingTimepoint
AND
    pre."EV_STA_Stance" = coalesce(assertion, pre."EV_STA_Stance")
ORDER BY
    pre."EV_STA_ChangedAt" DESC,
    pre."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folEV_STA_Event_Status" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(20)
AS
$$
SELECT
    fol."EV_STA_Event_Status"
FROM
    attributes."fEV_STA_Event_Status"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_STA_EV_ID" = id
AND
    fol."EV_STA_ChangedAt" > changingTimepoint
AND
    fol."EV_STA_Stance" = coalesce(assertion, fol."EV_STA_Stance")
ORDER BY
    fol."EV_STA_ChangedAt" ASC,
    fol."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Event_Utilization_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_UTL",
    "EV_UTL_ID",
    "EV_UTL_PositedAt",
    "EV_UTL_Who",
    "EV_UTL_Confidence",
    "EV_UTL_Stance"
FROM
    attributes."EV_UTL_Event_Utilization_Meta"
WHERE
    "EV_UTL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Event_Utilization" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1),
    "EV_UTL_EV_ID" numeric(12,0),
    "EV_UTL_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."EV_UTL_ID", a."EV_UTL_Who")
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Who",
    a."EV_UTL_Confidence",
    a."EV_UTL_Stance",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Event_Utilization_Fact" p
JOIN
    attributes."rEV_UTL_Event_Utilization_Meta"(positingTimepoint) a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
AND
    a."EV_UTL_Who" = coalesce(positor, a."EV_UTL_Who")
ORDER BY
    p."EV_UTL_ID", a."EV_UTL_Who",
    a."EV_UTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" bigint,
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
    attributes."EV_LVL_Event_Level_Fact"
WHERE
    "EV_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Event_Level_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" bigint,
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
    attributes."EV_LVL_Event_Level_Fact"
WHERE
    "EV_LVL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_LVL",
    "EV_LVL_ID",
    "EV_LVL_PositedAt",
    "EV_LVL_Who",
    "EV_LVL_Confidence",
    "EV_LVL_Stance"
FROM
    attributes."EV_LVL_Event_Level_Meta"
WHERE
    "EV_LVL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID", a."EV_LVL_Who")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Who",
    a."EV_LVL_Confidence",
    a."EV_LVL_Stance",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."rEV_LVL_Event_Level_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Event_Level_Meta"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
AND
    a."EV_LVL_Who" = coalesce(positor, a."EV_LVL_Who")
ORDER BY
    p."EV_LVL_ID", a."EV_LVL_Who",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Event_Level" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID", a."EV_LVL_Who")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Who",
    a."EV_LVL_Confidence",
    a."EV_LVL_Stance",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."fEV_LVL_Event_Level_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Event_Level_Meta"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
AND
    a."EV_LVL_Who" = coalesce(positor, a."EV_LVL_Who")
ORDER BY
    p."EV_LVL_ID", a."EV_LVL_Who",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preEV_LVL_Event_Level" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."EV_LVL_PLV_ID"
FROM
    attributes."rEV_LVL_Event_Level"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_LVL_EV_ID" = id
AND
    pre."EV_LVL_ChangedAt" < changingTimepoint
AND
    pre."EV_LVL_Stance" = coalesce(assertion, pre."EV_LVL_Stance")
ORDER BY
    pre."EV_LVL_ChangedAt" DESC,
    pre."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folEV_LVL_Event_Level" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."EV_LVL_PLV_ID"
FROM
    attributes."fEV_LVL_Event_Level"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_LVL_EV_ID" = id
AND
    fol."EV_LVL_ChangedAt" > changingTimepoint
AND
    fol."EV_LVL_Stance" = coalesce(assertion, fol."EV_LVL_Stance")
ORDER BY
    fol."EV_LVL_ChangedAt" ASC,
    fol."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" bigint,
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
    attributes."ST_NAM_Stage_Name_Fact"
WHERE
    "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Stage_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" bigint,
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
    attributes."ST_NAM_Stage_Name_Fact"
WHERE
    "ST_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_NAM",
    "ST_NAM_ID",
    "ST_NAM_PositedAt",
    "ST_NAM_Who",
    "ST_NAM_Confidence",
    "ST_NAM_Stance"
FROM
    attributes."ST_NAM_Stage_Name_Meta"
WHERE
    "ST_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID", a."ST_NAM_Who")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Who",
    a."ST_NAM_Confidence",
    a."ST_NAM_Stance",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."rST_NAM_Stage_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Stage_Name_Meta"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Who" = coalesce(positor, a."ST_NAM_Who")
ORDER BY
    p."ST_NAM_ID", a."ST_NAM_Who",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Stage_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID", a."ST_NAM_Who")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Who",
    a."ST_NAM_Confidence",
    a."ST_NAM_Stance",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."fST_NAM_Stage_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Stage_Name_Meta"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Who" = coalesce(positor, a."ST_NAM_Who")
ORDER BY
    p."ST_NAM_ID", a."ST_NAM_Who",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preST_NAM_Stage_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."ST_NAM_Stage_Name"
FROM
    attributes."rST_NAM_Stage_Name"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_NAM_ST_ID" = id
AND
    pre."ST_NAM_ChangedAt" < changingTimepoint
AND
    pre."ST_NAM_Stance" = coalesce(assertion, pre."ST_NAM_Stance")
ORDER BY
    pre."ST_NAM_ChangedAt" DESC,
    pre."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folST_NAM_Stage_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."ST_NAM_Stage_Name"
FROM
    attributes."fST_NAM_Stage_Name"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_NAM_ST_ID" = id
AND
    fol."ST_NAM_ChangedAt" > changingTimepoint
AND
    fol."ST_NAM_Stance" = coalesce(assertion, fol."ST_NAM_Stance")
ORDER BY
    fol."ST_NAM_ChangedAt" ASC,
    fol."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Stage_Location_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_LOC",
    "ST_LOC_ID",
    "ST_LOC_PositedAt",
    "ST_LOC_Who",
    "ST_LOC_Confidence",
    "ST_LOC_Stance"
FROM
    attributes."ST_LOC_Stage_Location_Meta"
WHERE
    "ST_LOC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Stage_Location" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1),
    "ST_LOC_ST_ID" integer,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography
)
AS
$$
SELECT DISTINCT ON (p."ST_LOC_ID", a."ST_LOC_Who")
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Who",
    a."ST_LOC_Confidence",
    a."ST_LOC_Stance",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    attributes."ST_LOC_Stage_Location_Fact" p
JOIN
    attributes."rST_LOC_Stage_Location_Meta"(positingTimepoint) a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
AND
    a."ST_LOC_Who" = coalesce(positor, a."ST_LOC_Who")
ORDER BY
    p."ST_LOC_ID", a."ST_LOC_Who",
    a."ST_LOC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" bigint,
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
    attributes."ST_AVG_Stage_Average_Fact"
WHERE
    "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Stage_Average_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" bigint,
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
    attributes."ST_AVG_Stage_Average_Fact"
WHERE
    "ST_AVG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_AVG",
    "ST_AVG_ID",
    "ST_AVG_PositedAt",
    "ST_AVG_Who",
    "ST_AVG_Confidence",
    "ST_AVG_Stance"
FROM
    attributes."ST_AVG_Stage_Average_Meta"
WHERE
    "ST_AVG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID", a."ST_AVG_Who")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Who",
    a."ST_AVG_Confidence",
    a."ST_AVG_Stance",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."rST_AVG_Stage_Average_Fact"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Stage_Average_Meta"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Who" = coalesce(positor, a."ST_AVG_Who")
ORDER BY
    p."ST_AVG_ID", a."ST_AVG_Who",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Stage_Average" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID", a."ST_AVG_Who")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Who",
    a."ST_AVG_Confidence",
    a."ST_AVG_Stance",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."fST_AVG_Stage_Average_Fact"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Stage_Average_Meta"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Who" = coalesce(positor, a."ST_AVG_Who")
ORDER BY
    p."ST_AVG_ID", a."ST_AVG_Who",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preST_AVG_Stage_Average" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."ST_AVG_UTL_ID"
FROM
    attributes."rST_AVG_Stage_Average"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_AVG_ST_ID" = id
AND
    pre."ST_AVG_ChangedAt" < changingTimepoint
AND
    pre."ST_AVG_Stance" = coalesce(assertion, pre."ST_AVG_Stance")
ORDER BY
    pre."ST_AVG_ChangedAt" DESC,
    pre."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folST_AVG_Stage_Average" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."ST_AVG_UTL_ID"
FROM
    attributes."fST_AVG_Stage_Average"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_AVG_ST_ID" = id
AND
    fol."ST_AVG_ChangedAt" > changingTimepoint
AND
    fol."ST_AVG_Stance" = coalesce(assertion, fol."ST_AVG_Stance")
ORDER BY
    fol."ST_AVG_ChangedAt" ASC,
    fol."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Stage_Minimum_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_MIN",
    "ST_MIN_ID",
    "ST_MIN_PositedAt",
    "ST_MIN_Who",
    "ST_MIN_Confidence",
    "ST_MIN_Stance"
FROM
    attributes."ST_MIN_Stage_Minimum_Meta"
WHERE
    "ST_MIN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Stage_Minimum" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1),
    "ST_MIN_ST_ID" integer,
    "ST_MIN_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."ST_MIN_ID", a."ST_MIN_Who")
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Who",
    a."ST_MIN_Confidence",
    a."ST_MIN_Stance",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Stage_Minimum_Fact" p
JOIN
    attributes."rST_MIN_Stage_Minimum_Meta"(positingTimepoint) a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
AND
    a."ST_MIN_Who" = coalesce(positor, a."ST_MIN_Who")
ORDER BY
    p."ST_MIN_ID", a."ST_MIN_Who",
    a."ST_MIN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" bigint,
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
    attributes."AC_NAM_Actor_Name_Fact"
WHERE
    "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Actor_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" bigint,
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
    attributes."AC_NAM_Actor_Name_Fact"
WHERE
    "AC_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_NAM",
    "AC_NAM_ID",
    "AC_NAM_PositedAt",
    "AC_NAM_Who",
    "AC_NAM_Confidence",
    "AC_NAM_Stance"
FROM
    attributes."AC_NAM_Actor_Name_Meta"
WHERE
    "AC_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID", a."AC_NAM_Who")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Who",
    a."AC_NAM_Confidence",
    a."AC_NAM_Stance",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."rAC_NAM_Actor_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Actor_Name_Meta"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Who" = coalesce(positor, a."AC_NAM_Who")
ORDER BY
    p."AC_NAM_ID", a."AC_NAM_Who",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Actor_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID", a."AC_NAM_Who")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Who",
    a."AC_NAM_Confidence",
    a."AC_NAM_Stance",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."fAC_NAM_Actor_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Actor_Name_Meta"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Who" = coalesce(positor, a."AC_NAM_Who")
ORDER BY
    p."AC_NAM_ID", a."AC_NAM_Who",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preAC_NAM_Actor_Name" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."AC_NAM_Actor_Name"
FROM
    attributes."rAC_NAM_Actor_Name"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_NAM_AC_ID" = id
AND
    pre."AC_NAM_ChangedAt" < changingTimepoint
AND
    pre."AC_NAM_Stance" = coalesce(assertion, pre."AC_NAM_Stance")
ORDER BY
    pre."AC_NAM_ChangedAt" DESC,
    pre."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folAC_NAM_Actor_Name" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."AC_NAM_Actor_Name"
FROM
    attributes."fAC_NAM_Actor_Name"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_NAM_AC_ID" = id
AND
    fol."AC_NAM_ChangedAt" > changingTimepoint
AND
    fol."AC_NAM_Stance" = coalesce(assertion, fol."AC_NAM_Stance")
ORDER BY
    fol."AC_NAM_ChangedAt" ASC,
    fol."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Actor_Gender_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_GEN",
    "AC_GEN_ID",
    "AC_GEN_PositedAt",
    "AC_GEN_Who",
    "AC_GEN_Confidence",
    "AC_GEN_Stance"
FROM
    attributes."AC_GEN_Actor_Gender_Meta"
WHERE
    "AC_GEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Actor_Gender" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1),
    "AC_GEN_AC_ID" smallint,
    "AC_GEN_GEN_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."AC_GEN_ID", a."AC_GEN_Who")
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Who",
    a."AC_GEN_Confidence",
    a."AC_GEN_Stance",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Actor_Gender_Fact" p
JOIN
    attributes."rAC_GEN_Actor_Gender_Meta"(positingTimepoint) a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
AND
    a."AC_GEN_Who" = coalesce(positor, a."AC_GEN_Who")
ORDER BY
    p."AC_GEN_ID", a."AC_GEN_Who",
    a."AC_GEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" bigint,
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
    attributes."AC_PLV_Actor_ProfessionalLevel_Fact"
WHERE
    "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Actor_ProfessionalLevel_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" bigint,
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
    attributes."AC_PLV_Actor_ProfessionalLevel_Fact"
WHERE
    "AC_PLV_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_PLV",
    "AC_PLV_ID",
    "AC_PLV_PositedAt",
    "AC_PLV_Who",
    "AC_PLV_Confidence",
    "AC_PLV_Stance"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Meta"
WHERE
    "AC_PLV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID", a."AC_PLV_Who")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Who",
    a."AC_PLV_Confidence",
    a."AC_PLV_Stance",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."rAC_PLV_Actor_ProfessionalLevel_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel_Meta"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Who" = coalesce(positor, a."AC_PLV_Who")
ORDER BY
    p."AC_PLV_ID", a."AC_PLV_Who",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Actor_ProfessionalLevel" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID", a."AC_PLV_Who")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Who",
    a."AC_PLV_Confidence",
    a."AC_PLV_Stance",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."fAC_PLV_Actor_ProfessionalLevel_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel_Meta"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Who" = coalesce(positor, a."AC_PLV_Who")
ORDER BY
    p."AC_PLV_ID", a."AC_PLV_Who",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preAC_PLV_Actor_ProfessionalLevel" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."AC_PLV_PLV_ID"
FROM
    attributes."rAC_PLV_Actor_ProfessionalLevel"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_PLV_AC_ID" = id
AND
    pre."AC_PLV_ChangedAt" < changingTimepoint
AND
    pre."AC_PLV_Stance" = coalesce(assertion, pre."AC_PLV_Stance")
ORDER BY
    pre."AC_PLV_ChangedAt" DESC,
    pre."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folAC_PLV_Actor_ProfessionalLevel" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."AC_PLV_PLV_ID"
FROM
    attributes."fAC_PLV_Actor_ProfessionalLevel"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_PLV_AC_ID" = id
AND
    fol."AC_PLV_ChangedAt" > changingTimepoint
AND
    fol."AC_PLV_Stance" = coalesce(assertion, fol."AC_PLV_Stance")
ORDER BY
    fol."AC_PLV_ChangedAt" ASC,
    fol."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Program_Name_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_PR_NAM",
    "PR_NAM_ID",
    "PR_NAM_PositedAt",
    "PR_NAM_Who",
    "PR_NAM_Confidence",
    "PR_NAM_Stance"
FROM
    attributes."PR_NAM_Program_Name_Meta"
WHERE
    "PR_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Program_Name" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1),
    "PR_NAM_PR_ID" bigint,
    "PR_NAM_Program_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."PR_NAM_ID", a."PR_NAM_Who")
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Who",
    a."PR_NAM_Confidence",
    a."PR_NAM_Stance",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name"
FROM
    attributes."PR_NAM_Program_Name_Fact" p
JOIN
    attributes."rPR_NAM_Program_Name_Meta"(positingTimepoint) a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
AND
    a."PR_NAM_Who" = coalesce(positor, a."PR_NAM_Who")
ORDER BY
    p."PR_NAM_ID", a."PR_NAM_Who",
    a."PR_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" bigint,
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
    attributes."PR_LEN_Program_Length_Fact"
WHERE
    "PR_LEN_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Program_Length_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" bigint,
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
    attributes."PR_LEN_Program_Length_Fact"
WHERE
    "PR_LEN_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_PR_LEN",
    "PR_LEN_ID",
    "PR_LEN_PositedAt",
    "PR_LEN_Who",
    "PR_LEN_Confidence",
    "PR_LEN_Stance"
FROM
    attributes."PR_LEN_Program_Length_Meta"
WHERE
    "PR_LEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID", a."PR_LEN_Who")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Who",
    a."PR_LEN_Confidence",
    a."PR_LEN_Stance",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."rPR_LEN_Program_Length_Fact"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Program_Length_Meta"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Who" = coalesce(positor, a."PR_LEN_Who")
ORDER BY
    p."PR_LEN_ID", a."PR_LEN_Who",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Program_Length" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID", a."PR_LEN_Who")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Who",
    a."PR_LEN_Confidence",
    a."PR_LEN_Stance",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."fPR_LEN_Program_Length_Fact"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Program_Length_Meta"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Who" = coalesce(positor, a."PR_LEN_Who")
ORDER BY
    p."PR_LEN_ID", a."PR_LEN_Who",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."prePR_LEN_Program_Length" (
    id bigint,
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS time
AS
$$
SELECT
    pre."PR_LEN_Program_Length"
FROM
    attributes."rPR_LEN_Program_Length"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."PR_LEN_PR_ID" = id
AND
    pre."PR_LEN_ChangedAt" < changingTimepoint
AND
    pre."PR_LEN_Stance" = coalesce(assertion, pre."PR_LEN_Stance")
ORDER BY
    pre."PR_LEN_ChangedAt" DESC,
    pre."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folPR_LEN_Program_Length" (
    id bigint,
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS time
AS
$$
SELECT
    fol."PR_LEN_Program_Length"
FROM
    attributes."fPR_LEN_Program_Length"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."PR_LEN_PR_ID" = id
AND
    fol."PR_LEN_ChangedAt" > changingTimepoint
AND
    fol."PR_LEN_Stance" = coalesce(assertion, fol."PR_LEN_Stance")
ORDER BY
    fol."PR_LEN_ChangedAt" ASC,
    fol."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
