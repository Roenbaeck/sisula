-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID_partner" int,
    "AC_ID_with" int,
    "currently_ONG_Ongoing" varchar(3),
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
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(iff(r."AC_partner_AC_with_ONG_currently_Assertion" <> '?', r."AC_partner_AC_with_ONG_currently_ChangedAt", null)) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            TABLE(public."rAC_partner_AC_with_ONG_currently"(
                null::tinyint,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = coalesce(assertion, s."AC_partner_AC_with_ONG_currently_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
    )
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) = 1
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "AC_ID_partner" int,
    "AC_ID_with" int,
    "currently_ONG_Ongoing" varchar(3),
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
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "AC_ID_partner" int,
    "AC_ID_with" int,
    "currently_ONG_Ongoing" varchar(3),
    "ONG_ID_currently" tinyint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" string
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. Snowflake cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_partner_AC_with_ONG_currently_Positor" AS positor,
        "AC_partner_AC_with_ONG_currently_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public."AC_partner_AC_with_ONG_currently"
    WHERE
        "AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (
            PARTITION BY
                y."AC_partner_AC_with_ONG_currently_Positor",
                y."AC_ID_partner",
                y."AC_ID_with",
                y."ONG_ID_currently"
            ORDER BY y."AC_partner_AC_with_ONG_currently_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            TABLE(public."rAC_partner_AC_with_ONG_currently"(
                null::tinyint,
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."AC_partner_AC_with_ONG_currently_Assertion" <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently",
                    r."AC_partner_AC_with_ONG_currently_ChangedAt"
                ORDER BY
                    iff(r."AC_partner_AC_with_ONG_currently_Assertion" = '+', 0, 1),
                    r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                    r."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                    r."AC_partner_AC_with_ONG_currently_ID" DESC
            ) = 1
    ) y
) t
ON
    t."AC_partner_AC_with_ONG_currently_Positor" = tp.positor
AND
    t."AC_partner_AC_with_ONG_currently_Assertion" = '+'
