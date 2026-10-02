-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public.EV_DAT_Event_Date COPY GRANTS AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Event_Date,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion
FROM
    public.EV_DAT_Event_Date_Posit p
JOIN
    public.EV_DAT_Event_Date_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW public.EV_AUD_Event_Audience COPY GRANTS AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Event_Audience,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion
FROM
    public.EV_AUD_Event_Audience_Posit p
JOIN
    public.EV_AUD_Event_Audience_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW public.EV_REV_Event_Revenue COPY GRANTS AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    p.EV_REV_EV_ID,
    p.EV_REV_Event_Revenue,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion
FROM
    public.EV_REV_Event_Revenue_Posit p
JOIN
    public.EV_REV_Event_Revenue_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW public.ST_NAM_Stage_Name COPY GRANTS AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Checksum,
    p.ST_NAM_Stage_Name,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion
FROM
    public.ST_NAM_Stage_Name_Posit p
JOIN
    public.ST_NAM_Stage_Name_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW public.ST_LOC_Stage_Location COPY GRANTS AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Stage_Location,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion
FROM
    public.ST_LOC_Stage_Location_Posit p
JOIN
    public.ST_LOC_Stage_Location_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW public.ST_AVG_Stage_Average COPY GRANTS AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion
FROM
    public.ST_AVG_Stage_Average_Posit p
JOIN
    public.ST_AVG_Stage_Average_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW public.ST_MIN_Stage_Minimum COPY GRANTS AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion
FROM
    public.ST_MIN_Stage_Minimum_Posit p
JOIN
    public.ST_MIN_Stage_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW public.AC_NAM_Actor_Name COPY GRANTS AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Checksum,
    p.AC_NAM_Actor_Name,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion
FROM
    public.AC_NAM_Actor_Name_Posit p
JOIN
    public.AC_NAM_Actor_Name_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW public.AC_GEN_Actor_Gender COPY GRANTS AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion
FROM
    public.AC_GEN_Actor_Gender_Posit p
JOIN
    public.AC_GEN_Actor_Gender_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW public.AC_PLV_Actor_ProfessionalLevel COPY GRANTS AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion
FROM
    public.AC_PLV_Actor_ProfessionalLevel_Posit p
JOIN
    public.AC_PLV_Actor_ProfessionalLevel_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW public.PR_NAM_Program_Name COPY GRANTS AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Program_Name,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion
FROM
    public.PR_NAM_Program_Name_Posit p
JOIN
    public.PR_NAM_Program_Name_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW public.PR_LEN_Program_Length COPY GRANTS AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Program_Length,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion
FROM
    public.PR_LEN_Program_Length_Posit p
JOIN
    public.PR_LEN_Program_Length_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
