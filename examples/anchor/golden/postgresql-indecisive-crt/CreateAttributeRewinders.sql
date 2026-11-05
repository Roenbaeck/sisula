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
CREATE OR REPLACE FUNCTION public."rEV_QTY_Event_Quantity_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Positor" smallint,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_QTY",
    "EV_QTY_ID",
    "EV_QTY_PositedAt",
    "EV_QTY_Positor",
    "EV_QTY_Reliability",
    "EV_QTY_Assertion"
FROM
    public."EV_QTY_Event_Quantity_Annex"
WHERE
    "EV_QTY_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_QTY_Event_Quantity" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Positor" smallint,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Assertion" char(1),
    "EV_QTY_EV_ID" integer,
    "EV_QTY_Event_Quantity" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_QTY_ID", a."EV_QTY_Positor")
    a."Metadata_EV_QTY",
    p."EV_QTY_ID",
    a."EV_QTY_PositedAt",
    a."EV_QTY_Positor",
    a."EV_QTY_Reliability",
    a."EV_QTY_Assertion",
    p."EV_QTY_EV_ID",
    p."EV_QTY_Event_Quantity"
FROM
    public."EV_QTY_Event_Quantity_Posit" p
JOIN
    public."rEV_QTY_Event_Quantity_Annex"(positingTimepoint) a
ON
    a."EV_QTY_ID" = p."EV_QTY_ID"
AND
    a."EV_QTY_Positor" = coalesce(positor, a."EV_QTY_Positor")
ORDER BY
    p."EV_QTY_ID", a."EV_QTY_Positor",
    a."EV_QTY_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_PLC_ID" integer,
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_PLC_ID",
    "EV_PLC_EV_ID",
    "EV_PLC_Event_Place",
    "EV_PLC_ChangedAt"
FROM
    public."EV_PLC_Event_Place_Posit"
WHERE
    "EV_PLC_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fEV_PLC_Event_Place_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_PLC_ID" integer,
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_PLC_ID",
    "EV_PLC_EV_ID",
    "EV_PLC_Event_Place",
    "EV_PLC_ChangedAt"
FROM
    public."EV_PLC_Event_Place_Posit"
WHERE
    "EV_PLC_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Positor" smallint,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_PLC",
    "EV_PLC_ID",
    "EV_PLC_PositedAt",
    "EV_PLC_Positor",
    "EV_PLC_Reliability",
    "EV_PLC_Assertion"
FROM
    public."EV_PLC_Event_Place_Annex"
WHERE
    "EV_PLC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Positor" smallint,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Assertion" char(1),
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_PLC_ID", a."EV_PLC_Positor")
    a."Metadata_EV_PLC",
    p."EV_PLC_ID",
    a."EV_PLC_PositedAt",
    a."EV_PLC_Positor",
    a."EV_PLC_Reliability",
    a."EV_PLC_Assertion",
    p."EV_PLC_EV_ID",
    p."EV_PLC_Event_Place",
    p."EV_PLC_ChangedAt"
FROM
    public."rEV_PLC_Event_Place_Posit"(changingTimepoint) p
JOIN
    public."rEV_PLC_Event_Place_Annex"(positingTimepoint) a
ON
    a."EV_PLC_ID" = p."EV_PLC_ID"
AND
    a."EV_PLC_Positor" = coalesce(positor, a."EV_PLC_Positor")
ORDER BY
    p."EV_PLC_ID", a."EV_PLC_Positor",
    a."EV_PLC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fEV_PLC_Event_Place" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Positor" smallint,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Assertion" char(1),
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_PLC_ID", a."EV_PLC_Positor")
    a."Metadata_EV_PLC",
    p."EV_PLC_ID",
    a."EV_PLC_PositedAt",
    a."EV_PLC_Positor",
    a."EV_PLC_Reliability",
    a."EV_PLC_Assertion",
    p."EV_PLC_EV_ID",
    p."EV_PLC_Event_Place",
    p."EV_PLC_ChangedAt"
FROM
    public."fEV_PLC_Event_Place_Posit"(changingTimepoint) p
JOIN
    public."rEV_PLC_Event_Place_Annex"(positingTimepoint) a
ON
    a."EV_PLC_ID" = p."EV_PLC_ID"
AND
    a."EV_PLC_Positor" = coalesce(positor, a."EV_PLC_Positor")
ORDER BY
    p."EV_PLC_ID", a."EV_PLC_Positor",
    a."EV_PLC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preEV_PLC_Event_Place" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."EV_PLC_Event_Place"
FROM
    public."rEV_PLC_Event_Place"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_PLC_EV_ID" = id
AND
    pre."EV_PLC_ChangedAt" < changingTimepoint
AND
    pre."EV_PLC_Assertion" = coalesce(assertion, pre."EV_PLC_Assertion")
ORDER BY
    pre."EV_PLC_ChangedAt" DESC,
    pre."EV_PLC_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folEV_PLC_Event_Place" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."EV_PLC_Event_Place"
FROM
    public."fEV_PLC_Event_Place"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_PLC_EV_ID" = id
AND
    fol."EV_PLC_ChangedAt" > changingTimepoint
AND
    fol."EV_PLC_Assertion" = coalesce(assertion, fol."EV_PLC_Assertion")
