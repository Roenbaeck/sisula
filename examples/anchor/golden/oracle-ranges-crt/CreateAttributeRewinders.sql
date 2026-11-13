-- ATTRIBUTE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views. These provide a stable baseline
-- for perspectives and can later be expanded to parameterized SQL macros.
--
CREATE OR REPLACE VIEW attributes.rEV_DAT_Event_Date AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Who,
    a.EV_DAT_Confidence,
    a.EV_DAT_Stance,
    a.,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date
FROM
    attributes.EV_DAT_Event_Date_Fact p
JOIN
    attributes.EV_DAT_Event_Date_Meta a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
WHERE
    a.EV_DAT_Who = 0
AND
    a.EV_DAT_PositedAt = (
        SELECT
            MAX(sub.EV_DAT_PositedAt)
        FROM
            attributes.EV_DAT_Event_Date_Meta sub
        WHERE
            sub.EV_DAT_ID = p.EV_DAT_ID
        AND
            sub.EV_DAT_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_AUD_Event_Audience AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Who,
    a.EV_AUD_Confidence,
    a.EV_AUD_Stance,
    a.,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience
FROM
    attributes.EV_AUD_Event_Audience_Fact p
JOIN
    attributes.EV_AUD_Event_Audience_Meta a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
WHERE
    a.EV_AUD_Who = 0
AND
    a.EV_AUD_PositedAt = (
        SELECT
            MAX(sub.EV_AUD_PositedAt)
        FROM
            attributes.EV_AUD_Event_Audience_Meta sub
        WHERE
            sub.EV_AUD_ID = p.EV_AUD_ID
        AND
            sub.EV_AUD_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_REV_Event_Revenue AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Who,
    a.EV_REV_Confidence,
    a.EV_REV_Stance,
    a.,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue
FROM
    attributes.EV_REV_Event_Revenue_Fact p
JOIN
    attributes.EV_REV_Event_Revenue_Meta a
ON
    a.EV_REV_ID = p.EV_REV_ID
WHERE
    a.EV_REV_Who = 0
AND
    a.EV_REV_PositedAt = (
        SELECT
            MAX(sub.EV_REV_PositedAt)
        FROM
            attributes.EV_REV_Event_Revenue_Meta sub
        WHERE
            sub.EV_REV_ID = p.EV_REV_ID
        AND
            sub.EV_REV_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_STA_Event_Status AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Who,
    a.EV_STA_Confidence,
    a.EV_STA_Stance,
    a.,
    p.EV_STA_EV_ID,
    p.EV_STA_Event_Status
    , p.EV_STA_ChangedAt
FROM
    attributes.EV_STA_Event_Status_Fact p
JOIN
    attributes.EV_STA_Event_Status_Meta a
ON
    a.EV_STA_ID = p.EV_STA_ID
WHERE
    a.EV_STA_Who = 0
AND
    a.EV_STA_PositedAt = (
        SELECT
            MAX(sub.EV_STA_PositedAt)
        FROM
            attributes.EV_STA_Event_Status_Meta sub
        WHERE
            sub.EV_STA_ID = p.EV_STA_ID
        AND
            sub.EV_STA_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_UTL_Event_Utilization AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Who,
    a.EV_UTL_Confidence,
    a.EV_UTL_Stance,
    a.,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID
FROM
    attributes.EV_UTL_Event_Utilization_Fact p
JOIN
    attributes.EV_UTL_Event_Utilization_Meta a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
WHERE
    a.EV_UTL_Who = 0
AND
    a.EV_UTL_PositedAt = (
        SELECT
            MAX(sub.EV_UTL_PositedAt)
        FROM
            attributes.EV_UTL_Event_Utilization_Meta sub
        WHERE
            sub.EV_UTL_ID = p.EV_UTL_ID
        AND
            sub.EV_UTL_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_LVL_Event_Level AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Who,
    a.EV_LVL_Confidence,
    a.EV_LVL_Stance,
    a.,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID
    , p.EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Event_Level_Fact p
JOIN
    attributes.EV_LVL_Event_Level_Meta a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
WHERE
    a.EV_LVL_Who = 0
AND
    a.EV_LVL_PositedAt = (
        SELECT
            MAX(sub.EV_LVL_PositedAt)
        FROM
            attributes.EV_LVL_Event_Level_Meta sub
        WHERE
            sub.EV_LVL_ID = p.EV_LVL_ID
        AND
            sub.EV_LVL_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_NAM_Stage_Name AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Who,
    a.ST_NAM_Confidence,
    a.ST_NAM_Stance,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Stage_Name
    , p.ST_NAM_ChangedAt
FROM
    attributes.ST_NAM_Stage_Name_Fact p
JOIN
    attributes.ST_NAM_Stage_Name_Meta a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
WHERE
    a.ST_NAM_Who = 0
AND
    a.ST_NAM_PositedAt = (
        SELECT
            MAX(sub.ST_NAM_PositedAt)
        FROM
            attributes.ST_NAM_Stage_Name_Meta sub
        WHERE
            sub.ST_NAM_ID = p.ST_NAM_ID
        AND
            sub.ST_NAM_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_LOC_Stage_Location AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Who,
    a.ST_LOC_Confidence,
    a.ST_LOC_Stance,
    a.,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location
FROM
    attributes.ST_LOC_Stage_Location_Fact p
JOIN
    attributes.ST_LOC_Stage_Location_Meta a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
WHERE
    a.ST_LOC_Who = 0
AND
    a.ST_LOC_PositedAt = (
        SELECT
            MAX(sub.ST_LOC_PositedAt)
        FROM
            attributes.ST_LOC_Stage_Location_Meta sub
        WHERE
            sub.ST_LOC_ID = p.ST_LOC_ID
        AND
            sub.ST_LOC_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_AVG_Stage_Average AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Who,
    a.ST_AVG_Confidence,
    a.ST_AVG_Stance,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID
    , p.ST_AVG_ChangedAt
FROM
    attributes.ST_AVG_Stage_Average_Fact p
JOIN
    attributes.ST_AVG_Stage_Average_Meta a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
WHERE
    a.ST_AVG_Who = 0
AND
    a.ST_AVG_PositedAt = (
        SELECT
            MAX(sub.ST_AVG_PositedAt)
        FROM
            attributes.ST_AVG_Stage_Average_Meta sub
        WHERE
            sub.ST_AVG_ID = p.ST_AVG_ID
        AND
            sub.ST_AVG_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_MIN_Stage_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Who,
    a.ST_MIN_Confidence,
    a.ST_MIN_Stance,
    a.,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    attributes.ST_MIN_Stage_Minimum_Fact p
JOIN
    attributes.ST_MIN_Stage_Minimum_Meta a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
WHERE
    a.ST_MIN_Who = 0
AND
    a.ST_MIN_PositedAt = (
        SELECT
            MAX(sub.ST_MIN_PositedAt)
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta sub
        WHERE
            sub.ST_MIN_ID = p.ST_MIN_ID
        AND
            sub.ST_MIN_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_NAM_Actor_Name AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Who,
    a.AC_NAM_Confidence,
    a.AC_NAM_Stance,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Actor_Name
    , p.AC_NAM_ChangedAt
FROM
    attributes.AC_NAM_Actor_Name_Fact p
JOIN
    attributes.AC_NAM_Actor_Name_Meta a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
WHERE
    a.AC_NAM_Who = 0
AND
    a.AC_NAM_PositedAt = (
        SELECT
            MAX(sub.AC_NAM_PositedAt)
        FROM
            attributes.AC_NAM_Actor_Name_Meta sub
        WHERE
            sub.AC_NAM_ID = p.AC_NAM_ID
        AND
            sub.AC_NAM_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_GEN_Actor_Gender AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Who,
    a.AC_GEN_Confidence,
    a.AC_GEN_Stance,
    a.,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    attributes.AC_GEN_Actor_Gender_Fact p
JOIN
    attributes.AC_GEN_Actor_Gender_Meta a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
WHERE
    a.AC_GEN_Who = 0
AND
    a.AC_GEN_PositedAt = (
        SELECT
            MAX(sub.AC_GEN_PositedAt)
        FROM
            attributes.AC_GEN_Actor_Gender_Meta sub
        WHERE
            sub.AC_GEN_ID = p.AC_GEN_ID
        AND
            sub.AC_GEN_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_PLV_Actor_ProfessionalLevel AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Who,
    a.AC_PLV_Confidence,
    a.AC_PLV_Stance,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID
    , p.AC_PLV_ChangedAt
FROM
    attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
JOIN
    attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
WHERE
    a.AC_PLV_Who = 0
AND
    a.AC_PLV_PositedAt = (
        SELECT
            MAX(sub.AC_PLV_PositedAt)
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta sub
        WHERE
            sub.AC_PLV_ID = p.AC_PLV_ID
        AND
            sub.AC_PLV_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_NAM_Program_Name AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Who,
    a.PR_NAM_Confidence,
    a.PR_NAM_Stance,
    a.,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name
FROM
    attributes.PR_NAM_Program_Name_Fact p
JOIN
    attributes.PR_NAM_Program_Name_Meta a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
WHERE
    a.PR_NAM_Who = 0
AND
    a.PR_NAM_PositedAt = (
        SELECT
            MAX(sub.PR_NAM_PositedAt)
        FROM
            attributes.PR_NAM_Program_Name_Meta sub
        WHERE
            sub.PR_NAM_ID = p.PR_NAM_ID
        AND
            sub.PR_NAM_Who = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_LEN_Program_Length AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Who,
    a.PR_LEN_Confidence,
    a.PR_LEN_Stance,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length
    , p.PR_LEN_ChangedAt
FROM
    attributes.PR_LEN_Program_Length_Fact p
JOIN
    attributes.PR_LEN_Program_Length_Meta a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
WHERE
    a.PR_LEN_Who = 0
AND
    a.PR_LEN_PositedAt = (
        SELECT
            MAX(sub.PR_LEN_PositedAt)
        FROM
            attributes.PR_LEN_Program_Length_Meta sub
        WHERE
            sub.PR_LEN_ID = p.PR_LEN_ID
        AND
            sub.PR_LEN_Who = 0
    )
;
