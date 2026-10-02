-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public.tAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    kONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    t.ONG_ID_currently
FROM
    TABLE(public.rAC_partner_AC_with_ONG_currently(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.ONG_Ongoing kONG_currently
ON
    kONG_currently.ONG_ID = t.ONG_ID_currently
WHERE
    t.AC_partner_AC_with_ONG_currently_Reliability = 1
AND
    t.AC_partner_AC_with_ONG_currently_ID = (
        SELECT
            sub.AC_partner_AC_with_ONG_currently_ID
        FROM
            TABLE(public.rAC_partner_AC_with_ONG_currently(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            (
                sub.AC_ID_partner = t.AC_ID_partner
            OR
                sub.AC_ID_with = t.AC_ID_with
            )
        ORDER BY
            sub.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
            sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID int,
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2),
    AC_ID_partner int,
    AC_ID_with int,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    t.AC_partner_AC_with_ONG_currently_ID,
    t.Metadata_AC_partner_AC_with_ONG_currently,
    t.AC_partner_AC_with_ONG_currently_ChangedAt,
    t.AC_partner_AC_with_ONG_currently_PositedAt,
    t.AC_partner_AC_with_ONG_currently_Reliability,
    t.AC_ID_partner,
    t.AC_ID_with,
    t.currently_ONG_Ongoing,
    t.currently_Metadata_ONG,
    t.ONG_ID_currently
FROM
    TABLE(public.tAC_partner_AC_with_ONG_currently(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION public.tAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID int,
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    t.AC_subset_PN_of_ID,
    t.Metadata_AC_subset_PN_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Reliability,
    t.AC_ID_subset,
    t.PN_ID_of
FROM
    TABLE(public.rAC_subset_PN_of(
        positingTimepoint::datetime
    )) t
WHERE
    t.AC_subset_PN_of_Reliability = 1
AND
    t.AC_subset_PN_of_ID = (
        SELECT
            sub.AC_subset_PN_of_ID
        FROM
            TABLE(public.rAC_subset_PN_of(
                positingTimepoint::datetime
            )) sub
        WHERE
            (
                sub.AC_ID_subset = t.AC_ID_subset
            OR
                sub.PN_ID_of = t.PN_ID_of
            )
        ORDER BY
            sub.AC_subset_PN_of_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_subset_PN_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_subset_PN_of_ID int,
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2),
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    t.AC_subset_PN_of_ID,
    t.Metadata_AC_subset_PN_of,
    t.AC_subset_PN_of_PositedAt,
    t.AC_subset_PN_of_Reliability,
    t.AC_ID_subset,
    t.PN_ID_of
FROM
    TABLE(public.tAC_subset_PN_of(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_subset_PN_of(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.tEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID int,
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    t.EV_in_AC_wasCast_ID,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_ID_in,
    t.AC_ID_wasCast
FROM
    TABLE(public.rEV_in_AC_wasCast(
        positingTimepoint::datetime
    )) t
WHERE
    t.EV_in_AC_wasCast_Reliability = 1
AND
    t.EV_in_AC_wasCast_ID = (
        SELECT
            sub.EV_in_AC_wasCast_ID
        FROM
            TABLE(public.rEV_in_AC_wasCast(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID_in = t.EV_ID_in
        AND
            sub.AC_ID_wasCast = t.AC_ID_wasCast
        ORDER BY
            sub.EV_in_AC_wasCast_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tEV_in_AC_wasCast(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    EV_in_AC_wasCast_ID int,
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2),
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    t.EV_in_AC_wasCast_ID,
    t.Metadata_EV_in_AC_wasCast,
    t.EV_in_AC_wasCast_PositedAt,
    t.EV_in_AC_wasCast_Reliability,
    t.EV_ID_in,
    t.AC_ID_wasCast
FROM
    TABLE(public.tEV_in_AC_wasCast(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tEV_in_AC_wasCast(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.tAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    kRAT_got.Metadata_RAT AS got_Metadata_RAT,
    t.RAT_ID_got
FROM
    TABLE(public.rAC_part_PR_in_RAT_got(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = t.RAT_ID_got
WHERE
    t.AC_part_PR_in_RAT_got_Reliability = 1
AND
    t.AC_part_PR_in_RAT_got_ID = (
        SELECT
            sub.AC_part_PR_in_RAT_got_ID
        FROM
            TABLE(public.rAC_part_PR_in_RAT_got(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_ID_part = t.AC_ID_part
        AND
            sub.PR_ID_in = t.PR_ID_in
        ORDER BY
            sub.AC_part_PR_in_RAT_got_ChangedAt DESC,
            sub.AC_part_PR_in_RAT_got_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID int,
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2),
    AC_ID_part int,
    PR_ID_in int,
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    t.AC_part_PR_in_RAT_got_ID,
    t.Metadata_AC_part_PR_in_RAT_got,
    t.AC_part_PR_in_RAT_got_ChangedAt,
    t.AC_part_PR_in_RAT_got_PositedAt,
    t.AC_part_PR_in_RAT_got_Reliability,
    t.AC_ID_part,
    t.PR_ID_in,
    t.got_RAT_Rating,
    t.got_Metadata_RAT,
    t.RAT_ID_got
FROM
    TABLE(public.tAC_part_PR_in_RAT_got(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION public.tST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(public.rST_at_PR_isPlaying(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_Reliability = 1
AND
    t.ST_at_PR_isPlaying_ID = (
        SELECT
            sub.ST_at_PR_isPlaying_ID
        FROM
            TABLE(public.rST_at_PR_isPlaying(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.ST_ID_at = t.ST_ID_at
        AND
            sub.PR_ID_isPlaying = t.PR_ID_isPlaying
        ORDER BY
            sub.ST_at_PR_isPlaying_ChangedAt DESC,
            sub.ST_at_PR_isPlaying_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tST_at_PR_isPlaying(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(public.tST_at_PR_isPlaying(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tST_at_PR_isPlaying(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID int,
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2),
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    t.ST_at_PR_isPlaying_ID,
    t.Metadata_ST_at_PR_isPlaying,
    t.ST_at_PR_isPlaying_ChangedAt,
    t.ST_at_PR_isPlaying_PositedAt,
    t.ST_at_PR_isPlaying_Reliability,
    t.ST_ID_at,
    t.PR_ID_isPlaying
FROM
    TABLE(public.tST_at_PR_isPlaying(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION public.tAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID int,
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT int,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    t.AC_parent_AC_child_PAT_having_ID,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_ID_parent,
    t.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    kPAT_having.Metadata_PAT AS having_Metadata_PAT,
    t.PAT_ID_having
FROM
    TABLE(public.rAC_parent_AC_child_PAT_having(
        positingTimepoint::datetime
    )) t
LEFT JOIN
    public.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = t.PAT_ID_having
WHERE
    t.AC_parent_AC_child_PAT_having_Reliability = 1
AND
    t.AC_parent_AC_child_PAT_having_ID = (
        SELECT
            sub.AC_parent_AC_child_PAT_having_ID
        FROM
            TABLE(public.rAC_parent_AC_child_PAT_having(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.AC_ID_parent = t.AC_ID_parent
        AND
            sub.AC_ID_child = t.AC_ID_child
        AND
            sub.PAT_ID_having = t.PAT_ID_having
        ORDER BY
            sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_parent_AC_child_PAT_having(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_parent_AC_child_PAT_having_ID int,
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2),
    AC_ID_parent int,
    AC_ID_child int,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT int,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    t.AC_parent_AC_child_PAT_having_ID,
    t.Metadata_AC_parent_AC_child_PAT_having,
    t.AC_parent_AC_child_PAT_having_PositedAt,
    t.AC_parent_AC_child_PAT_having_Reliability,
    t.AC_ID_parent,
    t.AC_ID_child,
    t.having_PAT_ParentalType,
    t.having_Metadata_PAT,
    t.PAT_ID_having
FROM
    TABLE(public.tAC_parent_AC_child_PAT_having(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tAC_parent_AC_child_PAT_having(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.tPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID int,
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(public.rPR_content_ST_location_EV_of(
        positingTimepoint::datetime
    )) t
WHERE
    t.PR_content_ST_location_EV_of_Reliability = 1
AND
    t.PR_content_ST_location_EV_of_ID = (
        SELECT
            sub.PR_content_ST_location_EV_of_ID
        FROM
            TABLE(public.rPR_content_ST_location_EV_of(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub.EV_ID_of = t.EV_ID_of
        ORDER BY
            sub.PR_content_ST_location_EV_of_PositedAt DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tPR_content_ST_location_EV_of(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID int,
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2),
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    t.PR_content_ST_location_EV_of_ID,
    t.Metadata_PR_content_ST_location_EV_of,
    t.PR_content_ST_location_EV_of_PositedAt,
    t.PR_content_ST_location_EV_of_Reliability,
    t.PR_ID_content,
    t.ST_ID_location,
    t.EV_ID_of
FROM
    TABLE(public.tPR_content_ST_location_EV_of(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.tPR_content_ST_location_EV_of(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
