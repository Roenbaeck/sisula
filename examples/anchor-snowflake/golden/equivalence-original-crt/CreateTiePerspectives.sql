-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    ONG_Ongoing varchar(3),
    Metadata_ONG int,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS ONG_Ongoing,
    kONG_currently.Metadata_ONG AS Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion
FROM
    TABLE(ties.rAC_partner_AC_with_ONG_currently(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Assertion = coalesce(assertion, t.AC_partner_AC_with_ONG_currently_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    ONG_Ongoing varchar(3),
    Metadata_ONG int,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.ONG_Ongoing,
    t.Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    ONG_Ongoing varchar(3),
    Metadata_ONG int,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.ONG_Ongoing,
    t.Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion
FROM
    dw._Positor p
JOIN (
    SELECT DISTINCT
        AC_partner_AC_with_ONG_currently_Positor AS positor,
        AC_partner_AC_with_ONG_currently_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.AC_partner_AC_with_ONG_currently
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_ID_subset smallint,
    PN_ID_of bigint,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_subset_PN_of,
    t.AC_ID_subset,
    t.PN_ID_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Positor,
    t.AC_subset_PN_of_Reliability,
    t.AC_subset_PN_of_Assertion
FROM
    TABLE(ties.rAC_subset_PN_of(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t.AC_subset_PN_of_Assertion = coalesce(assertion, t.AC_subset_PN_of_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_subset_PN_of(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_subset_PN_of int,
    AC_ID_subset smallint,
    PN_ID_of bigint,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_subset_PN_of,
    t.AC_ID_subset,
    t.PN_ID_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Positor,
    t.AC_subset_PN_of_Reliability,
    t.AC_subset_PN_of_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tAC_subset_PN_of(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_subset_PN_of(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    t.Metadata_EV_in_AC_wasCast,
    t.EV_ID_in,
    t.AC_ID_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Positor,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_in_AC_wasCast_Assertion
FROM
    TABLE(ties.rEV_in_AC_wasCast(
        positor,
        positingTimepoint::datetime
    )) t
WHERE
    t.EV_in_AC_wasCast_Assertion = coalesce(assertion, t.EV_in_AC_wasCast_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tEV_in_AC_wasCast(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_ID_in,
    t.AC_ID_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Positor,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_in_AC_wasCast_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tEV_in_AC_wasCast(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tEV_in_AC_wasCast(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    RAT_Checksum numeric(19,0),
    RAT_Rating varchar(42),
    Metadata_RAT int,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Checksum AS RAT_Checksum,
    kRAT_got.RAT_Rating AS RAT_Rating,
    kRAT_got.Metadata_RAT AS Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion
FROM
    TABLE(ties.rAC_part_PR_in_RAT_got(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Assertion = coalesce(assertion, t.AC_part_PR_in_RAT_got_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_part_PR_in_RAT_got(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_part_PR_in_RAT_got int,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    RAT_Checksum numeric(19,0),
    RAT_Rating varchar(42),
    Metadata_RAT int,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    t.RAT_Checksum,
    t.RAT_Rating,
    t.Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tAC_part_PR_in_RAT_got(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_part_PR_in_RAT_got(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_AC_part_PR_in_RAT_got int,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    RAT_Checksum numeric(19,0),
    RAT_Rating varchar(42),
    Metadata_RAT int,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    t.RAT_Checksum,
    t.RAT_Rating,
    t.Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion
FROM
    dw._Positor p
JOIN (
    SELECT DISTINCT
        AC_part_PR_in_RAT_got_Positor AS positor,
        AC_part_PR_in_RAT_got_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.AC_part_PR_in_RAT_got
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(ties.tAC_part_PR_in_RAT_got(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0),
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion
FROM
    TABLE(ties.rST_at_PR_isPlaying(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_Assertion = coalesce(assertion, t.ST_at_PR_isPlaying_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tST_at_PR_isPlaying(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_ST_at_PR_isPlaying int,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0),
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tST_at_PR_isPlaying(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tST_at_PR_isPlaying(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_ST_at_PR_isPlaying int,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0),
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion
FROM
    dw._Positor p
JOIN (
    SELECT DISTINCT
        ST_at_PR_isPlaying_Positor AS positor,
        ST_at_PR_isPlaying_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.ST_at_PR_isPlaying
    WHERE
        ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(ties.tST_at_PR_isPlaying(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent smallint,
    AC_ID_child smallint,
    PAT_ParentalType varchar(42),
    Metadata_PAT int,
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
)
AS
$$
SELECT
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS PAT_ParentalType,
    kPAT_having.Metadata_PAT AS Metadata_PAT,
    t.PAT_ID_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Positor,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_parent_AC_child_PAT_having_Assertion
FROM
    TABLE(ties.rAC_parent_AC_child_PAT_having(
        positor,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Assertion = coalesce(assertion, t.AC_parent_AC_child_PAT_having_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent smallint,
    AC_ID_child smallint,
    PAT_ParentalType varchar(42),
    Metadata_PAT int,
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.PAT_ParentalType,
    t.Metadata_PAT,
    t.PAT_ID_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Positor,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_parent_AC_child_PAT_having_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0),
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion
FROM
    TABLE(ties.rPR_content_ST_location_EV_of(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Assertion = coalesce(assertion, t.PR_content_ST_location_EV_of_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tPR_content_ST_location_EV_of(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    Metadata_PR_content_ST_location_EV_of int,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0),
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion
FROM
    dw._Positor p,
    TABLE(ties.tPR_content_ST_location_EV_of(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    p.Positor,
    cast(null as decimal(5,2)) AS Reliability,
    t.*
FROM
    dw._Positor p,
    TABLE(ties.tPR_content_ST_location_EV_of(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_PR_content_ST_location_EV_of int,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0),
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion
FROM
    dw._Positor p
JOIN (
    SELECT DISTINCT
        PR_content_ST_location_EV_of_Positor AS positor,
        PR_content_ST_location_EV_of_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.PR_content_ST_location_EV_of
    WHERE
        PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor,
    TABLE(ties.tPR_content_ST_location_EV_of(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
