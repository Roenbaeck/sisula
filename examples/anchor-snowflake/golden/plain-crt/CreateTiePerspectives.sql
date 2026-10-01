-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_partner_AC_with_ONG_currently (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string,
     int
)
AS
$$
SELECT
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS ONG_Ongoing,
    t.ONG_ID_currently
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion,
    t.
FROM
    TABLE(public.rAC_partner_AC_with_ONG_currently(
        positor,
        changingTimepoint
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Assertion = coalesce(assertion, t.AC_partner_AC_with_ONG_currently_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.ONG_Ongoing,
    t.ONG_ID_currently
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Positor tinyint,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_partner_AC_with_ONG_currently_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.ONG_Ongoing,
    t.ONG_ID_currently
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Positor,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_partner_AC_with_ONG_currently_Assertion,
    t.
FROM
    public._Positor p
JOIN (
    SELECT DISTINCT
        AC_partner_AC_with_ONG_currently_Positor AS positor,
        AC_partner_AC_with_ONG_currently_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public.AC_partner_AC_with_ONG_currently_Posit
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor
CROSS JOIN LATERAL
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_subset_PN_of (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    AC_ID_subset int,
    PN_ID_of int
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string,
     int
)
AS
$$
SELECT
    t.AC_ID_subset,
    t.PN_ID_of
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Positor,
    t.AC_subset_PN_of_Reliability,
    t.AC_subset_PN_of_Assertion,
    t.
FROM
    TABLE(public.rAC_subset_PN_of(
        positor,
        :,
        positingTimepoint::datetime
    )) t
WHERE
    t.AC_subset_PN_of_Assertion = coalesce(assertion, t.AC_subset_PN_of_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_subset_PN_of AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_subset_PN_of(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    AC_ID_subset int,
    PN_ID_of int
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Positor tinyint,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_subset_PN_of_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.AC_ID_subset,
    t.PN_ID_of
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Positor,
    t.AC_subset_PN_of_Reliability,
    t.AC_subset_PN_of_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_subset_PN_of(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_subset_PN_of AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_subset_PN_of(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tEV_in_AC_wasCast (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    EV_ID_in int,
    AC_ID_wasCast int
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string,
     int
)
AS
$$
SELECT
    t.EV_ID_in,
    t.AC_ID_wasCast
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Positor,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_in_AC_wasCast_Assertion,
    t.
FROM
    TABLE(public.rEV_in_AC_wasCast(
        positor,
        :,
        positingTimepoint::datetime
    )) t
WHERE
    t.EV_in_AC_wasCast_Assertion = coalesce(assertion, t.EV_in_AC_wasCast_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tEV_in_AC_wasCast(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    EV_ID_in int,
    AC_ID_wasCast int
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Positor tinyint,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_in_AC_wasCast_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.EV_ID_in,
    t.AC_ID_wasCast
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Positor,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_in_AC_wasCast_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tEV_in_AC_wasCast(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tEV_in_AC_wasCast(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_part_PR_in_RAT_got (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string,
     int
)
AS
$$
SELECT
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Rating AS RAT_Rating,
    t.RAT_ID_got
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion,
    t.
FROM
    TABLE(public.rAC_part_PR_in_RAT_got(
        positor,
        changingTimepoint
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Assertion = coalesce(assertion, t.AC_part_PR_in_RAT_got_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_part_PR_in_RAT_got(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    t.RAT_Rating,
    t.RAT_ID_got
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_part_PR_in_RAT_got(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_part_PR_in_RAT_got(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Positor tinyint,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_part_PR_in_RAT_got_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.AC_ID_part,
    t.PR_ID_in,
    t.RAT_Rating,
    t.RAT_ID_got
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Positor,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_part_PR_in_RAT_got_Assertion,
    t.
FROM
    public._Positor p
JOIN (
    SELECT DISTINCT
        AC_part_PR_in_RAT_got_Positor AS positor,
        AC_part_PR_in_RAT_got_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public.AC_part_PR_in_RAT_got_Posit
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor
CROSS JOIN LATERAL
    TABLE(public.tAC_part_PR_in_RAT_got(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tST_at_PR_isPlaying (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    ST_ID_at int,
    PR_ID_isPlaying int
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string,
     int
)
AS
$$
SELECT
    t.ST_ID_at,
    t.PR_ID_isPlaying
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion,
    t.
FROM
    TABLE(public.rST_at_PR_isPlaying(
        positor,
        changingTimepoint
        positingTimepoint::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_Assertion = coalesce(assertion, t.ST_at_PR_isPlaying_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tST_at_PR_isPlaying(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tST_at_PR_isPlaying(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tST_at_PR_isPlaying(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    inspectedTimepoint timestamp_ntz(9),
    ST_ID_at int,
    PR_ID_isPlaying int
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Positor tinyint,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_at_PR_isPlaying_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
    tp.inspectedTimepoint,
    t.ST_ID_at,
    t.PR_ID_isPlaying
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Positor,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_at_PR_isPlaying_Assertion,
    t.
FROM
    public._Positor p
JOIN (
    SELECT DISTINCT
        ST_at_PR_isPlaying_Positor AS positor,
        ST_at_PR_isPlaying_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint
    FROM
        public.ST_at_PR_isPlaying_Posit
    WHERE
        ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.Positor
CROSS JOIN LATERAL
    TABLE(public.tST_at_PR_isPlaying(
        tp.positor,
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tAC_parent_AC_child_PAT_having (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    PAT_ParentalType varchar(42),
    PAT_ID_having tinyint
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string,
     int
)
AS
$$
SELECT
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS PAT_ParentalType,
    t.PAT_ID_having
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Positor,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_parent_AC_child_PAT_having_Assertion,
    t.
FROM
    TABLE(public.rAC_parent_AC_child_PAT_having(
        positor,
        :,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Assertion = coalesce(assertion, t.AC_parent_AC_child_PAT_having_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_parent_AC_child_PAT_having(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    AC_ID_parent int,
    AC_ID_child int,
    PAT_ParentalType varchar(42),
    PAT_ID_having tinyint
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Positor tinyint,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_parent_AC_child_PAT_having_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.PAT_ParentalType,
    t.PAT_ID_having
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Positor,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_parent_AC_child_PAT_having_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_parent_AC_child_PAT_having(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tAC_parent_AC_child_PAT_having(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tPR_content_ST_location_EV_of (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
RETURNS TABLE (
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string,
     int
)
AS
$$
SELECT
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion,
    t.
FROM
    TABLE(public.rPR_content_ST_location_EV_of(
        positor,
        :,
        positingTimepoint::datetime
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Assertion = coalesce(assertion, t.PR_content_ST_location_EV_of_Assertion)
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tPR_content_ST_location_EV_of(
        p.Positor,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Positor tinyint,
    Reliability decimal(5,2),
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Positor tinyint,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_content_ST_location_EV_of_Assertion string,
     int
)
AS
$$
SELECT
    p.Positor,
     AS Reliability,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Positor,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_content_ST_location_EV_of_Assertion,
    t.
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tPR_content_ST_location_EV_of(
        p.Positor,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of AS
SELECT
    p.Positor,
     AS Reliability,
    t.*
FROM
    public._Positor p
CROSS JOIN LATERAL
    TABLE(public.tPR_content_ST_location_EV_of(
        p.Positor,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) t
;
