-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently (
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner COMMENT 'One of the actors in the partnership.',
    AC_ID_with COMMENT 'The other actor in the partnership.',
    ONG_Ongoing COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    ONG_ID_currently COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COPY GRANTS COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
AS
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently sub
        WHERE
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently sub
        WHERE
        (
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
        )
        AND
            sub.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_partner_AC_with_ONG_currently(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner int,
    AC_ID_with int,
    ONG_Ongoing varchar(3),
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_subset_PN_of (
    AC_ID_subset COMMENT 'The actor.',
    PN_ID_of COMMENT 'The person who is the actor.'
) COPY GRANTS COMMENT = 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.'
AS
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_ID_subset int,
    PN_ID_of int
)
AS
$$
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_subset_PN_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_subset_PN_of(sysdate()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast (
    EV_ID_in COMMENT 'The event the actor was cast in.',
    AC_ID_wasCast COMMENT 'An actor cast in the event.'
) COPY GRANTS COMMENT = 'The actors that were cast in an event, meaning those who performed at that performance.'
AS
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    EV_ID_in int,
    AC_ID_wasCast int
)
AS
$$
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pEV_in_AC_wasCast(sysdate()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got (
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part COMMENT 'The actor having a part in the program.',
    PR_ID_in COMMENT 'The program the actor has a part in.',
    RAT_Rating COMMENT 'The rating the actor got for the part.',
    RAT_ID_got COMMENT 'The rating the actor got for the part.'
) COPY GRANTS COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            public.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            public.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        AND
            sub.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_part_PR_in_RAT_got(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part int,
    PR_ID_in int,
    RAT_Rating varchar(42),
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying (
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at COMMENT 'The stage where the program is playing.',
    PR_ID_isPlaying COMMENT 'The program playing at the stage.'
) COPY GRANTS COMMENT = 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.'
AS
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            public.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            public.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        AND
            sub.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pST_at_PR_isPlaying(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying int
)
AS
$$
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having (
    AC_ID_parent COMMENT 'The actor who is the parent.',
    AC_ID_child COMMENT 'The actor who is the child.',
    PAT_ParentalType COMMENT 'The type of parental relationship.',
    PAT_ID_having COMMENT 'The type of parental relationship.'
) COPY GRANTS COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS PAT_ParentalType,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    public.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    AC_ID_parent int,
    AC_ID_child int,
    PAT_ParentalType varchar(42),
    PAT_ID_having tinyint
)
AS
$$
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS PAT_ParentalType,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    public.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pAC_parent_AC_child_PAT_having(sysdate()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of (
    PR_ID_content COMMENT 'The program that made up the content of the event.',
    ST_ID_location COMMENT 'The stage where the event was located.',
    EV_ID_of COMMENT 'The event.'
) COPY GRANTS COMMENT = 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.'
AS
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    PR_ID_content int,
    ST_ID_location int,
    EV_ID_of int
)
AS
$$
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of COPY GRANTS AS
SELECT
    *
FROM
    TABLE(public.pPR_content_ST_location_EV_of(sysdate()::timestamp_ntz(9)))
;
