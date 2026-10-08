-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection.
--
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime
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
    ties."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime
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
    ties."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
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
    ties."AC_partner_AC_with_ONG_currently_Annex"
WHERE
    "AC_partner_AC_with_ONG_currently_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
SELECT
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
    TABLE(ties."rAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint)) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_partner_AC_with_ONG_currently_ID"
        ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ID" int,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
SELECT
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
    TABLE(ties."fAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint)) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_partner_AC_with_ONG_currently_ID"
        ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_ID" int,
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
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
    ties."AC_subset_PN_of_Annex"
WHERE
    "AC_subset_PN_of_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_ID" int,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    TABLE(ties."rAC_subset_PN_of_Annex"(positingTimepoint)) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_subset_PN_of_ID"
        ORDER BY a."AC_subset_PN_of_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_subset_PN_of" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_ID" int,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    TABLE(ties."rAC_subset_PN_of_Annex"(positingTimepoint)) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_subset_PN_of_ID"
        ORDER BY a."AC_subset_PN_of_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_rollsattes_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_ID" int,
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    "Metadata_EV_in_AC_rollsattes",
    "EV_in_AC_rollsattes_ID",
    "EV_in_AC_rollsattes_PositedAt",
    "EV_in_AC_rollsattes_Positor",
    "EV_in_AC_rollsattes_Reliability",
    "EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Annex"
WHERE
    "EV_in_AC_rollsattes_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_rollsattes" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_ID" int,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_rollsattes" smallint, 
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Positor",
    a."EV_in_AC_rollsattes_Reliability",
    a."EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    TABLE(ties."rEV_in_AC_rollsattes_Annex"(positingTimepoint)) a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
AND
    a."EV_in_AC_rollsattes_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_in_AC_rollsattes_ID"
        ORDER BY a."EV_in_AC_rollsattes_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fEV_in_AC_rollsattes" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_ID" int,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_rollsattes" smallint, 
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Positor",
    a."EV_in_AC_rollsattes_Reliability",
    a."EV_in_AC_rollsattes_Assertion"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    TABLE(ties."rEV_in_AC_rollsattes_Annex"(positingTimepoint)) a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
AND
    a."EV_in_AC_rollsattes_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."EV_in_AC_rollsattes_ID"
        ORDER BY a."EV_in_AC_rollsattes_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime
)
AS
$$
SELECT
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_ID_deltar",
    "PR_ID_in",
    "RAT_ID_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
WHERE
    "AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_deltar_PR_in_RAT_fick_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime
)
AS
$$
SELECT
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_ID_deltar",
    "PR_ID_in",
    "RAT_ID_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
WHERE
    "AC_deltar_PR_in_RAT_fick_ChangedAt" > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_deltar_PR_in_RAT_fick_PositedAt",
    "AC_deltar_PR_in_RAT_fick_Positor",
    "AC_deltar_PR_in_RAT_fick_Reliability",
    "AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex"
WHERE
    "AC_deltar_PR_in_RAT_fick_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Positor",
    a."AC_deltar_PR_in_RAT_fick_Reliability",
    a."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    TABLE(ties."rAC_deltar_PR_in_RAT_fick_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_deltar_PR_in_RAT_fick_Annex"(positingTimepoint)) a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
AND
    a."AC_deltar_PR_in_RAT_fick_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_deltar_PR_in_RAT_fick_ID"
        ORDER BY a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_deltar_PR_in_RAT_fick" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" number(10,0), 
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Positor",
    a."AC_deltar_PR_in_RAT_fick_Reliability",
    a."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    TABLE(ties."fAC_deltar_PR_in_RAT_fick_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rAC_deltar_PR_in_RAT_fick_Annex"(positingTimepoint)) a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
AND
    a."AC_deltar_PR_in_RAT_fick_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_deltar_PR_in_RAT_fick_ID"
        ORDER BY a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime
)
AS
$$
SELECT
    "ST_at_PR_spelas_ID",
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
FROM
    ties."ST_at_PR_spelas_Posit"
WHERE
    "ST_at_PR_spelas_ChangedAt" <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_spelas_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime
)
AS
$$
SELECT
    "ST_at_PR_spelas_ID",
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
FROM
    ties."ST_at_PR_spelas_Posit"