ORDER BY
    fol."EV_PLC_ChangedAt" ASC,
    fol."EV_PLC_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_NAM_Subject_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Positor" smallint,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_NAM",
    "SU_NAM_ID",
    "SU_NAM_PositedAt",
    "SU_NAM_Positor",
    "SU_NAM_Reliability",
    "SU_NAM_Assertion"
FROM
    public."SU_NAM_Subject_Name_Annex"
WHERE
    "SU_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_NAM_Subject_Name" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Positor" smallint,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Assertion" char(1),
    "SU_NAM_SU_ID" integer,
    "SU_NAM_Subject_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."SU_NAM_ID", a."SU_NAM_Positor")
    a."Metadata_SU_NAM",
    p."SU_NAM_ID",
    a."SU_NAM_PositedAt",
    a."SU_NAM_Positor",
    a."SU_NAM_Reliability",
    a."SU_NAM_Assertion",
    p."SU_NAM_SU_ID",
    p."SU_NAM_Subject_Name"
FROM
    public."SU_NAM_Subject_Name_Posit" p
JOIN
    public."rSU_NAM_Subject_Name_Annex"(positingTimepoint) a
ON
    a."SU_NAM_ID" = p."SU_NAM_ID"
AND
    a."SU_NAM_Positor" = coalesce(positor, a."SU_NAM_Positor")
ORDER BY
    p."SU_NAM_ID", a."SU_NAM_Positor",
    a."SU_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_COD_Subject_Code_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Positor" smallint,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_COD",
    "SU_COD_ID",
    "SU_COD_PositedAt",
    "SU_COD_Positor",
    "SU_COD_Reliability",
    "SU_COD_Assertion"
FROM
    public."SU_COD_Subject_Code_Annex"
WHERE
    "SU_COD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_COD_Subject_Code" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Positor" smallint,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Assertion" char(1),
    "SU_COD_SU_ID" integer,
    "SU_COD_Subject_Code" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."SU_COD_ID", a."SU_COD_Positor")
    a."Metadata_SU_COD",
    p."SU_COD_ID",
    a."SU_COD_PositedAt",
    a."SU_COD_Positor",
    a."SU_COD_Reliability",
    a."SU_COD_Assertion",
    p."SU_COD_SU_ID",
    p."SU_COD_Subject_Code"
FROM
    public."SU_COD_Subject_Code_Posit" p
JOIN
    public."rSU_COD_Subject_Code_Annex"(positingTimepoint) a
ON
    a."SU_COD_ID" = p."SU_COD_ID"
AND
    a."SU_COD_Positor" = coalesce(positor, a."SU_COD_Positor")
ORDER BY
    p."SU_COD_ID", a."SU_COD_Positor",
    a."SU_COD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_GRD_Subject_Grade_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Positor" smallint,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_GRD",
    "SU_GRD_ID",
    "SU_GRD_PositedAt",
    "SU_GRD_Positor",
    "SU_GRD_Reliability",
    "SU_GRD_Assertion"
FROM
    public."SU_GRD_Subject_Grade_Annex"
WHERE
    "SU_GRD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_GRD_Subject_Grade" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Positor" smallint,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_Assertion" char(1),
    "SU_GRD_SU_ID" integer,
    "SU_GRD_GRD_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."SU_GRD_ID", a."SU_GRD_Positor")
    a."Metadata_SU_GRD",
    p."SU_GRD_ID",
    a."SU_GRD_PositedAt",
    a."SU_GRD_Positor",
    a."SU_GRD_Reliability",
    a."SU_GRD_Assertion",
    p."SU_GRD_SU_ID",
    p."SU_GRD_GRD_ID"
FROM
    public."SU_GRD_Subject_Grade_Posit" p
JOIN
    public."rSU_GRD_Subject_Grade_Annex"(positingTimepoint) a
ON
    a."SU_GRD_ID" = p."SU_GRD_ID"
AND
    a."SU_GRD_Positor" = coalesce(positor, a."SU_GRD_Positor")
ORDER BY
    p."SU_GRD_ID", a."SU_GRD_Positor",
    a."SU_GRD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_NOT_Subject_Note_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Positor" smallint,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_NOT",
    "SU_NOT_ID",
    "SU_NOT_PositedAt",
    "SU_NOT_Positor",
    "SU_NOT_Reliability",
    "SU_NOT_Assertion"
FROM
    public."SU_NOT_Subject_Note_Annex"
WHERE
    "SU_NOT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_NOT_Subject_Note" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Positor" smallint,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Assertion" char(1),
    "SU_NOT_SU_ID" integer,
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text
)
AS
$$
SELECT DISTINCT ON (p."SU_NOT_ID", a."SU_NOT_Positor")
    a."Metadata_SU_NOT",
    p."SU_NOT_ID",
    a."SU_NOT_PositedAt",
    a."SU_NOT_Positor",
    a."SU_NOT_Reliability",
    a."SU_NOT_Assertion",
    p."SU_NOT_SU_ID",
    p."SU_NOT_Checksum",
    p."SU_NOT_Subject_Note"
FROM
    public."SU_NOT_Subject_Note_Posit" p
JOIN
    public."rSU_NOT_Subject_Note_Annex"(positingTimepoint) a
ON
    a."SU_NOT_ID" = p."SU_NOT_ID"
