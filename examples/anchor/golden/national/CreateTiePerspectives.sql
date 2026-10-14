-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" (
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_ID_partner" COMMENT 'One of the actors in the partnership.',
    "AC_ID_with" COMMENT 'The other actor in the partnership.',
    "currently_ONG_Pågående" COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    "currently_ONG_EQ",
    "currently_Metadata_ONG",
    "ONG_ID_currently" COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COPY GRANTS COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
AS
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(0)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = (
        SELECT
            max(sub."AC_partner_AC_with_ONG_currently_ChangedAt")
        FROM
            ties."AC_partner_AC_with_ONG_currently" sub
        WHERE
            sub."AC_ID_partner" = tie."AC_ID_partner"
        OR
            sub."AC_ID_with" = tie."AC_ID_with"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(0)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = (
        SELECT
            max(sub."AC_partner_AC_with_ONG_currently_ChangedAt")
        FROM
            ties."AC_partner_AC_with_ONG_currently" sub
        WHERE
        (
            sub."AC_ID_partner" = tie."AC_ID_partner"
        OR
            sub."AC_ID_with" = tie."AC_ID_with"
        )
        AND
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_partner_AC_with_ONG_currently"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(0)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_partner_AC_with_ONG_currently" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(equivalent)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = (
        SELECT
            max(sub."AC_partner_AC_with_ONG_currently_ChangedAt")
        FROM
            ties."AC_partner_AC_with_ONG_currently" sub
        WHERE
        (
            sub."AC_ID_partner" = tie."AC_ID_partner"
        OR
            sub."AC_ID_with" = tie."AC_ID_with"
        )
        AND
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_partner_AC_with_ONG_currently" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_partner_AC_with_ONG_currently"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_partner_AC_with_ONG_currently" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_partner_AC_with_ONG_currently"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_partner_AC_with_ONG_currently" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(equivalent)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" (
    "Metadata_AC_subset_PN_of",
    "AC_ID_subset" COMMENT 'An actor, a person who performs parts in programs and is cast in events.',
    "PN_ID_of" COMMENT 'The person who is the actor.'
) COPY GRANTS 
AS
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    ties."AC_subset_PN_of" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    ties."AC_subset_PN_of" tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_subset_PN_of"(sysdate()::timestamp_ntz(9)))
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_subset_PN_of" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    ties."AC_subset_PN_of" tie
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_subset_PN_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_subset_PN_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_subset_PN_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_subset_PN_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" (
    "Metadata_EV_in_AC_rollsattes",
    "EV_ID_in" COMMENT 'The event the actor was cast in.',
    "AC_ID_rollsattes" COMMENT 'An actor cast in the event.'
) COPY GRANTS COMMENT = 'The actors that were cast in an event, meaning those who performed at that performance.'
AS
SELECT
    tie."Metadata_EV_in_AC_rollsattes",
    tie."EV_ID_in",
    tie."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_rollsattes",
    tie."EV_ID_in",
    tie."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pEV_in_AC_rollsattes"(sysdate()::timestamp_ntz(9)))
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epEV_in_AC_rollsattes" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_rollsattes",
    tie."EV_ID_in",
    tie."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" tie
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elEV_in_AC_rollsattes" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epEV_in_AC_rollsattes"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enEV_in_AC_rollsattes" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epEV_in_AC_rollsattes"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" (
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt",
    "AC_ID_deltar" COMMENT 'The actor having a part in the program.',
    "PR_ID_in" COMMENT 'The program the actor has a part in.',
    "fick_RAT_Checksum",
    "fick_RAT_Betyg" COMMENT 'The rating the actor got for the part.',
    "fick_RAT_EQ",
    "fick_Metadata_RAT",
    "RAT_ID_fick" COMMENT 'The rating the actor got for the part.'
) COPY GRANTS COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(0)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = (
        SELECT
            max(sub."AC_deltar_PR_in_RAT_fick_ChangedAt")
        FROM
            ties."AC_deltar_PR_in_RAT_fick" sub
        WHERE
            sub."AC_ID_deltar" = tie."AC_ID_deltar"
        AND
            sub."PR_ID_in" = tie."PR_ID_in"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(0)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = (
        SELECT
            max(sub."AC_deltar_PR_in_RAT_fick_ChangedAt")
        FROM
            ties."AC_deltar_PR_in_RAT_fick" sub
        WHERE
            sub."AC_ID_deltar" = tie."AC_ID_deltar"
        AND
            sub."PR_ID_in" = tie."PR_ID_in"
        AND
            sub."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_deltar_PR_in_RAT_fick"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(0)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(equivalent)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = (
        SELECT
            max(sub."AC_deltar_PR_in_RAT_fick_ChangedAt")
        FROM
            ties."AC_deltar_PR_in_RAT_fick" sub
        WHERE
            sub."AC_ID_deltar" = tie."AC_ID_deltar"
        AND
            sub."PR_ID_in" = tie."PR_ID_in"
        AND
            sub."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_deltar_PR_in_RAT_fick"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_deltar_PR_in_RAT_fick"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(equivalent)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" (
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ChangedAt",
    "ST_ID_at" COMMENT 'The stage where the program is playing.',
    "PR_ID_spelas" COMMENT 'The program playing at the stage.'
) COPY GRANTS COMMENT = 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.'
AS
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = (
        SELECT
            max(sub."ST_at_PR_spelas_ChangedAt")
        FROM
            ties."ST_at_PR_spelas" sub
        WHERE
            sub."ST_ID_at" = tie."ST_ID_at"
        AND
            sub."PR_ID_spelas" = tie."PR_ID_spelas"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = (
        SELECT
            max(sub."ST_at_PR_spelas_ChangedAt")
        FROM
            ties."ST_at_PR_spelas" sub
        WHERE
            sub."ST_ID_at" = tie."ST_ID_at"
        AND
            sub."PR_ID_spelas" = tie."PR_ID_spelas"
        AND
            sub."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pST_at_PR_spelas"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epST_at_PR_spelas" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = (
        SELECT
            max(sub."ST_at_PR_spelas_ChangedAt")
        FROM
            ties."ST_at_PR_spelas" sub
        WHERE
            sub."ST_ID_at" = tie."ST_ID_at"
        AND
            sub."PR_ID_spelas" = tie."PR_ID_spelas"
        AND
            sub."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elST_at_PR_spelas" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epST_at_PR_spelas"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enST_at_PR_spelas" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epST_at_PR_spelas"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edST_at_PR_spelas" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" (
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_ID_förälder" COMMENT 'The actor who is the parent.',
    "AC_ID_barn" COMMENT 'The actor who is the child.',
    "har_PAT_Föräldratyp" COMMENT 'The type of parental relationship.',
    "har_PAT_EQ",
    "har_Metadata_PAT",
    "PAT_ID_har" COMMENT 'The type of parental relationship.'
) COPY GRANTS COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie."Metadata_AC_förälder_AC_barn_PAT_har",
    tie."AC_ID_förälder",
    tie."AC_ID_barn",
    "PAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "PAT_har"."PAT_EQ" AS "har_PAT_EQ",
    "PAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    tie."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" tie
LEFT JOIN
    TABLE(knots."ePAT_Föräldratyp"(0)) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_förälder_AC_barn_PAT_har",
    tie."AC_ID_förälder",
    tie."AC_ID_barn",
    "PAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "PAT_har"."PAT_EQ" AS "har_PAT_EQ",
    "PAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    tie."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" tie
LEFT JOIN
    TABLE(knots."ePAT_Föräldratyp"(0)) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_förälder_AC_barn_PAT_har"(sysdate()::timestamp_ntz(9)))
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_förälder_AC_barn_PAT_har" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_förälder_AC_barn_PAT_har",
    tie."AC_ID_förälder",
    tie."AC_ID_barn",
    "PAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "PAT_har"."PAT_EQ" AS "har_PAT_EQ",
    "PAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    tie."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" tie
LEFT JOIN
    TABLE(knots."ePAT_Föräldratyp"(equivalent)) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_förälder_AC_barn_PAT_har" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_förälder_AC_barn_PAT_har"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_förälder_AC_barn_PAT_har" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_förälder_AC_barn_PAT_har"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" (
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt",
    "PR_ID_innehåll" COMMENT 'The program that made up the content of the event.',
    "ST_ID_plats" COMMENT 'The stage where the event was located.',
    "EV_ID_of" COMMENT 'The event.'
) COPY GRANTS COMMENT = 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.'
AS
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = (
        SELECT
            max(sub."PR_innehåll_ST_plats_EV_of_ChangedAt")
        FROM
            ties."PR_innehåll_ST_plats_EV_of" sub
        WHERE
            sub."PR_ID_innehåll" = tie."PR_ID_innehåll"
        OR
            sub."ST_ID_plats" = tie."ST_ID_plats"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = (
        SELECT
            max(sub."PR_innehåll_ST_plats_EV_of_ChangedAt")
        FROM
            ties."PR_innehåll_ST_plats_EV_of" sub
        WHERE
        (
            sub."PR_ID_innehåll" = tie."PR_ID_innehåll"
        OR
            sub."ST_ID_plats" = tie."ST_ID_plats"
        )
        AND
            sub."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pPR_innehåll_ST_plats_EV_of"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = (
        SELECT
            max(sub."PR_innehåll_ST_plats_EV_of_ChangedAt")
        FROM
            ties."PR_innehåll_ST_plats_EV_of" sub
        WHERE
        (
            sub."PR_ID_innehåll" = tie."PR_ID_innehåll"
        OR
            sub."ST_ID_plats" = tie."ST_ID_plats"
        )
        AND
            sub."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epPR_innehåll_ST_plats_EV_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epPR_innehåll_ST_plats_EV_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
