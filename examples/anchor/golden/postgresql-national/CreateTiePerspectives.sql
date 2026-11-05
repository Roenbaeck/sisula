-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" (
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_ID_partner",
    "AC_ID_with",
    "currently_ONG_Pågående",
    "currently_ONG_EQ",
    "currently_Metadata_ONG",
    "ONG_ID_currently"
)
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_partner") AS "latestAC_ID_partner",
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_with") AS "latestAC_ID_with"
        FROM
            ties."AC_partner_AC_with_ONG_currently" t
    ) tie
LEFT JOIN
    knots."eONG_Pågående"(0::smallint) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_partner") AS "latestAC_ID_partner",
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_with") AS "latestAC_ID_with"
        FROM
            ties."AC_partner_AC_with_ONG_currently" t
        WHERE
            t."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eONG_Pågående"(0::smallint) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    ties."pAC_partner_AC_with_ONG_currently"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    knots."eONG_Pågående"(0::smallint) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_partner_AC_with_ONG_currently" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_partner") AS "latestAC_ID_partner",
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_with") AS "latestAC_ID_with"
        FROM
            ties."AC_partner_AC_with_ONG_currently" t
        WHERE
            t."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eONG_Pågående"(equivalent) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_partner_AC_with_ONG_currently" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_partner_AC_with_ONG_currently"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_partner_AC_with_ONG_currently" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_partner_AC_with_ONG_currently"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_partner_AC_with_ONG_currently" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    knots."eONG_Pågående"(equivalent) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" (
    "Metadata_AC_subset_PN_of",
    "AC_ID_subset",
    "PN_ID_of"
)
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
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
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
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    *
FROM
    ties."pAC_subset_PN_of"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_subset_PN_of" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
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
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_subset_PN_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_subset_PN_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_subset_PN_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_subset_PN_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" (
    "Metadata_EV_in_AC_rollsattes",
    "EV_ID_in",
    "AC_ID_rollsattes"
)
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
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
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
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    *
FROM
    ties."pEV_in_AC_rollsattes"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epEV_in_AC_rollsattes" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
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
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elEV_in_AC_rollsattes" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epEV_in_AC_rollsattes"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enEV_in_AC_rollsattes" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epEV_in_AC_rollsattes"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" (
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt",
    "AC_ID_deltar",
    "PR_ID_in",
    "fick_RAT_Checksum",
    "fick_RAT_Betyg",
    "fick_RAT_EQ",
    "fick_Metadata_RAT",
    "RAT_ID_fick"
)
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_deltar_PR_in_RAT_fick_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_deltar",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_deltar_PR_in_RAT_fick" t
    ) tie
LEFT JOIN
    knots."eRAT_Betyg"(0::smallint) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_deltar_PR_in_RAT_fick_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_deltar",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_deltar_PR_in_RAT_fick" t
        WHERE
            t."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eRAT_Betyg"(0::smallint) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" AS
SELECT
    *
FROM
    ties."pAC_deltar_PR_in_RAT_fick"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    knots."eRAT_Betyg"(0::smallint) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_deltar_PR_in_RAT_fick" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_deltar_PR_in_RAT_fick_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_deltar",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_deltar_PR_in_RAT_fick" t
        WHERE
            t."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eRAT_Betyg"(equivalent) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_deltar_PR_in_RAT_fick" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_deltar_PR_in_RAT_fick"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_deltar_PR_in_RAT_fick" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_deltar_PR_in_RAT_fick"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_deltar_PR_in_RAT_fick" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    knots."eRAT_Betyg"(equivalent) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" (
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ChangedAt",
    "ST_ID_at",
    "PR_ID_spelas"
)
AS
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_spelas_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_spelas"
            ) AS "latest"
        FROM
            ties."ST_at_PR_spelas" t
    ) tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_spelas_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_spelas"
            ) AS "latest"
        FROM
            ties."ST_at_PR_spelas" t
        WHERE
            t."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    *
FROM
    ties."pST_at_PR_spelas"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
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
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epST_at_PR_spelas" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_spelas_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_spelas"
            ) AS "latest"
        FROM
            ties."ST_at_PR_spelas" t
        WHERE
            t."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elST_at_PR_spelas" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epST_at_PR_spelas"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enST_at_PR_spelas" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epST_at_PR_spelas"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edST_at_PR_spelas" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
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
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" (
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_ID_förälder",
    "AC_ID_barn",
    "har_PAT_Föräldratyp",
    "har_PAT_EQ",
    "har_Metadata_PAT",
    "PAT_ID_har"
)
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
    knots."ePAT_Föräldratyp"(0::smallint) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
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
    knots."ePAT_Föräldratyp"(0::smallint) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    *
FROM
    ties."pAC_förälder_AC_barn_PAT_har"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_förälder_AC_barn_PAT_har" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
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
    knots."ePAT_Föräldratyp"(equivalent) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_förälder_AC_barn_PAT_har" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_förälder_AC_barn_PAT_har"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_förälder_AC_barn_PAT_har" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_förälder_AC_barn_PAT_har"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" (
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt",
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of"
)
AS
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_innehåll") AS "latestPR_ID_innehåll",
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_plats") AS "latestST_ID_plats"
        FROM
            ties."PR_innehåll_ST_plats_EV_of" t
    ) tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestPR_ID_innehåll"
AND
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestST_ID_plats"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_innehåll") AS "latestPR_ID_innehåll",
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_plats") AS "latestST_ID_plats"
        FROM
            ties."PR_innehåll_ST_plats_EV_of" t
        WHERE
            t."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestPR_ID_innehåll"
AND
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestST_ID_plats"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    *
FROM
    ties."pPR_innehåll_ST_plats_EV_of"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epPR_innehåll_ST_plats_EV_of" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_innehåll") AS "latestPR_ID_innehåll",
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_plats") AS "latestST_ID_plats"
        FROM
            ties."PR_innehåll_ST_plats_EV_of" t
        WHERE
            t."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestPR_ID_innehåll"
AND
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestST_ID_plats"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elPR_innehåll_ST_plats_EV_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    ties."epPR_innehåll_ST_plats_EV_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enPR_innehåll_ST_plats_EV_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    ties."epPR_innehåll_ST_plats_EV_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edPR_innehåll_ST_plats_EV_of" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
$$ LANGUAGE sql STABLE;
