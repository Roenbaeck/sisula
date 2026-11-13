-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` (
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_ID_partner` OPTIONS(description='One of the actors in the partnership.'),
    `AC_ID_with` OPTIONS(description='The other actor in the partnership.'),
    `currently_ONG_Pågående` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).'),
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
    `ONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Pågående` `ONG_currently`
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
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Pågående` `ONG_currently`
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
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`pAC_partner_AC_with_ONG_currently`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Pågående` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` (
    `Metadata_AC_subset_PN_of`,
    `AC_ID_subset` OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.'),
    `PN_ID_of` OPTIONS(description='The person who is the actor.')
)
AS
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    ties.`AC_subset_PN_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    ties.`AC_subset_PN_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`pAC_subset_PN_of`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lEV_in_AC_rollsattes` (
    `Metadata_EV_in_AC_rollsattes`,
    `EV_ID_in` OPTIONS(description='The event the actor was cast in.'),
    `AC_ID_rollsattes` OPTIONS(description='An actor cast in the event.')
)
OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.')
AS
SELECT
    tie.`Metadata_EV_in_AC_rollsattes`,
    tie.`EV_ID_in`,
    tie.`AC_ID_rollsattes`
FROM
    ties.`EV_in_AC_rollsattes` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_rollsattes` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_EV_in_AC_rollsattes`,
    tie.`EV_ID_in`,
    tie.`AC_ID_rollsattes`