AND
    a."SU_NOT_Positor" = coalesce(positor, a."SU_NOT_Positor")
ORDER BY
    p."SU_NOT_ID", a."SU_NOT_Positor",
    a."SU_NOT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TTL_ID" integer,
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TTL_ID",
    "SU_TTL_SU_ID",
    "SU_TTL_Subject_Title",
    "SU_TTL_ChangedAt"
FROM
    public."SU_TTL_Subject_Title_Posit"
WHERE
    "SU_TTL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_TTL_Subject_Title_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TTL_ID" integer,
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TTL_ID",
    "SU_TTL_SU_ID",
    "SU_TTL_Subject_Title",
    "SU_TTL_ChangedAt"
FROM
    public."SU_TTL_Subject_Title_Posit"
WHERE
    "SU_TTL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Positor" smallint,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_TTL",
    "SU_TTL_ID",
    "SU_TTL_PositedAt",
    "SU_TTL_Positor",
    "SU_TTL_Reliability",
    "SU_TTL_Assertion"
FROM
    public."SU_TTL_Subject_Title_Annex"
WHERE
    "SU_TTL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Positor" smallint,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Assertion" char(1),
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TTL_ID", a."SU_TTL_Positor")
    a."Metadata_SU_TTL",
    p."SU_TTL_ID",
    a."SU_TTL_PositedAt",
    a."SU_TTL_Positor",
    a."SU_TTL_Reliability",
    a."SU_TTL_Assertion",
    p."SU_TTL_SU_ID",
    p."SU_TTL_Subject_Title",
    p."SU_TTL_ChangedAt"
FROM
    public."rSU_TTL_Subject_Title_Posit"(changingTimepoint) p
JOIN
    public."rSU_TTL_Subject_Title_Annex"(positingTimepoint) a
ON
    a."SU_TTL_ID" = p."SU_TTL_ID"
AND
    a."SU_TTL_Positor" = coalesce(positor, a."SU_TTL_Positor")
ORDER BY
    p."SU_TTL_ID", a."SU_TTL_Positor",
    a."SU_TTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_TTL_Subject_Title" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Positor" smallint,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Assertion" char(1),
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TTL_ID", a."SU_TTL_Positor")
    a."Metadata_SU_TTL",
    p."SU_TTL_ID",
    a."SU_TTL_PositedAt",
    a."SU_TTL_Positor",
    a."SU_TTL_Reliability",
    a."SU_TTL_Assertion",
    p."SU_TTL_SU_ID",
    p."SU_TTL_Subject_Title",
    p."SU_TTL_ChangedAt"
FROM
    public."fSU_TTL_Subject_Title_Posit"(changingTimepoint) p
JOIN
    public."rSU_TTL_Subject_Title_Annex"(positingTimepoint) a
ON
    a."SU_TTL_ID" = p."SU_TTL_ID"
AND
    a."SU_TTL_Positor" = coalesce(positor, a."SU_TTL_Positor")
ORDER BY
    p."SU_TTL_ID", a."SU_TTL_Positor",
    a."SU_TTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_TTL_Subject_Title" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_TTL_Subject_Title"
FROM
    public."rSU_TTL_Subject_Title"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_TTL_SU_ID" = id
AND
    pre."SU_TTL_ChangedAt" < changingTimepoint
AND
    pre."SU_TTL_Assertion" = coalesce(assertion, pre."SU_TTL_Assertion")
ORDER BY
    pre."SU_TTL_ChangedAt" DESC,
    pre."SU_TTL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_TTL_Subject_Title" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_TTL_Subject_Title"
FROM
    public."fSU_TTL_Subject_Title"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_TTL_SU_ID" = id
AND
    fol."SU_TTL_ChangedAt" > changingTimepoint
AND
    fol."SU_TTL_Assertion" = coalesce(assertion, fol."SU_TTL_Assertion")
ORDER BY
    fol."SU_TTL_ChangedAt" ASC,
    fol."SU_TTL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_STA_ID" integer,
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_STA_ID",
    "SU_STA_SU_ID",
    "SU_STA_Subject_State",
    "SU_STA_ChangedAt"
FROM
    public."SU_STA_Subject_State_Posit"
WHERE
    "SU_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_STA_Subject_State_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_STA_ID" integer,
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_STA_ID",
    "SU_STA_SU_ID",
    "SU_STA_Subject_State",
    "SU_STA_ChangedAt"
FROM
    public."SU_STA_Subject_State_Posit"
WHERE
    "SU_STA_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Positor" smallint,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_STA",
    "SU_STA_ID",
    "SU_STA_PositedAt",
    "SU_STA_Positor",
    "SU_STA_Reliability",
    "SU_STA_Assertion"
FROM
    public."SU_STA_Subject_State_Annex"
WHERE
    "SU_STA_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Positor" smallint,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Assertion" char(1),
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_STA_ID", a."SU_STA_Positor")
    a."Metadata_SU_STA",
    p."SU_STA_ID",
    a."SU_STA_PositedAt",
    a."SU_STA_Positor",
    a."SU_STA_Reliability",
    a."SU_STA_Assertion",
    p."SU_STA_SU_ID",
    p."SU_STA_Subject_State",
    p."SU_STA_ChangedAt"
FROM
    public."rSU_STA_Subject_State_Posit"(changingTimepoint) p
