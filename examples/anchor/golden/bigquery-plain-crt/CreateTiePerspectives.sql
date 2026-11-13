-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_partner_AC_with_ONG_currently` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `ONG_Ongoing`,
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
            public.`rAC_partner_AC_with_ONG_currently`(
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
    public.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`ONG_Ongoing`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_partner_AC_with_ONG_currently` (
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
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `ONG_Ongoing`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_partner_AC_with_ONG_currently_Positor` AS positor,
        CAST(`AC_partner_AC_with_ONG_currently_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        public.`AC_partner_AC_with_ONG_currently`
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
            public.`rAC_partner_AC_with_ONG_currently`(
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
    public.`ONG_Ongoing` `kONG_currently`
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
CREATE OR REPLACE TABLE FUNCTION public.`tAC_subset_PN_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
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
            public.`rAC_subset_PN_of`(
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
CREATE OR REPLACE VIEW public.`lAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Positor`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_subset_PN_of_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tEV_in_AC_wasCast` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Positor`,
    t.`EV_in_AC_wasCast_Reliability`,
    t.`EV_in_AC_wasCast_Assertion`
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
            public.`rEV_in_AC_wasCast`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`EV_in_AC_wasCast_Assertion` = coalesce(assertion, s.`EV_in_AC_wasCast_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`EV_in_AC_wasCast_Positor`,
                s.`EV_ID_in`,
                s.`AC_ID_wasCast`
            ORDER BY
                s.`EV_in_AC_wasCast_PositedAt` DESC,
                s.`EV_in_AC_wasCast_Reliability` DESC,
                s.`EV_in_AC_wasCast_ID` DESC
        ) = 1
) t
WHERE
    t.`EV_in_AC_wasCast_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_in_AC_wasCast` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tEV_in_AC_wasCast`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Positor`,
    t.`EV_in_AC_wasCast_Reliability`,
    t.`EV_in_AC_wasCast_Assertion`
FROM
    public.`_Positor` p,
    public.`tEV_in_AC_wasCast`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_in_AC_wasCast` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tEV_in_AC_wasCast`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_part_PR_in_RAT_got` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `RAT_Rating`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Positor`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_part_PR_in_RAT_got_Assertion`
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
            max(IF(r.`AC_part_PR_in_RAT_got_Assertion` <> '?', r.`AC_part_PR_in_RAT_got_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_part_PR_in_RAT_got_Positor`,
                    r.`AC_ID_part`,
                    r.`PR_ID_in`
            ) AS `inEffect`
        FROM
            public.`rAC_part_PR_in_RAT_got`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_part_PR_in_RAT_got_Assertion` = coalesce(assertion, s.`AC_part_PR_in_RAT_got_Assertion`)
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
                s.`AC_part_PR_in_RAT_got_Positor`,
                s.`AC_ID_part`,
                s.`PR_ID_in`
            ORDER BY
                s.`AC_part_PR_in_RAT_got_ChangedAt` DESC,
                s.`AC_part_PR_in_RAT_got_PositedAt` DESC,
                s.`AC_part_PR_in_RAT_got_Reliability` DESC,
                s.`AC_part_PR_in_RAT_got_ID` DESC
        ) = 1
) t
LEFT JOIN
    public.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
