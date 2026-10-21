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
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" int,
    "AC_ID_with" int,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" int,
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
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    TABLE(public."rAC_partner_AC_with_ONG_currently"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Assertion" = coalesce(assertion, t."AC_partner_AC_with_ONG_currently_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."AC_partner_AC_with_ONG_currently_ID" = (
        SELECT
            sub."AC_partner_AC_with_ONG_currently_ID"
        FROM
            (
                SELECT
                    r.*,
                    -- the latest changing time with an assertion that is not a retraction, which supersedes those before
                    -- it whatever its sign
                    max(iff(r."AC_partner_AC_with_ONG_currently_Assertion" <> '?', r."AC_partner_AC_with_ONG_currently_ChangedAt", null)) OVER (
                        PARTITION BY
                            r."AC_ID_partner",
                            r."AC_ID_with",
                            r."ONG_ID_currently"
                    ) AS "inEffect"
                FROM
                    TABLE(public."rAC_partner_AC_with_ONG_currently"(
                        positor,
                        changingTimepoint::datetime,
                        positingTimepoint::datetime
                    )) r
            ) sub
        WHERE
            (
                sub."AC_ID_partner" = t."AC_ID_partner"
            OR
                sub."AC_ID_with" = t."AC_ID_with"
            )
        AND
            sub."AC_partner_AC_with_ONG_currently_Assertion" = coalesce(assertion, sub."AC_partner_AC_with_ONG_currently_Assertion")
        AND ( -- asked for positive or negative assertions, only those at that changing time
            coalesce(assertion, '?') = '?'
        OR
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" = sub."inEffect"
        )
        ORDER BY
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            sub."AC_partner_AC_with_ONG_currently_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" int,
    "AC_ID_with" int,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" int,
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
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
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
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" int,
    "AC_ID_with" int,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" int,
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
    tp.inspectedTimepoint,
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
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
    tp.positor = p."Positor",
    TABLE(public."tAC_partner_AC_with_ONG_currently"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
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
    "Metadata_AC_subset_PN_of" int,
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
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM
    TABLE(public."rAC_subset_PN_of"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."AC_subset_PN_of_Assertion" = coalesce(assertion, t."AC_subset_PN_of_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."AC_subset_PN_of_ID" = (
        SELECT
            sub."AC_subset_PN_of_ID"
        FROM
            TABLE(public."rAC_subset_PN_of"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            (
                sub."AC_ID_subset" = t."AC_ID_subset"
            OR
                sub."PN_ID_of" = t."PN_ID_of"
            )
        AND
            sub."AC_subset_PN_of_Assertion" = coalesce(assertion, sub."AC_subset_PN_of_Assertion")
        ORDER BY
            sub."AC_subset_PN_of_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_AC_subset_PN_of" int,
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
    t."Metadata_AC_subset_PN_of",
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
    "Metadata_EV_in_AC_wasCast" int,
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
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM
    TABLE(public."rEV_in_AC_wasCast"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."EV_in_AC_wasCast_Assertion" = coalesce(assertion, t."EV_in_AC_wasCast_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."EV_in_AC_wasCast_ID" = (
        SELECT
            sub."EV_in_AC_wasCast_ID"
        FROM
            TABLE(public."rEV_in_AC_wasCast"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_ID_in" = t."EV_ID_in"
        AND
            sub."AC_ID_wasCast" = t."AC_ID_wasCast"
        AND
            sub."EV_in_AC_wasCast_Assertion" = coalesce(assertion, sub."EV_in_AC_wasCast_Assertion")
        ORDER BY
            sub."EV_in_AC_wasCast_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_EV_in_AC_wasCast" int,
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
    t."Metadata_EV_in_AC_wasCast",
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
    "Metadata_AC_part_PR_in_RAT_got" int,
    "AC_ID_part" int,
    "PR_ID_in" int,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" int,
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
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM
    TABLE(public."rAC_part_PR_in_RAT_got"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."AC_part_PR_in_RAT_got_Assertion" = coalesce(assertion, t."AC_part_PR_in_RAT_got_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."AC_part_PR_in_RAT_got_ID" = (
        SELECT
            sub."AC_part_PR_in_RAT_got_ID"
        FROM
            (
                SELECT
                    r.*,
                    -- the latest changing time with an assertion that is not a retraction, which supersedes those before
                    -- it whatever its sign
                    max(iff(r."AC_part_PR_in_RAT_got_Assertion" <> '?', r."AC_part_PR_in_RAT_got_ChangedAt", null)) OVER (
                        PARTITION BY
                            r."AC_ID_part",
                            r."PR_ID_in"
                    ) AS "inEffect"
                FROM
                    TABLE(public."rAC_part_PR_in_RAT_got"(
                        positor,
                        changingTimepoint::datetime,
                        positingTimepoint::datetime
                    )) r
            ) sub
        WHERE
            sub."AC_ID_part" = t."AC_ID_part"
        AND
            sub."PR_ID_in" = t."PR_ID_in"
        AND
            sub."AC_part_PR_in_RAT_got_Assertion" = coalesce(assertion, sub."AC_part_PR_in_RAT_got_Assertion")
        AND ( -- asked for positive or negative assertions, only those at that changing time
            coalesce(assertion, '?') = '?'
        OR
            sub."AC_part_PR_in_RAT_got_ChangedAt" = sub."inEffect"
        )
        ORDER BY
            sub."AC_part_PR_in_RAT_got_ChangedAt" DESC,
            sub."AC_part_PR_in_RAT_got_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_AC_part_PR_in_RAT_got" int,
    "AC_ID_part" int,
    "PR_ID_in" int,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" int,
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
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
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
    "Metadata_AC_part_PR_in_RAT_got" int,
    "AC_ID_part" int,
    "PR_ID_in" int,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" int,
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
    tp.inspectedTimepoint,
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
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
    tp.positor = p."Positor",
    TABLE(public."tAC_part_PR_in_RAT_got"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
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
    "Metadata_ST_at_PR_isPlaying" int,
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
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM
    TABLE(public."rST_at_PR_isPlaying"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."ST_at_PR_isPlaying_Assertion" = coalesce(assertion, t."ST_at_PR_isPlaying_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."ST_at_PR_isPlaying_ID" = (
        SELECT
            sub."ST_at_PR_isPlaying_ID"
        FROM
            (
                SELECT
                    r.*,
                    -- the latest changing time with an assertion that is not a retraction, which supersedes those before
                    -- it whatever its sign
                    max(iff(r."ST_at_PR_isPlaying_Assertion" <> '?', r."ST_at_PR_isPlaying_ChangedAt", null)) OVER (
                        PARTITION BY
                            r."ST_ID_at",
                            r."PR_ID_isPlaying"
                    ) AS "inEffect"
                FROM
                    TABLE(public."rST_at_PR_isPlaying"(
                        positor,
                        changingTimepoint::datetime,
                        positingTimepoint::datetime
                    )) r
            ) sub
        WHERE
            sub."ST_ID_at" = t."ST_ID_at"
        AND
            sub."PR_ID_isPlaying" = t."PR_ID_isPlaying"
        AND
            sub."ST_at_PR_isPlaying_Assertion" = coalesce(assertion, sub."ST_at_PR_isPlaying_Assertion")
        AND ( -- asked for positive or negative assertions, only those at that changing time
            coalesce(assertion, '?') = '?'
        OR
            sub."ST_at_PR_isPlaying_ChangedAt" = sub."inEffect"
        )
        ORDER BY
            sub."ST_at_PR_isPlaying_ChangedAt" DESC,
            sub."ST_at_PR_isPlaying_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_ST_at_PR_isPlaying" int,
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
    t."Metadata_ST_at_PR_isPlaying",
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
    "Metadata_ST_at_PR_isPlaying" int,
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
    tp.inspectedTimepoint,
    t."Metadata_ST_at_PR_isPlaying",
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
    tp.positor = p."Positor",
    TABLE(public."tST_at_PR_isPlaying"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
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
    "Metadata_AC_parent_AC_child_PAT_having" int,
    "AC_ID_parent" int,
    "AC_ID_child" int,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" int,
    "PAT_ID_having" tinyint,
    "AC_parent_AC_child_PAT_having_PositedAt" datetime,
    "AC_parent_AC_child_PAT_having_Positor" tinyint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" string
)
AS
$$
SELECT
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM
    TABLE(public."rAC_parent_AC_child_PAT_having"(
        positor,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."AC_parent_AC_child_PAT_having_Assertion" = coalesce(assertion, t."AC_parent_AC_child_PAT_having_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."AC_parent_AC_child_PAT_having_ID" = (
        SELECT
            sub."AC_parent_AC_child_PAT_having_ID"
        FROM
            TABLE(public."rAC_parent_AC_child_PAT_having"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_ID_parent" = t."AC_ID_parent"
        AND
            sub."AC_ID_child" = t."AC_ID_child"
        AND
            sub."PAT_ID_having" = t."PAT_ID_having"
        AND
            sub."AC_parent_AC_child_PAT_having_Assertion" = coalesce(assertion, sub."AC_parent_AC_child_PAT_having_Assertion")
        ORDER BY
            sub."AC_parent_AC_child_PAT_having_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_AC_parent_AC_child_PAT_having" int,
    "AC_ID_parent" int,
    "AC_ID_child" int,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" int,
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
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    t."having_PAT_ParentalType",
    t."having_Metadata_PAT",
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
    "Metadata_PR_content_ST_location_EV_of" int,
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
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM
    TABLE(public."rPR_content_ST_location_EV_of"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."PR_content_ST_location_EV_of_Assertion" = coalesce(assertion, t."PR_content_ST_location_EV_of_Assertion")
AND -- the posit in effect for the identifiers, as in uni and bi (all of them used to be shown)
    t."PR_content_ST_location_EV_of_ID" = (
        SELECT
            sub."PR_content_ST_location_EV_of_ID"
        FROM
            TABLE(public."rPR_content_ST_location_EV_of"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_ID_of" = t."EV_ID_of"
        AND
            sub."PR_content_ST_location_EV_of_Assertion" = coalesce(assertion, sub."PR_content_ST_location_EV_of_Assertion")
        ORDER BY
            sub."PR_content_ST_location_EV_of_PositedAt" DESC
        LIMIT 1
    )
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
    "Metadata_PR_content_ST_location_EV_of" int,
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
    t."Metadata_PR_content_ST_location_EV_of",
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