JOIN
    public."rSU_STA_Subject_State_Annex"(positingTimepoint) a
ON
    a."SU_STA_ID" = p."SU_STA_ID"
AND
    a."SU_STA_Positor" = coalesce(positor, a."SU_STA_Positor")
ORDER BY
    p."SU_STA_ID", a."SU_STA_Positor",
    a."SU_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_STA_Subject_State" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Positor" smallint,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Assertion" char(1),
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_STA_ID", a."SU_STA_Positor")
    a."Metadata_SU_STA",
    p."SU_STA_ID",
    a."SU_STA_PositedAt",
    a."SU_STA_Positor",
    a."SU_STA_Reliability",
    a."SU_STA_Assertion",
    p."SU_STA_SU_ID",
    p."SU_STA_Subject_State",
    p."SU_STA_ChangedAt"
FROM
    public."fSU_STA_Subject_State_Posit"(changingTimepoint) p
JOIN
    public."rSU_STA_Subject_State_Annex"(positingTimepoint) a
ON
    a."SU_STA_ID" = p."SU_STA_ID"
AND
    a."SU_STA_Positor" = coalesce(positor, a."SU_STA_Positor")
ORDER BY
    p."SU_STA_ID", a."SU_STA_Positor",
    a."SU_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_STA_Subject_State" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_STA_Subject_State"
FROM
    public."rSU_STA_Subject_State"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_STA_SU_ID" = id
AND
    pre."SU_STA_ChangedAt" < changingTimepoint
AND
    pre."SU_STA_Assertion" = coalesce(assertion, pre."SU_STA_Assertion")
ORDER BY
    pre."SU_STA_ChangedAt" DESC,
    pre."SU_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_STA_Subject_State" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_STA_Subject_State"
FROM
    public."fSU_STA_Subject_State"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_STA_SU_ID" = id
AND
    fol."SU_STA_ChangedAt" > changingTimepoint
AND
    fol."SU_STA_Assertion" = coalesce(assertion, fol."SU_STA_Assertion")
ORDER BY
    fol."SU_STA_ChangedAt" ASC,
    fol."SU_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LBL_ID" integer,
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LBL_ID",
    "SU_LBL_SU_ID",
    "SU_LBL_Subject_Label",
    "SU_LBL_ChangedAt"
FROM
    public."SU_LBL_Subject_Label_Posit"
WHERE
    "SU_LBL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_LBL_Subject_Label_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LBL_ID" integer,
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LBL_ID",
    "SU_LBL_SU_ID",
    "SU_LBL_Subject_Label",
    "SU_LBL_ChangedAt"
FROM
    public."SU_LBL_Subject_Label_Posit"
WHERE
    "SU_LBL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Positor" smallint,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_LBL",
    "SU_LBL_ID",
    "SU_LBL_PositedAt",
    "SU_LBL_Positor",
    "SU_LBL_Reliability",
    "SU_LBL_Assertion"
FROM
    public."SU_LBL_Subject_Label_Annex"
WHERE
    "SU_LBL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Positor" smallint,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Assertion" char(1),
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LBL_ID", a."SU_LBL_Positor")
    a."Metadata_SU_LBL",
    p."SU_LBL_ID",
    a."SU_LBL_PositedAt",
    a."SU_LBL_Positor",
    a."SU_LBL_Reliability",
    a."SU_LBL_Assertion",
    p."SU_LBL_SU_ID",
    p."SU_LBL_Subject_Label",
    p."SU_LBL_ChangedAt"
FROM
    public."rSU_LBL_Subject_Label_Posit"(changingTimepoint) p
JOIN
    public."rSU_LBL_Subject_Label_Annex"(positingTimepoint) a
ON
    a."SU_LBL_ID" = p."SU_LBL_ID"
AND
    a."SU_LBL_Positor" = coalesce(positor, a."SU_LBL_Positor")
ORDER BY
    p."SU_LBL_ID", a."SU_LBL_Positor",
    a."SU_LBL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_LBL_Subject_Label" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Positor" smallint,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Assertion" char(1),
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LBL_ID", a."SU_LBL_Positor")
    a."Metadata_SU_LBL",
    p."SU_LBL_ID",
    a."SU_LBL_PositedAt",
    a."SU_LBL_Positor",
    a."SU_LBL_Reliability",
    a."SU_LBL_Assertion",
    p."SU_LBL_SU_ID",
    p."SU_LBL_Subject_Label",
    p."SU_LBL_ChangedAt"
FROM
    public."fSU_LBL_Subject_Label_Posit"(changingTimepoint) p
JOIN
    public."rSU_LBL_Subject_Label_Annex"(positingTimepoint) a
ON
    a."SU_LBL_ID" = p."SU_LBL_ID"
AND
    a."SU_LBL_Positor" = coalesce(positor, a."SU_LBL_Positor")
ORDER BY
    p."SU_LBL_ID", a."SU_LBL_Positor",
    a."SU_LBL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_LBL_Subject_Label" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_LBL_Subject_Label"
FROM
    public."rSU_LBL_Subject_Label"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_LBL_SU_ID" = id
AND
    pre."SU_LBL_ChangedAt" < changingTimepoint
AND
    pre."SU_LBL_Assertion" = coalesce(assertion, pre."SU_LBL_Assertion")