AND
    t."AC_partner_AC_with_ONG_currently_ChangedAt" <= tp.inspectedTimepoint::datetime
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::datetime
)
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
QUALIFY -- a tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."AC_ID_partner"
        ORDER BY
            t."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_Reliability" DESC,
            t."AC_partner_AC_with_ONG_currently_ID" DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."AC_ID_with"
        ORDER BY
            t."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_Reliability" DESC,
            t."AC_partner_AC_with_ONG_currently_ID" DESC
    ) = 1
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_subset_PN_of" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID_subset" int,
    "PN_ID_of" int,
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
)
AS
$$
SELECT
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(public."rAC_subset_PN_of"(
                null::tinyint,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = coalesce(assertion, s."AC_subset_PN_of_Assertion")
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) = 1
) t
WHERE
    t."AC_subset_PN_of_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_subset_PN_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_subset_PN_of"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "AC_ID_subset" int,
    "PN_ID_of" int,
    "AC_subset_PN_of_PositedAt" datetime,
    "AC_subset_PN_of_Positor" tinyint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tAC_subset_PN_of"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_subset_PN_of"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tEV_in_AC_wasCast" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID_in" int,
    "AC_ID_wasCast" int,
    "EV_in_AC_wasCast_PositedAt" datetime,
    "EV_in_AC_wasCast_Positor" tinyint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" string
)
AS
$$
SELECT
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(public."rEV_in_AC_wasCast"(
                null::tinyint,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Assertion" = coalesce(assertion, s."EV_in_AC_wasCast_Assertion")
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Positor",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Reliability" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) = 1
) t
WHERE
    t."EV_in_AC_wasCast_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tEV_in_AC_wasCast"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_in_AC_wasCast" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "EV_ID_in" int,
    "AC_ID_wasCast" int,
    "EV_in_AC_wasCast_PositedAt" datetime,
    "EV_in_AC_wasCast_Positor" tinyint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tEV_in_AC_wasCast"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tEV_in_AC_wasCast"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_part_PR_in_RAT_got" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID_part" int,
    "PR_ID_in" int,
    "got_RAT_Rating" varchar(42),
    "RAT_ID_got" tinyint,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime,
    "AC_part_PR_in_RAT_got_PositedAt" datetime,
    "AC_part_PR_in_RAT_got_Positor" tinyint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" string
)
AS
$$
SELECT
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(iff(r."AC_part_PR_in_RAT_got_Assertion" <> '?', r."AC_part_PR_in_RAT_got_ChangedAt", null)) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            TABLE(public."rAC_part_PR_in_RAT_got"(
                null::tinyint,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Assertion" = coalesce(assertion, s."AC_part_PR_in_RAT_got_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
    )
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Positor",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Reliability" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) = 1
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."AC_part_PR_in_RAT_got_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_part_PR_in_RAT_got"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "AC_ID_part" int,
    "PR_ID_in" int,
    "got_RAT_Rating" varchar(42),
    "RAT_ID_got" tinyint,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime,
    "AC_part_PR_in_RAT_got_PositedAt" datetime,
    "AC_part_PR_in_RAT_got_Positor" tinyint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tAC_part_PR_in_RAT_got"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_part_PR_in_RAT_got" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_part_PR_in_RAT_got"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "AC_ID_part" int,
    "PR_ID_in" int,
    "got_RAT_Rating" varchar(42),
    "RAT_ID_got" tinyint,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime,
    "AC_part_PR_in_RAT_got_PositedAt" datetime,
    "AC_part_PR_in_RAT_got_Positor" tinyint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" string
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. Snowflake cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_part_PR_in_RAT_got_Positor" AS positor,
        "AC_part_PR_in_RAT_got_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public."AC_part_PR_in_RAT_got"
    WHERE
        "AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."AC_part_PR_in_RAT_got_ChangedAt") OVER (
            PARTITION BY
                y."AC_part_PR_in_RAT_got_Positor",
                y."AC_ID_part",
                y."PR_ID_in"
            ORDER BY y."AC_part_PR_in_RAT_got_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            TABLE(public."rAC_part_PR_in_RAT_got"(
                null::tinyint,
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."AC_part_PR_in_RAT_got_Assertion" <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in",
                    r."AC_part_PR_in_RAT_got_ChangedAt"
                ORDER BY
                    iff(r."AC_part_PR_in_RAT_got_Assertion" = '+', 0, 1),
                    r."AC_part_PR_in_RAT_got_PositedAt" DESC,
                    r."AC_part_PR_in_RAT_got_Reliability" DESC,
                    r."AC_part_PR_in_RAT_got_ID" DESC
            ) = 1
    ) y
) t
ON
    t."AC_part_PR_in_RAT_got_Positor" = tp.positor
AND
    t."AC_part_PR_in_RAT_got_Assertion" = '+'