FROM
    ties.`EV_in_AC_rollsattes` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nEV_in_AC_rollsattes` AS
SELECT
    *
FROM
    ties.`pEV_in_AC_rollsattes`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_deltar_PR_in_RAT_fick` (
    `Metadata_AC_deltar_PR_in_RAT_fick`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`,
    `AC_ID_deltar` OPTIONS(description='The actor having a part in the program.'),
    `PR_ID_in` OPTIONS(description='The program the actor has a part in.'),
    `fick_RAT_Checksum`,
    `fick_RAT_Betyg` OPTIONS(description='The rating the actor got for the part.'),
    `fick_Metadata_RAT`,
    `RAT_ID_fick` OPTIONS(description='The rating the actor got for the part.')
)
OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.')
AS
SELECT
    tie.`Metadata_AC_deltar_PR_in_RAT_fick`,
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    tie.`AC_ID_deltar`,
    tie.`PR_ID_in`,
    `RAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `RAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `RAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    tie.`RAT_ID_fick`
FROM
    ties.`AC_deltar_PR_in_RAT_fick` tie
LEFT JOIN
    knots.`RAT_Betyg` `RAT_fick`
ON
    `RAT_fick`.`RAT_ID` = tie.`RAT_ID_fick`
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` = max(tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_deltar`,
            tie.`PR_ID_in`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_deltar_PR_in_RAT_fick`,
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    tie.`AC_ID_deltar`,
    tie.`PR_ID_in`,
    `RAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `RAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `RAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    tie.`RAT_ID_fick`
FROM
    ties.`AC_deltar_PR_in_RAT_fick` tie
LEFT JOIN
    knots.`RAT_Betyg` `RAT_fick`
ON
    `RAT_fick`.`RAT_ID` = tie.`RAT_ID_fick`
WHERE
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` = max(tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_deltar`,
            tie.`PR_ID_in`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_deltar_PR_in_RAT_fick` AS
SELECT
    *
FROM
    ties.`pAC_deltar_PR_in_RAT_fick`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_deltar_PR_in_RAT_fick` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_deltar_PR_in_RAT_fick`,
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    tie.`AC_ID_deltar`,
    tie.`PR_ID_in`,
    `RAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `RAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `RAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    tie.`RAT_ID_fick`
FROM
    ties.`AC_deltar_PR_in_RAT_fick` tie
LEFT JOIN
    knots.`RAT_Betyg` `RAT_fick`
ON
    `RAT_fick`.`RAT_ID` = tie.`RAT_ID_fick`
WHERE
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lST_at_PR_spelas` (
    `Metadata_ST_at_PR_spelas`,
    `ST_at_PR_spelas_ChangedAt`,
    `ST_ID_at` OPTIONS(description='The stage where the program is playing.'),
    `PR_ID_spelas` OPTIONS(description='The program playing at the stage.')
)
OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.')
AS
SELECT
    tie.`Metadata_ST_at_PR_spelas`,
    tie.`ST_at_PR_spelas_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_spelas`
FROM
    ties.`ST_at_PR_spelas` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_spelas_ChangedAt` = max(tie.`ST_at_PR_spelas_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_spelas`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_spelas` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_spelas`,
    tie.`ST_at_PR_spelas_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_spelas`
FROM
    ties.`ST_at_PR_spelas` tie
WHERE
    tie.`ST_at_PR_spelas_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_spelas_ChangedAt` = max(tie.`ST_at_PR_spelas_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_spelas`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nST_at_PR_spelas` AS
SELECT
    *
FROM
    ties.`pST_at_PR_spelas`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_spelas` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_spelas`,
    tie.`ST_at_PR_spelas_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_spelas`
FROM
    ties.`ST_at_PR_spelas` tie
WHERE
    tie.`ST_at_PR_spelas_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_förälder_AC_barn_PAT_har` (
    `Metadata_AC_förälder_AC_barn_PAT_har`,
    `AC_ID_förälder` OPTIONS(description='The actor who is the parent.'),
    `AC_ID_barn` OPTIONS(description='The actor who is the child.'),
    `har_PAT_Föräldratyp` OPTIONS(description='The type of parental relationship.'),
    `har_Metadata_PAT`,
    `PAT_ID_har` OPTIONS(description='The type of parental relationship.')
)
OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.')
AS
SELECT
    tie.`Metadata_AC_förälder_AC_barn_PAT_har`,
    tie.`AC_ID_förälder`,
    tie.`AC_ID_barn`,
    `PAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `PAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    tie.`PAT_ID_har`
FROM
    ties.`AC_förälder_AC_barn_PAT_har` tie
LEFT JOIN
    knots.`PAT_Föräldratyp` `PAT_har`
ON
    `PAT_har`.`PAT_ID` = tie.`PAT_ID_har`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_förälder_AC_barn_PAT_har`,
    tie.`AC_ID_förälder`,
    tie.`AC_ID_barn`,
    `PAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `PAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    tie.`PAT_ID_har`
FROM
    ties.`AC_förälder_AC_barn_PAT_har` tie
LEFT JOIN
    knots.`PAT_Föräldratyp` `PAT_har`
ON
    `PAT_har`.`PAT_ID` = tie.`PAT_ID_har`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_förälder_AC_barn_PAT_har` AS
SELECT
    *
FROM
    ties.`pAC_förälder_AC_barn_PAT_har`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lPR_innehåll_ST_plats_EV_of` (
    `Metadata_PR_innehåll_ST_plats_EV_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`,
    `PR_ID_innehåll` OPTIONS(description='The program that made up the content of the event.'),
    `ST_ID_plats` OPTIONS(description='The stage where the event was located.'),
    `EV_ID_of` OPTIONS(description='The event.')
)
OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.')
AS
SELECT
    tie.`Metadata_PR_innehåll_ST_plats_EV_of`,
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    tie.`PR_ID_innehåll`,
    tie.`ST_ID_plats`,
    tie.`EV_ID_of`
FROM
    ties.`PR_innehåll_ST_plats_EV_of` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`PR_ID_innehåll`)
AND
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`ST_ID_plats`)
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_PR_innehåll_ST_plats_EV_of`,
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    tie.`PR_ID_innehåll`,
    tie.`ST_ID_plats`,
    tie.`EV_ID_of`
FROM
    ties.`PR_innehåll_ST_plats_EV_of` tie
WHERE
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`PR_ID_innehåll`)
AND
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`ST_ID_plats`)
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nPR_innehåll_ST_plats_EV_of` AS
SELECT
    *
FROM
    ties.`pPR_innehåll_ST_plats_EV_of`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_innehåll_ST_plats_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_PR_innehåll_ST_plats_EV_of`,
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    tie.`PR_ID_innehåll`,
    tie.`ST_ID_plats`,
    tie.`EV_ID_of`
FROM
    ties.`PR_innehåll_ST_plats_EV_of` tie
WHERE
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
