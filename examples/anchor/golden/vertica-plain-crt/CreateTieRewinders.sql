-- TIE REWINDERS ------------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of a tie with the latest row of their annex for each positor: what is known now about each posit,
-- which each positor asserts, retracts or denies. Vertica has no function that returns a table, so it is a view and shows what
-- is known now (the rewinders of the other databases can be asked about an earlier time, or about a positor); the perspectives
-- that Vertica has are over it.
--
CREATE OR REPLACE VIEW public."rAC_partner_AC_with_ONG_currently" AS
SELECT
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
    public."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    public."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor"
    ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_subset_PN_of" AS
SELECT
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
    public."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor"
    ORDER BY a."AC_subset_PN_of_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rEV_in_AC_wasCast" AS
SELECT
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
    public."EV_in_AC_wasCast_Annex" a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor"
    ORDER BY a."EV_in_AC_wasCast_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_part_PR_in_RAT_got" AS
SELECT
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
    public."AC_part_PR_in_RAT_got_Posit" p
JOIN
    public."AC_part_PR_in_RAT_got_Annex" a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor"
    ORDER BY a."AC_part_PR_in_RAT_got_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rST_at_PR_isPlaying" AS
SELECT
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."ST_at_PR_isPlaying_Posit" p
JOIN
    public."ST_at_PR_isPlaying_Annex" a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor"
    ORDER BY a."ST_at_PR_isPlaying_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_parent_AC_child_PAT_having" AS
SELECT
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
    public."AC_parent_AC_child_PAT_having_Annex" a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor"
    ORDER BY a."AC_parent_AC_child_PAT_having_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rPR_content_ST_location_EV_of" AS
SELECT
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
    public."PR_content_ST_location_EV_of_Annex" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor"
    ORDER BY a."PR_content_ST_location_EV_of_PositedAt" DESC
)
;