WHERE
    t.`AC_part_PR_in_RAT_got_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_part_PR_in_RAT_got` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_part_PR_in_RAT_got`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`RAT_Rating`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Positor`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_part_PR_in_RAT_got`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_part_PR_in_RAT_got` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_part_PR_in_RAT_got`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_part_PR_in_RAT_got` (
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
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `RAT_Rating`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Positor`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_part_PR_in_RAT_got_Positor` AS positor,
        CAST(`AC_part_PR_in_RAT_got_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        public.`AC_part_PR_in_RAT_got`
    WHERE
        `AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_part_PR_in_RAT_got_Positor`,
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
            public.`rAC_part_PR_in_RAT_got`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_part_PR_in_RAT_got_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_part_PR_in_RAT_got_Positor`,
                    r.`AC_ID_part`,
                    r.`PR_ID_in`,
                    r.`AC_part_PR_in_RAT_got_ChangedAt`
                ORDER BY
                    IF(r.`AC_part_PR_in_RAT_got_Assertion` = '+', 0, 1),
                    r.`AC_part_PR_in_RAT_got_PositedAt` DESC,
                    r.`AC_part_PR_in_RAT_got_Reliability` DESC,
                    r.`AC_part_PR_in_RAT_got_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_part_PR_in_RAT_got_Positor` = tp.positor
AND
    t.`AC_part_PR_in_RAT_got_Assertion` = '+'
AND
    t.`AC_part_PR_in_RAT_got_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tST_at_PR_isPlaying` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Positor`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_at_PR_isPlaying_Assertion`
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
            max(IF(r.`ST_at_PR_isPlaying_Assertion` <> '?', r.`ST_at_PR_isPlaying_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`ST_at_PR_isPlaying_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_isPlaying`
            ) AS `inEffect`
        FROM
            public.`rST_at_PR_isPlaying`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`ST_at_PR_isPlaying_Assertion` = coalesce(assertion, s.`ST_at_PR_isPlaying_Assertion`)
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
                s.`ST_at_PR_isPlaying_Positor`,
                s.`ST_ID_at`,
                s.`PR_ID_isPlaying`
            ORDER BY
                s.`ST_at_PR_isPlaying_ChangedAt` DESC,
                s.`ST_at_PR_isPlaying_PositedAt` DESC,
                s.`ST_at_PR_isPlaying_Reliability` DESC,
                s.`ST_at_PR_isPlaying_ID` DESC
        ) = 1
) t
WHERE
    t.`ST_at_PR_isPlaying_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lST_at_PR_isPlaying` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tST_at_PR_isPlaying`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Positor`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_at_PR_isPlaying_Assertion`
FROM
    public.`_Positor` p,
    public.`tST_at_PR_isPlaying`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nST_at_PR_isPlaying` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tST_at_PR_isPlaying`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_at_PR_isPlaying` (
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
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Positor`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_at_PR_isPlaying_Assertion`
FROM
    public.`_Positor` p
JOIN (
    SELECT DISTINCT
        `ST_at_PR_isPlaying_Positor` AS positor,
        CAST(`ST_at_PR_isPlaying_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        public.`ST_at_PR_isPlaying`
    WHERE
        `ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`ST_at_PR_isPlaying_ChangedAt`) OVER (
            PARTITION BY
                y.`ST_at_PR_isPlaying_Positor`,
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
            public.`rST_at_PR_isPlaying`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_at_PR_isPlaying_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`ST_at_PR_isPlaying_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_isPlaying`,
                    r.`ST_at_PR_isPlaying_ChangedAt`
                ORDER BY
                    IF(r.`ST_at_PR_isPlaying_Assertion` = '+', 0, 1),
                    r.`ST_at_PR_isPlaying_PositedAt` DESC,
                    r.`ST_at_PR_isPlaying_Reliability` DESC,
                    r.`ST_at_PR_isPlaying_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`ST_at_PR_isPlaying_Positor` = tp.positor
AND
    t.`ST_at_PR_isPlaying_Assertion` = '+'
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
CREATE OR REPLACE TABLE FUNCTION public.`tAC_parent_AC_child_PAT_having` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    `kPAT_having`.`PAT_ParentalType` AS `PAT_ParentalType`,
    t.`PAT_ID_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Positor`,
    t.`AC_parent_AC_child_PAT_having_Reliability`,
    t.`AC_parent_AC_child_PAT_having_Assertion`
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
            public.`rAC_parent_AC_child_PAT_having`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_parent_AC_child_PAT_having_Assertion` = coalesce(assertion, s.`AC_parent_AC_child_PAT_having_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_parent_AC_child_PAT_having_Positor`,
                s.`AC_ID_parent`,
                s.`AC_ID_child`,
                s.`PAT_ID_having`
            ORDER BY
                s.`AC_parent_AC_child_PAT_having_PositedAt` DESC,
                s.`AC_parent_AC_child_PAT_having_Reliability` DESC,
                s.`AC_parent_AC_child_PAT_having_ID` DESC
        ) = 1
) t
LEFT JOIN
    public.`PAT_ParentalType` `kPAT_having`
ON
    `kPAT_having`.`PAT_ID` = t.`PAT_ID_having`
WHERE
    t.`AC_parent_AC_child_PAT_having_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_parent_AC_child_PAT_having` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_parent_AC_child_PAT_having`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    t.`PAT_ParentalType`,
    t.`PAT_ID_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Positor`,
    t.`AC_parent_AC_child_PAT_having_Reliability`,
    t.`AC_parent_AC_child_PAT_having_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_parent_AC_child_PAT_having`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_parent_AC_child_PAT_having` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_parent_AC_child_PAT_having`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tPR_content_ST_location_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Positor`,
    t.`PR_content_ST_location_EV_of_Reliability`,
    t.`PR_content_ST_location_EV_of_Assertion`
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
            public.`rPR_content_ST_location_EV_of`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`PR_content_ST_location_EV_of_Assertion` = coalesce(assertion, s.`PR_content_ST_location_EV_of_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`PR_content_ST_location_EV_of_Positor`,
                s.`EV_ID_of`
            ORDER BY
                s.`PR_content_ST_location_EV_of_PositedAt` DESC,
                s.`PR_content_ST_location_EV_of_Reliability` DESC,
                s.`PR_content_ST_location_EV_of_ID` DESC
        ) = 1
) t
WHERE
    t.`PR_content_ST_location_EV_of_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_content_ST_location_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tPR_content_ST_location_EV_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Positor`,
    t.`PR_content_ST_location_EV_of_Reliability`,
    t.`PR_content_ST_location_EV_of_Assertion`
FROM
    public.`_Positor` p,
    public.`tPR_content_ST_location_EV_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nPR_content_ST_location_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tPR_content_ST_location_EV_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