ORDER BY
    pre."SU_LBL_ChangedAt" DESC,
    pre."SU_LBL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_LBL_Subject_Label" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_LBL_Subject_Label"
FROM
    public."fSU_LBL_Subject_Label"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_LBL_SU_ID" = id
AND
    fol."SU_LBL_ChangedAt" > changingTimepoint
AND
    fol."SU_LBL_Assertion" = coalesce(assertion, fol."SU_LBL_Assertion")
ORDER BY
    fol."SU_LBL_ChangedAt" ASC,
    fol."SU_LBL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TAG_ID" integer,
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TAG_ID",
    "SU_TAG_SU_ID",
    "SU_TAG_Subject_Tag",
    "SU_TAG_ChangedAt"
FROM
    public."SU_TAG_Subject_Tag_Posit"
WHERE
    "SU_TAG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_TAG_Subject_Tag_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TAG_ID" integer,
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TAG_ID",
    "SU_TAG_SU_ID",
    "SU_TAG_Subject_Tag",
    "SU_TAG_ChangedAt"
FROM
    public."SU_TAG_Subject_Tag_Posit"
WHERE
    "SU_TAG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Positor" smallint,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_TAG",
    "SU_TAG_ID",
    "SU_TAG_PositedAt",
    "SU_TAG_Positor",
    "SU_TAG_Reliability",
    "SU_TAG_Assertion"
FROM
    public."SU_TAG_Subject_Tag_Annex"
WHERE
    "SU_TAG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Positor" smallint,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Assertion" char(1),
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TAG_ID", a."SU_TAG_Positor")
    a."Metadata_SU_TAG",
    p."SU_TAG_ID",
    a."SU_TAG_PositedAt",
    a."SU_TAG_Positor",
    a."SU_TAG_Reliability",
    a."SU_TAG_Assertion",
    p."SU_TAG_SU_ID",
    p."SU_TAG_Subject_Tag",
    p."SU_TAG_ChangedAt"
FROM
    public."rSU_TAG_Subject_Tag_Posit"(changingTimepoint) p
JOIN
    public."rSU_TAG_Subject_Tag_Annex"(positingTimepoint) a
ON
    a."SU_TAG_ID" = p."SU_TAG_ID"
AND
    a."SU_TAG_Positor" = coalesce(positor, a."SU_TAG_Positor")
ORDER BY
    p."SU_TAG_ID", a."SU_TAG_Positor",
    a."SU_TAG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_TAG_Subject_Tag" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Positor" smallint,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Assertion" char(1),
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TAG_ID", a."SU_TAG_Positor")
    a."Metadata_SU_TAG",
    p."SU_TAG_ID",
    a."SU_TAG_PositedAt",
    a."SU_TAG_Positor",
    a."SU_TAG_Reliability",
    a."SU_TAG_Assertion",
    p."SU_TAG_SU_ID",
    p."SU_TAG_Subject_Tag",
    p."SU_TAG_ChangedAt"
FROM
    public."fSU_TAG_Subject_Tag_Posit"(changingTimepoint) p
JOIN
    public."rSU_TAG_Subject_Tag_Annex"(positingTimepoint) a
ON
    a."SU_TAG_ID" = p."SU_TAG_ID"
AND
    a."SU_TAG_Positor" = coalesce(positor, a."SU_TAG_Positor")
ORDER BY
    p."SU_TAG_ID", a."SU_TAG_Positor",
    a."SU_TAG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_TAG_Subject_Tag" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_TAG_Subject_Tag"
FROM
    public."rSU_TAG_Subject_Tag"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_TAG_SU_ID" = id
AND
    pre."SU_TAG_ChangedAt" < changingTimepoint
AND
    pre."SU_TAG_Assertion" = coalesce(assertion, pre."SU_TAG_Assertion")
ORDER BY
    pre."SU_TAG_ChangedAt" DESC,
    pre."SU_TAG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_TAG_Subject_Tag" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_TAG_Subject_Tag"
FROM
    public."fSU_TAG_Subject_Tag"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_TAG_SU_ID" = id
AND
    fol."SU_TAG_ChangedAt" > changingTimepoint
AND
    fol."SU_TAG_Assertion" = coalesce(assertion, fol."SU_TAG_Assertion")
ORDER BY
    fol."SU_TAG_ChangedAt" ASC,
    fol."SU_TAG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LVL_ID" integer,
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LVL_ID",
    "SU_LVL_SU_ID",
    "SU_LVL_GRD_ID",
    "SU_LVL_ChangedAt"
FROM
    public."SU_LVL_Subject_Level_Posit"
WHERE
    "SU_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_LVL_Subject_Level_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LVL_ID" integer,
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LVL_ID",
    "SU_LVL_SU_ID",
    "SU_LVL_GRD_ID",
    "SU_LVL_ChangedAt"
FROM
    public."SU_LVL_Subject_Level_Posit"
WHERE
    "SU_LVL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Positor" smallint,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_LVL",
    "SU_LVL_ID",
    "SU_LVL_PositedAt",
    "SU_LVL_Positor",
    "SU_LVL_Reliability",
    "SU_LVL_Assertion"
FROM
    public."SU_LVL_Subject_Level_Annex"
