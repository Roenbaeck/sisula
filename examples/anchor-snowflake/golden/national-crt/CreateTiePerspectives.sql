-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
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
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    TABLE(ties."rAC_partner_AC_with_ONG_currently"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Assertion" = coalesce(assertion, t."AC_partner_AC_with_ONG_currently_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
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
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
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
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_partner_AC_with_ONG_currently_Positor" AS positor,
        "AC_partner_AC_with_ONG_currently_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."AC_partner_AC_with_ONG_currently"
    WHERE
        "AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint,
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
    TABLE(ties."rAC_subset_PN_of"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."AC_subset_PN_of_Assertion" = coalesce(assertion, t."AC_subset_PN_of_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_subset_PN_of"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint,
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
    dw."_Positor" p,
    TABLE(ties."tAC_subset_PN_of"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_subset_PN_of"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_rollsattes" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint,
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Positor",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_in_AC_rollsattes_Assertion"
FROM
    TABLE(ties."rEV_in_AC_rollsattes"(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t."EV_in_AC_rollsattes_Assertion" = coalesce(assertion, t."EV_in_AC_rollsattes_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tEV_in_AC_rollsattes"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint,
    "EV_in_AC_rollsattes_PositedAt" datetime,
    "EV_in_AC_rollsattes_Positor" tinyint,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_in_AC_rollsattes_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Positor",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_in_AC_rollsattes_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tEV_in_AC_rollsattes"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tEV_in_AC_rollsattes"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_deltar_PR_in_RAT_fick" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    TABLE(ties."rAC_deltar_PR_in_RAT_fick"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."AC_deltar_PR_in_RAT_fick_Assertion" = coalesce(assertion, t."AC_deltar_PR_in_RAT_fick_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Checksum",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Positor" tinyint,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_deltar_PR_in_RAT_fick_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Checksum",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_deltar_PR_in_RAT_fick_Positor" AS positor,
        "AC_deltar_PR_in_RAT_fick_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."AC_deltar_PR_in_RAT_fick"
    WHERE
        "AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tST_at_PR_spelas" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0),
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM
    TABLE(ties."rST_at_PR_spelas"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."ST_at_PR_spelas_Assertion" = coalesce(assertion, t."ST_at_PR_spelas_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tST_at_PR_spelas"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_ST_at_PR_spelas" int,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0),
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tST_at_PR_spelas"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tST_at_PR_spelas"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_ST_at_PR_spelas" int,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0),
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Positor" tinyint,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_at_PR_spelas_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "ST_at_PR_spelas_Positor" AS positor,
        "ST_at_PR_spelas_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."ST_at_PR_spelas"
    WHERE
        "ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tST_at_PR_spelas"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_förälder_AC_barn_PAT_har" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Positor",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    TABLE(ties."rAC_förälder_AC_barn_PAT_har"(
        positor,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."AC_förälder_AC_barn_PAT_har_Assertion" = coalesce(assertion, t."AC_förälder_AC_barn_PAT_har_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Positor" tinyint,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_förälder_AC_barn_PAT_har_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    t."har_PAT_Föräldratyp",
    t."har_Metadata_PAT",
    t."PAT_ID_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Positor",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_förälder_AC_barn_PAT_har_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tPR_innehåll_ST_plats_EV_of" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0),
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    TABLE(ties."rPR_innehåll_ST_plats_EV_of"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."PR_innehåll_ST_plats_EV_of_Assertion" = coalesce(assertion, t."PR_innehåll_ST_plats_EV_of_Assertion")
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0),
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    dw."_Positor" p,
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    dw."_Positor" p,
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0),
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Positor" tinyint,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_innehåll_ST_plats_EV_of_Assertion" string
)
AS
$$
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM
    dw."_Positor" p
JOIN (
    SELECT DISTINCT
        "PR_innehåll_ST_plats_EV_of_Positor" AS positor,
        "PR_innehåll_ST_plats_EV_of_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties."PR_innehåll_ST_plats_EV_of"
    WHERE
        "PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor",
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
