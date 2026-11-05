-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION public."rSU_holder_OB_item_GRD_grade_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_holder_OB_item_GRD_grade_ID",
    "SU_ID_holder",
    "OB_ID_item",
    "GRD_ID_grade",
    "SU_holder_OB_item_GRD_grade_ChangedAt"
FROM
    public."SU_holder_OB_item_GRD_grade_Posit"
WHERE
    "SU_holder_OB_item_GRD_grade_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_holder_OB_item_GRD_grade_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_holder_OB_item_GRD_grade_ID",
    "SU_ID_holder",
    "OB_ID_item",
    "GRD_ID_grade",
    "SU_holder_OB_item_GRD_grade_ChangedAt"
FROM
    public."SU_holder_OB_item_GRD_grade_Posit"
WHERE
    "SU_holder_OB_item_GRD_grade_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_holder_OB_item_GRD_grade_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_holder_OB_item_GRD_grade",
    "SU_holder_OB_item_GRD_grade_ID",
    "SU_holder_OB_item_GRD_grade_PositedAt",
    "SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."SU_holder_OB_item_GRD_grade_Annex"
WHERE
    "SU_holder_OB_item_GRD_grade_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_holder_OB_item_GRD_grade_ID")
    a."Metadata_SU_holder_OB_item_GRD_grade",
    p."SU_holder_OB_item_GRD_grade_ID",
    p."SU_ID_holder",
    p."OB_ID_item",
    p."GRD_ID_grade",
    p."SU_holder_OB_item_GRD_grade_ChangedAt",
    a."SU_holder_OB_item_GRD_grade_PositedAt",
    a."SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."rSU_holder_OB_item_GRD_grade_Posit"(changingTimepoint) p 
JOIN
    public."rSU_holder_OB_item_GRD_grade_Annex"(positingTimepoint) a
ON
    a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
ORDER BY
    p."SU_holder_OB_item_GRD_grade_ID",
    a."SU_holder_OB_item_GRD_grade_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_holder_OB_item_GRD_grade_ID")
    a."Metadata_SU_holder_OB_item_GRD_grade",
    p."SU_holder_OB_item_GRD_grade_ID",
    p."SU_ID_holder",
    p."OB_ID_item",
    p."GRD_ID_grade",
    p."SU_holder_OB_item_GRD_grade_ChangedAt",
    a."SU_holder_OB_item_GRD_grade_PositedAt",
    a."SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."fSU_holder_OB_item_GRD_grade_Posit"(changingTimepoint) p 
JOIN
    public."rSU_holder_OB_item_GRD_grade_Annex"(positingTimepoint) a
ON
    a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
ORDER BY
    p."SU_holder_OB_item_GRD_grade_ID",
    a."SU_holder_OB_item_GRD_grade_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_keeper_OB_thing_GRD_rank_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_keeper_OB_thing_GRD_rank_ID",
    "SU_ID_keeper",
    "OB_ID_thing",
    "GRD_ID_rank",
    "SU_keeper_OB_thing_GRD_rank_ChangedAt"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Posit"
WHERE
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_keeper_OB_thing_GRD_rank_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_keeper_OB_thing_GRD_rank_ID",
    "SU_ID_keeper",
    "OB_ID_thing",
    "GRD_ID_rank",
    "SU_keeper_OB_thing_GRD_rank_ChangedAt"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Posit"
WHERE
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_keeper_OB_thing_GRD_rank_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_keeper_OB_thing_GRD_rank",
    "SU_keeper_OB_thing_GRD_rank_ID",
    "SU_keeper_OB_thing_GRD_rank_PositedAt",
    "SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Annex"
WHERE
    "SU_keeper_OB_thing_GRD_rank_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_keeper_OB_thing_GRD_rank_ID")
    a."Metadata_SU_keeper_OB_thing_GRD_rank",
    p."SU_keeper_OB_thing_GRD_rank_ID",
    p."SU_ID_keeper",
    p."OB_ID_thing",
    p."GRD_ID_rank",
    p."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt",
    a."SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."rSU_keeper_OB_thing_GRD_rank_Posit"(changingTimepoint) p 
JOIN
    public."rSU_keeper_OB_thing_GRD_rank_Annex"(positingTimepoint) a
ON
    a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
