-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID ,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime
)
AS
$$
SELECT
    AC_partner_AC_with_ONG_currently_ID,
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
FROM
    ties.AC_partner_AC_with_ONG_currently_Posit
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID ,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime
)
AS
$$
SELECT
    AC_partner_AC_with_ONG_currently_ID,
    AC_ID_partner,
    AC_ID_with,
    ONG_ID_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt
FROM
    ties.AC_partner_AC_with_ONG_currently_Posit
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ID ,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ID,
    AC_partner_AC_with_ONG_currently_PositedAt,
    AC_partner_AC_with_ONG_currently_Reliability
FROM
    ties.AC_partner_AC_with_ONG_currently_Annex
WHERE
    AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ID ,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Reliability
FROM
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Annex(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ID ,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
    ONG_ID_currently tinyint,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_partner_AC_with_ONG_currently_PositedAt datetime,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Reliability
FROM
    TABLE(ties.fAC_partner_AC_with_ONG_currently_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Annex(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_ID ,
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_subset_PN_of,
    AC_subset_PN_of_ID,
    AC_subset_PN_of_PositedAt,
    AC_subset_PN_of_Reliability
FROM
    ties.AC_subset_PN_of_Annex
WHERE
    AC_subset_PN_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_ID ,
    AC_ID_subset smallint, 
    PN_ID_of bigint, 
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Reliability
FROM
    ties.AC_subset_PN_of_Posit p
JOIN
    TABLE(ties.rAC_subset_PN_of_Annex(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_subset_PN_of_ID ,
    AC_ID_subset smallint, 
    PN_ID_of bigint, 
    AC_subset_PN_of_PositedAt datetime,
    AC_subset_PN_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Reliability
FROM
    ties.AC_subset_PN_of_Posit p
JOIN
    TABLE(ties.rAC_subset_PN_of_Annex(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_ID ,
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_EV_in_AC_wasCast,
    EV_in_AC_wasCast_ID,
    EV_in_AC_wasCast_PositedAt,
    EV_in_AC_wasCast_Reliability
FROM
    ties.EV_in_AC_wasCast_Annex
WHERE
    EV_in_AC_wasCast_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_ID ,
    EV_ID_in numeric(12,0), 
    AC_ID_wasCast smallint, 
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Reliability
FROM
    ties.EV_in_AC_wasCast_Posit p
JOIN
    TABLE(ties.rEV_in_AC_wasCast_Annex(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_wasCast (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_in_AC_wasCast_ID ,
    EV_ID_in numeric(12,0), 
    AC_ID_wasCast smallint, 
    EV_in_AC_wasCast_PositedAt datetime,
    EV_in_AC_wasCast_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Reliability
FROM
    ties.EV_in_AC_wasCast_Posit p
JOIN
    TABLE(ties.rEV_in_AC_wasCast_Annex(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID ,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime
)
AS
$$
SELECT
    AC_part_PR_in_RAT_got_ID,
    AC_ID_part,
    PR_ID_in,
    RAT_ID_got,
    AC_part_PR_in_RAT_got_ChangedAt
FROM
    ties.AC_part_PR_in_RAT_got_Posit
WHERE
    AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID ,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime
)
AS
$$
SELECT
    AC_part_PR_in_RAT_got_ID,
    AC_ID_part,
    PR_ID_in,
    RAT_ID_got,
    AC_part_PR_in_RAT_got_ChangedAt
FROM
    ties.AC_part_PR_in_RAT_got_Posit
WHERE
    AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ID ,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ID,
    AC_part_PR_in_RAT_got_PositedAt,
    AC_part_PR_in_RAT_got_Reliability
FROM
    ties.AC_part_PR_in_RAT_got_Annex
WHERE
    AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ID ,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Reliability
FROM
    TABLE(ties.rAC_part_PR_in_RAT_got_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_part_PR_in_RAT_got_Annex(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ID ,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
    RAT_ID_got tinyint,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_part_PR_in_RAT_got_PositedAt datetime,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Reliability
FROM
    TABLE(ties.fAC_part_PR_in_RAT_got_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_part_PR_in_RAT_got_Annex(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID ,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime
)
AS
$$
SELECT
    ST_at_PR_isPlaying_ID,
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
FROM
    ties.ST_at_PR_isPlaying_Posit
WHERE
    ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ID ,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime
)
AS
$$
SELECT
    ST_at_PR_isPlaying_ID,
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
FROM
    ties.ST_at_PR_isPlaying_Posit
WHERE
    ST_at_PR_isPlaying_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ID ,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ID,
    ST_at_PR_isPlaying_PositedAt,
    ST_at_PR_isPlaying_Reliability
FROM
    ties.ST_at_PR_isPlaying_Annex
WHERE
    ST_at_PR_isPlaying_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ID ,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Reliability
FROM
    TABLE(ties.rST_at_PR_isPlaying_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rST_at_PR_isPlaying_Annex(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ID ,
    ST_ID_at int, 
    PR_ID_isPlaying number(10,0), 
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_at_PR_isPlaying_PositedAt datetime,
    ST_at_PR_isPlaying_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Reliability
FROM
    TABLE(ties.fST_at_PR_isPlaying_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rST_at_PR_isPlaying_Annex(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_ID ,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_AC_parent_AC_child_PAT_having,
    AC_parent_AC_child_PAT_having_ID,
    AC_parent_AC_child_PAT_having_PositedAt,
    AC_parent_AC_child_PAT_having_Reliability
FROM
    ties.AC_parent_AC_child_PAT_having_Annex
WHERE
    AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_ID ,
    AC_ID_parent smallint, 
    AC_ID_child smallint, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Reliability
FROM
    ties.AC_parent_AC_child_PAT_having_Posit p
JOIN
    TABLE(ties.rAC_parent_AC_child_PAT_having_Annex(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_parent_AC_child_PAT_having (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_parent_AC_child_PAT_having_ID ,
    AC_ID_parent smallint, 
    AC_ID_child smallint, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt datetime,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Reliability
FROM
    ties.AC_parent_AC_child_PAT_having_Posit p
JOIN
    TABLE(ties.rAC_parent_AC_child_PAT_having_Annex(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID ,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime
)
AS
$$
SELECT
    PR_content_ST_location_EV_of_ID,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of,
    PR_content_ST_location_EV_of_ChangedAt
FROM
    ties.PR_content_ST_location_EV_of_Posit
WHERE
    PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of_Posit (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID ,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime
)
AS
$$
SELECT
    PR_content_ST_location_EV_of_ID,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of,
    PR_content_ST_location_EV_of_ChangedAt
FROM
    ties.PR_content_ST_location_EV_of_Posit
WHERE
    PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Annex (
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ID ,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ID,
    PR_content_ST_location_EV_of_PositedAt,
    PR_content_ST_location_EV_of_Reliability
FROM
    ties.PR_content_ST_location_EV_of_Annex
WHERE
    PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ID ,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Reliability
FROM
    TABLE(ties.rPR_content_ST_location_EV_of_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rPR_content_ST_location_EV_of_Annex(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of (
    changingTimepoint datetime,
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ID ,
    PR_ID_content number(10,0), 
    ST_ID_location int, 
    EV_ID_of numeric(12,0), 
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_content_ST_location_EV_of_PositedAt datetime,
    PR_content_ST_location_EV_of_Reliability decimal(5,2)
)
AS
$$
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Reliability
FROM
    TABLE(ties.fPR_content_ST_location_EV_of_Posit(changingTimepoint)) p 
JOIN
    TABLE(ties.rPR_content_ST_location_EV_of_Annex(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
