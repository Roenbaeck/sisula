-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of an attribute with the latest row of their annex for each positor: what is known now about each
-- posit, which each positor asserts, retracts or denies. Vertica has no function that returns a table, so it is a view and shows
-- what is known now (the rewinders of the other databases can be asked about an earlier time, or about a positor); the
-- perspectives that Vertica has are over it.
--
CREATE OR REPLACE VIEW attributes."rEV_DAT_Event_Date" AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Who",
    a."EV_DAT_Confidence",
    a."EV_DAT_Stance",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date"
FROM
    attributes."EV_DAT_Event_Date_Fact" p
JOIN
    attributes."EV_DAT_Event_Date_Meta" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_DAT_ID", a."EV_DAT_Who"
    ORDER BY a."EV_DAT_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_AUD_Event_Audience" AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Who",
    a."EV_AUD_Confidence",
    a."EV_AUD_Stance",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    attributes."EV_AUD_Event_Audience_Fact" p
JOIN
    attributes."EV_AUD_Event_Audience_Meta" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_AUD_ID", a."EV_AUD_Who"
    ORDER BY a."EV_AUD_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_REV_Event_Revenue" AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Who",
    a."EV_REV_Confidence",
    a."EV_REV_Stance",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    attributes."EV_REV_Event_Revenue_Fact" p
JOIN
    attributes."EV_REV_Event_Revenue_Meta" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_REV_ID", a."EV_REV_Who"
    ORDER BY a."EV_REV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_STA_Event_Status" AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Who",
    a."EV_STA_Confidence",
    a."EV_STA_Stance",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Event_Status_Fact" p
JOIN
    attributes."EV_STA_Event_Status_Meta" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_STA_ID", a."EV_STA_Who"
    ORDER BY a."EV_STA_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_UTL_Event_Utilization" AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Who",
    a."EV_UTL_Confidence",
    a."EV_UTL_Stance",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Event_Utilization_Fact" p
JOIN
    attributes."EV_UTL_Event_Utilization_Meta" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_UTL_ID", a."EV_UTL_Who"
    ORDER BY a."EV_UTL_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_LVL_Event_Level" AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Who",
    a."EV_LVL_Confidence",
    a."EV_LVL_Stance",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Event_Level_Fact" p
JOIN
    attributes."EV_LVL_Event_Level_Meta" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_LVL_ID", a."EV_LVL_Who"
    ORDER BY a."EV_LVL_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_NAM_Stage_Name" AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Who",
    a."ST_NAM_Confidence",
    a."ST_NAM_Stance",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Stage_Name_Fact" p
JOIN
    attributes."ST_NAM_Stage_Name_Meta" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_NAM_ID", a."ST_NAM_Who"
    ORDER BY a."ST_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_LOC_Stage_Location" AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Who",
    a."ST_LOC_Confidence",
    a."ST_LOC_Stance",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    attributes."ST_LOC_Stage_Location_Fact" p
JOIN
    attributes."ST_LOC_Stage_Location_Meta" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_LOC_ID", a."ST_LOC_Who"
    ORDER BY a."ST_LOC_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_AVG_Stage_Average" AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Who",
    a."ST_AVG_Confidence",
    a."ST_AVG_Stance",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."ST_AVG_Stage_Average_Fact" p
JOIN
    attributes."ST_AVG_Stage_Average_Meta" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_AVG_ID", a."ST_AVG_Who"
    ORDER BY a."ST_AVG_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_MIN_Stage_Minimum" AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Who",
    a."ST_MIN_Confidence",
    a."ST_MIN_Stance",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Stage_Minimum_Fact" p
JOIN
    attributes."ST_MIN_Stage_Minimum_Meta" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_MIN_ID", a."ST_MIN_Who"
    ORDER BY a."ST_MIN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_NAM_Actor_Name" AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Who",
    a."AC_NAM_Confidence",
    a."AC_NAM_Stance",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Actor_Name_Fact" p
JOIN
    attributes."AC_NAM_Actor_Name_Meta" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_NAM_ID", a."AC_NAM_Who"
    ORDER BY a."AC_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_GEN_Actor_Gender" AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Who",
    a."AC_GEN_Confidence",
    a."AC_GEN_Stance",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Actor_Gender_Fact" p
JOIN
    attributes."AC_GEN_Actor_Gender_Meta" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_GEN_ID", a."AC_GEN_Who"
    ORDER BY a."AC_GEN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_PLV_Actor_ProfessionalLevel" AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Who",
    a."AC_PLV_Confidence",
    a."AC_PLV_Stance",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Fact" p
JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel_Meta" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_PLV_ID", a."AC_PLV_Who"
    ORDER BY a."AC_PLV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rPR_NAM_Program_Name" AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Who",
    a."PR_NAM_Confidence",
    a."PR_NAM_Stance",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name"
FROM
    attributes."PR_NAM_Program_Name_Fact" p
JOIN
    attributes."PR_NAM_Program_Name_Meta" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_NAM_ID", a."PR_NAM_Who"
    ORDER BY a."PR_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rPR_LEN_Program_Length" AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Who",
    a."PR_LEN_Confidence",
    a."PR_LEN_Stance",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Program_Length_Fact" p
JOIN
    attributes."PR_LEN_Program_Length_Meta" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_LEN_ID", a."PR_LEN_Who"
    ORDER BY a."PR_LEN_PositedAt" DESC
)
;
