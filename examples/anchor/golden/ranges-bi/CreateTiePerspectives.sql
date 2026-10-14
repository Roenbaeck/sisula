-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp_ntz(3),
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Confidence",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    TABLE(ties."rAC_partner_AC_with_ONG_currently"(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Confidence" = 1
AND
    t."AC_partner_AC_with_ONG_currently_ID" = (
        SELECT
            sub."AC_partner_AC_with_ONG_currently_ID"
        FROM
            TABLE(ties."rAC_partner_AC_with_ONG_currently"(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
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
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp_ntz(3),
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Confidence",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp_ntz(3),
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Confidence",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    TABLE(ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "AC_subset_PN_of_ID" bigint,
    "Metadata_AC_subset_PN_of" bigint,
    "AC_subset_PN_of_PositedAt" timestamp_ntz(3),
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Confidence",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    TABLE(ties."rAC_subset_PN_of"(
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t."AC_subset_PN_of_Confidence" = 1
AND
    t."AC_subset_PN_of_ID" = (
        SELECT
            sub."AC_subset_PN_of_ID"
        FROM
            TABLE(ties."rAC_subset_PN_of"(
                positingTimepoint::timestamp_ntz(3)
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
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_subset_PN_of_ID" bigint,
    "Metadata_AC_subset_PN_of" bigint,
    "AC_subset_PN_of_PositedAt" timestamp_ntz(3),
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Confidence",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    TABLE(ties."tAC_subset_PN_of"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_subset_PN_of"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_wasCast" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "EV_in_AC_wasCast_ID" bigint,
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_in_AC_wasCast_PositedAt" timestamp_ntz(3),
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    t."EV_in_AC_wasCast_ID",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Confidence",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM
    TABLE(ties."rEV_in_AC_wasCast"(
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t."EV_in_AC_wasCast_Confidence" = 1
AND
    t."EV_in_AC_wasCast_ID" = (
        SELECT
            sub."EV_in_AC_wasCast_ID"
        FROM
            TABLE(ties."rEV_in_AC_wasCast"(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub."EV_ID_in" = t."EV_ID_in"
        AND
            sub."AC_ID_wasCast" = t."AC_ID_wasCast"
        ORDER BY
            sub."EV_in_AC_wasCast_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lEV_in_AC_wasCast" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tEV_in_AC_wasCast"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_wasCast" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "EV_in_AC_wasCast_ID" bigint,
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_in_AC_wasCast_PositedAt" timestamp_ntz(3),
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    t."EV_in_AC_wasCast_ID",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Confidence",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM
    TABLE(ties."tEV_in_AC_wasCast"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nEV_in_AC_wasCast" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tEV_in_AC_wasCast"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."tAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" bigint,
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp_ntz(3),
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_ID_part" smallint,
    "PR_ID_in" number(10,0),
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" tinyint
)
AS
$$
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Confidence",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got"
FROM
    TABLE(ties."rAC_part_PR_in_RAT_got"(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."AC_part_PR_in_RAT_got_Confidence" = 1
AND
    t."AC_part_PR_in_RAT_got_ID" = (
        SELECT
            sub."AC_part_PR_in_RAT_got_ID"
        FROM
            TABLE(ties."rAC_part_PR_in_RAT_got"(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub."AC_ID_part" = t."AC_ID_part"
        AND
            sub."PR_ID_in" = t."PR_ID_in"
        ORDER BY
            sub."AC_part_PR_in_RAT_got_ChangedAt" DESC,
            sub."AC_part_PR_in_RAT_got_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lAC_part_PR_in_RAT_got" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_part_PR_in_RAT_got"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" bigint,
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp_ntz(3),
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_ID_part" smallint,
    "PR_ID_in" number(10,0),
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" tinyint
)
AS
$$
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Confidence",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
    t."RAT_ID_got"
FROM
    TABLE(ties."tAC_part_PR_in_RAT_got"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_part_PR_in_RAT_got" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_part_PR_in_RAT_got"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" bigint,
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ChangedAt" datetime,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp_ntz(3),
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_ID_part" smallint,
    "PR_ID_in" number(10,0),
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" tinyint
)
AS
$$
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Confidence",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
    t."RAT_ID_got"
FROM
    TABLE(ties."tAC_part_PR_in_RAT_got"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t."AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties."tST_at_PR_isPlaying" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" bigint,
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" datetime,
    "ST_at_PR_isPlaying_PositedAt" timestamp_ntz(3),
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_ID_at" int,
    "PR_ID_isPlaying" number(10,0)
)
AS
$$
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Confidence",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
    TABLE(ties."rST_at_PR_isPlaying"(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t."ST_at_PR_isPlaying_Confidence" = 1
AND
    t."ST_at_PR_isPlaying_ID" = (
        SELECT
            sub."ST_at_PR_isPlaying_ID"
        FROM
            TABLE(ties."rST_at_PR_isPlaying"(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub."ST_ID_at" = t."ST_ID_at"
        AND
            sub."PR_ID_isPlaying" = t."PR_ID_isPlaying"
        ORDER BY
            sub."ST_at_PR_isPlaying_ChangedAt" DESC,
            sub."ST_at_PR_isPlaying_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lST_at_PR_isPlaying" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tST_at_PR_isPlaying"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pST_at_PR_isPlaying" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" bigint,
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" datetime,
    "ST_at_PR_isPlaying_PositedAt" timestamp_ntz(3),
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_ID_at" int,
    "PR_ID_isPlaying" number(10,0)
)
AS
$$
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Confidence",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
    TABLE(ties."tST_at_PR_isPlaying"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nST_at_PR_isPlaying" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tST_at_PR_isPlaying"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."dST_at_PR_isPlaying" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" bigint,
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" datetime,
    "ST_at_PR_isPlaying_PositedAt" timestamp_ntz(3),
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_ID_at" int,
    "PR_ID_isPlaying" number(10,0)
)
AS
$$
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Confidence",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
    TABLE(ties."tST_at_PR_isPlaying"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t."ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
CREATE OR REPLACE FUNCTION ties."tAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "AC_parent_AC_child_PAT_having_ID" bigint,
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp_ntz(3),
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" bigint,
    "PAT_ID_having" tinyint
)
AS
$$
SELECT
    t."AC_parent_AC_child_PAT_having_ID",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Confidence",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having"
FROM
    TABLE(ties."rAC_parent_AC_child_PAT_having"(
        positingTimepoint::timestamp_ntz(3)
    )) t
LEFT JOIN
    knots."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."AC_parent_AC_child_PAT_having_Confidence" = 1
AND
    t."AC_parent_AC_child_PAT_having_ID" = (
        SELECT
            sub."AC_parent_AC_child_PAT_having_ID"
        FROM
            TABLE(ties."rAC_parent_AC_child_PAT_having"(
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub."AC_ID_parent" = t."AC_ID_parent"
        AND
            sub."AC_ID_child" = t."AC_ID_child"
        AND
            sub."PAT_ID_having" = t."PAT_ID_having"
        ORDER BY
            sub."AC_parent_AC_child_PAT_having_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lAC_parent_AC_child_PAT_having" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_parent_AC_child_PAT_having"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_parent_AC_child_PAT_having_ID" bigint,
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp_ntz(3),
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" bigint,
    "PAT_ID_having" tinyint
)
AS
$$
SELECT
    t."AC_parent_AC_child_PAT_having_ID",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Confidence",
    t."AC_ID_parent",
    t."AC_ID_child",
    t."having_PAT_ParentalType",
    t."having_Metadata_PAT",
    t."PAT_ID_having"
FROM
    TABLE(ties."tAC_parent_AC_child_PAT_having"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nAC_parent_AC_child_PAT_having" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tAC_parent_AC_child_PAT_having"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."tPR_content_ST_location_EV_of" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3)
)
COPY GRANTS
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" bigint,
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ChangedAt" datetime,
    "PR_content_ST_location_EV_of_PositedAt" timestamp_ntz(3),
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_ID_content" number(10,0),
    "ST_ID_location" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Confidence",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM
    TABLE(ties."rPR_content_ST_location_EV_of"(
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) t
WHERE
    t."PR_content_ST_location_EV_of_Confidence" = 1
AND
    t."PR_content_ST_location_EV_of_ID" = (
        SELECT
            sub."PR_content_ST_location_EV_of_ID"
        FROM
            TABLE(ties."rPR_content_ST_location_EV_of"(
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            (
                sub."PR_ID_content" = t."PR_ID_content"
            OR
                sub."ST_ID_location" = t."ST_ID_location"
            )
        ORDER BY
            sub."PR_content_ST_location_EV_of_ChangedAt" DESC,
            sub."PR_content_ST_location_EV_of_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW ties."lPR_content_ST_location_EV_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tPR_content_ST_location_EV_of"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" bigint,
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ChangedAt" datetime,
    "PR_content_ST_location_EV_of_PositedAt" timestamp_ntz(3),
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_ID_content" number(10,0),
    "ST_ID_location" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Confidence",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM
    TABLE(ties."tPR_content_ST_location_EV_of"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
$$
;
CREATE OR REPLACE VIEW ties."nPR_content_ST_location_EV_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."tPR_content_ST_location_EV_of"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    ))
;
CREATE OR REPLACE FUNCTION ties."dPR_content_ST_location_EV_of" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" bigint,
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ChangedAt" datetime,
    "PR_content_ST_location_EV_of_PositedAt" timestamp_ntz(3),
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_ID_content" number(10,0),
    "ST_ID_location" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Confidence",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM
    TABLE(ties."tPR_content_ST_location_EV_of"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3)
    )) t
WHERE
    t."PR_content_ST_location_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
