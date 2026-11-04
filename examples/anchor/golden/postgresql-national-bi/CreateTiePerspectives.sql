-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM
        ties."rAC_partner_AC_with_ONG_currently"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_partner_AC_with_ONG_currently_Reliability" = 1
) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_subset_PN_of_ID" integer,
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_subset"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY r."PN_ID_of"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM
        ties."rAC_subset_PN_of"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_subset_PN_of_Reliability" = 1
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" AS
SELECT
    *
FROM
    ties."tAC_subset_PN_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_subset_PN_of_ID" integer,
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    ties."tAC_subset_PN_of"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    *
FROM
    ties."tAC_subset_PN_of"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_rollsattes" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_in_AC_rollsattes_ID" integer,
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    t."EV_in_AC_rollsattes_ID",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."EV_ID_in",
                r."AC_ID_rollsattes"
            ORDER BY
                r."EV_in_AC_rollsattes_PositedAt" DESC,
                r."EV_in_AC_rollsattes_ID" DESC
        ) AS "latest"
    FROM
        ties."rEV_in_AC_rollsattes"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_in_AC_rollsattes_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" AS
SELECT
    *
FROM
    ties."tEV_in_AC_rollsattes"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_in_AC_rollsattes_ID" integer,
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    t."EV_in_AC_rollsattes_ID",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM
    ties."tEV_in_AC_rollsattes"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    *
FROM
    ties."tEV_in_AC_rollsattes"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."tAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    t."AC_deltar_PR_in_RAT_fick_ID",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_deltar",
                r."PR_ID_in"
            ORDER BY
                r."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC,
                r."AC_deltar_PR_in_RAT_fick_PositedAt" DESC,
                r."AC_deltar_PR_in_RAT_fick_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_deltar_PR_in_RAT_fick"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_deltar_PR_in_RAT_fick_Reliability" = 1
) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" AS
SELECT
    *
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    t."AC_deltar_PR_in_RAT_fick_ID",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" AS
SELECT
    *
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    t."AC_deltar_PR_in_RAT_fick_ID",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."tST_at_PR_spelas" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    t."ST_at_PR_spelas_ID",
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Reliability",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_spelas"
            ORDER BY
                r."ST_at_PR_spelas_ChangedAt" DESC,
                r."ST_at_PR_spelas_PositedAt" DESC,
                r."ST_at_PR_spelas_ID" DESC
        ) AS "latest"
    FROM
        ties."rST_at_PR_spelas"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_at_PR_spelas_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" AS
SELECT
    *
FROM
    ties."tST_at_PR_spelas"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    t."ST_at_PR_spelas_ID",
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Reliability",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
    ties."tST_at_PR_spelas"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    *
FROM
    ties."tST_at_PR_spelas"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    t."ST_at_PR_spelas_ID",
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Reliability",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
    ties."tST_at_PR_spelas"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."tAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    t."AC_förälder_AC_barn_PAT_har_ID",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_förälder",
                r."AC_ID_barn",
                r."PAT_ID_har"
            ORDER BY
                r."AC_förälder_AC_barn_PAT_har_PositedAt" DESC,
                r."AC_förälder_AC_barn_PAT_har_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_förälder_AC_barn_PAT_har"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_förälder_AC_barn_PAT_har_Reliability" = 1
) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" AS
SELECT
    *
FROM
    ties."tAC_förälder_AC_barn_PAT_har"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    t."AC_förälder_AC_barn_PAT_har_ID",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    t."har_PAT_Föräldratyp",
    t."har_Metadata_PAT",
    t."PAT_ID_har"
FROM
    ties."tAC_förälder_AC_barn_PAT_har"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    *
FROM
    ties."tAC_förälder_AC_barn_PAT_har"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."tPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_innehåll_ST_plats_EV_of_ID",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_innehåll"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY r."ST_ID_plats"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestST_ID_plats"
    FROM
        ties."rPR_innehåll_ST_plats_EV_of"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."PR_innehåll_ST_plats_EV_of_Reliability" = 1
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" AS
SELECT
    *
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_innehåll_ST_plats_EV_of_ID",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    *
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_innehåll_ST_plats_EV_of_ID",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
