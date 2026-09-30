-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner COMMENT 'One of the actors in the partnership.',
    AC_ID_with COMMENT 'The other actor in the partnership.',
    currently_ONG_Ongoing COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    currently_Metadata_ONG,
    ONG_ID_currently COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently sub
        WHERE
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently sub
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
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    TABLE(ties.pAC_partner_AC_with_ONG_currently(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_partner_AC_with_ONG_currently int,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime,
    AC_ID_partner smallint,
    AC_ID_with smallint,
    currently_ONG_Ongoing varchar(3),
    currently_Metadata_ONG int,
    ONG_ID_currently tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of (
    Metadata_AC_subset_PN_of,
    AC_ID_subset COMMENT 'An actor, a person who performs parts in programs and is cast in events.',
    PN_ID_of COMMENT 'The person who is the actor.'
) 
AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_subset_PN_of int,
    AC_ID_subset smallint,
    PN_ID_of bigint
)
AS
$$
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    TABLE(ties.pAC_subset_PN_of(current_timestamp()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast (
    Metadata_EV_in_AC_wasCast,
    EV_ID_in COMMENT 'The event the actor was cast in.',
    AC_ID_wasCast COMMENT 'An actor cast in the event.'
) COMMENT = 'The actors that were cast in an event, meaning those who performed at that performance.'
AS
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    ties.EV_in_AC_wasCast tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_EV_in_AC_wasCast int,
    EV_ID_in numeric(12,0),
    AC_ID_wasCast smallint
)
AS
$$
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    ties.EV_in_AC_wasCast tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    TABLE(ties.pEV_in_AC_wasCast(current_timestamp()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got (
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part COMMENT 'The actor having a part in the program.',
    PR_ID_in COMMENT 'The program the actor has a part in.',
    got_RAT_Checksum,
    got_RAT_Rating COMMENT 'The rating the actor got for the part.',
    got_Metadata_RAT,
    RAT_ID_got COMMENT 'The rating the actor got for the part.'
) COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Checksum AS got_RAT_Checksum,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    knots.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            ties.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Checksum AS got_RAT_Checksum,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    knots.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            ties.AC_part_PR_in_RAT_got sub
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
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    TABLE(ties.pAC_part_PR_in_RAT_got(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_part_PR_in_RAT_got int,
    AC_part_PR_in_RAT_got_ChangedAt datetime,
    AC_ID_part smallint,
    PR_ID_in number(10,0),
    got_RAT_Checksum numeric(19,0),
    got_RAT_Rating varchar(42),
    got_Metadata_RAT int,
    RAT_ID_got tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Checksum AS got_RAT_Checksum,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    knots.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying (
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at COMMENT 'The stage where the program is playing.',
    PR_ID_isPlaying COMMENT 'The program playing at the stage.'
) COMMENT = 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.'
AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            ties.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            ties.ST_at_PR_isPlaying sub
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
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    TABLE(ties.pST_at_PR_isPlaying(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_ST_at_PR_isPlaying int,
    ST_at_PR_isPlaying_ChangedAt datetime,
    ST_ID_at int,
    PR_ID_isPlaying number(10,0)
)
AS
$$
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having (
    Metadata_AC_parent_AC_child_PAT_having,
    AC_ID_parent COMMENT 'The actor who is the parent.',
    AC_ID_child COMMENT 'The actor who is the child.',
    having_PAT_ParentalType COMMENT 'The type of parental relationship.',
    having_Metadata_PAT,
    PAT_ID_having COMMENT 'The type of parental relationship.'
) COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    ties.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    knots.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_AC_parent_AC_child_PAT_having int,
    AC_ID_parent smallint,
    AC_ID_child smallint,
    having_PAT_ParentalType varchar(42),
    having_Metadata_PAT int,
    PAT_ID_having tinyint
)
AS
$$
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    ties.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    knots.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    TABLE(ties.pAC_parent_AC_child_PAT_having(current_timestamp()::timestamp_ntz(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of (
    Metadata_PR_content_ST_location_EV_of,
    PR_content_ST_location_EV_of_ChangedAt,
    PR_ID_content COMMENT 'The program that made up the content of the event.',
    ST_ID_location COMMENT 'The stage where the event was located.',
    EV_ID_of COMMENT 'The event.'
) COMMENT = 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.'
AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt = (
        SELECT
            max(sub.PR_content_ST_location_EV_of_ChangedAt)
        FROM
            ties.PR_content_ST_location_EV_of sub
        WHERE
            sub.PR_ID_content = tie.PR_ID_content
        OR
            sub.ST_ID_location = tie.ST_ID_location
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt = (
        SELECT
            max(sub.PR_content_ST_location_EV_of_ChangedAt)
        FROM
            ties.PR_content_ST_location_EV_of sub
        WHERE
        (
            sub.PR_ID_content = tie.PR_ID_content
        OR
            sub.ST_ID_location = tie.ST_ID_location
        )
        AND
            sub.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    TABLE(ties.pPR_content_ST_location_EV_of(current_timestamp()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
RETURNS TABLE (
    Metadata_PR_content_ST_location_EV_of int,
    PR_content_ST_location_EV_of_ChangedAt datetime,
    PR_ID_content number(10,0),
    ST_ID_location int,
    EV_ID_of numeric(12,0)
)
AS
$$
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
$$
;
