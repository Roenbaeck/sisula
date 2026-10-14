-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--
-- In a bitemporal model an attribute and a tie are a posit table and an annex table, each with a view. What is not
-- checked is restatement and whether the time of a posit overlaps another: the uni-temporal checks do not carry over.
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a RELY foreign key cannot make the optimizer drop the join.
--
-- PAT_Föräldratyp integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PAT_Föräldratyp" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_Föräldratyp',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_ID', "PAT_ID"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp"
GROUP BY
    "PAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_Föräldratyp',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PAT_Föräldratyp', "PAT_Föräldratyp"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp"
GROUP BY
    "PAT_Föräldratyp"
HAVING
    COUNT(*) > 1;
-- GEN_Kön integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_GEN_Kön" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Kön',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_ID', "GEN_ID"),
    COUNT(*)
FROM
    knots."GEN_Kön"
GROUP BY
    "GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Kön',
    'duplicate unique key',
    OBJECT_CONSTRUCT('GEN_Checksum', "GEN_Checksum"),
    COUNT(*)
FROM
    knots."GEN_Kön"
GROUP BY
    "GEN_Checksum"
HAVING
    COUNT(*) > 1;
-- PLV_Yrkesnivå integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PLV_Yrkesnivå" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PLV_Yrkesnivå',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PLV_ID', "PLV_ID"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå"
GROUP BY
    "PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_Yrkesnivå',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PLV_Checksum', "PLV_Checksum"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå"
GROUP BY
    "PLV_Checksum"
HAVING
    COUNT(*) > 1;
-- UTL_Utnyttjande integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_UTL_Utnyttjande" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'UTL_Utnyttjande',
    'duplicate primary key',
    OBJECT_CONSTRUCT('UTL_ID', "UTL_ID"),
    COUNT(*)
FROM
    knots."UTL_Utnyttjande"
GROUP BY
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utnyttjande',
    'duplicate unique key',
    OBJECT_CONSTRUCT('UTL_Utnyttjande', "UTL_Utnyttjande"),
    COUNT(*)
FROM
    knots."UTL_Utnyttjande"
GROUP BY
    "UTL_Utnyttjande"
HAVING
    COUNT(*) > 1;
-- ONG_Pågående integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ONG_Pågående" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Pågående',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_ID', "ONG_ID"),
    COUNT(*)
FROM
    knots."ONG_Pågående"
GROUP BY
    "ONG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Pågående',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ONG_Pågående', "ONG_Pågående"),
    COUNT(*)
FROM
    knots."ONG_Pågående"
GROUP BY
    "ONG_Pågående"
HAVING
    COUNT(*) > 1;
-- RAT_Betyg integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_RAT_Betyg" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Betyg',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_ID', "RAT_ID"),
    COUNT(*)
FROM
    knots."RAT_Betyg"
GROUP BY
    "RAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Betyg',
    'duplicate unique key',
    OBJECT_CONSTRUCT('RAT_Checksum', "RAT_Checksum"),
    COUNT(*)
FROM
    knots."RAT_Betyg"
GROUP BY
    "RAT_Checksum"
HAVING
    COUNT(*) > 1;
-- ETY_Händelsetyp integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ETY_Händelsetyp" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ETY_Händelsetyp',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ETY_ID', "ETY_ID"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp"
GROUP BY
    "ETY_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_Händelsetyp',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ETY_Checksum', "ETY_Checksum"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp"
GROUP BY
    "ETY_Checksum"
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PN_Person" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PN_ID', "PN_ID"),
    COUNT(*)
FROM
    anchors."PN_Person"
GROUP BY
    "PN_ID"
HAVING
    COUNT(*) > 1;
-- ST_Scen integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_ST_Scen" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_Scen',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_ID', "ST_ID"),
    COUNT(*)
FROM
    anchors."ST_Scen"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- AC_Skådespelare integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_AC_Skådespelare" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_Skådespelare',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_ID', "AC_ID"),
    COUNT(*)
FROM
    anchors."AC_Skådespelare"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- PR_Föreställning integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PR_Föreställning" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_Föreställning',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_ID', "PR_ID"),
    COUNT(*)
FROM
    anchors."PR_Föreställning"
GROUP BY
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- EV_Händelse integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."ic_EV_Händelse" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_Händelse',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_ID', "EV_ID"),
    COUNT(*)
