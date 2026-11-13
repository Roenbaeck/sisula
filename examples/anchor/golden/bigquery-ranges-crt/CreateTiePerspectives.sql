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
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Who`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_partner_AC_with_ONG_currently_Stance`
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
            max(IF(r.`AC_partner_AC_with_ONG_currently_Stance` <> '?', r.`AC_partner_AC_with_ONG_currently_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_partner_AC_with_ONG_currently_Who`,
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
        s.`AC_partner_AC_with_ONG_currently_Stance` = coalesce(assertion, s.`AC_partner_AC_with_ONG_currently_Stance`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_partner_AC_with_ONG_currently_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`AC_partner_AC_with_ONG_currently_Who`, s.`AC_ID_partner`
            ORDER BY
                s.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_Confidence` DESC,
                s.`AC_partner_AC_with_ONG_currently_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`AC_partner_AC_with_ONG_currently_Who`, s.`AC_ID_with`
            ORDER BY
                s.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_Confidence` DESC,
                s.`AC_partner_AC_with_ONG_currently_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Who`,
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
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Who`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_partner_AC_with_ONG_currently_Stance`
FROM
    dw.`_Who` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Who`,
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
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Who`,
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
    p.`Who`,
    tp.inspectedTimepoint,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Who`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_partner_AC_with_ONG_currently_Stance`
FROM
    dw.`_Who` p
JOIN (
    SELECT DISTINCT
        `AC_partner_AC_with_ONG_currently_Who` AS positor,
        CAST(`AC_partner_AC_with_ONG_currently_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`AC_partner_AC_with_ONG_currently`
    WHERE
        `AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Who`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_partner_AC_with_ONG_currently_Who`,
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
            r.`AC_partner_AC_with_ONG_currently_Stance` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_partner_AC_with_ONG_currently_Who`,
                    r.`AC_ID_partner`,
                    r.`AC_ID_with`,
                    r.`ONG_ID_currently`,
                    r.`AC_partner_AC_with_ONG_currently_ChangedAt`
                ORDER BY
                    IF(r.`AC_partner_AC_with_ONG_currently_Stance` = '+', 0, 1),
                    r.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                    r.`AC_partner_AC_with_ONG_currently_Confidence` DESC,
                    r.`AC_partner_AC_with_ONG_currently_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_partner_AC_with_ONG_currently_Who` = tp.positor
AND
    t.`AC_partner_AC_with_ONG_currently_Stance` = '+'
AND
    t.`AC_partner_AC_with_ONG_currently_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`ONG_Ongoing` `kONG_currently`
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
            t.`AC_partner_AC_with_ONG_currently_Confidence` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`AC_ID_with`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_Confidence` DESC,
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
    t.`AC_subset_PN_of_Who`,
    t.`AC_subset_PN_of_Confidence`,
    t.`AC_subset_PN_of_Stance`
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
        s.`AC_subset_PN_of_Stance` = coalesce(assertion, s.`AC_subset_PN_of_Stance`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`AC_subset_PN_of_Who`, s.`AC_ID_subset`
            ORDER BY
                s.`AC_subset_PN_of_PositedAt` DESC,
                s.`AC_subset_PN_of_Confidence` DESC,
                s.`AC_subset_PN_of_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`AC_subset_PN_of_Who`, s.`PN_ID_of`
            ORDER BY
                s.`AC_subset_PN_of_PositedAt` DESC,
                s.`AC_subset_PN_of_Confidence` DESC,
                s.`AC_subset_PN_of_ID` DESC
        ) = 1
) t
WHERE
    t.`AC_subset_PN_of_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_subset_PN_of`(
        p.`Who`,
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
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Who`,
    t.`AC_subset_PN_of_Confidence`,
    t.`AC_subset_PN_of_Stance`
FROM
    dw.`_Who` p,
    ties.`tAC_subset_PN_of`(
        p.`Who`,
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
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_subset_PN_of`(
        p.`Who`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_wasCast` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Who`,
    t.`EV_in_AC_wasCast_Confidence`,
    t.`EV_in_AC_wasCast_Stance`
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
            ties.`rEV_in_AC_wasCast`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`EV_in_AC_wasCast_Stance` = coalesce(assertion, s.`EV_in_AC_wasCast_Stance`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`EV_in_AC_wasCast_Who`,
                s.`EV_ID_in`,
                s.`AC_ID_wasCast`
            ORDER BY
                s.`EV_in_AC_wasCast_PositedAt` DESC,
                s.`EV_in_AC_wasCast_Confidence` DESC,
                s.`EV_in_AC_wasCast_ID` DESC
        ) = 1
) t
WHERE
    t.`EV_in_AC_wasCast_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lEV_in_AC_wasCast` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tEV_in_AC_wasCast`(
        p.`Who`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Who`,
    t.`EV_in_AC_wasCast_Confidence`,
    t.`EV_in_AC_wasCast_Stance`
FROM
    dw.`_Who` p,
    ties.`tEV_in_AC_wasCast`(
        p.`Who`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nEV_in_AC_wasCast` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tEV_in_AC_wasCast`(
        p.`Who`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_part_PR_in_RAT_got` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Checksum` AS `got_RAT_Checksum`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Who`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_part_PR_in_RAT_got_Stance`
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
            max(IF(r.`AC_part_PR_in_RAT_got_Stance` <> '?', r.`AC_part_PR_in_RAT_got_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_part_PR_in_RAT_got_Who`,
                    r.`AC_ID_part`,
                    r.`PR_ID_in`
            ) AS `inEffect`
        FROM
            ties.`rAC_part_PR_in_RAT_got`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_part_PR_in_RAT_got_Stance` = coalesce(assertion, s.`AC_part_PR_in_RAT_got_Stance`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_part_PR_in_RAT_got_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_part_PR_in_RAT_got_Who`,
                s.`AC_ID_part`,
                s.`PR_ID_in`
            ORDER BY
                s.`AC_part_PR_in_RAT_got_ChangedAt` DESC,
                s.`AC_part_PR_in_RAT_got_PositedAt` DESC,
                s.`AC_part_PR_in_RAT_got_Confidence` DESC,
                s.`AC_part_PR_in_RAT_got_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
WHERE
    t.`AC_part_PR_in_RAT_got_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_part_PR_in_RAT_got` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_part_PR_in_RAT_got`(
        p.`Who`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Checksum`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Who`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_part_PR_in_RAT_got_Stance`
FROM
    dw.`_Who` p,
    ties.`tAC_part_PR_in_RAT_got`(
        p.`Who`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_part_PR_in_RAT_got` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_part_PR_in_RAT_got`(
        p.`Who`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Who`,
    tp.inspectedTimepoint,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Checksum` AS `got_RAT_Checksum`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Who`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_part_PR_in_RAT_got_Stance`
FROM
    dw.`_Who` p
JOIN (
    SELECT DISTINCT
        `AC_part_PR_in_RAT_got_Who` AS positor,
        CAST(`AC_part_PR_in_RAT_got_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`AC_part_PR_in_RAT_got`
    WHERE
        `AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Who`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_part_PR_in_RAT_got_Who`,
                y.`AC_ID_part`,
                y.`PR_ID_in`
            ORDER BY y.`AC_part_PR_in_RAT_got_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rAC_part_PR_in_RAT_got`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_part_PR_in_RAT_got_Stance` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_part_PR_in_RAT_got_Who`,
                    r.`AC_ID_part`,
                    r.`PR_ID_in`,
                    r.`AC_part_PR_in_RAT_got_ChangedAt`
                ORDER BY
                    IF(r.`AC_part_PR_in_RAT_got_Stance` = '+', 0, 1),
                    r.`AC_part_PR_in_RAT_got_PositedAt` DESC,
                    r.`AC_part_PR_in_RAT_got_Confidence` DESC,
                    r.`AC_part_PR_in_RAT_got_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_part_PR_in_RAT_got_Who` = tp.positor
AND
    t.`AC_part_PR_in_RAT_got_Stance` = '+'
AND
    t.`AC_part_PR_in_RAT_got_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_isPlaying` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Who`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_at_PR_isPlaying_Stance`
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
            max(IF(r.`ST_at_PR_isPlaying_Stance` <> '?', r.`ST_at_PR_isPlaying_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`ST_at_PR_isPlaying_Who`,
                    r.`ST_ID_at`,
                    r.`PR_ID_isPlaying`
            ) AS `inEffect`
        FROM
            ties.`rST_at_PR_isPlaying`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`ST_at_PR_isPlaying_Stance` = coalesce(assertion, s.`ST_at_PR_isPlaying_Stance`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`ST_at_PR_isPlaying_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`ST_at_PR_isPlaying_Who`,
                s.`ST_ID_at`,
                s.`PR_ID_isPlaying`
            ORDER BY
                s.`ST_at_PR_isPlaying_ChangedAt` DESC,
                s.`ST_at_PR_isPlaying_PositedAt` DESC,
                s.`ST_at_PR_isPlaying_Confidence` DESC,
                s.`ST_at_PR_isPlaying_ID` DESC
        ) = 1
) t
WHERE
    t.`ST_at_PR_isPlaying_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lST_at_PR_isPlaying` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tST_at_PR_isPlaying`(
        p.`Who`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Who`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_at_PR_isPlaying_Stance`
FROM
    dw.`_Who` p,
    ties.`tST_at_PR_isPlaying`(
        p.`Who`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nST_at_PR_isPlaying` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tST_at_PR_isPlaying`(
        p.`Who`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Who`,
    tp.inspectedTimepoint,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Who`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_at_PR_isPlaying_Stance`
FROM
    dw.`_Who` p
JOIN (
    SELECT DISTINCT
        `ST_at_PR_isPlaying_Who` AS positor,
        CAST(`ST_at_PR_isPlaying_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`ST_at_PR_isPlaying`
    WHERE
        `ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Who`
JOIN (
    SELECT
        y.*,
        lead(y.`ST_at_PR_isPlaying_ChangedAt`) OVER (
            PARTITION BY
                y.`ST_at_PR_isPlaying_Who`,
                y.`ST_ID_at`,
                y.`PR_ID_isPlaying`
            ORDER BY y.`ST_at_PR_isPlaying_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rST_at_PR_isPlaying`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_at_PR_isPlaying_Stance` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`ST_at_PR_isPlaying_Who`,
                    r.`ST_ID_at`,
                    r.`PR_ID_isPlaying`,
                    r.`ST_at_PR_isPlaying_ChangedAt`
                ORDER BY
                    IF(r.`ST_at_PR_isPlaying_Stance` = '+', 0, 1),
                    r.`ST_at_PR_isPlaying_PositedAt` DESC,
                    r.`ST_at_PR_isPlaying_Confidence` DESC,
                    r.`ST_at_PR_isPlaying_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`ST_at_PR_isPlaying_Who` = tp.positor
AND
    t.`ST_at_PR_isPlaying_Stance` = '+'
AND
    t.`ST_at_PR_isPlaying_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_parent_AC_child_PAT_having` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    `kPAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `kPAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    t.`PAT_ID_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Who`,
    t.`AC_parent_AC_child_PAT_having_Confidence`,
    t.`AC_parent_AC_child_PAT_having_Stance`
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
            ties.`rAC_parent_AC_child_PAT_having`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_parent_AC_child_PAT_having_Stance` = coalesce(assertion, s.`AC_parent_AC_child_PAT_having_Stance`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_parent_AC_child_PAT_having_Who`,
                s.`AC_ID_parent`,
                s.`AC_ID_child`,
                s.`PAT_ID_having`
            ORDER BY
                s.`AC_parent_AC_child_PAT_having_PositedAt` DESC,
                s.`AC_parent_AC_child_PAT_having_Confidence` DESC,
                s.`AC_parent_AC_child_PAT_having_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`PAT_ParentalType` `kPAT_having`
ON
    `kPAT_having`.`PAT_ID` = t.`PAT_ID_having`
WHERE
    t.`AC_parent_AC_child_PAT_having_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_parent_AC_child_PAT_having` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_parent_AC_child_PAT_having`(
        p.`Who`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    t.`having_PAT_ParentalType`,
    t.`having_Metadata_PAT`,
    t.`PAT_ID_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Who`,
    t.`AC_parent_AC_child_PAT_having_Confidence`,
    t.`AC_parent_AC_child_PAT_having_Stance`
FROM
    dw.`_Who` p,
    ties.`tAC_parent_AC_child_PAT_having`(
        p.`Who`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_parent_AC_child_PAT_having` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tAC_parent_AC_child_PAT_having`(
        p.`Who`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_content_ST_location_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Who`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_content_ST_location_EV_of_Stance`
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
            max(IF(r.`PR_content_ST_location_EV_of_Stance` <> '?', r.`PR_content_ST_location_EV_of_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`PR_content_ST_location_EV_of_Who`,
                    r.`PR_ID_content`,
                    r.`ST_ID_location`,
                    r.`EV_ID_of`
            ) AS `inEffect`
        FROM
            ties.`rPR_content_ST_location_EV_of`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`PR_content_ST_location_EV_of_Stance` = coalesce(assertion, s.`PR_content_ST_location_EV_of_Stance`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`PR_content_ST_location_EV_of_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`PR_content_ST_location_EV_of_Who`, s.`PR_ID_content`
            ORDER BY
                s.`PR_content_ST_location_EV_of_ChangedAt` DESC,
                s.`PR_content_ST_location_EV_of_PositedAt` DESC,
                s.`PR_content_ST_location_EV_of_Confidence` DESC,
                s.`PR_content_ST_location_EV_of_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`PR_content_ST_location_EV_of_Who`, s.`ST_ID_location`
            ORDER BY
                s.`PR_content_ST_location_EV_of_ChangedAt` DESC,
                s.`PR_content_ST_location_EV_of_PositedAt` DESC,
                s.`PR_content_ST_location_EV_of_Confidence` DESC,
                s.`PR_content_ST_location_EV_of_ID` DESC
        ) = 1
) t
WHERE
    t.`PR_content_ST_location_EV_of_Who` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lPR_content_ST_location_EV_of` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tPR_content_ST_location_EV_of`(
        p.`Who`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Who`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_content_ST_location_EV_of_Stance`
FROM
    dw.`_Who` p,
    ties.`tPR_content_ST_location_EV_of`(
        p.`Who`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nPR_content_ST_location_EV_of` AS
SELECT
    p.`Who`,
    cast(null as numeric(7,3)) AS `Confidence`,
    t.*
FROM
    dw.`_Who` p,
    ties.`tPR_content_ST_location_EV_of`(
        p.`Who`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_content_ST_location_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Who`,
    tp.inspectedTimepoint,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Who`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_content_ST_location_EV_of_Stance`
FROM
    dw.`_Who` p
JOIN (
    SELECT DISTINCT
        `PR_content_ST_location_EV_of_Who` AS positor,
        CAST(`PR_content_ST_location_EV_of_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`PR_content_ST_location_EV_of`
    WHERE
        `PR_content_ST_location_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Who`
JOIN (
    SELECT
        y.*,
        lead(y.`PR_content_ST_location_EV_of_ChangedAt`) OVER (
            PARTITION BY
                y.`PR_content_ST_location_EV_of_Who`,
                y.`PR_ID_content`,
                y.`ST_ID_location`,
                y.`EV_ID_of`
            ORDER BY y.`PR_content_ST_location_EV_of_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rPR_content_ST_location_EV_of`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_content_ST_location_EV_of_Stance` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`PR_content_ST_location_EV_of_Who`,
                    r.`PR_ID_content`,
                    r.`ST_ID_location`,
                    r.`EV_ID_of`,
                    r.`PR_content_ST_location_EV_of_ChangedAt`
                ORDER BY
                    IF(r.`PR_content_ST_location_EV_of_Stance` = '+', 0, 1),
                    r.`PR_content_ST_location_EV_of_PositedAt` DESC,
                    r.`PR_content_ST_location_EV_of_Confidence` DESC,
                    r.`PR_content_ST_location_EV_of_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`PR_content_ST_location_EV_of_Who` = tp.positor
AND
    t.`PR_content_ST_location_EV_of_Stance` = '+'
AND
    t.`PR_content_ST_location_EV_of_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
WHERE
    TRUE
QUALIFY -- a tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`PR_ID_content`
        ORDER BY
            t.`PR_content_ST_location_EV_of_ChangedAt` DESC,
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_Confidence` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`ST_ID_location`
        ORDER BY
            t.`PR_content_ST_location_EV_of_ChangedAt` DESC,
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_Confidence` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
)
;