WHERE
    "SU_LVL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Positor" smallint,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_Assertion" char(1),
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LVL_ID", a."SU_LVL_Positor")
    a."Metadata_SU_LVL",
    p."SU_LVL_ID",
    a."SU_LVL_PositedAt",
    a."SU_LVL_Positor",
    a."SU_LVL_Reliability",
    a."SU_LVL_Assertion",
    p."SU_LVL_SU_ID",
    p."SU_LVL_GRD_ID",
    p."SU_LVL_ChangedAt"
FROM
    public."rSU_LVL_Subject_Level_Posit"(changingTimepoint) p
JOIN
    public."rSU_LVL_Subject_Level_Annex"(positingTimepoint) a
ON
    a."SU_LVL_ID" = p."SU_LVL_ID"
AND
    a."SU_LVL_Positor" = coalesce(positor, a."SU_LVL_Positor")
ORDER BY
    p."SU_LVL_ID", a."SU_LVL_Positor",
    a."SU_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_LVL_Subject_Level" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Positor" smallint,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_Assertion" char(1),
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LVL_ID", a."SU_LVL_Positor")
    a."Metadata_SU_LVL",
    p."SU_LVL_ID",
    a."SU_LVL_PositedAt",
    a."SU_LVL_Positor",
    a."SU_LVL_Reliability",
    a."SU_LVL_Assertion",
    p."SU_LVL_SU_ID",
    p."SU_LVL_GRD_ID",
    p."SU_LVL_ChangedAt"
FROM
    public."fSU_LVL_Subject_Level_Posit"(changingTimepoint) p
JOIN
    public."rSU_LVL_Subject_Level_Annex"(positingTimepoint) a
ON
    a."SU_LVL_ID" = p."SU_LVL_ID"
AND
    a."SU_LVL_Positor" = coalesce(positor, a."SU_LVL_Positor")
ORDER BY
    p."SU_LVL_ID", a."SU_LVL_Positor",
    a."SU_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_LVL_Subject_Level" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."SU_LVL_GRD_ID"
FROM
    public."rSU_LVL_Subject_Level"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_LVL_SU_ID" = id
AND
    pre."SU_LVL_ChangedAt" < changingTimepoint
AND
    pre."SU_LVL_Assertion" = coalesce(assertion, pre."SU_LVL_Assertion")
ORDER BY
    pre."SU_LVL_ChangedAt" DESC,
    pre."SU_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_LVL_Subject_Level" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."SU_LVL_GRD_ID"
FROM
    public."fSU_LVL_Subject_Level"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_LVL_SU_ID" = id
AND
    fol."SU_LVL_ChangedAt" > changingTimepoint
AND
    fol."SU_LVL_Assertion" = coalesce(assertion, fol."SU_LVL_Assertion")
ORDER BY
    fol."SU_LVL_ChangedAt" ASC,
    fol."SU_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TXT_ID" integer,
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TXT_ID",
    "SU_TXT_SU_ID",
    "SU_TXT_Checksum",
    "SU_TXT_Subject_Text",
    "SU_TXT_ChangedAt"
FROM
    public."SU_TXT_Subject_Text_Posit"
WHERE
    "SU_TXT_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_TXT_Subject_Text_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TXT_ID" integer,
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TXT_ID",
    "SU_TXT_SU_ID",
    "SU_TXT_Checksum",
    "SU_TXT_Subject_Text",
    "SU_TXT_ChangedAt"
FROM
    public."SU_TXT_Subject_Text_Posit"
WHERE
    "SU_TXT_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Positor" smallint,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_TXT",
    "SU_TXT_ID",
    "SU_TXT_PositedAt",
    "SU_TXT_Positor",
    "SU_TXT_Reliability",
    "SU_TXT_Assertion"
FROM
    public."SU_TXT_Subject_Text_Annex"
WHERE
    "SU_TXT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Positor" smallint,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Assertion" char(1),
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TXT_ID", a."SU_TXT_Positor")
    a."Metadata_SU_TXT",
    p."SU_TXT_ID",
    a."SU_TXT_PositedAt",
    a."SU_TXT_Positor",
    a."SU_TXT_Reliability",
    a."SU_TXT_Assertion",
    p."SU_TXT_SU_ID",
    p."SU_TXT_Checksum",
    p."SU_TXT_Subject_Text",
    p."SU_TXT_ChangedAt"
FROM
    public."rSU_TXT_Subject_Text_Posit"(changingTimepoint) p
JOIN
    public."rSU_TXT_Subject_Text_Annex"(positingTimepoint) a
ON
    a."SU_TXT_ID" = p."SU_TXT_ID"
AND
    a."SU_TXT_Positor" = coalesce(positor, a."SU_TXT_Positor")
ORDER BY
    p."SU_TXT_ID", a."SU_TXT_Positor",
    a."SU_TXT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_TXT_Subject_Text" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Positor" smallint,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Assertion" char(1),
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TXT_ID", a."SU_TXT_Positor")
    a."Metadata_SU_TXT",
    p."SU_TXT_ID",
    a."SU_TXT_PositedAt",
    a."SU_TXT_Positor",
    a."SU_TXT_Reliability",
    a."SU_TXT_Assertion",
    p."SU_TXT_SU_ID",
    p."SU_TXT_Checksum",
    p."SU_TXT_Subject_Text",
    p."SU_TXT_ChangedAt"
