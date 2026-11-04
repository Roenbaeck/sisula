-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null.
--
CREATE OR REPLACE FUNCTION public."rAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_partner_AC_with_ONG_currently_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Positor",
    "AC_partner_AC_with_ONG_currently_Reliability",
    "AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."AC_partner_AC_with_ONG_currently_Annex"
WHERE
    "AC_partner_AC_with_ONG_currently_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."rAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint) p 
JOIN
    public."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = coalesce(positor, a."AC_partner_AC_with_ONG_currently_Positor")
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."fAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint) p 
JOIN
    public."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = coalesce(positor, a."AC_partner_AC_with_ONG_currently_Positor")
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_subset_PN_of_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_subset_PN_of",
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_PositedAt",
    "AC_subset_PN_of_Positor",
    "AC_subset_PN_of_Reliability",
    "AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Annex"
WHERE
    "AC_subset_PN_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_subset_PN_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_ID_subset" integer, 
    "PN_ID_of" integer, 
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."rAC_subset_PN_of_Annex"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = coalesce(positor, a."AC_subset_PN_of_Positor")
ORDER BY
    p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_subset_PN_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_ID_subset" integer, 
    "PN_ID_of" integer, 
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."rAC_subset_PN_of_Annex"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = coalesce(positor, a."AC_subset_PN_of_Positor")
ORDER BY
    p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_in_AC_wasCast_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_ID" integer,
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_in_AC_wasCast",
    "EV_in_AC_wasCast_ID",
    "EV_in_AC_wasCast_PositedAt",
    "EV_in_AC_wasCast_Positor",
    "EV_in_AC_wasCast_Reliability",
    "EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Annex"
WHERE
    "EV_in_AC_wasCast_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_in_AC_wasCast" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_ID" integer,
    "EV_ID_in" integer, 
    "AC_ID_wasCast" integer, 
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor")
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."rEV_in_AC_wasCast_Annex"(positingTimepoint) a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
AND
    a."EV_in_AC_wasCast_Positor" = coalesce(positor, a."EV_in_AC_wasCast_Positor")
ORDER BY
    p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fEV_in_AC_wasCast" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_ID" integer,
    "EV_ID_in" integer, 
    "AC_ID_wasCast" integer, 
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor")
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."rEV_in_AC_wasCast_Annex"(positingTimepoint) a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
AND
    a."EV_in_AC_wasCast_Positor" = coalesce(positor, a."EV_in_AC_wasCast_Positor")
ORDER BY
    p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_part_PR_in_RAT_got_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_part_PR_in_RAT_got_ID",
    "AC_ID_part",
    "PR_ID_in",
    "RAT_ID_got",
    "AC_part_PR_in_RAT_got_ChangedAt"
FROM
    public."AC_part_PR_in_RAT_got_Posit"
WHERE
    "AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_part_PR_in_RAT_got_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_part_PR_in_RAT_got_ID",
    "AC_ID_part",
    "PR_ID_in",
    "RAT_ID_got",
    "AC_part_PR_in_RAT_got_ChangedAt"
FROM
    public."AC_part_PR_in_RAT_got_Posit"
WHERE
    "AC_part_PR_in_RAT_got_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_part_PR_in_RAT_got_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_part_PR_in_RAT_got",
    "AC_part_PR_in_RAT_got_ID",
    "AC_part_PR_in_RAT_got_PositedAt",
    "AC_part_PR_in_RAT_got_Positor",
    "AC_part_PR_in_RAT_got_Reliability",
    "AC_part_PR_in_RAT_got_Assertion"
FROM
    public."AC_part_PR_in_RAT_got_Annex"
WHERE
    "AC_part_PR_in_RAT_got_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor")
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."rAC_part_PR_in_RAT_got_Posit"(changingTimepoint) p 
JOIN
    public."rAC_part_PR_in_RAT_got_Annex"(positingTimepoint) a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
AND
    a."AC_part_PR_in_RAT_got_Positor" = coalesce(positor, a."AC_part_PR_in_RAT_got_Positor")
ORDER BY
    p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor")
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."fAC_part_PR_in_RAT_got_Posit"(changingTimepoint) p 
JOIN
    public."rAC_part_PR_in_RAT_got_Annex"(positingTimepoint) a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
