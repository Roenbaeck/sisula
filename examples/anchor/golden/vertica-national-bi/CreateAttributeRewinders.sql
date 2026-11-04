-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of an attribute with the latest row of their annex: what is known now about each posit, which
-- is asserted or retracted. Vertica has no function that returns a table, so it is a view and shows what is known now
-- (the rewinders of the other databases can be asked about an earlier time); the perspectives that Vertica has are over it.
--
CREATE OR REPLACE VIEW attributes."rEV_DAT_Händelse_Datum" AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Reliability",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Händelse_Datum"
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" p
JOIN
    attributes."EV_DAT_Händelse_Datum_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_DAT_ID"
    ORDER BY a."EV_DAT_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_AUD_Händelse_Publik" AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Reliability",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Händelse_Publik"
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" p
JOIN
    attributes."EV_AUD_Händelse_Publik_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_AUD_ID"
    ORDER BY a."EV_AUD_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_REV_Händelse_Intäkt" AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Reliability",
    p."EV_REV_EV_ID",
    p."EV_REV_Händelse_Intäkt"
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" p
JOIN
    attributes."EV_REV_Händelse_Intäkt_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_REV_ID"
    ORDER BY a."EV_REV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_STA_Händelse_Status" AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Händelse_Status_Posit" p
JOIN
    attributes."EV_STA_Händelse_Status_Annex" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_STA_ID"
    ORDER BY a."EV_STA_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_UTL_Händelse_Utnyttjande" AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Reliability",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
JOIN
    attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_UTL_ID"
    ORDER BY a."EV_UTL_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_LVL_Händelse_Level" AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Händelse_Level_Posit" p
JOIN
    attributes."EV_LVL_Händelse_Level_Annex" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_LVL_ID"
    ORDER BY a."EV_LVL_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_NAM_Scen_Namn" AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Scen_Namn_Posit" p
JOIN
    attributes."ST_NAM_Scen_Namn_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_NAM_ID"
    ORDER BY a."ST_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_LOC_Scen_Plats" AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Reliability",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Scen_Plats"
FROM
    attributes."ST_LOC_Scen_Plats_Posit" p
JOIN
    attributes."ST_LOC_Scen_Plats_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_LOC_ID"
    ORDER BY a."ST_LOC_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_AVG_Scen_Medel" AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."ST_AVG_Scen_Medel_Posit" p
JOIN
    attributes."ST_AVG_Scen_Medel_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_AVG_ID"
    ORDER BY a."ST_AVG_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_MIN_Scen_Minimum" AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Reliability",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Scen_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_MIN_ID"
    ORDER BY a."ST_MIN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_NAM_Skådespelare_Namn" AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit" p
JOIN
    attributes."AC_NAM_Skådespelare_Namn_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_NAM_ID"
    ORDER BY a."AC_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_GEN_Skådespelare_Kön" AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Reliability",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
JOIN
    attributes."AC_GEN_Skådespelare_Kön_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_GEN_ID"
    ORDER BY a."AC_GEN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_PLV_Skådespelare_Yrkesnivå" AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_PLV_ID"
    ORDER BY a."AC_PLV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rPR_NAM_Föreställning_Namn" AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Reliability",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Föreställning_Namn"
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" p
JOIN
    attributes."PR_NAM_Föreställning_Namn_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_NAM_ID"
    ORDER BY a."PR_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rPR_LEN_Föreställning_Längd" AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit" p
JOIN
    attributes."PR_LEN_Föreställning_Längd_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_LEN_ID"
    ORDER BY a."PR_LEN_PositedAt" DESC
)
;
