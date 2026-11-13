-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`rAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`AC_ID_partner`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`AC_ID_with`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_subset_PN_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_subset_PN_of_ID`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Confidence`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    ties.`rAC_subset_PN_of`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`AC_subset_PN_of_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`AC_ID_subset`
        ORDER BY
            t.`AC_subset_PN_of_PositedAt` DESC,
            t.`AC_subset_PN_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`PN_ID_of`
        ORDER BY
            t.`AC_subset_PN_of_PositedAt` DESC,
            t.`AC_subset_PN_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`tAC_subset_PN_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_subset_PN_of_ID`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Confidence`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    ties.`tAC_subset_PN_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`tAC_subset_PN_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_wasCast` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_wasCast_ID`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Confidence`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`
FROM
    ties.`rEV_in_AC_wasCast`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`EV_in_AC_wasCast_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`EV_ID_in`,
            t.`AC_ID_wasCast`
        ORDER BY
            t.`EV_in_AC_wasCast_PositedAt` DESC,
            t.`EV_in_AC_wasCast_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lEV_in_AC_wasCast` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_wasCast`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_wasCast_ID`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Confidence`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`
FROM
    ties.`tEV_in_AC_wasCast`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nEV_in_AC_wasCast` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_wasCast`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    ties.`rAC_part_PR_in_RAT_got`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
WHERE
    t.`AC_part_PR_in_RAT_got_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_part`,
            t.`PR_ID_in`
        ORDER BY
            t.`AC_part_PR_in_RAT_got_ChangedAt` DESC,
            t.`AC_part_PR_in_RAT_got_PositedAt` DESC,
            t.`AC_part_PR_in_RAT_got_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    ties.`rST_at_PR_isPlaying`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`ST_at_PR_isPlaying_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`ST_ID_at`,
            t.`PR_ID_isPlaying`
        ORDER BY
            t.`ST_at_PR_isPlaying_ChangedAt` DESC,
            t.`ST_at_PR_isPlaying_PositedAt` DESC,
            t.`ST_at_PR_isPlaying_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lST_at_PR_isPlaying` AS
SELECT
    *
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nST_at_PR_isPlaying` AS
SELECT
    *
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_parent_AC_child_PAT_having_ID`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Confidence`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    `kPAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `kPAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    t.`PAT_ID_having`
FROM
    ties.`rAC_parent_AC_child_PAT_having`(
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`PAT_ParentalType` `kPAT_having`
ON
    `kPAT_having`.`PAT_ID` = t.`PAT_ID_having`
WHERE
    t.`AC_parent_AC_child_PAT_having_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_parent`,
            t.`AC_ID_child`,
            t.`PAT_ID_having`
        ORDER BY
            t.`AC_parent_AC_child_PAT_having_PositedAt` DESC,
            t.`AC_parent_AC_child_PAT_having_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    ties.`tAC_parent_AC_child_PAT_having`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_parent_AC_child_PAT_having_ID`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Confidence`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    t.`having_PAT_ParentalType`,
    t.`having_Metadata_PAT`,
    t.`PAT_ID_having`
FROM
    ties.`tAC_parent_AC_child_PAT_having`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    ties.`tAC_parent_AC_child_PAT_having`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_content_ST_location_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    ties.`rPR_content_ST_location_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`PR_content_ST_location_EV_of_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`PR_ID_content`
        ORDER BY
            t.`PR_content_ST_location_EV_of_ChangedAt` DESC,
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`ST_ID_location`
        ORDER BY
            t.`PR_content_ST_location_EV_of_ChangedAt` DESC,
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_content_ST_location_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`PR_content_ST_location_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
