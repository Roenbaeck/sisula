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
    "currently_ONG_Ongoing",
    "currently_Metadata_ONG",
    "ONG_ID_currently"
)
AS
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
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
    knots."ONG_Ongoing" "ONG_currently"
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
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
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
    knots."ONG_Ongoing" "ONG_currently"
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
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    knots."ONG_Ongoing" "ONG_currently"
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
    "Metadata_AC_subset_PN_of" bigint,
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_wasCast" (
    "Metadata_EV_in_AC_wasCast",
    "EV_ID_in",
    "AC_ID_wasCast"
)
AS
SELECT
    tie."Metadata_EV_in_AC_wasCast",
    tie."EV_ID_in",
    tie."AC_ID_wasCast"
FROM
    ties."EV_in_AC_wasCast" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_wasCast" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_wasCast",
    tie."EV_ID_in",
    tie."AC_ID_wasCast"
FROM
    ties."EV_in_AC_wasCast" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_wasCast" AS
SELECT
    *
FROM
    ties."pEV_in_AC_wasCast"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_part_PR_in_RAT_got" (
    "Metadata_AC_part_PR_in_RAT_got",
    "AC_part_PR_in_RAT_got_ChangedAt",
    "AC_ID_part",
    "PR_ID_in",
    "got_RAT_Checksum",
    "got_RAT_Rating",
    "got_Metadata_RAT",
    "RAT_ID_got"
)
AS
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_part_PR_in_RAT_got_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_part",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_part_PR_in_RAT_got" t
    ) tie
LEFT JOIN
    knots."RAT_Rating" "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_part_PR_in_RAT_got_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_part",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_part_PR_in_RAT_got" t
        WHERE
            t."AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."RAT_Rating" "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_part_PR_in_RAT_got" AS
SELECT
    *
FROM
    ties."pAC_part_PR_in_RAT_got"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    ties."AC_part_PR_in_RAT_got" tie
LEFT JOIN
    knots."RAT_Rating" "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_isPlaying" (
    "Metadata_ST_at_PR_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt",
    "ST_ID_at",
    "PR_ID_isPlaying"
)
AS
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_isPlaying_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_isPlaying"
            ) AS "latest"
        FROM
            ties."ST_at_PR_isPlaying" t
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_isPlaying" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_isPlaying_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_isPlaying"
            ) AS "latest"
        FROM
            ties."ST_at_PR_isPlaying" t
        WHERE
            t."ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_isPlaying" AS
SELECT
    *
FROM
    ties."pST_at_PR_isPlaying"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_isPlaying" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    ties."ST_at_PR_isPlaying" tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_parent_AC_child_PAT_having" (
    "Metadata_AC_parent_AC_child_PAT_having",
    "AC_ID_parent",
    "AC_ID_child",
    "having_PAT_ParentalType",
    "having_Metadata_PAT",
    "PAT_ID_having"
)
AS
SELECT
    tie."Metadata_AC_parent_AC_child_PAT_having",
    tie."AC_ID_parent",
    tie."AC_ID_child",
    "PAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    ties."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    knots."PAT_ParentalType" "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" bigint,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_parent_AC_child_PAT_having",
    tie."AC_ID_parent",
    tie."AC_ID_child",
    "PAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    ties."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    knots."PAT_ParentalType" "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_parent_AC_child_PAT_having" AS
SELECT
    *
FROM
    ties."pAC_parent_AC_child_PAT_having"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_content_ST_location_EV_of" (
    "Metadata_PR_content_ST_location_EV_of",
    "PR_content_ST_location_EV_of_ChangedAt",
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of"
)
AS
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_content") AS "latestPR_ID_content",
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_location") AS "latestST_ID_location"
        FROM
            ties."PR_content_ST_location_EV_of" t
    ) tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestPR_ID_content"
AND
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestST_ID_location"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_content") AS "latestPR_ID_content",
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_location") AS "latestST_ID_location"
        FROM
            ties."PR_content_ST_location_EV_of" t
        WHERE
            t."PR_content_ST_location_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestPR_ID_content"
AND
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestST_ID_location"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_content_ST_location_EV_of" AS
SELECT
    *
FROM
    ties."pPR_content_ST_location_EV_of"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_content_ST_location_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    ties."PR_content_ST_location_EV_of" tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