AND
    a."AC_part_PR_in_RAT_got_Positor" = coalesce(positor, a."AC_part_PR_in_RAT_got_Positor")
ORDER BY
    p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rST_at_PR_isPlaying_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_at_PR_isPlaying_ID",
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt"
FROM
    public."ST_at_PR_isPlaying_Posit"
WHERE
    "ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fST_at_PR_isPlaying_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_at_PR_isPlaying_ID",
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt"
FROM
    public."ST_at_PR_isPlaying_Posit"
WHERE
    "ST_at_PR_isPlaying_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rST_at_PR_isPlaying_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ID" integer,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_ST_at_PR_isPlaying",
    "ST_at_PR_isPlaying_ID",
    "ST_at_PR_isPlaying_PositedAt",
    "ST_at_PR_isPlaying_Positor",
    "ST_at_PR_isPlaying_Reliability",
    "ST_at_PR_isPlaying_Assertion"
FROM
    public."ST_at_PR_isPlaying_Annex"
WHERE
    "ST_at_PR_isPlaying_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor")
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."rST_at_PR_isPlaying_Posit"(changingTimepoint) p 
JOIN
    public."rST_at_PR_isPlaying_Annex"(positingTimepoint) a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
AND
    a."ST_at_PR_isPlaying_Positor" = coalesce(positor, a."ST_at_PR_isPlaying_Positor")
ORDER BY
    p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor")
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."fST_at_PR_isPlaying_Posit"(changingTimepoint) p 
JOIN
    public."rST_at_PR_isPlaying_Annex"(positingTimepoint) a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
AND
    a."ST_at_PR_isPlaying_Positor" = coalesce(positor, a."ST_at_PR_isPlaying_Positor")
ORDER BY
    p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_parent_AC_child_PAT_having_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_ID" integer,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_parent_AC_child_PAT_having",
    "AC_parent_AC_child_PAT_having_ID",
    "AC_parent_AC_child_PAT_having_PositedAt",
    "AC_parent_AC_child_PAT_having_Positor",
    "AC_parent_AC_child_PAT_having_Reliability",
    "AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Annex"
WHERE
    "AC_parent_AC_child_PAT_having_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_parent_AC_child_PAT_having" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_ID" integer,
    "AC_ID_parent" integer, 
    "AC_ID_child" integer, 
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor")
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."rAC_parent_AC_child_PAT_having_Annex"(positingTimepoint) a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
AND
    a."AC_parent_AC_child_PAT_having_Positor" = coalesce(positor, a."AC_parent_AC_child_PAT_having_Positor")
ORDER BY
    p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_parent_AC_child_PAT_having" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_ID" integer,
    "AC_ID_parent" integer, 
    "AC_ID_child" integer, 
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor")
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."rAC_parent_AC_child_PAT_having_Annex"(positingTimepoint) a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
AND
    a."AC_parent_AC_child_PAT_having_Positor" = coalesce(positor, a."AC_parent_AC_child_PAT_having_Positor")
ORDER BY
    p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rPR_content_ST_location_EV_of_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ID" integer,
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_PR_content_ST_location_EV_of",
    "PR_content_ST_location_EV_of_ID",
    "PR_content_ST_location_EV_of_PositedAt",
    "PR_content_ST_location_EV_of_Positor",
    "PR_content_ST_location_EV_of_Reliability",
    "PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Annex"
WHERE
    "PR_content_ST_location_EV_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rPR_content_ST_location_EV_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ID" integer,
    "PR_ID_content" integer, 
    "ST_ID_location" integer, 
    "EV_ID_of" integer, 
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor")
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."rPR_content_ST_location_EV_of_Annex"(positingTimepoint) a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
AND
    a."PR_content_ST_location_EV_of_Positor" = coalesce(positor, a."PR_content_ST_location_EV_of_Positor")
ORDER BY
    p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fPR_content_ST_location_EV_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ID" integer,
    "PR_ID_content" integer, 
    "ST_ID_location" integer, 
    "EV_ID_of" integer, 
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor")
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."rPR_content_ST_location_EV_of_Annex"(positingTimepoint) a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
AND
    a."PR_content_ST_location_EV_of_Positor" = coalesce(positor, a."PR_content_ST_location_EV_of_Positor")
ORDER BY
    p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
