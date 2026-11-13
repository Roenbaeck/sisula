-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_partner_AC_with_ONG_currently_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    `AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex`
WHERE
    `AC_partner_AC_with_ONG_currently_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`rAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`fAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_subset_PN_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Annex`
WHERE
    `AC_subset_PN_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_subset_PN_of` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`rAC_subset_PN_of_Annex`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_subset_PN_of` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`rAC_subset_PN_of_Annex`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_in_AC_wasCast_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `EV_in_AC_wasCast_ID`,
    `EV_in_AC_wasCast_PositedAt`,
    `EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Annex`
WHERE
    `EV_in_AC_wasCast_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_in_AC_wasCast` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`rEV_in_AC_wasCast_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fEV_in_AC_wasCast` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`rEV_in_AC_wasCast_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_part_PR_in_RAT_got_ID`,
    `AC_ID_part`,
    `PR_ID_in`,
    `RAT_ID_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`
FROM
    public.`AC_part_PR_in_RAT_got_Posit`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_part_PR_in_RAT_got_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_part_PR_in_RAT_got_ID`,
    `AC_ID_part`,
    `PR_ID_in`,
    `RAT_ID_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`
FROM
    public.`AC_part_PR_in_RAT_got_Posit`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `AC_part_PR_in_RAT_got_ID`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    `AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`AC_part_PR_in_RAT_got_Annex`
WHERE
    `AC_part_PR_in_RAT_got_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`rAC_part_PR_in_RAT_got_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_part_PR_in_RAT_got_Annex`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`fAC_part_PR_in_RAT_got_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_part_PR_in_RAT_got_Annex`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    public.`ST_at_PR_isPlaying_Posit`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_at_PR_isPlaying_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    public.`ST_at_PR_isPlaying_Posit`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_at_PR_isPlaying_PositedAt`,
    `ST_at_PR_isPlaying_Reliability`
FROM
    public.`ST_at_PR_isPlaying_Annex`
WHERE
    `ST_at_PR_isPlaying_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Reliability`
FROM
    public.`rST_at_PR_isPlaying_Posit`(changingTimepoint) p 
JOIN
    public.`rST_at_PR_isPlaying_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Reliability`
FROM
    public.`fST_at_PR_isPlaying_Posit`(changingTimepoint) p 
JOIN
    public.`rST_at_PR_isPlaying_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_parent_AC_child_PAT_having_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `AC_parent_AC_child_PAT_having_ID`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    `AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Annex`
WHERE
    `AC_parent_AC_child_PAT_having_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_parent_AC_child_PAT_having` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`rAC_parent_AC_child_PAT_having_Annex`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_parent_AC_child_PAT_having` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`rAC_parent_AC_child_PAT_having_Annex`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_content_ST_location_EV_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `PR_content_ST_location_EV_of_ID`,
    `PR_content_ST_location_EV_of_PositedAt`,
    `PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Annex`
WHERE
    `PR_content_ST_location_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_content_ST_location_EV_of` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`rPR_content_ST_location_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fPR_content_ST_location_EV_of` (
    positingTimepoint datetime
)
AS (
SELECT
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`rPR_content_ST_location_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