FROM
    public."fSU_TXT_Subject_Text_Posit"(changingTimepoint) p
JOIN
    public."rSU_TXT_Subject_Text_Annex"(positingTimepoint) a
ON
    a."SU_TXT_ID" = p."SU_TXT_ID"
AND
    a."SU_TXT_Positor" = coalesce(positor, a."SU_TXT_Positor")
ORDER BY
    p."SU_TXT_ID", a."SU_TXT_Positor",
    a."SU_TXT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_TXT_Subject_Text" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS bytea
AS
$$
SELECT
    pre."SU_TXT_Checksum" 
FROM
    public."rSU_TXT_Subject_Text"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_TXT_SU_ID" = id
AND
    pre."SU_TXT_ChangedAt" < changingTimepoint
AND
    pre."SU_TXT_Assertion" = coalesce(assertion, pre."SU_TXT_Assertion")
ORDER BY
    pre."SU_TXT_ChangedAt" DESC,
    pre."SU_TXT_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_TXT_Subject_Text" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS bytea
AS
$$
SELECT
    fol."SU_TXT_Checksum" 
FROM
    public."fSU_TXT_Subject_Text"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_TXT_SU_ID" = id
AND
    fol."SU_TXT_ChangedAt" > changingTimepoint
AND
    fol."SU_TXT_Assertion" = coalesce(assertion, fol."SU_TXT_Assertion")
ORDER BY
    fol."SU_TXT_ChangedAt" ASC,
    fol."SU_TXT_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ASR_ID" integer,
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ASR_ID",
    "SU_ASR_SU_ID",
    "SU_ASR_Subject_Assessment",
    "SU_ASR_ChangedAt"
FROM
    public."SU_ASR_Subject_Assessment_Posit"
WHERE
    "SU_ASR_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_ASR_Subject_Assessment_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ASR_ID" integer,
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ASR_ID",
    "SU_ASR_SU_ID",
    "SU_ASR_Subject_Assessment",
    "SU_ASR_ChangedAt"
FROM
    public."SU_ASR_Subject_Assessment_Posit"
WHERE
    "SU_ASR_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Positor" smallint,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_ASR",
    "SU_ASR_ID",
    "SU_ASR_PositedAt",
    "SU_ASR_Positor",
    "SU_ASR_Reliability",
    "SU_ASR_Assertion"
FROM
    public."SU_ASR_Subject_Assessment_Annex"
WHERE
    "SU_ASR_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Positor" smallint,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Assertion" char(1),
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ASR_ID", a."SU_ASR_Positor")
    a."Metadata_SU_ASR",
    p."SU_ASR_ID",
    a."SU_ASR_PositedAt",
    a."SU_ASR_Positor",
    a."SU_ASR_Reliability",
    a."SU_ASR_Assertion",
    p."SU_ASR_SU_ID",
    p."SU_ASR_Subject_Assessment",
    p."SU_ASR_ChangedAt"
FROM
    public."rSU_ASR_Subject_Assessment_Posit"(changingTimepoint) p
JOIN
    public."rSU_ASR_Subject_Assessment_Annex"(positingTimepoint) a
ON
    a."SU_ASR_ID" = p."SU_ASR_ID"
AND
    a."SU_ASR_Positor" = coalesce(positor, a."SU_ASR_Positor")
ORDER BY
    p."SU_ASR_ID", a."SU_ASR_Positor",
    a."SU_ASR_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_ASR_Subject_Assessment" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Positor" smallint,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Assertion" char(1),
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ASR_ID", a."SU_ASR_Positor")
    a."Metadata_SU_ASR",
    p."SU_ASR_ID",
    a."SU_ASR_PositedAt",
    a."SU_ASR_Positor",
    a."SU_ASR_Reliability",
    a."SU_ASR_Assertion",
    p."SU_ASR_SU_ID",
    p."SU_ASR_Subject_Assessment",
    p."SU_ASR_ChangedAt"
FROM
    public."fSU_ASR_Subject_Assessment_Posit"(changingTimepoint) p
JOIN
    public."rSU_ASR_Subject_Assessment_Annex"(positingTimepoint) a
ON
    a."SU_ASR_ID" = p."SU_ASR_ID"
AND
    a."SU_ASR_Positor" = coalesce(positor, a."SU_ASR_Positor")
ORDER BY
    p."SU_ASR_ID", a."SU_ASR_Positor",
    a."SU_ASR_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_ASR_Subject_Assessment" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_ASR_Subject_Assessment"
FROM
    public."rSU_ASR_Subject_Assessment"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_ASR_SU_ID" = id
AND
    pre."SU_ASR_ChangedAt" < changingTimepoint
AND
    pre."SU_ASR_Assertion" = coalesce(assertion, pre."SU_ASR_Assertion")
ORDER BY
    pre."SU_ASR_ChangedAt" DESC,
    pre."SU_ASR_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_ASR_Subject_Assessment" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_ASR_Subject_Assessment"
FROM
    public."fSU_ASR_Subject_Assessment"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_ASR_SU_ID" = id
AND
    fol."SU_ASR_ChangedAt" > changingTimepoint
AND
    fol."SU_ASR_Assertion" = coalesce(assertion, fol."SU_ASR_Assertion")
