-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_partner_AC_with_ONG_currently` (
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_ID_partner` OPTIONS(description='One of the actors in the partnership.'),
    `AC_ID_with` OPTIONS(description='The other actor in the partnership.'),
    `currently_ONG_Ongoing` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).'),
    `currently_Metadata_ONG`,
    `ONG_ID_currently` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).')
)
OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.')
AS
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    public.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    public.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_partner`)
AND
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_with`)
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    public.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    public.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_partner`)
AND
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_with`)
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    public.`pAC_partner_AC_with_ONG_currently`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    public.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    public.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_subset_PN_of` (
    `Metadata_AC_subset_PN_of`,
    `AC_ID_subset` OPTIONS(description='The actor.'),
    `PN_ID_of` OPTIONS(description='The person who is the actor.')
)
OPTIONS(description='Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.')
AS
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    public.`AC_subset_PN_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    public.`AC_subset_PN_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    public.`pAC_subset_PN_of`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_in_AC_wasCast` (
    `Metadata_EV_in_AC_wasCast`,
    `EV_ID_in` OPTIONS(description='The event the actor was cast in.'),
    `AC_ID_wasCast` OPTIONS(description='An actor cast in the event.')
)
OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.')
AS
SELECT
    tie.`Metadata_EV_in_AC_wasCast`,
    tie.`EV_ID_in`,
    tie.`AC_ID_wasCast`
FROM
    public.`EV_in_AC_wasCast` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_EV_in_AC_wasCast`,
    tie.`EV_ID_in`,
    tie.`AC_ID_wasCast`
FROM
    public.`EV_in_AC_wasCast` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_in_AC_wasCast` AS
SELECT
    *
FROM
    public.`pEV_in_AC_wasCast`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_part_PR_in_RAT_got` (
    `Metadata_AC_part_PR_in_RAT_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_ID_part` OPTIONS(description='The actor having a part in the program.'),
    `PR_ID_in` OPTIONS(description='The program the actor has a part in.'),
    `got_RAT_Rating` OPTIONS(description='The rating the actor got for the part.'),
    `got_Metadata_RAT`,
    `RAT_ID_got` OPTIONS(description='The rating the actor got for the part.')
)
OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.')
AS
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    public.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    public.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_part_PR_in_RAT_got_ChangedAt` = max(tie.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_part`,
            tie.`PR_ID_in`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    public.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    public.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    tie.`AC_part_PR_in_RAT_got_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_part_PR_in_RAT_got_ChangedAt` = max(tie.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_part`,
            tie.`PR_ID_in`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    public.`pAC_part_PR_in_RAT_got`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    public.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    public.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    tie.`AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lST_at_PR_isPlaying` (
    `Metadata_ST_at_PR_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_ID_at` OPTIONS(description='The stage where the program is playing.'),
    `PR_ID_isPlaying` OPTIONS(description='The program playing at the stage.')
)
OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.')
AS
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    public.`ST_at_PR_isPlaying` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_isPlaying_ChangedAt` = max(tie.`ST_at_PR_isPlaying_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_isPlaying`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    public.`ST_at_PR_isPlaying` tie
WHERE
    tie.`ST_at_PR_isPlaying_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_isPlaying_ChangedAt` = max(tie.`ST_at_PR_isPlaying_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_isPlaying`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nST_at_PR_isPlaying` AS
SELECT
    *
FROM
    public.`pST_at_PR_isPlaying`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    public.`ST_at_PR_isPlaying` tie
WHERE
    tie.`ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_parent_AC_child_PAT_having` (
    `Metadata_AC_parent_AC_child_PAT_having`,
    `AC_ID_parent` OPTIONS(description='The actor who is the parent.'),
    `AC_ID_child` OPTIONS(description='The actor who is the child.'),
    `having_PAT_ParentalType` OPTIONS(description='The type of parental relationship.'),
    `having_Metadata_PAT`,
    `PAT_ID_having` OPTIONS(description='The type of parental relationship.')
)
OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.')
AS
SELECT
    tie.`Metadata_AC_parent_AC_child_PAT_having`,
    tie.`AC_ID_parent`,
    tie.`AC_ID_child`,
    `PAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `PAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    tie.`PAT_ID_having`
FROM
    public.`AC_parent_AC_child_PAT_having` tie
LEFT JOIN
    public.`PAT_ParentalType` `PAT_having`
ON
    `PAT_having`.`PAT_ID` = tie.`PAT_ID_having`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_parent_AC_child_PAT_having`,
    tie.`AC_ID_parent`,
    tie.`AC_ID_child`,
    `PAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `PAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    tie.`PAT_ID_having`
FROM
    public.`AC_parent_AC_child_PAT_having` tie
LEFT JOIN
    public.`PAT_ParentalType` `PAT_having`
ON
    `PAT_having`.`PAT_ID` = tie.`PAT_ID_having`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    public.`pAC_parent_AC_child_PAT_having`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_content_ST_location_EV_of` (
    `Metadata_PR_content_ST_location_EV_of`,
    `PR_ID_content` OPTIONS(description='The program that made up the content of the event.'),
    `ST_ID_location` OPTIONS(description='The stage where the event was located.'),
    `EV_ID_of` OPTIONS(description='The event.')
)
OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.')
AS
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    public.`PR_content_ST_location_EV_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    public.`PR_content_ST_location_EV_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    public.`pPR_content_ST_location_EV_of`(CAST(current_datetime() AS datetime))
;
