-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null.
--
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Fact` (
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
    ties.`AC_partner_AC_with_ONG_currently_Fact`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently_Fact` (
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
    ties.`AC_partner_AC_with_ONG_currently_Fact`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    `AC_partner_AC_with_ONG_currently_Who`,
    `AC_partner_AC_with_ONG_currently_Confidence`,
    CASE
        WHEN `AC_partner_AC_with_ONG_currently_Confidence` > 0.25 THEN '+'
        WHEN `AC_partner_AC_with_ONG_currently_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Stance`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Meta`
WHERE
    `AC_partner_AC_with_ONG_currently_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_partner_AC_with_ONG_currently`,
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Who`,
    a.`AC_partner_AC_with_ONG_currently_Confidence`,
    CASE
        WHEN a.`AC_partner_AC_with_ONG_currently_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_partner_AC_with_ONG_currently_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Stance`
FROM
    ties.`rAC_partner_AC_with_ONG_currently_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Meta`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
AND
    a.`AC_partner_AC_with_ONG_currently_Who` = coalesce(positor, a.`AC_partner_AC_with_ONG_currently_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`, a.`AC_partner_AC_with_ONG_currently_Who`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_partner_AC_with_ONG_currently`,
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Who`,
    a.`AC_partner_AC_with_ONG_currently_Confidence`,
    CASE
        WHEN a.`AC_partner_AC_with_ONG_currently_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_partner_AC_with_ONG_currently_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Stance`
FROM
    ties.`fAC_partner_AC_with_ONG_currently_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Meta`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
AND
    a.`AC_partner_AC_with_ONG_currently_Who` = coalesce(positor, a.`AC_partner_AC_with_ONG_currently_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`, a.`AC_partner_AC_with_ONG_currently_Who`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_subset_PN_of`,
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Who`,
    `AC_subset_PN_of_Confidence`,
    CASE
        WHEN `AC_subset_PN_of_Confidence` > 0.25 THEN '+'
        WHEN `AC_subset_PN_of_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Stance`
FROM
    ties.`AC_subset_PN_of_Meta`
WHERE
    `AC_subset_PN_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Who`,
    a.`AC_subset_PN_of_Confidence`,
    CASE
        WHEN a.`AC_subset_PN_of_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_subset_PN_of_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Stance`
FROM
    ties.`AC_subset_PN_of_Fact` p
JOIN
    ties.`rAC_subset_PN_of_Meta`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
AND
    a.`AC_subset_PN_of_Who` = coalesce(positor, a.`AC_subset_PN_of_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`, a.`AC_subset_PN_of_Who`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_subset_PN_of` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Who`,
    a.`AC_subset_PN_of_Confidence`,
    CASE
        WHEN a.`AC_subset_PN_of_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_subset_PN_of_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Stance`
FROM
    ties.`AC_subset_PN_of_Fact` p
JOIN
    ties.`rAC_subset_PN_of_Meta`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
AND
    a.`AC_subset_PN_of_Who` = coalesce(positor, a.`AC_subset_PN_of_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`, a.`AC_subset_PN_of_Who`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_wasCast_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_in_AC_wasCast`,
    `EV_in_AC_wasCast_ID`,
    `EV_in_AC_wasCast_PositedAt`,
    `EV_in_AC_wasCast_Who`,
    `EV_in_AC_wasCast_Confidence`,
    CASE
        WHEN `EV_in_AC_wasCast_Confidence` > 0.25 THEN '+'
        WHEN `EV_in_AC_wasCast_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Stance`
FROM
    ties.`EV_in_AC_wasCast_Meta`
WHERE
    `EV_in_AC_wasCast_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_wasCast` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Who`,
    a.`EV_in_AC_wasCast_Confidence`,
    CASE
        WHEN a.`EV_in_AC_wasCast_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_in_AC_wasCast_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Stance`
FROM
    ties.`EV_in_AC_wasCast_Fact` p
JOIN
    ties.`rEV_in_AC_wasCast_Meta`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
AND
    a.`EV_in_AC_wasCast_Who` = coalesce(positor, a.`EV_in_AC_wasCast_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`, a.`EV_in_AC_wasCast_Who`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fEV_in_AC_wasCast` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Who`,
    a.`EV_in_AC_wasCast_Confidence`,
    CASE
        WHEN a.`EV_in_AC_wasCast_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_in_AC_wasCast_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Stance`
FROM
    ties.`EV_in_AC_wasCast_Fact` p
JOIN
    ties.`rEV_in_AC_wasCast_Meta`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
AND
    a.`EV_in_AC_wasCast_Who` = coalesce(positor, a.`EV_in_AC_wasCast_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`, a.`EV_in_AC_wasCast_Who`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_part_PR_in_RAT_got_Fact` (
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
    ties.`AC_part_PR_in_RAT_got_Fact`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_part_PR_in_RAT_got_Fact` (
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
    ties.`AC_part_PR_in_RAT_got_Fact`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_part_PR_in_RAT_got_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_part_PR_in_RAT_got`,
    `AC_part_PR_in_RAT_got_ID`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    `AC_part_PR_in_RAT_got_Who`,
    `AC_part_PR_in_RAT_got_Confidence`,
    CASE
        WHEN `AC_part_PR_in_RAT_got_Confidence` > 0.25 THEN '+'
        WHEN `AC_part_PR_in_RAT_got_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Stance`
FROM
    ties.`AC_part_PR_in_RAT_got_Meta`
WHERE
    `AC_part_PR_in_RAT_got_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_part_PR_in_RAT_got` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_part_PR_in_RAT_got`,
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Who`,
    a.`AC_part_PR_in_RAT_got_Confidence`,
    CASE
        WHEN a.`AC_part_PR_in_RAT_got_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_part_PR_in_RAT_got_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Stance`
FROM
    ties.`rAC_part_PR_in_RAT_got_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_part_PR_in_RAT_got_Meta`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
AND
    a.`AC_part_PR_in_RAT_got_Who` = coalesce(positor, a.`AC_part_PR_in_RAT_got_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`, a.`AC_part_PR_in_RAT_got_Who`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_part_PR_in_RAT_got` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_part_PR_in_RAT_got`,
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Who`,
    a.`AC_part_PR_in_RAT_got_Confidence`,
    CASE
        WHEN a.`AC_part_PR_in_RAT_got_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_part_PR_in_RAT_got_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Stance`
FROM
    ties.`fAC_part_PR_in_RAT_got_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_part_PR_in_RAT_got_Meta`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
AND
    a.`AC_part_PR_in_RAT_got_Who` = coalesce(positor, a.`AC_part_PR_in_RAT_got_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`, a.`AC_part_PR_in_RAT_got_Who`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_isPlaying_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    ties.`ST_at_PR_isPlaying_Fact`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_isPlaying_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    ties.`ST_at_PR_isPlaying_Fact`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_isPlaying_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_at_PR_isPlaying`,
    `ST_at_PR_isPlaying_ID`,
    `ST_at_PR_isPlaying_PositedAt`,
    `ST_at_PR_isPlaying_Who`,
    `ST_at_PR_isPlaying_Confidence`,
    CASE
        WHEN `ST_at_PR_isPlaying_Confidence` > 0.25 THEN '+'
        WHEN `ST_at_PR_isPlaying_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Stance`
FROM
    ties.`ST_at_PR_isPlaying_Meta`
WHERE
    `ST_at_PR_isPlaying_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_isPlaying` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_isPlaying`,
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Who`,
    a.`ST_at_PR_isPlaying_Confidence`,
    CASE
        WHEN a.`ST_at_PR_isPlaying_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_at_PR_isPlaying_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Stance`
FROM
    ties.`rST_at_PR_isPlaying_Fact`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_isPlaying_Meta`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
AND
    a.`ST_at_PR_isPlaying_Who` = coalesce(positor, a.`ST_at_PR_isPlaying_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`, a.`ST_at_PR_isPlaying_Who`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_isPlaying` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_isPlaying`,
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Who`,
    a.`ST_at_PR_isPlaying_Confidence`,
    CASE
        WHEN a.`ST_at_PR_isPlaying_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_at_PR_isPlaying_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Stance`
FROM
    ties.`fST_at_PR_isPlaying_Fact`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_isPlaying_Meta`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
AND
    a.`ST_at_PR_isPlaying_Who` = coalesce(positor, a.`ST_at_PR_isPlaying_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`, a.`ST_at_PR_isPlaying_Who`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_parent_AC_child_PAT_having_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_parent_AC_child_PAT_having`,
    `AC_parent_AC_child_PAT_having_ID`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    `AC_parent_AC_child_PAT_having_Who`,
    `AC_parent_AC_child_PAT_having_Confidence`,
    CASE
        WHEN `AC_parent_AC_child_PAT_having_Confidence` > 0.25 THEN '+'
        WHEN `AC_parent_AC_child_PAT_having_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Stance`
FROM
    ties.`AC_parent_AC_child_PAT_having_Meta`
WHERE
    `AC_parent_AC_child_PAT_having_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_parent_AC_child_PAT_having` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_parent_AC_child_PAT_having`,
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Who`,
    a.`AC_parent_AC_child_PAT_having_Confidence`,
    CASE
        WHEN a.`AC_parent_AC_child_PAT_having_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_parent_AC_child_PAT_having_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Stance`
FROM
    ties.`AC_parent_AC_child_PAT_having_Fact` p
JOIN
    ties.`rAC_parent_AC_child_PAT_having_Meta`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
AND
    a.`AC_parent_AC_child_PAT_having_Who` = coalesce(positor, a.`AC_parent_AC_child_PAT_having_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`, a.`AC_parent_AC_child_PAT_having_Who`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_parent_AC_child_PAT_having` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_parent_AC_child_PAT_having`,
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Who`,
    a.`AC_parent_AC_child_PAT_having_Confidence`,
    CASE
        WHEN a.`AC_parent_AC_child_PAT_having_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_parent_AC_child_PAT_having_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Stance`
FROM
    ties.`AC_parent_AC_child_PAT_having_Fact` p
JOIN
    ties.`rAC_parent_AC_child_PAT_having_Meta`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
AND
    a.`AC_parent_AC_child_PAT_having_Who` = coalesce(positor, a.`AC_parent_AC_child_PAT_having_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`, a.`AC_parent_AC_child_PAT_having_Who`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_content_ST_location_EV_of_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_content_ST_location_EV_of_ID`,
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_ChangedAt`
FROM
    ties.`PR_content_ST_location_EV_of_Fact`
WHERE
    `PR_content_ST_location_EV_of_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_content_ST_location_EV_of_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_content_ST_location_EV_of_ID`,
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_ChangedAt`
FROM
    ties.`PR_content_ST_location_EV_of_Fact`
WHERE
    `PR_content_ST_location_EV_of_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_content_ST_location_EV_of_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_content_ST_location_EV_of`,
    `PR_content_ST_location_EV_of_ID`,
    `PR_content_ST_location_EV_of_PositedAt`,
    `PR_content_ST_location_EV_of_Who`,
    `PR_content_ST_location_EV_of_Confidence`,
    CASE
        WHEN `PR_content_ST_location_EV_of_Confidence` > 0.25 THEN '+'
        WHEN `PR_content_ST_location_EV_of_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Stance`
FROM
    ties.`PR_content_ST_location_EV_of_Meta`
WHERE
    `PR_content_ST_location_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_content_ST_location_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    p.`PR_content_ST_location_EV_of_ChangedAt`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Who`,
    a.`PR_content_ST_location_EV_of_Confidence`,
    CASE
        WHEN a.`PR_content_ST_location_EV_of_Confidence` > 0.25 THEN '+'
        WHEN a.`PR_content_ST_location_EV_of_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Stance`
FROM
    ties.`rPR_content_ST_location_EV_of_Fact`(changingTimepoint) p 
JOIN
    ties.`rPR_content_ST_location_EV_of_Meta`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
AND
    a.`PR_content_ST_location_EV_of_Who` = coalesce(positor, a.`PR_content_ST_location_EV_of_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`, a.`PR_content_ST_location_EV_of_Who`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_content_ST_location_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    p.`PR_content_ST_location_EV_of_ChangedAt`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Who`,
    a.`PR_content_ST_location_EV_of_Confidence`,
    CASE
        WHEN a.`PR_content_ST_location_EV_of_Confidence` > 0.25 THEN '+'
        WHEN a.`PR_content_ST_location_EV_of_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Stance`
FROM
    ties.`fPR_content_ST_location_EV_of_Fact`(changingTimepoint) p 
JOIN
    ties.`rPR_content_ST_location_EV_of_Meta`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
AND
    a.`PR_content_ST_location_EV_of_Who` = coalesce(positor, a.`PR_content_ST_location_EV_of_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`, a.`PR_content_ST_location_EV_of_Who`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