ORDER BY
    fol."SU_ASR_ChangedAt" ASC,
    fol."SU_ASR_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ERS_ID" integer,
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ERS_ID",
    "SU_ERS_SU_ID",
    "SU_ERS_Subject_Erasable",
    "SU_ERS_ChangedAt"
FROM
    public."SU_ERS_Subject_Erasable_Posit"
WHERE
    "SU_ERS_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_ERS_Subject_Erasable_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ERS_ID" integer,
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ERS_ID",
    "SU_ERS_SU_ID",
    "SU_ERS_Subject_Erasable",
    "SU_ERS_ChangedAt"
FROM
    public."SU_ERS_Subject_Erasable_Posit"
WHERE
    "SU_ERS_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Positor" smallint,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_SU_ERS",
    "SU_ERS_ID",
    "SU_ERS_PositedAt",
    "SU_ERS_Positor",
    "SU_ERS_Reliability",
    "SU_ERS_Assertion"
FROM
    public."SU_ERS_Subject_Erasable_Annex"
WHERE
    "SU_ERS_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Positor" smallint,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Assertion" char(1),
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ERS_ID", a."SU_ERS_Positor")
    a."Metadata_SU_ERS",
    p."SU_ERS_ID",
    a."SU_ERS_PositedAt",
    a."SU_ERS_Positor",
    a."SU_ERS_Reliability",
    a."SU_ERS_Assertion",
    p."SU_ERS_SU_ID",
    p."SU_ERS_Subject_Erasable",
    p."SU_ERS_ChangedAt"
FROM
    public."rSU_ERS_Subject_Erasable_Posit"(changingTimepoint) p
JOIN
    public."rSU_ERS_Subject_Erasable_Annex"(positingTimepoint) a
ON
    a."SU_ERS_ID" = p."SU_ERS_ID"
AND
    a."SU_ERS_Positor" = coalesce(positor, a."SU_ERS_Positor")
ORDER BY
    p."SU_ERS_ID", a."SU_ERS_Positor",
    a."SU_ERS_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fSU_ERS_Subject_Erasable" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Positor" smallint,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Assertion" char(1),
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ERS_ID", a."SU_ERS_Positor")
    a."Metadata_SU_ERS",
    p."SU_ERS_ID",
    a."SU_ERS_PositedAt",
    a."SU_ERS_Positor",
    a."SU_ERS_Reliability",
    a."SU_ERS_Assertion",
    p."SU_ERS_SU_ID",
    p."SU_ERS_Subject_Erasable",
    p."SU_ERS_ChangedAt"
FROM
    public."fSU_ERS_Subject_Erasable_Posit"(changingTimepoint) p
JOIN
    public."rSU_ERS_Subject_Erasable_Annex"(positingTimepoint) a
ON
    a."SU_ERS_ID" = p."SU_ERS_ID"
AND
    a."SU_ERS_Positor" = coalesce(positor, a."SU_ERS_Positor")
ORDER BY
    p."SU_ERS_ID", a."SU_ERS_Positor",
    a."SU_ERS_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preSU_ERS_Subject_Erasable" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_ERS_Subject_Erasable"
FROM
    public."rSU_ERS_Subject_Erasable"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_ERS_SU_ID" = id
AND
    pre."SU_ERS_ChangedAt" < changingTimepoint
AND
    pre."SU_ERS_Assertion" = coalesce(assertion, pre."SU_ERS_Assertion")
ORDER BY
    pre."SU_ERS_ChangedAt" DESC,
    pre."SU_ERS_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folSU_ERS_Subject_Erasable" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_ERS_Subject_Erasable"
FROM
    public."fSU_ERS_Subject_Erasable"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_ERS_SU_ID" = id
AND
    fol."SU_ERS_ChangedAt" > changingTimepoint
AND
    fol."SU_ERS_Assertion" = coalesce(assertion, fol."SU_ERS_Assertion")
ORDER BY
    fol."SU_ERS_ChangedAt" ASC,
    fol."SU_ERS_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rOB_NAM_Object_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Positor" smallint,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_OB_NAM",
    "OB_NAM_ID",
    "OB_NAM_PositedAt",
    "OB_NAM_Positor",
    "OB_NAM_Reliability",
    "OB_NAM_Assertion"
FROM
    public."OB_NAM_Object_Name_Annex"
WHERE
    "OB_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rOB_NAM_Object_Name" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Positor" smallint,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_Assertion" char(1),
    "OB_NAM_OB_ID" integer,
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."OB_NAM_ID", a."OB_NAM_Positor")
    a."Metadata_OB_NAM",
    p."OB_NAM_ID",
    a."OB_NAM_PositedAt",
    a."OB_NAM_Positor",
    a."OB_NAM_Reliability",
    a."OB_NAM_Assertion",
    p."OB_NAM_OB_ID",
    p."OB_NAM_Object_Name"
FROM
    public."OB_NAM_Object_Name_Posit" p
JOIN
    public."rOB_NAM_Object_Name_Annex"(positingTimepoint) a
ON
    a."OB_NAM_ID" = p."OB_NAM_ID"
AND
    a."OB_NAM_Positor" = coalesce(positor, a."OB_NAM_Positor")
ORDER BY
    p."OB_NAM_ID", a."OB_NAM_Positor",
    a."OB_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
