-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_partner_AC_with_ONG_currently` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`AC_partner_AC_with_ONG_currently_Assertion` <> '?', r.`AC_partner_AC_with_ONG_currently_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_partner_AC_with_ONG_currently_Positor`,
                    r.`AC_ID_partner`,
                    r.`AC_ID_with`,
                    r.`ONG_ID_currently`
            ) AS `inEffect`
        FROM
            ties.`rAC_partner_AC_with_ONG_currently`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_partner_AC_with_ONG_currently_Assertion` = coalesce(assertion, s.`AC_partner_AC_with_ONG_currently_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_partner_AC_with_ONG_currently_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`AC_partner_AC_with_ONG_currently_Positor`, s.`AC_ID_partner`
            ORDER BY
                s.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
                s.`AC_partner_AC_with_ONG_currently_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`AC_partner_AC_with_ONG_currently_Positor`, s.`AC_ID_with`
            ORDER BY
                s.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
                s.`AC_partner_AC_with_ONG_currently_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`ONG_Pågående` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Pågående`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_partner_AC_with_ONG_currently_Positor` AS positor,
        CAST(`AC_partner_AC_with_ONG_currently_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`AC_partner_AC_with_ONG_currently`
    WHERE
        `AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_partner_AC_with_ONG_currently_Positor`,
                y.`AC_ID_partner`,
                y.`AC_ID_with`,
                y.`ONG_ID_currently`
            ORDER BY y.`AC_partner_AC_with_ONG_currently_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rAC_partner_AC_with_ONG_currently`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_partner_AC_with_ONG_currently_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_partner_AC_with_ONG_currently_Positor`,
                    r.`AC_ID_partner`,
                    r.`AC_ID_with`,
                    r.`ONG_ID_currently`,
                    r.`AC_partner_AC_with_ONG_currently_ChangedAt`
                ORDER BY
                    IF(r.`AC_partner_AC_with_ONG_currently_Assertion` = '+', 0, 1),
                    r.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                    r.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
                    r.`AC_partner_AC_with_ONG_currently_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_partner_AC_with_ONG_currently_Positor` = tp.positor
AND
    t.`AC_partner_AC_with_ONG_currently_Assertion` = '+'
AND
    t.`AC_partner_AC_with_ONG_currently_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`ONG_Pågående` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    TRUE
QUALIFY -- a tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`AC_ID_partner`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`AC_ID_with`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_subset_PN_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Positor`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_subset_PN_of_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            ties.`rAC_subset_PN_of`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_subset_PN_of_Assertion` = coalesce(assertion, s.`AC_subset_PN_of_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`AC_subset_PN_of_Positor`, s.`AC_ID_subset`
            ORDER BY
                s.`AC_subset_PN_of_PositedAt` DESC,
                s.`AC_subset_PN_of_Reliability` DESC,
                s.`AC_subset_PN_of_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`AC_subset_PN_of_Positor`, s.`PN_ID_of`
            ORDER BY
                s.`AC_subset_PN_of_PositedAt` DESC,
                s.`AC_subset_PN_of_Reliability` DESC,
                s.`AC_subset_PN_of_ID` DESC
        ) = 1
) t
WHERE
    t.`AC_subset_PN_of_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Positor`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_subset_PN_of_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_rollsattes` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Positor`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_in_AC_rollsattes_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            ties.`rEV_in_AC_rollsattes`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`EV_in_AC_rollsattes_Assertion` = coalesce(assertion, s.`EV_in_AC_rollsattes_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`EV_in_AC_rollsattes_Positor`,
                s.`EV_ID_in`,
                s.`AC_ID_rollsattes`
            ORDER BY
                s.`EV_in_AC_rollsattes_PositedAt` DESC,
                s.`EV_in_AC_rollsattes_Reliability` DESC,
                s.`EV_in_AC_rollsattes_ID` DESC
        ) = 1
) t
WHERE
    t.`EV_in_AC_rollsattes_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lEV_in_AC_rollsattes` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tEV_in_AC_rollsattes`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_rollsattes` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Positor`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_in_AC_rollsattes_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tEV_in_AC_rollsattes`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nEV_in_AC_rollsattes` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tEV_in_AC_rollsattes`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_deltar_PR_in_RAT_fick` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    `kRAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `kRAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `kRAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    t.`RAT_ID_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Positor`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_deltar_PR_in_RAT_fick_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`AC_deltar_PR_in_RAT_fick_Assertion` <> '?', r.`AC_deltar_PR_in_RAT_fick_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_deltar_PR_in_RAT_fick_Positor`,
                    r.`AC_ID_deltar`,
                    r.`PR_ID_in`
            ) AS `inEffect`
        FROM
            ties.`rAC_deltar_PR_in_RAT_fick`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_deltar_PR_in_RAT_fick_Assertion` = coalesce(assertion, s.`AC_deltar_PR_in_RAT_fick_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_deltar_PR_in_RAT_fick_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_deltar_PR_in_RAT_fick_Positor`,
                s.`AC_ID_deltar`,
                s.`PR_ID_in`
            ORDER BY
                s.`AC_deltar_PR_in_RAT_fick_ChangedAt` DESC,
                s.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC,
                s.`AC_deltar_PR_in_RAT_fick_Reliability` DESC,
                s.`AC_deltar_PR_in_RAT_fick_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`RAT_Betyg` `kRAT_fick`
ON
    `kRAT_fick`.`RAT_ID` = t.`RAT_ID_fick`
WHERE
    t.`AC_deltar_PR_in_RAT_fick_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_deltar_PR_in_RAT_fick` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_deltar_PR_in_RAT_fick`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    t.`fick_RAT_Checksum`,
    t.`fick_RAT_Betyg`,
    t.`fick_Metadata_RAT`,
    t.`RAT_ID_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Positor`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_deltar_PR_in_RAT_fick`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_deltar_PR_in_RAT_fick` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_deltar_PR_in_RAT_fick`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_deltar_PR_in_RAT_fick` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    `kRAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `kRAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `kRAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    t.`RAT_ID_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Positor`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_deltar_PR_in_RAT_fick_Positor` AS positor,
        CAST(`AC_deltar_PR_in_RAT_fick_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`AC_deltar_PR_in_RAT_fick`
    WHERE
        `AC_deltar_PR_in_RAT_fick_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_deltar_PR_in_RAT_fick_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_deltar_PR_in_RAT_fick_Positor`,
                y.`AC_ID_deltar`,
                y.`PR_ID_in`
            ORDER BY y.`AC_deltar_PR_in_RAT_fick_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rAC_deltar_PR_in_RAT_fick`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_deltar_PR_in_RAT_fick_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_deltar_PR_in_RAT_fick_Positor`,
                    r.`AC_ID_deltar`,
                    r.`PR_ID_in`,
                    r.`AC_deltar_PR_in_RAT_fick_ChangedAt`
                ORDER BY
                    IF(r.`AC_deltar_PR_in_RAT_fick_Assertion` = '+', 0, 1),
                    r.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC,
                    r.`AC_deltar_PR_in_RAT_fick_Reliability` DESC,
                    r.`AC_deltar_PR_in_RAT_fick_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_deltar_PR_in_RAT_fick_Positor` = tp.positor
AND
    t.`AC_deltar_PR_in_RAT_fick_Assertion` = '+'
AND
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`RAT_Betyg` `kRAT_fick`
ON
    `kRAT_fick`.`RAT_ID` = t.`RAT_ID_fick`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_spelas` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Positor`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_at_PR_spelas_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`ST_at_PR_spelas_Assertion` <> '?', r.`ST_at_PR_spelas_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`ST_at_PR_spelas_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_spelas`
            ) AS `inEffect`
        FROM
            ties.`rST_at_PR_spelas`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`ST_at_PR_spelas_Assertion` = coalesce(assertion, s.`ST_at_PR_spelas_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`ST_at_PR_spelas_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`ST_at_PR_spelas_Positor`,
                s.`ST_ID_at`,
                s.`PR_ID_spelas`
            ORDER BY
                s.`ST_at_PR_spelas_ChangedAt` DESC,
                s.`ST_at_PR_spelas_PositedAt` DESC,
                s.`ST_at_PR_spelas_Reliability` DESC,
                s.`ST_at_PR_spelas_ID` DESC
        ) = 1
) t
WHERE
    t.`ST_at_PR_spelas_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lST_at_PR_spelas` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tST_at_PR_spelas`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_spelas` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Positor`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_at_PR_spelas_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tST_at_PR_spelas`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nST_at_PR_spelas` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tST_at_PR_spelas`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_spelas` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Positor`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_at_PR_spelas_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `ST_at_PR_spelas_Positor` AS positor,
        CAST(`ST_at_PR_spelas_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`ST_at_PR_spelas`
    WHERE
        `ST_at_PR_spelas_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`ST_at_PR_spelas_ChangedAt`) OVER (
            PARTITION BY
                y.`ST_at_PR_spelas_Positor`,
                y.`ST_ID_at`,
                y.`PR_ID_spelas`
            ORDER BY y.`ST_at_PR_spelas_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rST_at_PR_spelas`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_at_PR_spelas_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`ST_at_PR_spelas_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_spelas`,
                    r.`ST_at_PR_spelas_ChangedAt`
                ORDER BY
                    IF(r.`ST_at_PR_spelas_Assertion` = '+', 0, 1),
                    r.`ST_at_PR_spelas_PositedAt` DESC,
                    r.`ST_at_PR_spelas_Reliability` DESC,
                    r.`ST_at_PR_spelas_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`ST_at_PR_spelas_Positor` = tp.positor
AND
    t.`ST_at_PR_spelas_Assertion` = '+'
AND
    t.`ST_at_PR_spelas_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_förälder_AC_barn_PAT_har` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    `kPAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `kPAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    t.`PAT_ID_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Positor`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_förälder_AC_barn_PAT_har_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            ties.`rAC_förälder_AC_barn_PAT_har`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_förälder_AC_barn_PAT_har_Assertion` = coalesce(assertion, s.`AC_förälder_AC_barn_PAT_har_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_förälder_AC_barn_PAT_har_Positor`,
                s.`AC_ID_förälder`,
                s.`AC_ID_barn`,
                s.`PAT_ID_har`
            ORDER BY
                s.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC,
                s.`AC_förälder_AC_barn_PAT_har_Reliability` DESC,
                s.`AC_förälder_AC_barn_PAT_har_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`PAT_Föräldratyp` `kPAT_har`
ON
    `kPAT_har`.`PAT_ID` = t.`PAT_ID_har`
WHERE
    t.`AC_förälder_AC_barn_PAT_har_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_förälder_AC_barn_PAT_har` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_förälder_AC_barn_PAT_har`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    t.`har_PAT_Föräldratyp`,
    t.`har_Metadata_PAT`,
    t.`PAT_ID_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Positor`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_förälder_AC_barn_PAT_har_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_förälder_AC_barn_PAT_har`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_förälder_AC_barn_PAT_har` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_förälder_AC_barn_PAT_har`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_innehåll_ST_plats_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Positor`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_innehåll_ST_plats_EV_of_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`PR_innehåll_ST_plats_EV_of_Assertion` <> '?', r.`PR_innehåll_ST_plats_EV_of_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`PR_innehåll_ST_plats_EV_of_Positor`,
                    r.`PR_ID_innehåll`,
                    r.`ST_ID_plats`,
                    r.`EV_ID_of`
            ) AS `inEffect`
        FROM
            ties.`rPR_innehåll_ST_plats_EV_of`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`PR_innehåll_ST_plats_EV_of_Assertion` = coalesce(assertion, s.`PR_innehåll_ST_plats_EV_of_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`PR_innehåll_ST_plats_EV_of_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`PR_innehåll_ST_plats_EV_of_Positor`, s.`PR_ID_innehåll`
            ORDER BY
                s.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
                s.`PR_innehåll_ST_plats_EV_of_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`PR_innehåll_ST_plats_EV_of_Positor`, s.`ST_ID_plats`
            ORDER BY
                s.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
                s.`PR_innehåll_ST_plats_EV_of_ID` DESC
        ) = 1
) t
WHERE
    t.`PR_innehåll_ST_plats_EV_of_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lPR_innehåll_ST_plats_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tPR_innehåll_ST_plats_EV_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Positor`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tPR_innehåll_ST_plats_EV_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nPR_innehåll_ST_plats_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tPR_innehåll_ST_plats_EV_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_innehåll_ST_plats_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Positor`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `PR_innehåll_ST_plats_EV_of_Positor` AS positor,
        CAST(`PR_innehåll_ST_plats_EV_of_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`PR_innehåll_ST_plats_EV_of`
    WHERE
        `PR_innehåll_ST_plats_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (
            PARTITION BY
                y.`PR_innehåll_ST_plats_EV_of_Positor`,
                y.`PR_ID_innehåll`,
                y.`ST_ID_plats`,
                y.`EV_ID_of`
            ORDER BY y.`PR_innehåll_ST_plats_EV_of_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rPR_innehåll_ST_plats_EV_of`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_innehåll_ST_plats_EV_of_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`PR_innehåll_ST_plats_EV_of_Positor`,
                    r.`PR_ID_innehåll`,
                    r.`ST_ID_plats`,
                    r.`EV_ID_of`,
                    r.`PR_innehåll_ST_plats_EV_of_ChangedAt`
                ORDER BY
                    IF(r.`PR_innehåll_ST_plats_EV_of_Assertion` = '+', 0, 1),
                    r.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
                    r.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
                    r.`PR_innehåll_ST_plats_EV_of_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`PR_innehåll_ST_plats_EV_of_Positor` = tp.positor
AND
    t.`PR_innehåll_ST_plats_EV_of_Assertion` = '+'
AND
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
WHERE
    TRUE
QUALIFY -- a tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`PR_ID_innehåll`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`ST_ID_plats`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
)
;
