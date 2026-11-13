-- ATTRIBUTE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views. These provide a stable baseline
-- for perspectives and can later be expanded to parameterized SQL macros.
--
CREATE OR REPLACE VIEW attributes.rEV_DAT_Händelse_Datum AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion,
    a.,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Händelse_Datum
FROM
    attributes.EV_DAT_Händelse_Datum_Posit p
JOIN
    attributes.EV_DAT_Händelse_Datum_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
WHERE
    a.EV_DAT_Positor = 0
AND
    a.EV_DAT_PositedAt = (
        SELECT
            MAX(sub.EV_DAT_PositedAt)
        FROM
            attributes.EV_DAT_Händelse_Datum_Annex sub
        WHERE
            sub.EV_DAT_ID = p.EV_DAT_ID
        AND
            sub.EV_DAT_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_AUD_Händelse_Publik AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion,
    a.,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Händelse_Publik
FROM
    attributes.EV_AUD_Händelse_Publik_Posit p
JOIN
    attributes.EV_AUD_Händelse_Publik_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
WHERE
    a.EV_AUD_Positor = 0
AND
    a.EV_AUD_PositedAt = (
        SELECT
            MAX(sub.EV_AUD_PositedAt)
        FROM
            attributes.EV_AUD_Händelse_Publik_Annex sub
        WHERE
            sub.EV_AUD_ID = p.EV_AUD_ID
        AND
            sub.EV_AUD_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_REV_Händelse_Intäkt AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion,
    a.,
    p.EV_REV_EV_ID,
    p.EV_REV_Händelse_Intäkt
FROM
    attributes.EV_REV_Händelse_Intäkt_Posit p
JOIN
    attributes.EV_REV_Händelse_Intäkt_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
WHERE
    a.EV_REV_Positor = 0
AND
    a.EV_REV_PositedAt = (
        SELECT
            MAX(sub.EV_REV_PositedAt)
        FROM
            attributes.EV_REV_Händelse_Intäkt_Annex sub
        WHERE
            sub.EV_REV_ID = p.EV_REV_ID
        AND
            sub.EV_REV_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_STA_Händelse_Status AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Positor,
    a.EV_STA_Reliability,
    a.EV_STA_Assertion,
    a.,
    p.EV_STA_EV_ID,
    p.EV_STA_Händelse_Status
    , p.EV_STA_ChangedAt
FROM
    attributes.EV_STA_Händelse_Status_Posit p
JOIN
    attributes.EV_STA_Händelse_Status_Annex a
ON
    a.EV_STA_ID = p.EV_STA_ID
WHERE
    a.EV_STA_Positor = 0
AND
    a.EV_STA_PositedAt = (
        SELECT
            MAX(sub.EV_STA_PositedAt)
        FROM
            attributes.EV_STA_Händelse_Status_Annex sub
        WHERE
            sub.EV_STA_ID = p.EV_STA_ID
        AND
            sub.EV_STA_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_UTL_Händelse_Utnyttjande AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Positor,
    a.EV_UTL_Reliability,
    a.EV_UTL_Assertion,
    a.,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID
FROM
    attributes.EV_UTL_Händelse_Utnyttjande_Posit p
JOIN
    attributes.EV_UTL_Händelse_Utnyttjande_Annex a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
WHERE
    a.EV_UTL_Positor = 0
AND
    a.EV_UTL_PositedAt = (
        SELECT
            MAX(sub.EV_UTL_PositedAt)
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Annex sub
        WHERE
            sub.EV_UTL_ID = p.EV_UTL_ID
        AND
            sub.EV_UTL_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_LVL_Händelse_Level AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Positor,
    a.EV_LVL_Reliability,
    a.EV_LVL_Assertion,
    a.,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID
    , p.EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Händelse_Level_Posit p
JOIN
    attributes.EV_LVL_Händelse_Level_Annex a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
WHERE
    a.EV_LVL_Positor = 0
AND
    a.EV_LVL_PositedAt = (
        SELECT
            MAX(sub.EV_LVL_PositedAt)
        FROM
            attributes.EV_LVL_Händelse_Level_Annex sub
        WHERE
            sub.EV_LVL_ID = p.EV_LVL_ID
        AND
            sub.EV_LVL_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_NAM_Scen_Namn AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Scen_Namn
    , p.ST_NAM_ChangedAt
FROM
    attributes.ST_NAM_Scen_Namn_Posit p
JOIN
    attributes.ST_NAM_Scen_Namn_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
WHERE
    a.ST_NAM_Positor = 0
AND
    a.ST_NAM_PositedAt = (
        SELECT
            MAX(sub.ST_NAM_PositedAt)
        FROM
            attributes.ST_NAM_Scen_Namn_Annex sub
        WHERE
            sub.ST_NAM_ID = p.ST_NAM_ID
        AND
            sub.ST_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_LOC_Scen_Plats AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion,
    a.,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Scen_Plats
FROM
    attributes.ST_LOC_Scen_Plats_Posit p
JOIN
    attributes.ST_LOC_Scen_Plats_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
WHERE
    a.ST_LOC_Positor = 0
AND
    a.ST_LOC_PositedAt = (
        SELECT
            MAX(sub.ST_LOC_PositedAt)
        FROM
            attributes.ST_LOC_Scen_Plats_Annex sub
        WHERE
            sub.ST_LOC_ID = p.ST_LOC_ID
        AND
            sub.ST_LOC_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_AVG_Scen_Medel AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID
    , p.ST_AVG_ChangedAt
FROM
    attributes.ST_AVG_Scen_Medel_Posit p
JOIN
    attributes.ST_AVG_Scen_Medel_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
WHERE
    a.ST_AVG_Positor = 0
AND
    a.ST_AVG_PositedAt = (
        SELECT
            MAX(sub.ST_AVG_PositedAt)
        FROM
            attributes.ST_AVG_Scen_Medel_Annex sub
        WHERE
            sub.ST_AVG_ID = p.ST_AVG_ID
        AND
            sub.ST_AVG_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_MIN_Scen_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion,
    a.,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    attributes.ST_MIN_Scen_Minimum_Posit p
JOIN
    attributes.ST_MIN_Scen_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
WHERE
    a.ST_MIN_Positor = 0
AND
    a.ST_MIN_PositedAt = (
        SELECT
            MAX(sub.ST_MIN_PositedAt)
        FROM
            attributes.ST_MIN_Scen_Minimum_Annex sub
        WHERE
            sub.ST_MIN_ID = p.ST_MIN_ID
        AND
            sub.ST_MIN_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_NAM_Skådespelare_Namn AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Skådespelare_Namn
    , p.AC_NAM_ChangedAt
FROM
    attributes.AC_NAM_Skådespelare_Namn_Posit p
JOIN
    attributes.AC_NAM_Skådespelare_Namn_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
WHERE
    a.AC_NAM_Positor = 0
AND
    a.AC_NAM_PositedAt = (
        SELECT
            MAX(sub.AC_NAM_PositedAt)
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Annex sub
        WHERE
            sub.AC_NAM_ID = p.AC_NAM_ID
        AND
            sub.AC_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_GEN_Skådespelare_Kön AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion,
    a.,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    attributes.AC_GEN_Skådespelare_Kön_Posit p
JOIN
    attributes.AC_GEN_Skådespelare_Kön_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
WHERE
    a.AC_GEN_Positor = 0
AND
    a.AC_GEN_PositedAt = (
        SELECT
            MAX(sub.AC_GEN_PositedAt)
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Annex sub
        WHERE
            sub.AC_GEN_ID = p.AC_GEN_ID
        AND
            sub.AC_GEN_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_PLV_Skådespelare_Yrkesnivå AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID
    , p.AC_PLV_ChangedAt
FROM
    attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
JOIN
    attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
WHERE
    a.AC_PLV_Positor = 0
AND
    a.AC_PLV_PositedAt = (
        SELECT
            MAX(sub.AC_PLV_PositedAt)
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex sub
        WHERE
            sub.AC_PLV_ID = p.AC_PLV_ID
        AND
            sub.AC_PLV_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_NAM_Föreställning_Namn AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion,
    a.,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Föreställning_Namn
FROM
    attributes.PR_NAM_Föreställning_Namn_Posit p
JOIN
    attributes.PR_NAM_Föreställning_Namn_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
WHERE
    a.PR_NAM_Positor = 0
AND
    a.PR_NAM_PositedAt = (
        SELECT
            MAX(sub.PR_NAM_PositedAt)
        FROM
            attributes.PR_NAM_Föreställning_Namn_Annex sub
        WHERE
            sub.PR_NAM_ID = p.PR_NAM_ID
        AND
            sub.PR_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_LEN_Föreställning_Längd AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Föreställning_Längd
    , p.PR_LEN_ChangedAt
FROM
    attributes.PR_LEN_Föreställning_Längd_Posit p
JOIN
    attributes.PR_LEN_Föreställning_Längd_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
WHERE
    a.PR_LEN_Positor = 0
AND
    a.PR_LEN_PositedAt = (
        SELECT
            MAX(sub.PR_LEN_PositedAt)
        FROM
            attributes.PR_LEN_Föreställning_Längd_Annex sub
        WHERE
            sub.PR_LEN_ID = p.PR_LEN_ID
        AND
            sub.PR_LEN_Positor = 0
    )
;
