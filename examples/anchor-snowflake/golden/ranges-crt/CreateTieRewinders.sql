-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection.
--
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
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
    ties.AC_partner_AC_with_ONG_currently_Fact
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ID bigint,
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
    ties.AC_partner_AC_with_ONG_currently_Fact
WHERE
    AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp_ntz(3),
    AC_partner_AC_with_ONG_currently_Who smallint,
    AC_partner_AC_with_ONG_currently_Confidence decimal(7,3),
    AC_partner_AC_with_ONG_currently_Stance string
)
AS
$$
SELECT
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ID,
    AC_partner_AC_with_ONG_currently_PositedAt,
    AC_partner_AC_with_ONG_currently_Who,
    AC_partner_AC_with_ONG_currently_Confidence,
    AC_partner_AC_with_ONG_currently_Stance
FROM
    ties.AC_partner_AC_with_ONG_currently_Meta
WHERE
    AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
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
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Who,
    a.AC_partner_AC_with_ONG_currently_Confidence,
    a.AC_partner_AC_with_ONG_currently_Stance
FROM
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Meta(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
AND
    a.AC_partner_AC_with_ONG_currently_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently bigint,
    AC_partner_AC_with_ONG_currently_ID bigint,
    AC_ID_partner smallint, 
    AC_ID_with smallint, 
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
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Who,
    a.AC_partner_AC_with_ONG_currently_Confidence,
    a.AC_partner_AC_with_ONG_currently_Stance
FROM
    TABLE(ties.fAC_partner_AC_with_ONG_currently_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_partner_AC_with_ONG_currently_Meta(positingTimepoint)) a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
AND
    a.AC_partner_AC_with_ONG_currently_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_partner_AC_with_ONG_currently_ID
        ORDER BY a.AC_partner_AC_with_ONG_currently_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_ID bigint,
    AC_subset_PN_of_PositedAt timestamp_ntz(3),
    AC_subset_PN_of_Who smallint,
    AC_subset_PN_of_Confidence decimal(7,3),
    AC_subset_PN_of_Stance string
)
AS
$$
SELECT
    Metadata_AC_subset_PN_of,
    AC_subset_PN_of_ID,
    AC_subset_PN_of_PositedAt,
    AC_subset_PN_of_Who,
    AC_subset_PN_of_Confidence,
    AC_subset_PN_of_Stance
FROM
    ties.AC_subset_PN_of_Meta
