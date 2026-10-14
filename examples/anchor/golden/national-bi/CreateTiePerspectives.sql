-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
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
FROM
    TABLE(ties."rAC_partner_AC_with_ONG_currently"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Reliability" = 1
AND
    t."AC_partner_AC_with_ONG_currently_ID" = (
        SELECT
            sub."AC_partner_AC_with_ONG_currently_ID"
        FROM
            TABLE(ties."rAC_partner_AC_with_ONG_currently"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            (
                sub."AC_ID_partner" = t."AC_ID_partner"
            OR
                sub."AC_ID_with" = t."AC_ID_with"
            )
        ORDER BY
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            sub."AC_partner_AC_with_ONG_currently_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
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
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" int,
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" datetime,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
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
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_subset_PN_of_ID" int,
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_PositedAt" datetime,
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
    TABLE(ties."rAC_subset_PN_of"(
        positingTimepoint::datetime
    )) t
WHERE
    t."AC_subset_PN_of_Reliability" = 1
AND
    t."AC_subset_PN_of_ID" = (
        SELECT
            sub."AC_subset_PN_of_ID"
        FROM
            TABLE(ties."rAC_subset_PN_of"(
                positingTimepoint::datetime
            )) sub
        WHERE
            (
                sub."AC_ID_subset" = t."AC_ID_subset"
            OR
                sub."PN_ID_of" = t."PN_ID_of"
            )
        ORDER BY
            sub."AC_subset_PN_of_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_subset_PN_of"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_subset_PN_of_ID" int,
    "Metadata_AC_subset_PN_of" int,
    "AC_subset_PN_of_PositedAt" datetime,
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
    TABLE(ties."tAC_subset_PN_of"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_subset_PN_of"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_rollsattes" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "EV_in_AC_rollsattes_ID" int,
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_PositedAt" datetime,
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
    TABLE(ties."rEV_in_AC_rollsattes"(
        positingTimepoint::datetime
    )) t
WHERE
    t."EV_in_AC_rollsattes_Reliability" = 1
AND
    t."EV_in_AC_rollsattes_ID" = (
        SELECT
            sub."EV_in_AC_rollsattes_ID"
        FROM
            TABLE(ties."rEV_in_AC_rollsattes"(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."EV_ID_in" = t."EV_ID_in"
        AND
            sub."AC_ID_rollsattes" = t."AC_ID_rollsattes"
        ORDER BY
            sub."EV_in_AC_rollsattes_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tEV_in_AC_rollsattes"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "EV_in_AC_rollsattes_ID" int,
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_in_AC_rollsattes_PositedAt" datetime,
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
    TABLE(ties."tEV_in_AC_rollsattes"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tEV_in_AC_rollsattes"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."tAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
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
FROM
    TABLE(ties."rAC_deltar_PR_in_RAT_fick"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."AC_deltar_PR_in_RAT_fick_Reliability" = 1
AND
    t."AC_deltar_PR_in_RAT_fick_ID" = (
        SELECT
            sub."AC_deltar_PR_in_RAT_fick_ID"
        FROM
            TABLE(ties."rAC_deltar_PR_in_RAT_fick"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_ID_deltar" = t."AC_ID_deltar"
        AND
            sub."PR_ID_in" = t."PR_ID_in"
        ORDER BY
            sub."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC,
            sub."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
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
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" int,
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_PositedAt" datetime,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
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
    TABLE(ties."tAC_deltar_PR_in_RAT_fick"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties."tST_at_PR_spelas" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
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
    TABLE(ties."rST_at_PR_spelas"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."ST_at_PR_spelas_Reliability" = 1
AND
    t."ST_at_PR_spelas_ID" = (
        SELECT
            sub."ST_at_PR_spelas_ID"
        FROM
            TABLE(ties."rST_at_PR_spelas"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_ID_at" = t."ST_ID_at"
        AND
            sub."PR_ID_spelas" = t."PR_ID_spelas"
        ORDER BY
            sub."ST_at_PR_spelas_ChangedAt" DESC,
            sub."ST_at_PR_spelas_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tST_at_PR_spelas"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
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
    TABLE(ties."tST_at_PR_spelas"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tST_at_PR_spelas"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_spelas_ID" int,
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_at_PR_spelas_PositedAt" datetime,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
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
    TABLE(ties."tST_at_PR_spelas"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties."tAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
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
FROM
    TABLE(ties."rAC_förälder_AC_barn_PAT_har"(
        positingTimepoint::datetime
    )) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."AC_förälder_AC_barn_PAT_har_Reliability" = 1
AND
    t."AC_förälder_AC_barn_PAT_har_ID" = (
        SELECT
            sub."AC_förälder_AC_barn_PAT_har_ID"
        FROM
            TABLE(ties."rAC_förälder_AC_barn_PAT_har"(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_ID_förälder" = t."AC_ID_förälder"
        AND
            sub."AC_ID_barn" = t."AC_ID_barn"
        AND
            sub."PAT_ID_har" = t."PAT_ID_har"
        ORDER BY
            sub."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_förälder_AC_barn_PAT_har_ID" int,
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_förälder_AC_barn_PAT_har_PositedAt" datetime,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
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
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_förälder_AC_barn_PAT_har"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."tPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
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
    TABLE(ties."rPR_innehåll_ST_plats_EV_of"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) t
WHERE
    t."PR_innehåll_ST_plats_EV_of_Reliability" = 1
AND
    t."PR_innehåll_ST_plats_EV_of_ID" = (
        SELECT
            sub."PR_innehåll_ST_plats_EV_of_ID"
        FROM
            TABLE(ties."rPR_innehåll_ST_plats_EV_of"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            (
                sub."PR_ID_innehåll" = t."PR_ID_innehåll"
            OR
                sub."ST_ID_plats" = t."ST_ID_plats"
            )
        ORDER BY
            sub."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
            sub."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
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
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    ))
;
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" int,
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_PositedAt" datetime,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
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
    TABLE(ties."tPR_innehåll_ST_plats_EV_of"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) t
WHERE
    t."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