AND
    t."AC_part_PR_in_RAT_got_ChangedAt" <= tp.inspectedTimepoint::datetime
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::datetime
)
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tST_at_PR_isPlaying" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID_at" int,
    "PR_ID_isPlaying" int,
    "ST_at_PR_isPlaying_ChangedAt" datetime,
    "ST_at_PR_isPlaying_PositedAt" datetime,
    "ST_at_PR_isPlaying_Positor" tinyint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" string
)
AS
$$
SELECT
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(iff(r."ST_at_PR_isPlaying_Assertion" <> '?', r."ST_at_PR_isPlaying_ChangedAt", null)) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            TABLE(public."rST_at_PR_isPlaying"(
                null::tinyint,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Assertion" = coalesce(assertion, s."ST_at_PR_isPlaying_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
    )
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Positor",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Reliability" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) = 1
) t
WHERE
    t."ST_at_PR_isPlaying_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_at_PR_isPlaying" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tST_at_PR_isPlaying"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_at_PR_isPlaying" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "ST_ID_at" int,
    "PR_ID_isPlaying" int,
    "ST_at_PR_isPlaying_ChangedAt" datetime,
    "ST_at_PR_isPlaying_PositedAt" datetime,
    "ST_at_PR_isPlaying_Positor" tinyint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tST_at_PR_isPlaying"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tST_at_PR_isPlaying"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_at_PR_isPlaying" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "ST_ID_at" int,
    "PR_ID_isPlaying" int,
    "ST_at_PR_isPlaying_ChangedAt" datetime,
    "ST_at_PR_isPlaying_PositedAt" datetime,
    "ST_at_PR_isPlaying_Positor" tinyint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" string
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. Snowflake cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "ST_at_PR_isPlaying_Positor" AS positor,
        "ST_at_PR_isPlaying_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public."ST_at_PR_isPlaying"
    WHERE
        "ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."ST_at_PR_isPlaying_ChangedAt") OVER (
            PARTITION BY
                y."ST_at_PR_isPlaying_Positor",
                y."ST_ID_at",
                y."PR_ID_isPlaying"
            ORDER BY y."ST_at_PR_isPlaying_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            TABLE(public."rST_at_PR_isPlaying"(
                null::tinyint,
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."ST_at_PR_isPlaying_Assertion" <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying",
                    r."ST_at_PR_isPlaying_ChangedAt"
                ORDER BY
                    iff(r."ST_at_PR_isPlaying_Assertion" = '+', 0, 1),
                    r."ST_at_PR_isPlaying_PositedAt" DESC,
                    r."ST_at_PR_isPlaying_Reliability" DESC,
                    r."ST_at_PR_isPlaying_ID" DESC
            ) = 1
    ) y
) t
ON
    t."ST_at_PR_isPlaying_Positor" = tp.positor
AND
    t."ST_at_PR_isPlaying_Assertion" = '+'
AND
    t."ST_at_PR_isPlaying_ChangedAt" <= tp.inspectedTimepoint::datetime
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::datetime
)
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_parent_AC_child_PAT_having" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID_parent" int,
    "AC_ID_child" int,
    "having_PAT_ParentalType" varchar(42),
    "PAT_ID_having" tinyint,
    "AC_parent_AC_child_PAT_having_PositedAt" datetime,
    "AC_parent_AC_child_PAT_having_Positor" tinyint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" string
)
AS
$$
SELECT
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(public."rAC_parent_AC_child_PAT_having"(
                null::tinyint,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Assertion" = coalesce(assertion, s."AC_parent_AC_child_PAT_having_Assertion")
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Positor",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Reliability" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) = 1
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."AC_parent_AC_child_PAT_having_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_parent_AC_child_PAT_having"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "AC_ID_parent" int,
    "AC_ID_child" int,
    "having_PAT_ParentalType" varchar(42),
    "PAT_ID_having" tinyint,
    "AC_parent_AC_child_PAT_having_PositedAt" datetime,
    "AC_parent_AC_child_PAT_having_Positor" tinyint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    t."having_PAT_ParentalType",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tAC_parent_AC_child_PAT_having"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tAC_parent_AC_child_PAT_having"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tPR_content_ST_location_EV_of" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID_content" int,
    "ST_ID_location" int,
    "EV_ID_of" int,
    "PR_content_ST_location_EV_of_PositedAt" datetime,
    "PR_content_ST_location_EV_of_Positor" tinyint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" string
)
AS
$$
SELECT
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and Snowflake cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            TABLE(public."rPR_content_ST_location_EV_of"(
                null::tinyint,
                positingTimepoint::datetime
            )) r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Assertion" = coalesce(assertion, s."PR_content_ST_location_EV_of_Assertion")
    QUALIFY -- picked by a window: Snowflake cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."PR_content_ST_location_EV_of_Positor",
                s."EV_ID_of"
            ORDER BY
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Reliability" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) = 1
) t
WHERE
    t."PR_content_ST_location_EV_of_Positor" = positor
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tPR_content_ST_location_EV_of"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "PR_ID_content" int,
    "ST_ID_location" int,
    "EV_ID_of" int,
    "PR_content_ST_location_EV_of_PositedAt" datetime,
    "PR_content_ST_location_EV_of_Positor" tinyint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM
    public."_Positor" p,
    TABLE(public."tPR_content_ST_location_EV_of"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    TABLE(public."tPR_content_ST_location_EV_of"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
