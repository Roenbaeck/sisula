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
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`rAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`ONG_Pågående` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Reliability` = 1
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
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Pågående`,
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
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Pågående`,
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
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    ties.`rAC_subset_PN_of`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`AC_subset_PN_of_Reliability` = 1
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
    t.`AC_subset_PN_of_Reliability`,
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
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_rollsattes` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_rollsattes_ID`,
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`
FROM
    ties.`rEV_in_AC_rollsattes`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`EV_in_AC_rollsattes_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`EV_ID_in`,
            t.`AC_ID_rollsattes`
        ORDER BY
            t.`EV_in_AC_rollsattes_PositedAt` DESC,
            t.`EV_in_AC_rollsattes_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lEV_in_AC_rollsattes` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_rollsattes`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_rollsattes` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_rollsattes_ID`,
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`
FROM
    ties.`tEV_in_AC_rollsattes`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nEV_in_AC_rollsattes` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_rollsattes`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_deltar_PR_in_RAT_fick_ID`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    `kRAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `kRAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    t.`RAT_ID_fick`
FROM
    ties.`rAC_deltar_PR_in_RAT_fick`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`RAT_Betyg` `kRAT_fick`
ON
    `kRAT_fick`.`RAT_ID` = t.`RAT_ID_fick`
WHERE
    t.`AC_deltar_PR_in_RAT_fick_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_deltar`,
            t.`PR_ID_in`
        ORDER BY
            t.`AC_deltar_PR_in_RAT_fick_ChangedAt` DESC,
            t.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC,
            t.`AC_deltar_PR_in_RAT_fick_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_deltar_PR_in_RAT_fick` AS
SELECT
    *
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_deltar_PR_in_RAT_fick_ID`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    t.`fick_RAT_Betyg`,
    t.`fick_Metadata_RAT`,
    t.`RAT_ID_fick`
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_deltar_PR_in_RAT_fick` AS
SELECT
    *
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_deltar_PR_in_RAT_fick` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_deltar_PR_in_RAT_fick_ID`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    t.`fick_RAT_Betyg`,
    t.`fick_Metadata_RAT`,
    t.`RAT_ID_fick`
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_spelas` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_spelas_ID`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`
FROM
    ties.`rST_at_PR_spelas`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`ST_at_PR_spelas_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`ST_ID_at`,
            t.`PR_ID_spelas`
        ORDER BY
            t.`ST_at_PR_spelas_ChangedAt` DESC,
            t.`ST_at_PR_spelas_PositedAt` DESC,
            t.`ST_at_PR_spelas_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lST_at_PR_spelas` AS
SELECT
    *
FROM
    ties.`tST_at_PR_spelas`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_spelas` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_spelas_ID`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`
FROM
    ties.`tST_at_PR_spelas`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nST_at_PR_spelas` AS
SELECT
    *
FROM
    ties.`tST_at_PR_spelas`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_spelas` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`ST_at_PR_spelas_ID`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`
FROM
    ties.`tST_at_PR_spelas`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`ST_at_PR_spelas_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_förälder_AC_barn_PAT_har_ID`,
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    `kPAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `kPAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    t.`PAT_ID_har`
FROM
    ties.`rAC_förälder_AC_barn_PAT_har`(
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`PAT_Föräldratyp` `kPAT_har`
ON
    `kPAT_har`.`PAT_ID` = t.`PAT_ID_har`
WHERE
    t.`AC_förälder_AC_barn_PAT_har_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_förälder`,
            t.`AC_ID_barn`,
            t.`PAT_ID_har`
        ORDER BY
            t.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC,
            t.`AC_förälder_AC_barn_PAT_har_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_förälder_AC_barn_PAT_har` AS
SELECT
    *
FROM
    ties.`tAC_förälder_AC_barn_PAT_har`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_förälder_AC_barn_PAT_har_ID`,
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    t.`har_PAT_Föräldratyp`,
    t.`har_Metadata_PAT`,
    t.`PAT_ID_har`
FROM
    ties.`tAC_förälder_AC_barn_PAT_har`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_förälder_AC_barn_PAT_har` AS
SELECT
    *
FROM
    ties.`tAC_förälder_AC_barn_PAT_har`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`PR_innehåll_ST_plats_EV_of_ID`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`
FROM
    ties.`rPR_innehåll_ST_plats_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`PR_innehåll_ST_plats_EV_of_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`PR_ID_innehåll`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`ST_ID_plats`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lPR_innehåll_ST_plats_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`PR_innehåll_ST_plats_EV_of_ID`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nPR_innehåll_ST_plats_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_innehåll_ST_plats_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`PR_innehåll_ST_plats_EV_of_ID`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