FROM
    nexuses."EV_Händelse"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ST_Scen for ST_ID_hölls',
    OBJECT_CONSTRUCT('ST_ID_hölls', c."ST_ID_hölls"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_hölls"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_hölls"
UNION ALL
SELECT
    'EV_Händelse',
    'no row in PR_Föreställning for PR_ID_spelades',
    OBJECT_CONSTRUCT('PR_ID_spelades', c."PR_ID_spelades"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_spelades"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_spelades"
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ETY_Händelsetyp for ETY_ID_of',
    OBJECT_CONSTRUCT('ETY_ID_of', c."ETY_ID_of"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    knots."ETY_Händelsetyp" p
ON
    p."ETY_ID" = c."ETY_ID_of"
WHERE
    p."ETY_ID" IS NULL
GROUP BY
    c."ETY_ID_of"
;
-- EV_DAT_Händelse_Datum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Händelse_Datum_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Händelse_Datum_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_DAT_ID', "EV_DAT_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Posit"
GROUP BY
    "EV_DAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_DAT_EV_ID', "EV_DAT_EV_ID",
        'EV_DAT_Händelse_Datum', "EV_DAT_Händelse_Datum"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Posit"
GROUP BY
    "EV_DAT_EV_ID",
    "EV_DAT_Händelse_Datum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum_Posit',
    'no row in EV_Händelse for EV_DAT_EV_ID',
    OBJECT_CONSTRUCT('EV_DAT_EV_ID', c."EV_DAT_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_DAT_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_DAT_EV_ID"
;
-- EV_DAT_Händelse_Datum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Händelse_Datum_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Händelse_Datum_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_ID', "EV_DAT_ID",
        'EV_DAT_PositedAt', "EV_DAT_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Annex"
GROUP BY
    "EV_DAT_ID",
    "EV_DAT_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum_Annex',
    'no row in EV_DAT_Händelse_Datum_Posit for EV_DAT_ID',
    OBJECT_CONSTRUCT('EV_DAT_ID', c."EV_DAT_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum_Annex" c
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum_Posit" p
ON
    p."EV_DAT_ID" = c."EV_DAT_ID"
WHERE
    p."EV_DAT_ID" IS NULL
GROUP BY
    c."EV_DAT_ID"
;
-- EV_AUD_Händelse_Publik_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Händelse_Publik_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Händelse_Publik_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_AUD_ID', "EV_AUD_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Posit"
GROUP BY
    "EV_AUD_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_AUD_EV_ID', "EV_AUD_EV_ID",
        'EV_AUD_Händelse_Publik', "EV_AUD_Händelse_Publik"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Posit"
GROUP BY
    "EV_AUD_EV_ID",
    "EV_AUD_Händelse_Publik"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik_Posit',
    'no row in EV_Händelse for EV_AUD_EV_ID',
    OBJECT_CONSTRUCT('EV_AUD_EV_ID', c."EV_AUD_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_AUD_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_AUD_EV_ID"
;
-- EV_AUD_Händelse_Publik_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Händelse_Publik_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Händelse_Publik_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_ID', "EV_AUD_ID",
        'EV_AUD_PositedAt', "EV_AUD_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Annex"
GROUP BY
    "EV_AUD_ID",
    "EV_AUD_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik_Annex',
    'no row in EV_AUD_Händelse_Publik_Posit for EV_AUD_ID',
    OBJECT_CONSTRUCT('EV_AUD_ID', c."EV_AUD_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik_Annex" c
LEFT JOIN
    attributes."EV_AUD_Händelse_Publik_Posit" p
ON
    p."EV_AUD_ID" = c."EV_AUD_ID"
WHERE
    p."EV_AUD_ID" IS NULL
GROUP BY
    c."EV_AUD_ID"
;
-- EV_REV_Händelse_Intäkt_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Händelse_Intäkt_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Händelse_Intäkt_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_REV_ID', "EV_REV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit"
GROUP BY
    "EV_REV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_REV_EV_ID', "EV_REV_EV_ID",
        'EV_REV_Händelse_Intäkt', "EV_REV_Händelse_Intäkt"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit"
GROUP BY
    "EV_REV_EV_ID",
    "EV_REV_Händelse_Intäkt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt_Posit',
    'no row in EV_Händelse for EV_REV_EV_ID',
    OBJECT_CONSTRUCT('EV_REV_EV_ID', c."EV_REV_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_REV_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_REV_EV_ID"
;
-- EV_REV_Händelse_Intäkt_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Händelse_Intäkt_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Händelse_Intäkt_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_ID', "EV_REV_ID",
        'EV_REV_PositedAt', "EV_REV_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Annex"
GROUP BY
    "EV_REV_ID",
    "EV_REV_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt_Annex',
    'no row in EV_REV_Händelse_Intäkt_Posit for EV_REV_ID',
    OBJECT_CONSTRUCT('EV_REV_ID', c."EV_REV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt_Annex" c
LEFT JOIN
    attributes."EV_REV_Händelse_Intäkt_Posit" p
ON
    p."EV_REV_ID" = c."EV_REV_ID"
WHERE
    p."EV_REV_ID" IS NULL
GROUP BY
    c."EV_REV_ID"
;
-- EV_STA_Händelse_Status_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Händelse_Status_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Händelse_Status_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_STA_ID', "EV_STA_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Posit"
GROUP BY
    "EV_STA_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_STA_EV_ID', "EV_STA_EV_ID",
        'EV_STA_ChangedAt', "EV_STA_ChangedAt",
        'EV_STA_Händelse_Status', "EV_STA_Händelse_Status"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Posit"
GROUP BY
    "EV_STA_EV_ID",
    "EV_STA_ChangedAt",
    "EV_STA_Händelse_Status"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status_Posit',
    'no row in EV_Händelse for EV_STA_EV_ID',
    OBJECT_CONSTRUCT('EV_STA_EV_ID', c."EV_STA_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_STA_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_STA_EV_ID"
;
-- EV_STA_Händelse_Status_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Händelse_Status_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Händelse_Status_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_STA_ID', "EV_STA_ID",
        'EV_STA_PositedAt', "EV_STA_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Annex"
GROUP BY
    "EV_STA_ID",
    "EV_STA_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status_Annex',
    'no row in EV_STA_Händelse_Status_Posit for EV_STA_ID',
    OBJECT_CONSTRUCT('EV_STA_ID', c."EV_STA_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status_Annex" c
LEFT JOIN
    attributes."EV_STA_Händelse_Status_Posit" p
ON
    p."EV_STA_ID" = c."EV_STA_ID"
WHERE
    p."EV_STA_ID" IS NULL
GROUP BY
    c."EV_STA_ID"
;
-- EV_UTL_Händelse_Utnyttjande_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Händelse_Utnyttjande_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_UTL_ID', "EV_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit"
GROUP BY
    "EV_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_UTL_EV_ID', "EV_UTL_EV_ID",
        'EV_UTL_UTL_ID', "EV_UTL_UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit"
GROUP BY
    "EV_UTL_EV_ID",
    "EV_UTL_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'no row in EV_Händelse for EV_UTL_EV_ID',
    OBJECT_CONSTRUCT('EV_UTL_EV_ID', c."EV_UTL_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_UTL_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_UTL_EV_ID"
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Posit',
    'no row in UTL_Utnyttjande for EV_UTL_UTL_ID',
    OBJECT_CONSTRUCT('EV_UTL_UTL_ID', c."EV_UTL_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."EV_UTL_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."EV_UTL_UTL_ID"
;
-- EV_UTL_Händelse_Utnyttjande_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Händelse_Utnyttjande_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Händelse_Utnyttjande_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_UTL_ID', "EV_UTL_ID",
        'EV_UTL_PositedAt', "EV_UTL_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Annex"
GROUP BY
    "EV_UTL_ID",
    "EV_UTL_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande_Annex',
    'no row in EV_UTL_Händelse_Utnyttjande_Posit for EV_UTL_ID',
    OBJECT_CONSTRUCT('EV_UTL_ID', c."EV_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Annex" c
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
ON
    p."EV_UTL_ID" = c."EV_UTL_ID"
WHERE
    p."EV_UTL_ID" IS NULL
GROUP BY
    c."EV_UTL_ID"
;
-- EV_LVL_Händelse_Level_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Händelse_Level_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_LVL_ID', "EV_LVL_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit"
GROUP BY
    "EV_LVL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_LVL_EV_ID', "EV_LVL_EV_ID",
        'EV_LVL_ChangedAt', "EV_LVL_ChangedAt",
        'EV_LVL_PLV_ID', "EV_LVL_PLV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit"
GROUP BY
    "EV_LVL_EV_ID",
    "EV_LVL_ChangedAt",
    "EV_LVL_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'no row in EV_Händelse for EV_LVL_EV_ID',
    OBJECT_CONSTRUCT('EV_LVL_EV_ID', c."EV_LVL_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_LVL_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_LVL_EV_ID"
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Posit',
    'no row in PLV_Yrkesnivå for EV_LVL_PLV_ID',
    OBJECT_CONSTRUCT('EV_LVL_PLV_ID', c."EV_LVL_PLV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Posit" c
LEFT JOIN
    knots."PLV_Yrkesnivå" p
ON
    p."PLV_ID" = c."EV_LVL_PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."EV_LVL_PLV_ID"
;
-- EV_LVL_Händelse_Level_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Händelse_Level_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Händelse_Level_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_LVL_ID', "EV_LVL_ID",
        'EV_LVL_PositedAt', "EV_LVL_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Annex"
GROUP BY
    "EV_LVL_ID",
    "EV_LVL_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level_Annex',
    'no row in EV_LVL_Händelse_Level_Posit for EV_LVL_ID',
    OBJECT_CONSTRUCT('EV_LVL_ID', c."EV_LVL_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level_Annex" c
LEFT JOIN
    attributes."EV_LVL_Händelse_Level_Posit" p
ON
    p."EV_LVL_ID" = c."EV_LVL_ID"
WHERE
    p."EV_LVL_ID" IS NULL
GROUP BY
    c."EV_LVL_ID"
;
-- ST_NAM_Scen_Namn_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Scen_Namn_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Scen_Namn_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_NAM_ID', "ST_NAM_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Posit"
GROUP BY
    "ST_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ST_ID', "ST_NAM_ST_ID",
        'ST_NAM_ChangedAt', "ST_NAM_ChangedAt",
        'ST_NAM_Scen_Namn', "ST_NAM_Scen_Namn"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Posit"
GROUP BY
    "ST_NAM_ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_Scen_Namn"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn_Posit',
    'no row in ST_Scen for ST_NAM_ST_ID',
    OBJECT_CONSTRUCT('ST_NAM_ST_ID', c."ST_NAM_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_NAM_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_NAM_ST_ID"
;
-- ST_NAM_Scen_Namn_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Scen_Namn_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Scen_Namn_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_ID', "ST_NAM_ID",
        'ST_NAM_PositedAt', "ST_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Annex"
GROUP BY
    "ST_NAM_ID",
    "ST_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn_Annex',
    'no row in ST_NAM_Scen_Namn_Posit for ST_NAM_ID',
    OBJECT_CONSTRUCT('ST_NAM_ID', c."ST_NAM_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn_Annex" c
LEFT JOIN
    attributes."ST_NAM_Scen_Namn_Posit" p
ON
    p."ST_NAM_ID" = c."ST_NAM_ID"
WHERE
    p."ST_NAM_ID" IS NULL
GROUP BY
    c."ST_NAM_ID"
;
-- ST_LOC_Scen_Plats_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Scen_Plats_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Scen_Plats_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_LOC_ID', "ST_LOC_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Posit"
GROUP BY
    "ST_LOC_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ST_ID', "ST_LOC_ST_ID",
        'ST_LOC_Checksum', "ST_LOC_Checksum"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Posit"
GROUP BY
    "ST_LOC_ST_ID",
    "ST_LOC_Checksum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats_Posit',
    'no row in ST_Scen for ST_LOC_ST_ID',
    OBJECT_CONSTRUCT('ST_LOC_ST_ID', c."ST_LOC_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_LOC_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_LOC_ST_ID"
;
-- ST_LOC_Scen_Plats_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Scen_Plats_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Scen_Plats_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_ID', "ST_LOC_ID",
        'ST_LOC_PositedAt', "ST_LOC_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Annex"
GROUP BY
    "ST_LOC_ID",
    "ST_LOC_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats_Annex',
    'no row in ST_LOC_Scen_Plats_Posit for ST_LOC_ID',
    OBJECT_CONSTRUCT('ST_LOC_ID', c."ST_LOC_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats_Annex" c
LEFT JOIN
    attributes."ST_LOC_Scen_Plats_Posit" p
ON
    p."ST_LOC_ID" = c."ST_LOC_ID"
WHERE
    p."ST_LOC_ID" IS NULL
GROUP BY
    c."ST_LOC_ID"
;
-- ST_AVG_Scen_Medel_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Scen_Medel_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_AVG_ID', "ST_AVG_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit"
GROUP BY
    "ST_AVG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', "ST_AVG_ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt",
        'ST_AVG_UTL_ID', "ST_AVG_UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit"
GROUP BY
    "ST_AVG_ST_ID",
    "ST_AVG_ChangedAt",
    "ST_AVG_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'no row in ST_Scen for ST_AVG_ST_ID',
    OBJECT_CONSTRUCT('ST_AVG_ST_ID', c."ST_AVG_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_AVG_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_AVG_ST_ID"
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Posit',
    'no row in UTL_Utnyttjande for ST_AVG_UTL_ID',
    OBJECT_CONSTRUCT('ST_AVG_UTL_ID', c."ST_AVG_UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Posit" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."ST_AVG_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."ST_AVG_UTL_ID"
;
-- ST_AVG_Scen_Medel_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Scen_Medel_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Scen_Medel_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ID', "ST_AVG_ID",
        'ST_AVG_PositedAt', "ST_AVG_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Annex"
GROUP BY
    "ST_AVG_ID",
    "ST_AVG_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel_Annex',
    'no row in ST_AVG_Scen_Medel_Posit for ST_AVG_ID',
    OBJECT_CONSTRUCT('ST_AVG_ID', c."ST_AVG_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel_Annex" c
LEFT JOIN
    attributes."ST_AVG_Scen_Medel_Posit" p
ON
    p."ST_AVG_ID" = c."ST_AVG_ID"
WHERE
    p."ST_AVG_ID" IS NULL
GROUP BY
    c."ST_AVG_ID"
;
-- ST_MIN_Scen_Minimum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Scen_Minimum_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_MIN_ID', "ST_MIN_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit"
GROUP BY
    "ST_MIN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ST_ID', "ST_MIN_ST_ID",
        'ST_MIN_UTL_ID', "ST_MIN_UTL_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit"
GROUP BY
    "ST_MIN_ST_ID",
    "ST_MIN_UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'no row in ST_Scen for ST_MIN_ST_ID',
    OBJECT_CONSTRUCT('ST_MIN_ST_ID', c."ST_MIN_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_MIN_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_MIN_ST_ID"
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Posit',
    'no row in UTL_Utnyttjande for ST_MIN_UTL_ID',
    OBJECT_CONSTRUCT('ST_MIN_UTL_ID', c."ST_MIN_UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."ST_MIN_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."ST_MIN_UTL_ID"
;
-- ST_MIN_Scen_Minimum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Scen_Minimum_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Scen_Minimum_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ID', "ST_MIN_ID",
        'ST_MIN_PositedAt', "ST_MIN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Annex"
GROUP BY
    "ST_MIN_ID",
    "ST_MIN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum_Annex',
    'no row in ST_MIN_Scen_Minimum_Posit for ST_MIN_ID',
    OBJECT_CONSTRUCT('ST_MIN_ID', c."ST_MIN_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum_Annex" c
LEFT JOIN
    attributes."ST_MIN_Scen_Minimum_Posit" p
ON
    p."ST_MIN_ID" = c."ST_MIN_ID"
WHERE
    p."ST_MIN_ID" IS NULL
GROUP BY
    c."ST_MIN_ID"
;
-- AC_NAM_Skådespelare_Namn_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Skådespelare_Namn_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Skådespelare_Namn_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_NAM_ID', "AC_NAM_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit"
GROUP BY
    "AC_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', "AC_NAM_AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt",
        'AC_NAM_Skådespelare_Namn', "AC_NAM_Skådespelare_Namn"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit"
GROUP BY
    "AC_NAM_AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_Skådespelare_Namn"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn_Posit',
    'no row in AC_Skådespelare for AC_NAM_AC_ID',
    OBJECT_CONSTRUCT('AC_NAM_AC_ID', c."AC_NAM_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_NAM_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_NAM_AC_ID"
;
-- AC_NAM_Skådespelare_Namn_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Skådespelare_Namn_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Skådespelare_Namn_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_ID', "AC_NAM_ID",
        'AC_NAM_PositedAt', "AC_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Annex"
GROUP BY
    "AC_NAM_ID",
    "AC_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn_Annex',
    'no row in AC_NAM_Skådespelare_Namn_Posit for AC_NAM_ID',
    OBJECT_CONSTRUCT('AC_NAM_ID', c."AC_NAM_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn_Annex" c
LEFT JOIN
    attributes."AC_NAM_Skådespelare_Namn_Posit" p
ON
    p."AC_NAM_ID" = c."AC_NAM_ID"
WHERE
    p."AC_NAM_ID" IS NULL
GROUP BY
    c."AC_NAM_ID"
;
-- AC_GEN_Skådespelare_Kön_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Skådespelare_Kön_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_GEN_ID', "AC_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit"
GROUP BY
    "AC_GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_GEN_AC_ID', "AC_GEN_AC_ID",
        'AC_GEN_GEN_ID', "AC_GEN_GEN_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit"
GROUP BY
    "AC_GEN_AC_ID",
    "AC_GEN_GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'no row in AC_Skådespelare for AC_GEN_AC_ID',
    OBJECT_CONSTRUCT('AC_GEN_AC_ID', c."AC_GEN_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_GEN_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_GEN_AC_ID"
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Posit',
    'no row in GEN_Kön for AC_GEN_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_GEN_ID', c."AC_GEN_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" c
LEFT JOIN
    knots."GEN_Kön" p
ON
    p."GEN_ID" = c."AC_GEN_GEN_ID"
WHERE
    p."GEN_ID" IS NULL
GROUP BY
    c."AC_GEN_GEN_ID"
;
-- AC_GEN_Skådespelare_Kön_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Skådespelare_Kön_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Skådespelare_Kön_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_ID', "AC_GEN_ID",
        'AC_GEN_PositedAt', "AC_GEN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Annex"
GROUP BY
    "AC_GEN_ID",
    "AC_GEN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön_Annex',
    'no row in AC_GEN_Skådespelare_Kön_Posit for AC_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_ID', c."AC_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön_Annex" c
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
ON
    p."AC_GEN_ID" = c."AC_GEN_ID"
WHERE
    p."AC_GEN_ID" IS NULL
GROUP BY
    c."AC_GEN_ID"
;
-- AC_PLV_Skådespelare_Yrkesnivå_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_PLV_ID', "AC_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"
GROUP BY
    "AC_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_PLV_AC_ID', "AC_PLV_AC_ID",
        'AC_PLV_ChangedAt', "AC_PLV_ChangedAt",
        'AC_PLV_PLV_ID', "AC_PLV_PLV_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"
GROUP BY
    "AC_PLV_AC_ID",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'no row in AC_Skådespelare for AC_PLV_AC_ID',
    OBJECT_CONSTRUCT('AC_PLV_AC_ID', c."AC_PLV_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_PLV_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_PLV_AC_ID"
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Posit',
    'no row in PLV_Yrkesnivå for AC_PLV_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_PLV_ID', c."AC_PLV_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" c
LEFT JOIN
    knots."PLV_Yrkesnivå" p
ON
    p."PLV_ID" = c."AC_PLV_PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."AC_PLV_PLV_ID"
;
-- AC_PLV_Skådespelare_Yrkesnivå_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_ID', "AC_PLV_ID",
        'AC_PLV_PositedAt', "AC_PLV_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex"
GROUP BY
    "AC_PLV_ID",
    "AC_PLV_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå_Annex',
    'no row in AC_PLV_Skådespelare_Yrkesnivå_Posit for AC_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_ID', c."AC_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" c
LEFT JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
ON
    p."AC_PLV_ID" = c."AC_PLV_ID"
WHERE
    p."AC_PLV_ID" IS NULL
GROUP BY
    c."AC_PLV_ID"
;
-- PR_NAM_Föreställning_Namn_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Föreställning_Namn_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Föreställning_Namn_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_NAM_ID', "PR_NAM_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit"
GROUP BY
    "PR_NAM_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_NAM_PR_ID', "PR_NAM_PR_ID",
        'PR_NAM_Föreställning_Namn', "PR_NAM_Föreställning_Namn"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit"
GROUP BY
    "PR_NAM_PR_ID",
    "PR_NAM_Föreställning_Namn"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn_Posit',
    'no row in PR_Föreställning for PR_NAM_PR_ID',
    OBJECT_CONSTRUCT('PR_NAM_PR_ID', c."PR_NAM_PR_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_NAM_PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_NAM_PR_ID"
;
-- PR_NAM_Föreställning_Namn_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Föreställning_Namn_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Föreställning_Namn_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_ID', "PR_NAM_ID",
        'PR_NAM_PositedAt', "PR_NAM_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Annex"
GROUP BY
    "PR_NAM_ID",
    "PR_NAM_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn_Annex',
    'no row in PR_NAM_Föreställning_Namn_Posit for PR_NAM_ID',
    OBJECT_CONSTRUCT('PR_NAM_ID', c."PR_NAM_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn_Annex" c
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn_Posit" p
ON
    p."PR_NAM_ID" = c."PR_NAM_ID"
WHERE
    p."PR_NAM_ID" IS NULL
GROUP BY
    c."PR_NAM_ID"
;
-- PR_LEN_Föreställning_Längd_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Föreställning_Längd_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Föreställning_Längd_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_LEN_ID', "PR_LEN_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit"
GROUP BY
    "PR_LEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_LEN_PR_ID', "PR_LEN_PR_ID",
        'PR_LEN_ChangedAt', "PR_LEN_ChangedAt",
        'PR_LEN_Föreställning_Längd', "PR_LEN_Föreställning_Längd"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit"
GROUP BY
    "PR_LEN_PR_ID",
    "PR_LEN_ChangedAt",
    "PR_LEN_Föreställning_Längd"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd_Posit',
    'no row in PR_Föreställning for PR_LEN_PR_ID',
    OBJECT_CONSTRUCT('PR_LEN_PR_ID', c."PR_LEN_PR_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_LEN_PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_LEN_PR_ID"
;
-- PR_LEN_Föreställning_Längd_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Föreställning_Längd_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Föreställning_Längd_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_ID', "PR_LEN_ID",
        'PR_LEN_PositedAt', "PR_LEN_PositedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Annex"
GROUP BY
    "PR_LEN_ID",
    "PR_LEN_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd_Annex',
    'no row in PR_LEN_Föreställning_Längd_Posit for PR_LEN_ID',
    OBJECT_CONSTRUCT('PR_LEN_ID', c."PR_LEN_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd_Annex" c
LEFT JOIN
    attributes."PR_LEN_Föreställning_Längd_Posit" p
ON
    p."PR_LEN_ID" = c."PR_LEN_ID"
WHERE
    p."PR_LEN_ID" IS NULL
GROUP BY
    c."PR_LEN_ID"
;
-- AC_partner_AC_with_ONG_currently_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', "AC_partner_AC_with_ONG_currently_ID"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_partner_AC_with_ONG_currently_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_ID_with', "AC_ID_with",
        'ONG_ID_currently', "ONG_ID_currently",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_partner",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', "AC_ID_with",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit"
GROUP BY
    "AC_ID_with",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Skådespelare for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c."AC_ID_partner"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_partner"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_partner"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Skådespelare for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c."AC_ID_with"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_with"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_with"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in ONG_Pågående for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c."ONG_ID_currently"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" c
LEFT JOIN
    knots."ONG_Pågående" p
ON
    p."ONG_ID" = c."ONG_ID_currently"
WHERE
    p."ONG_ID" IS NULL
GROUP BY
    c."ONG_ID_currently"
;
-- AC_partner_AC_with_ONG_currently_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_partner_AC_with_ONG_currently_ID', "AC_partner_AC_with_ONG_currently_ID",
        'AC_partner_AC_with_ONG_currently_PositedAt', "AC_partner_AC_with_ONG_currently_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex"
GROUP BY
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'no row in AC_partner_AC_with_ONG_currently_Posit for AC_partner_AC_with_ONG_currently_ID',
    OBJECT_CONSTRUCT('AC_partner_AC_with_ONG_currently_ID', c."AC_partner_AC_with_ONG_currently_ID"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex" c
LEFT JOIN
    ties."AC_partner_AC_with_ONG_currently_Posit" p
ON
    p."AC_partner_AC_with_ONG_currently_ID" = c."AC_partner_AC_with_ONG_currently_ID"
WHERE
    p."AC_partner_AC_with_ONG_currently_ID" IS NULL
GROUP BY
    c."AC_partner_AC_with_ONG_currently_ID"
;
-- AC_subset_PN_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', "AC_subset_PN_of_ID"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_subset_PN_of_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset",
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_ID_subset",
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "AC_ID_subset"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit"
GROUP BY
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in AC_Skådespelare for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c."AC_ID_subset"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_subset"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_subset"
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c."PN_ID_of"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Posit" c
LEFT JOIN
    anchors."PN_Person" p
ON
    p."PN_ID" = c."PN_ID_of"
WHERE
    p."PN_ID" IS NULL
GROUP BY
    c."PN_ID_of"
;
-- AC_subset_PN_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_subset_PN_of_ID', "AC_subset_PN_of_ID",
        'AC_subset_PN_of_PositedAt', "AC_subset_PN_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Annex"
GROUP BY
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Annex',
    'no row in AC_subset_PN_of_Posit for AC_subset_PN_of_ID',
    OBJECT_CONSTRUCT('AC_subset_PN_of_ID', c."AC_subset_PN_of_ID"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of_Annex" c
LEFT JOIN
    ties."AC_subset_PN_of_Posit" p
ON
    p."AC_subset_PN_of_ID" = c."AC_subset_PN_of_ID"
WHERE
    p."AC_subset_PN_of_ID" IS NULL
GROUP BY
    c."AC_subset_PN_of_ID"
;
-- EV_in_AC_rollsattes_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_rollsattes_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_rollsattes_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_in_AC_rollsattes_ID', "EV_in_AC_rollsattes_ID"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit"
GROUP BY
    "EV_in_AC_rollsattes_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', "EV_ID_in",
        'AC_ID_rollsattes', "AC_ID_rollsattes"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit"
GROUP BY
    "EV_ID_in",
    "AC_ID_rollsattes"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Posit',
    'no row in EV_Händelse for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c."EV_ID_in"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_ID_in"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_in"
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Posit',
    'no row in AC_Skådespelare for AC_ID_rollsattes',
    OBJECT_CONSTRUCT('AC_ID_rollsattes', c."AC_ID_rollsattes"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_rollsattes"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_rollsattes"
;
-- EV_in_AC_rollsattes_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_rollsattes_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_rollsattes_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_in_AC_rollsattes_ID', "EV_in_AC_rollsattes_ID",
        'EV_in_AC_rollsattes_PositedAt', "EV_in_AC_rollsattes_PositedAt"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Annex"
GROUP BY
    "EV_in_AC_rollsattes_ID",
    "EV_in_AC_rollsattes_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes_Annex',
    'no row in EV_in_AC_rollsattes_Posit for EV_in_AC_rollsattes_ID',
    OBJECT_CONSTRUCT('EV_in_AC_rollsattes_ID', c."EV_in_AC_rollsattes_ID"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes_Annex" c
LEFT JOIN
    ties."EV_in_AC_rollsattes_Posit" p
ON
    p."EV_in_AC_rollsattes_ID" = c."EV_in_AC_rollsattes_ID"
WHERE
    p."EV_in_AC_rollsattes_ID" IS NULL
GROUP BY
    c."EV_in_AC_rollsattes_ID"
;
-- AC_deltar_PR_in_RAT_fick_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_deltar_PR_in_RAT_fick_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_deltar_PR_in_RAT_fick_ID', "AC_deltar_PR_in_RAT_fick_ID"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
GROUP BY
    "AC_deltar_PR_in_RAT_fick_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_deltar', "AC_ID_deltar",
        'PR_ID_in', "PR_ID_in",
        'RAT_ID_fick', "RAT_ID_fick",
        'AC_deltar_PR_in_RAT_fick_ChangedAt', "AC_deltar_PR_in_RAT_fick_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
GROUP BY
    "AC_ID_deltar",
    "PR_ID_in",
    "RAT_ID_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'no row in AC_Skådespelare for AC_ID_deltar',
    OBJECT_CONSTRUCT('AC_ID_deltar', c."AC_ID_deltar"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_deltar"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_deltar"
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'no row in PR_Föreställning for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c."PR_ID_in"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_in"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_in"
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Posit',
    'no row in RAT_Betyg for RAT_ID_fick',
    OBJECT_CONSTRUCT('RAT_ID_fick', c."RAT_ID_fick"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" c
LEFT JOIN
    knots."RAT_Betyg" p
ON
    p."RAT_ID" = c."RAT_ID_fick"
WHERE
    p."RAT_ID" IS NULL
GROUP BY
    c."RAT_ID_fick"
;
-- AC_deltar_PR_in_RAT_fick_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_deltar_PR_in_RAT_fick_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_deltar_PR_in_RAT_fick_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_deltar_PR_in_RAT_fick_ID', "AC_deltar_PR_in_RAT_fick_ID",
        'AC_deltar_PR_in_RAT_fick_PositedAt', "AC_deltar_PR_in_RAT_fick_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex"
GROUP BY
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_deltar_PR_in_RAT_fick_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick_Annex',
    'no row in AC_deltar_PR_in_RAT_fick_Posit for AC_deltar_PR_in_RAT_fick_ID',
    OBJECT_CONSTRUCT('AC_deltar_PR_in_RAT_fick_ID', c."AC_deltar_PR_in_RAT_fick_ID"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex" c
LEFT JOIN
    ties."AC_deltar_PR_in_RAT_fick_Posit" p
ON
    p."AC_deltar_PR_in_RAT_fick_ID" = c."AC_deltar_PR_in_RAT_fick_ID"
WHERE
    p."AC_deltar_PR_in_RAT_fick_ID" IS NULL
GROUP BY
    c."AC_deltar_PR_in_RAT_fick_ID"
;
-- ST_at_PR_spelas_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_spelas_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_spelas_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_at_PR_spelas_ID', "ST_at_PR_spelas_ID"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit"
GROUP BY
    "ST_at_PR_spelas_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', "ST_ID_at",
        'PR_ID_spelas', "PR_ID_spelas",
        'ST_at_PR_spelas_ChangedAt', "ST_at_PR_spelas_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit"
GROUP BY
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas_Posit',
    'no row in ST_Scen for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c."ST_ID_at"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_at"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_at"
UNION ALL
SELECT
    'ST_at_PR_spelas_Posit',
    'no row in PR_Föreställning for PR_ID_spelas',
    OBJECT_CONSTRUCT('PR_ID_spelas', c."PR_ID_spelas"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_spelas"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_spelas"
;
-- ST_at_PR_spelas_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_spelas_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_spelas_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_at_PR_spelas_ID', "ST_at_PR_spelas_ID",
        'ST_at_PR_spelas_PositedAt', "ST_at_PR_spelas_PositedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Annex"
GROUP BY
    "ST_at_PR_spelas_ID",
    "ST_at_PR_spelas_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas_Annex',
    'no row in ST_at_PR_spelas_Posit for ST_at_PR_spelas_ID',
    OBJECT_CONSTRUCT('ST_at_PR_spelas_ID', c."ST_at_PR_spelas_ID"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas_Annex" c
LEFT JOIN
    ties."ST_at_PR_spelas_Posit" p
ON
    p."ST_at_PR_spelas_ID" = c."ST_at_PR_spelas_ID"
WHERE
    p."ST_at_PR_spelas_ID" IS NULL
GROUP BY
    c."ST_at_PR_spelas_ID"
;
-- AC_förälder_AC_barn_PAT_har_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_förälder_AC_barn_PAT_har_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_förälder_AC_barn_PAT_har_ID', "AC_förälder_AC_barn_PAT_har_ID"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit"
GROUP BY
    "AC_förälder_AC_barn_PAT_har_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'AC_ID_förälder', "AC_ID_förälder",
        'AC_ID_barn', "AC_ID_barn",
        'PAT_ID_har', "PAT_ID_har"
    ),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit"
GROUP BY
    "AC_ID_förälder",
    "AC_ID_barn",
    "PAT_ID_har"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'no row in AC_Skådespelare for AC_ID_förälder',
    OBJECT_CONSTRUCT('AC_ID_förälder', c."AC_ID_förälder"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_förälder"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_förälder"
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'no row in AC_Skådespelare for AC_ID_barn',
    OBJECT_CONSTRUCT('AC_ID_barn', c."AC_ID_barn"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_barn"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_barn"
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Posit',
    'no row in PAT_Föräldratyp for PAT_ID_har',
    OBJECT_CONSTRUCT('PAT_ID_har', c."PAT_ID_har"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" c
LEFT JOIN
    knots."PAT_Föräldratyp" p
ON
    p."PAT_ID" = c."PAT_ID_har"
WHERE
    p."PAT_ID" IS NULL
GROUP BY
    c."PAT_ID_har"
;
-- AC_förälder_AC_barn_PAT_har_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_förälder_AC_barn_PAT_har_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_förälder_AC_barn_PAT_har_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_förälder_AC_barn_PAT_har_ID', "AC_förälder_AC_barn_PAT_har_ID",
        'AC_förälder_AC_barn_PAT_har_PositedAt', "AC_förälder_AC_barn_PAT_har_PositedAt"
    ),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex"
GROUP BY
    "AC_förälder_AC_barn_PAT_har_ID",
    "AC_förälder_AC_barn_PAT_har_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har_Annex',
    'no row in AC_förälder_AC_barn_PAT_har_Posit for AC_förälder_AC_barn_PAT_har_ID',
    OBJECT_CONSTRUCT('AC_förälder_AC_barn_PAT_har_ID', c."AC_förälder_AC_barn_PAT_har_ID"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex" c
LEFT JOIN
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
ON
    p."AC_förälder_AC_barn_PAT_har_ID" = c."AC_förälder_AC_barn_PAT_har_ID"
WHERE
    p."AC_förälder_AC_barn_PAT_har_ID" IS NULL
GROUP BY
    c."AC_förälder_AC_barn_PAT_har_ID"
;
-- PR_innehåll_ST_plats_EV_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_innehåll_ST_plats_EV_of_Posit" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_innehåll_ST_plats_EV_of_ID', "PR_innehåll_ST_plats_EV_of_ID"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "PR_innehåll_ST_plats_EV_of_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate unique key',
    OBJECT_CONSTRUCT(
        'PR_ID_innehåll', "PR_ID_innehåll",
        'ST_ID_plats', "ST_ID_plats",
        'EV_ID_of', "EV_ID_of",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate unique key (PR_innehåll)',
    OBJECT_CONSTRUCT(
        'PR_ID_innehåll', "PR_ID_innehåll",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "PR_ID_innehåll",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'duplicate unique key (ST_plats)',
    OBJECT_CONSTRUCT(
        'ST_ID_plats', "ST_ID_plats",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
GROUP BY
    "ST_ID_plats",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'no row in PR_Föreställning for PR_ID_innehåll',
    OBJECT_CONSTRUCT('PR_ID_innehåll', c."PR_ID_innehåll"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_innehåll"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_innehåll"
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'no row in ST_Scen for ST_ID_plats',
    OBJECT_CONSTRUCT('ST_ID_plats', c."ST_ID_plats"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_plats"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_plats"
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Posit',
    'no row in EV_Händelse for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c."EV_ID_of"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_ID_of"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_of"
;
-- PR_innehåll_ST_plats_EV_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_innehåll_ST_plats_EV_of_Annex" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_innehåll_ST_plats_EV_of_Annex',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_innehåll_ST_plats_EV_of_ID', "PR_innehåll_ST_plats_EV_of_ID",
        'PR_innehåll_ST_plats_EV_of_PositedAt', "PR_innehåll_ST_plats_EV_of_PositedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex"
GROUP BY
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_innehåll_ST_plats_EV_of_PositedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of_Annex',
    'no row in PR_innehåll_ST_plats_EV_of_Posit for PR_innehåll_ST_plats_EV_of_ID',
    OBJECT_CONSTRUCT('PR_innehåll_ST_plats_EV_of_ID', c."PR_innehåll_ST_plats_EV_of_ID"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex" c
LEFT JOIN
    ties."PR_innehåll_ST_plats_EV_of_Posit" p
ON
    p."PR_innehåll_ST_plats_EV_of_ID" = c."PR_innehåll_ST_plats_EV_of_ID"
WHERE
    p."PR_innehåll_ST_plats_EV_of_ID" IS NULL
GROUP BY
    c."PR_innehåll_ST_plats_EV_of_ID"
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW dw.IntegrityViolations (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM knots."ic_PAT_Föräldratyp"
UNION ALL SELECT * FROM knots."ic_GEN_Kön"
UNION ALL SELECT * FROM knots."ic_PLV_Yrkesnivå"
UNION ALL SELECT * FROM knots."ic_UTL_Utnyttjande"
UNION ALL SELECT * FROM knots."ic_ONG_Pågående"
UNION ALL SELECT * FROM knots."ic_RAT_Betyg"
UNION ALL SELECT * FROM knots."ic_ETY_Händelsetyp"
UNION ALL SELECT * FROM anchors."ic_PN_Person"
UNION ALL SELECT * FROM anchors."ic_ST_Scen"
UNION ALL SELECT * FROM anchors."ic_AC_Skådespelare"
UNION ALL SELECT * FROM anchors."ic_PR_Föreställning"
UNION ALL SELECT * FROM nexuses."ic_EV_Händelse"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Händelse_Datum_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Händelse_Datum_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Händelse_Publik_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Händelse_Publik_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Händelse_Intäkt_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Händelse_Intäkt_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Händelse_Status_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Händelse_Status_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Händelse_Utnyttjande_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Händelse_Utnyttjande_Annex"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Händelse_Level_Posit"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Händelse_Level_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Scen_Namn_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Scen_Namn_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Scen_Plats_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Scen_Plats_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Scen_Medel_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Scen_Medel_Annex"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Scen_Minimum_Posit"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Scen_Minimum_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Skådespelare_Namn_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Skådespelare_Namn_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Skådespelare_Kön_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Skådespelare_Kön_Annex"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Posit"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Skådespelare_Yrkesnivå_Annex"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Föreställning_Namn_Posit"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Föreställning_Namn_Annex"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Föreställning_Längd_Posit"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Föreställning_Längd_Annex"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently_Posit"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently_Annex"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of_Posit"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of_Annex"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_rollsattes_Posit"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_rollsattes_Annex"
UNION ALL SELECT * FROM ties."ic_AC_deltar_PR_in_RAT_fick_Posit"
UNION ALL SELECT * FROM ties."ic_AC_deltar_PR_in_RAT_fick_Annex"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_spelas_Posit"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_spelas_Annex"
UNION ALL SELECT * FROM ties."ic_AC_förälder_AC_barn_PAT_har_Posit"
UNION ALL SELECT * FROM ties."ic_AC_förälder_AC_barn_PAT_har_Annex"
UNION ALL SELECT * FROM ties."ic_PR_innehåll_ST_plats_EV_of_Posit"
UNION ALL SELECT * FROM ties."ic_PR_innehåll_ST_plats_EV_of_Annex"
;