WHERE
    AC_subset_PN_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
    positor smallint,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_ID bigint,
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
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Who,
    a.AC_subset_PN_of_Confidence,
    a.AC_subset_PN_of_Stance
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    TABLE(ties.rAC_subset_PN_of_Meta(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
AND
    a.AC_subset_PN_of_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
    positor smallint,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_subset_PN_of bigint,
    AC_subset_PN_of_ID bigint,
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
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Who,
    a.AC_subset_PN_of_Confidence,
    a.AC_subset_PN_of_Stance
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    TABLE(ties.rAC_subset_PN_of_Meta(positingTimepoint)) a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
AND
    a.AC_subset_PN_of_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_subset_PN_of_ID
        ORDER BY a.AC_subset_PN_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_ID bigint,
    EV_in_AC_wasCast_PositedAt timestamp_ntz(3),
    EV_in_AC_wasCast_Who smallint,
    EV_in_AC_wasCast_Confidence decimal(7,3),
    EV_in_AC_wasCast_Stance string
)
AS
$$
SELECT
    Metadata_EV_in_AC_wasCast,
    EV_in_AC_wasCast_ID,
    EV_in_AC_wasCast_PositedAt,
    EV_in_AC_wasCast_Who,
    EV_in_AC_wasCast_Confidence,
    EV_in_AC_wasCast_Stance
FROM
    ties.EV_in_AC_wasCast_Meta
WHERE
    EV_in_AC_wasCast_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast (
    positor smallint,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_ID bigint,
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
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Who,
    a.EV_in_AC_wasCast_Confidence,
    a.EV_in_AC_wasCast_Stance
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    TABLE(ties.rEV_in_AC_wasCast_Meta(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
AND
    a.EV_in_AC_wasCast_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_wasCast (
    positor smallint,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast bigint,
    EV_in_AC_wasCast_ID bigint,
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
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Who,
    a.EV_in_AC_wasCast_Confidence,
    a.EV_in_AC_wasCast_Stance
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    TABLE(ties.rEV_in_AC_wasCast_Meta(positingTimepoint)) a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
AND
    a.EV_in_AC_wasCast_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.EV_in_AC_wasCast_ID
        ORDER BY a.EV_in_AC_wasCast_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
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
    ties.AC_part_PR_in_RAT_got_Fact
WHERE
    AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ID bigint,
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
    ties.AC_part_PR_in_RAT_got_Fact
WHERE
    AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ID bigint,
    AC_part_PR_in_RAT_got_PositedAt timestamp_ntz(3),
    AC_part_PR_in_RAT_got_Who smallint,
    AC_part_PR_in_RAT_got_Confidence decimal(7,3),
    AC_part_PR_in_RAT_got_Stance string
)
AS
$$
SELECT
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ID,
    AC_part_PR_in_RAT_got_PositedAt,
    AC_part_PR_in_RAT_got_Who,
    AC_part_PR_in_RAT_got_Confidence,
    AC_part_PR_in_RAT_got_Stance
FROM
    ties.AC_part_PR_in_RAT_got_Meta
WHERE
    AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ID bigint,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
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
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Who,
    a.AC_part_PR_in_RAT_got_Confidence,
    a.AC_part_PR_in_RAT_got_Stance
FROM
    TABLE(ties.rAC_part_PR_in_RAT_got_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_part_PR_in_RAT_got_Meta(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
AND
    a.AC_part_PR_in_RAT_got_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got bigint,
    AC_part_PR_in_RAT_got_ID bigint,
    AC_ID_part smallint, 
    PR_ID_in number(10,0), 
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
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Who,
    a.AC_part_PR_in_RAT_got_Confidence,
    a.AC_part_PR_in_RAT_got_Stance
FROM
    TABLE(ties.fAC_part_PR_in_RAT_got_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rAC_part_PR_in_RAT_got_Meta(positingTimepoint)) a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
AND
    a.AC_part_PR_in_RAT_got_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_part_PR_in_RAT_got_ID
        ORDER BY a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
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
    ties.ST_at_PR_isPlaying_Fact
WHERE
    ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    ST_at_PR_isPlaying_ID bigint,
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
    ties.ST_at_PR_isPlaying_Fact
WHERE
    ST_at_PR_isPlaying_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ID bigint,
    ST_at_PR_isPlaying_PositedAt timestamp_ntz(3),
    ST_at_PR_isPlaying_Who smallint,
    ST_at_PR_isPlaying_Confidence decimal(7,3),
    ST_at_PR_isPlaying_Stance string
)
AS
$$
SELECT
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ID,
    ST_at_PR_isPlaying_PositedAt,
    ST_at_PR_isPlaying_Who,
    ST_at_PR_isPlaying_Confidence,
    ST_at_PR_isPlaying_Stance
FROM
    ties.ST_at_PR_isPlaying_Meta
WHERE
    ST_at_PR_isPlaying_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ID bigint,
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
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Who,
    a.ST_at_PR_isPlaying_Confidence,
    a.ST_at_PR_isPlaying_Stance
FROM
    TABLE(ties.rST_at_PR_isPlaying_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rST_at_PR_isPlaying_Meta(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
AND
    a.ST_at_PR_isPlaying_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying bigint,
    ST_at_PR_isPlaying_ID bigint,
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
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Who,
    a.ST_at_PR_isPlaying_Confidence,
    a.ST_at_PR_isPlaying_Stance
FROM
    TABLE(ties.fST_at_PR_isPlaying_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rST_at_PR_isPlaying_Meta(positingTimepoint)) a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
AND
    a.ST_at_PR_isPlaying_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.ST_at_PR_isPlaying_ID
        ORDER BY a.ST_at_PR_isPlaying_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_ID bigint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Who smallint,
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_parent_AC_child_PAT_having_Stance string
)
AS
$$
SELECT
    Metadata_AC_parent_AC_child_PAT_having,
    AC_parent_AC_child_PAT_having_ID,
    AC_parent_AC_child_PAT_having_PositedAt,
    AC_parent_AC_child_PAT_having_Who,
    AC_parent_AC_child_PAT_having_Confidence,
    AC_parent_AC_child_PAT_having_Stance
FROM
    ties.AC_parent_AC_child_PAT_having_Meta
WHERE
    AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having (
    positor smallint,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_ID bigint,
    AC_ID_parent smallint, 
    AC_ID_child smallint, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Who smallint,
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_parent_AC_child_PAT_having_Stance string
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
    a.AC_parent_AC_child_PAT_having_Who,
    a.AC_parent_AC_child_PAT_having_Confidence,
    a.AC_parent_AC_child_PAT_having_Stance
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    TABLE(ties.rAC_parent_AC_child_PAT_having_Meta(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
AND
    a.AC_parent_AC_child_PAT_having_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fAC_parent_AC_child_PAT_having (
    positor smallint,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having bigint,
    AC_parent_AC_child_PAT_having_ID bigint,
    AC_ID_parent smallint, 
    AC_ID_child smallint, 
    PAT_ID_having tinyint,
    AC_parent_AC_child_PAT_having_PositedAt timestamp_ntz(3),
    AC_parent_AC_child_PAT_having_Who smallint,
    AC_parent_AC_child_PAT_having_Confidence decimal(7,3),
    AC_parent_AC_child_PAT_having_Stance string
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
    a.AC_parent_AC_child_PAT_having_Who,
    a.AC_parent_AC_child_PAT_having_Confidence,
    a.AC_parent_AC_child_PAT_having_Stance
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    TABLE(ties.rAC_parent_AC_child_PAT_having_Meta(positingTimepoint)) a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
AND
    a.AC_parent_AC_child_PAT_having_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.AC_parent_AC_child_PAT_having_ID
        ORDER BY a.AC_parent_AC_child_PAT_having_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
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
    ties.PR_content_ST_location_EV_of_Fact
WHERE
    PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of_Fact (
    changingTimepoint datetime
)
RETURNS TABLE (
    PR_content_ST_location_EV_of_ID bigint,
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
    ties.PR_content_ST_location_EV_of_Fact
WHERE
    PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Meta (
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ID bigint,
    PR_content_ST_location_EV_of_PositedAt timestamp_ntz(3),
    PR_content_ST_location_EV_of_Who smallint,
    PR_content_ST_location_EV_of_Confidence decimal(7,3),
    PR_content_ST_location_EV_of_Stance string
)
AS
$$
SELECT
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ID,
    PR_content_ST_location_EV_of_PositedAt,
    PR_content_ST_location_EV_of_Who,
    PR_content_ST_location_EV_of_Confidence,
    PR_content_ST_location_EV_of_Stance
FROM
    ties.PR_content_ST_location_EV_of_Meta
WHERE
    PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
$$
;
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ID bigint,
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
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Who,
    a.PR_content_ST_location_EV_of_Confidence,
    a.PR_content_ST_location_EV_of_Stance
FROM
    TABLE(ties.rPR_content_ST_location_EV_of_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rPR_content_ST_location_EV_of_Meta(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
AND
    a.PR_content_ST_location_EV_of_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of (
    positor smallint,
    changingTimepoint datetime,
    positingTimepoint timestamp_ntz(3)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of bigint,
    PR_content_ST_location_EV_of_ID bigint,
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
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Who,
    a.PR_content_ST_location_EV_of_Confidence,
    a.PR_content_ST_location_EV_of_Stance
FROM
    TABLE(ties.fPR_content_ST_location_EV_of_Fact(changingTimepoint)) p 
JOIN
    TABLE(ties.rPR_content_ST_location_EV_of_Meta(positingTimepoint)) a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
AND
    a.PR_content_ST_location_EV_of_Who = positor
QUALIFY
    row_number() OVER (
        PARTITION BY p.PR_content_ST_location_EV_of_ID
        ORDER BY a.PR_content_ST_location_EV_of_PositedAt DESC
    ) = 1
$$
;