WHERE
    "ST_at_PR_spelas_ChangedAt" > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ID" int,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ID",
    "ST_at_PR_spelas_PositedAt",
    "ST_at_PR_spelas_Positor",
    "ST_at_PR_spelas_Reliability",
    "ST_at_PR_spelas_Assertion"
FROM
    ties."ST_at_PR_spelas_Annex"
WHERE
    "ST_at_PR_spelas_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Positor",
    a."ST_at_PR_spelas_Reliability",
    a."ST_at_PR_spelas_Assertion"
FROM
    TABLE(ties."rST_at_PR_spelas_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rST_at_PR_spelas_Annex"(positingTimepoint)) a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
AND
    a."ST_at_PR_spelas_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_at_PR_spelas_ID"
        ORDER BY a."ST_at_PR_spelas_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_spelas" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ID" int,
    "ST_ID_at" int, 
    "PR_ID_spelas" number(10,0), 
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Positor",
    a."ST_at_PR_spelas_Reliability",
    a."ST_at_PR_spelas_Assertion"
FROM
    TABLE(ties."fST_at_PR_spelas_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rST_at_PR_spelas_Annex"(positingTimepoint)) a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
AND
    a."ST_at_PR_spelas_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."ST_at_PR_spelas_ID"
        ORDER BY a."ST_at_PR_spelas_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_förälder_AC_barn_PAT_har_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_förälder_AC_barn_PAT_har_ID",
    "AC_förälder_AC_barn_PAT_har_PositedAt",
    "AC_förälder_AC_barn_PAT_har_Positor",
    "AC_förälder_AC_barn_PAT_har_Reliability",
    "AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex"
WHERE
    "AC_förälder_AC_barn_PAT_har_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rAC_förälder_AC_barn_PAT_har" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "AC_ID_förälder" smallint, 
    "AC_ID_barn" smallint, 
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Positor",
    a."AC_förälder_AC_barn_PAT_har_Reliability",
    a."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    TABLE(ties."rAC_förälder_AC_barn_PAT_har_Annex"(positingTimepoint)) a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
AND
    a."AC_förälder_AC_barn_PAT_har_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_förälder_AC_barn_PAT_har_ID"
        ORDER BY a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fAC_förälder_AC_barn_PAT_har" (
    positor tinyint,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "AC_ID_förälder" smallint, 
    "AC_ID_barn" smallint, 
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Positor",
    a."AC_förälder_AC_barn_PAT_har_Reliability",
    a."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    TABLE(ties."rAC_förälder_AC_barn_PAT_har_Annex"(positingTimepoint)) a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
AND
    a."AC_förälder_AC_barn_PAT_har_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."AC_förälder_AC_barn_PAT_har_ID"
        ORDER BY a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime
)
AS
$$
SELECT
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
WHERE
    "PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."fPR_innehåll_ST_plats_EV_of_Posit" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime
)
AS
$$
SELECT
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
WHERE
    "PR_innehåll_ST_plats_EV_of_ChangedAt" > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of_Annex" (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_innehåll_ST_plats_EV_of_PositedAt",
    "PR_innehåll_ST_plats_EV_of_Positor",
    "PR_innehåll_ST_plats_EV_of_Reliability",
    "PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex"
WHERE
    "PR_innehåll_ST_plats_EV_of_PositedAt" <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Positor",
    a."PR_innehåll_ST_plats_EV_of_Reliability",
    a."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    TABLE(ties."rPR_innehåll_ST_plats_EV_of_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rPR_innehåll_ST_plats_EV_of_Annex"(positingTimepoint)) a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
AND
    a."PR_innehåll_ST_plats_EV_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_innehåll_ST_plats_EV_of_ID"
        ORDER BY a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties."fPR_innehåll_ST_plats_EV_of" (
    positor tinyint,
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "PR_ID_innehåll" number(10,0), 
    "ST_ID_plats" int, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Positor",
    a."PR_innehåll_ST_plats_EV_of_Reliability",
    a."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    TABLE(ties."fPR_innehåll_ST_plats_EV_of_Posit"(changingTimepoint)) p 
JOIN
    TABLE(ties."rPR_innehåll_ST_plats_EV_of_Annex"(positingTimepoint)) a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
AND
    a."PR_innehåll_ST_plats_EV_of_Positor" = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p."PR_innehåll_ST_plats_EV_of_ID"
        ORDER BY a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
    ) = 1
$$
;
