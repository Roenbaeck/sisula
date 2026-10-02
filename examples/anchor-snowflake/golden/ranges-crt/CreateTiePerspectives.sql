-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG bigint,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Who smallint,
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_partner_AC_with_ONG_currently_Stance string
)
AS
$$
SELECT
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    kONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Who,
    t.AC_partner_AC_with_ONG_currently_Confidence,
    t.AC_partner_AC_with_ONG_currently_Stance
FROM
    TABLE(ties.rAC_partner_AC_with_ONG_currently(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Stance = coalesce(assertion, t.AC_partner_AC_with_ONG_currently_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG bigint,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Who smallint,
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_partner_AC_with_ONG_currently_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Who,
    t.AC_partner_AC_with_ONG_currently_Confidence,
    t.AC_partner_AC_with_ONG_currently_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG bigint,
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Who smallint,
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_partner_AC_with_ONG_currently_Stance string
)
AS
$$
SELECT
    p.Who,
    tp.inspectedTimepoint,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Who,
    t.AC_partner_AC_with_ONG_currently_Confidence,
    t.AC_partner_AC_with_ONG_currently_Stance
FROM
    dw._Who p
JOIN (
    SELECT DISTINCT
        AC_partner_AC_with_ONG_currently_Who AS positor,
        AC_partner_AC_with_ONG_currently_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.AC_partner_AC_with_ONG_currently_Fact
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Who
CROSS JOIN LATERAL
    TABLE(ties.tAC_partner_AC_with_ONG_currently(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_ID_subset smallint,
    PN_ID_of bigint,
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Who smallint,
    AC_subset_PN_of_Confidence decimal(7,3),
    AC_subset_PN_of_Stance string
)
AS
$$
SELECT
    t.Metadata_AC_subset_PN_of,
    t.AC_ID_subset,
    t.PN_ID_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Who,
    t.AC_subset_PN_of_Confidence,
    t.AC_subset_PN_of_Stance
FROM
    TABLE(ties.rAC_subset_PN_of(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.AC_subset_PN_of_Stance = coalesce(assertion, t.AC_subset_PN_of_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_subset_PN_of(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_AC_subset_PN_of bigint,
    AC_ID_subset smallint,
    PN_ID_of bigint,
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Who smallint,
    AC_subset_PN_of_Confidence decimal(7,3),
    AC_subset_PN_of_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_AC_subset_PN_of,
    t.AC_ID_subset,
    t.PN_ID_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Who,
    t.AC_subset_PN_of_Confidence,
    t.AC_subset_PN_of_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_subset_PN_of(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_subset_PN_of(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Who smallint,
    EV_in_AC_wasCast_Confidence decimal(7,3),
    EV_in_AC_wasCast_Stance string
)
AS
$$
SELECT
    t.Metadata_EV_in_AC_wasCast,
    t.EV_ID_in,
    t.AC_ID_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Who,
    t.EV_in_AC_wasCast_Confidence,
    t.EV_in_AC_wasCast_Stance
FROM
    TABLE(ties.rEV_in_AC_wasCast(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.EV_in_AC_wasCast_Stance = coalesce(assertion, t.EV_in_AC_wasCast_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tEV_in_AC_wasCast(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_EV_in_AC_wasCast bigint,
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Who smallint,
    EV_in_AC_wasCast_Confidence decimal(7,3),
    EV_in_AC_wasCast_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_ID_in,
    t.AC_ID_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Who,
    t.EV_in_AC_wasCast_Confidence,
    t.EV_in_AC_wasCast_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tEV_in_AC_wasCast(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tEV_in_AC_wasCast(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT bigint,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Who smallint,
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_part_PR_in_RAT_got_Stance string
)
AS
$$
SELECT
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Checksum AS got_RAT_Checksum,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    kRAT_got.Metadata_RAT AS got_Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Who,
    t.AC_part_PR_in_RAT_got_Confidence,
    t.AC_part_PR_in_RAT_got_Stance
FROM
    TABLE(ties.rAC_part_PR_in_RAT_got(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Stance = coalesce(assertion, t.AC_part_PR_in_RAT_got_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_part_PR_in_RAT_got(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT bigint,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Who smallint,
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_part_PR_in_RAT_got_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Checksum,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Who,
    t.AC_part_PR_in_RAT_got_Confidence,
    t.AC_part_PR_in_RAT_got_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_part_PR_in_RAT_got(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_part_PR_in_RAT_got(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT bigint,
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Who smallint,
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_part_PR_in_RAT_got_Stance string
)
AS
$$
SELECT
    p.Who,
    tp.inspectedTimepoint,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Checksum,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Who,
    t.AC_part_PR_in_RAT_got_Confidence,
    t.AC_part_PR_in_RAT_got_Stance
FROM
    dw._Who p
JOIN (
    SELECT DISTINCT
        AC_part_PR_in_RAT_got_Who AS positor,
        AC_part_PR_in_RAT_got_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.AC_part_PR_in_RAT_got_Fact
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Who
CROSS JOIN LATERAL
    TABLE(ties.tAC_part_PR_in_RAT_got(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0),
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Who smallint,
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_at_PR_isPlaying_Stance string
)
AS
$$
SELECT
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Who,
    t.ST_at_PR_isPlaying_Confidence,
    t.ST_at_PR_isPlaying_Stance
FROM
    TABLE(ties.rST_at_PR_isPlaying(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.ST_at_PR_isPlaying_Stance = coalesce(assertion, t.ST_at_PR_isPlaying_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tST_at_PR_isPlaying(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_ST_at_PR_isPlaying bigint,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0),
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Who smallint,
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_at_PR_isPlaying_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Who,
    t.ST_at_PR_isPlaying_Confidence,
    t.ST_at_PR_isPlaying_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tST_at_PR_isPlaying(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tST_at_PR_isPlaying(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_ST_at_PR_isPlaying bigint,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0),
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Who smallint,
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_at_PR_isPlaying_Stance string
)
AS
$$
SELECT
    p.Who,
    tp.inspectedTimepoint,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_ID_at,
    t.PR_ID_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Who,
    t.ST_at_PR_isPlaying_Confidence,
    t.ST_at_PR_isPlaying_Stance
FROM
    dw._Who p
JOIN (
    SELECT DISTINCT
        ST_at_PR_isPlaying_Who AS positor,
        ST_at_PR_isPlaying_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.ST_at_PR_isPlaying_Fact
    WHERE
        ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Who
CROSS JOIN LATERAL
    TABLE(ties.tST_at_PR_isPlaying(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_ID_parent smallint,
    AC_ID_child smallint,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT bigint,
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Who smallint,
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_parent_AC_child_PAT_having_Stance string
)
AS
$$
SELECT
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    kPAT_having.Metadata_PAT AS having_Metadata_PAT,
    t.PAT_ID_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Who,
    t.AC_parent_AC_child_PAT_having_Confidence,
    t.AC_parent_AC_child_PAT_having_Stance
FROM
    TABLE(ties.rAC_parent_AC_child_PAT_having(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Stance = coalesce(assertion, t.AC_parent_AC_child_PAT_having_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_ID_parent smallint,
    AC_ID_child smallint,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT bigint,
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Who smallint,
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_parent_AC_child_PAT_having_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.having_PAT_ParentalType,
    t.having_Metadata_PAT,
    t.PAT_ID_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Who,
    t.AC_parent_AC_child_PAT_having_Confidence,
    t.AC_parent_AC_child_PAT_having_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tAC_parent_AC_child_PAT_having(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0),
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Who smallint,
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_content_ST_location_EV_of_Stance string
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
    t.PR_content_ST_location_EV_of_Who,
    t.PR_content_ST_location_EV_of_Confidence,
    t.PR_content_ST_location_EV_of_Stance
FROM
    TABLE(ties.rPR_content_ST_location_EV_of(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Stance = coalesce(assertion, t.PR_content_ST_location_EV_of_Stance)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tPR_content_ST_location_EV_of(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0),
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Who smallint,
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_content_ST_location_EV_of_Stance string
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Who,
    t.PR_content_ST_location_EV_of_Confidence,
    t.PR_content_ST_location_EV_of_Stance
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tPR_content_ST_location_EV_of(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) AS Confidence,
    t.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(ties.tPR_content_ST_location_EV_of(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0),
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Who smallint,
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_content_ST_location_EV_of_Stance string
)
AS
$$
SELECT
    p.Who,
    tp.inspectedTimepoint,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of,
    t.PR_content_ST_location_EV_of_ChangedAt,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Who,
    t.PR_content_ST_location_EV_of_Confidence,
    t.PR_content_ST_location_EV_of_Stance
FROM
    dw._Who p
JOIN (
    SELECT DISTINCT
        PR_content_ST_location_EV_of_Who AS positor,
        PR_content_ST_location_EV_of_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        ties.PR_content_ST_location_EV_of_Fact
    WHERE
        PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Who
CROSS JOIN LATERAL
    TABLE(ties.tPR_content_ST_location_EV_of(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) t
$$
;