ORDER BY
    p."SU_keeper_OB_thing_GRD_rank_ID",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_keeper_OB_thing_GRD_rank_ID")
    a."Metadata_SU_keeper_OB_thing_GRD_rank",
    p."SU_keeper_OB_thing_GRD_rank_ID",
    p."SU_ID_keeper",
    p."OB_ID_thing",
    p."GRD_ID_rank",
    p."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt",
    a."SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."fSU_keeper_OB_thing_GRD_rank_Posit"(changingTimepoint) p 
JOIN
    public."rSU_keeper_OB_thing_GRD_rank_Annex"(positingTimepoint) a
ON
    a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
ORDER BY
    p."SU_keeper_OB_thing_GRD_rank_ID",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rOB_part_SU_owner_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_ID" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_OB_part_SU_owner",
    "OB_part_SU_owner_ID",
    "OB_part_SU_owner_PositedAt",
    "OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Annex"
WHERE
    "OB_part_SU_owner_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rOB_part_SU_owner" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_ID" integer,
    "OB_ID_part" integer, 
    "SU_ID_owner" integer, 
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."OB_part_SU_owner_ID")
    a."Metadata_OB_part_SU_owner",
    p."OB_part_SU_owner_ID",
    p."OB_ID_part",
    p."SU_ID_owner",
    a."OB_part_SU_owner_PositedAt",
    a."OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Posit" p
JOIN
    public."rOB_part_SU_owner_Annex"(positingTimepoint) a
ON
    a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
ORDER BY
    p."OB_part_SU_owner_ID",
    a."OB_part_SU_owner_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fOB_part_SU_owner" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_ID" integer,
    "OB_ID_part" integer, 
    "SU_ID_owner" integer, 
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."OB_part_SU_owner_ID")
    a."Metadata_OB_part_SU_owner",
    p."OB_part_SU_owner_ID",
    p."OB_ID_part",
    p."SU_ID_owner",
    a."OB_part_SU_owner_PositedAt",
    a."OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Posit" p
JOIN
    public."rOB_part_SU_owner_Annex"(positingTimepoint) a
ON
    a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
ORDER BY
    p."OB_part_SU_owner_ID",
    a."OB_part_SU_owner_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_partner_SU_with_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_partner_SU_with_ID",
    "SU_ID_partner",
    "SU_ID_with",
    "SU_partner_SU_with_ChangedAt"
FROM
    public."SU_partner_SU_with_Posit"
WHERE
    "SU_partner_SU_with_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_partner_SU_with_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_partner_SU_with_ID",
    "SU_ID_partner",
    "SU_ID_with",
    "SU_partner_SU_with_ChangedAt"
FROM
    public."SU_partner_SU_with_Posit"
WHERE
    "SU_partner_SU_with_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_partner_SU_with_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ID" integer,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_partner_SU_with",
    "SU_partner_SU_with_ID",
    "SU_partner_SU_with_PositedAt",
    "SU_partner_SU_with_Reliability"
FROM
    public."SU_partner_SU_with_Annex"
WHERE
    "SU_partner_SU_with_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_partner_SU_with" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_partner_SU_with_ID")
    a."Metadata_SU_partner_SU_with",
    p."SU_partner_SU_with_ID",
    p."SU_ID_partner",
    p."SU_ID_with",
    p."SU_partner_SU_with_ChangedAt",
    a."SU_partner_SU_with_PositedAt",
    a."SU_partner_SU_with_Reliability"
FROM
    public."rSU_partner_SU_with_Posit"(changingTimepoint) p 
JOIN
    public."rSU_partner_SU_with_Annex"(positingTimepoint) a
ON
    a."SU_partner_SU_with_ID" = p."SU_partner_SU_with_ID"
ORDER BY
    p."SU_partner_SU_with_ID",
    a."SU_partner_SU_with_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_partner_SU_with" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_partner_SU_with_ID")
    a."Metadata_SU_partner_SU_with",
    p."SU_partner_SU_with_ID",
    p."SU_ID_partner",
    p."SU_ID_with",
    p."SU_partner_SU_with_ChangedAt",
    a."SU_partner_SU_with_PositedAt",
    a."SU_partner_SU_with_Reliability"
FROM
    public."fSU_partner_SU_with_Posit"(changingTimepoint) p 
JOIN
    public."rSU_partner_SU_with_Annex"(positingTimepoint) a
ON
    a."SU_partner_SU_with_ID" = p."SU_partner_SU_with_ID"
ORDER BY
    p."SU_partner_SU_with_ID",
    a."SU_partner_SU_with_PositedAt" DESC
$$ LANGUAGE sql STABLE;
