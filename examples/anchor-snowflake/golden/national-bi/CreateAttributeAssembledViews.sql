-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes."EV_DAT_Händelse_Datum" COPY GRANTS AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Händelse_Datum",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Reliability"
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" p
JOIN
    attributes."EV_DAT_Händelse_Datum_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW attributes."EV_AUD_Händelse_Publik" COPY GRANTS AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Händelse_Publik",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Reliability"
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" p
JOIN
    attributes."EV_AUD_Händelse_Publik_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW attributes."EV_REV_Händelse_Intäkt" COPY GRANTS AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    p."EV_REV_EV_ID",
    p."EV_REV_Händelse_Intäkt",
    a."EV_REV_PositedAt",
    a."EV_REV_Reliability"
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" p
JOIN
    attributes."EV_REV_Händelse_Intäkt_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW attributes."EV_STA_Händelse_Status" COPY GRANTS AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability"
FROM
    attributes."EV_STA_Händelse_Status_Posit" p
JOIN
    attributes."EV_STA_Händelse_Status_Annex" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
;
CREATE OR REPLACE VIEW attributes."EV_UTL_Händelse_Utnyttjande" COPY GRANTS AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Reliability"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
JOIN
    attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
;
CREATE OR REPLACE VIEW attributes."EV_LVL_Händelse_Level" COPY GRANTS AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability"
FROM
    attributes."EV_LVL_Händelse_Level_Posit" p
JOIN
    attributes."EV_LVL_Händelse_Level_Annex" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
;
CREATE OR REPLACE VIEW attributes."ST_NAM_Scen_Namn" COPY GRANTS AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability"
FROM
    attributes."ST_NAM_Scen_Namn_Posit" p
JOIN
    attributes."ST_NAM_Scen_Namn_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."ST_LOC_Scen_Plats" COPY GRANTS AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Scen_Plats",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Reliability"
FROM
    attributes."ST_LOC_Scen_Plats_Posit" p
JOIN
    attributes."ST_LOC_Scen_Plats_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW attributes."ST_AVG_Scen_Medel" COPY GRANTS AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability"
FROM
    attributes."ST_AVG_Scen_Medel_Posit" p
JOIN
    attributes."ST_AVG_Scen_Medel_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW attributes."ST_MIN_Scen_Minimum" COPY GRANTS AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Reliability"
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Scen_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_NAM_Skådespelare_Namn" COPY GRANTS AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit" p
JOIN
    attributes."AC_NAM_Skådespelare_Namn_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."AC_GEN_Skådespelare_Kön" COPY GRANTS AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Reliability"
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
JOIN
    attributes."AC_GEN_Skådespelare_Kön_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_PLV_Skådespelare_Yrkesnivå" COPY GRANTS AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability"
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW attributes."PR_NAM_Föreställning_Namn" COPY GRANTS AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Föreställning_Namn",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Reliability"
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" p
JOIN
    attributes."PR_NAM_Föreställning_Namn_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."PR_LEN_Föreställning_Längd" COPY GRANTS AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability"
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit" p
JOIN
    attributes."PR_LEN_Föreställning_Längd_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
;
