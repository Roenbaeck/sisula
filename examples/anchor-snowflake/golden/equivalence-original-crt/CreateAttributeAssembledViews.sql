-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes."EV_DAT_Event_Date" COPY GRANTS AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    p."EV_ID",
    p."EV_DAT_Event_Date",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion"
FROM
    attributes."EV_DAT_Event_Date_Posit" p
JOIN
    attributes."EV_DAT_Event_Date_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW attributes."EV_AUD_Event_Audience" COPY GRANTS AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    p."EV_ID",
    p."EV_AUD_Event_Audience",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion"
FROM
    attributes."EV_AUD_Event_Audience_Posit" p
JOIN
    attributes."EV_AUD_Event_Audience_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW attributes."EV_REV_Event_Revenue" COPY GRANTS AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    p."EV_ID",
    p."EV_REV_Event_Revenue",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion"
FROM
    attributes."EV_REV_Event_Revenue_Posit" p
JOIN
    attributes."EV_REV_Event_Revenue_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW attributes."EV_STA_Event_Status" COPY GRANTS AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    p."EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt",
    a."EV_STA_PositedAt",
    a."EV_STA_Positor",
    a."EV_STA_Reliability",
    a."EV_STA_Assertion"
FROM
    attributes."EV_STA_Event_Status_Posit" p
JOIN
    attributes."EV_STA_Event_Status_Annex" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
;
CREATE OR REPLACE VIEW attributes."EV_UTL_Event_Utilization" COPY GRANTS AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    p."EV_ID",
    p."UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Positor",
    a."EV_UTL_Reliability",
    a."EV_UTL_Assertion"
FROM
    attributes."EV_UTL_Event_Utilization_Posit" p
JOIN
    attributes."EV_UTL_Event_Utilization_Annex" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
;
CREATE OR REPLACE VIEW attributes."EV_LVL_Event_Level" COPY GRANTS AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    p."EV_ID",
    p."PLV_ID",
    p."EV_LVL_ChangedAt",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Positor",
    a."EV_LVL_Reliability",
    a."EV_LVL_Assertion"
FROM
    attributes."EV_LVL_Event_Level_Posit" p
JOIN
    attributes."EV_LVL_Event_Level_Annex" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
;
CREATE OR REPLACE VIEW attributes."ST_NAM_Stage_Name" COPY GRANTS AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    p."ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion"
FROM
    attributes."ST_NAM_Stage_Name_Posit" p
JOIN
    attributes."ST_NAM_Stage_Name_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."ST_LOC_Stage_Location" COPY GRANTS AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    p."ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion"
FROM
    attributes."ST_LOC_Stage_Location_Posit" p
JOIN
    attributes."ST_LOC_Stage_Location_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW attributes."ST_AVG_Stage_Average" COPY GRANTS AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    p."ST_ID",
    p."UTL_ID",
    p."ST_AVG_ChangedAt",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Positor",
    a."ST_AVG_Reliability",
    a."ST_AVG_Assertion"
FROM
    attributes."ST_AVG_Stage_Average_Posit" p
JOIN
    attributes."ST_AVG_Stage_Average_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW attributes."ST_MIN_Stage_Minimum" COPY GRANTS AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    p."ST_ID",
    p."UTL_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Positor",
    a."ST_MIN_Reliability",
    a."ST_MIN_Assertion"
FROM
    attributes."ST_MIN_Stage_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Stage_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_NAM_Actor_Name" COPY GRANTS AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    p."AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion"
FROM
    attributes."AC_NAM_Actor_Name_Posit" p
JOIN
    attributes."AC_NAM_Actor_Name_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."AC_GEN_Actor_Gender" COPY GRANTS AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    p."AC_ID",
    p."GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Positor",
    a."AC_GEN_Reliability",
    a."AC_GEN_Assertion"
FROM
    attributes."AC_GEN_Actor_Gender_Posit" p
JOIN
    attributes."AC_GEN_Actor_Gender_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_PLV_Actor_ProfessionalLevel" COPY GRANTS AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    p."AC_ID",
    p."PLV_ID",
    p."AC_PLV_ChangedAt",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Positor",
    a."AC_PLV_Reliability",
    a."AC_PLV_Assertion"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit" p
JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW attributes."PR_NAM_Program_Name" COPY GRANTS AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    p."PR_ID",
    p."PR_NAM_Program_Name",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion"
FROM
    attributes."PR_NAM_Program_Name_Posit" p
JOIN
    attributes."PR_NAM_Program_Name_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."PR_LEN_Program_Length" COPY GRANTS AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    p."PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion"
FROM
    attributes."PR_LEN_Program_Length_Posit" p
JOIN
    attributes."PR_LEN_Program_Length_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
;
