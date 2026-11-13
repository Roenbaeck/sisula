-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW EV_QTY_Event_Quantity AS
SELECT
    a.Metadata_EV_QTY,
    p.EV_QTY_ID,
    p.EV_QTY_EV_ID,
    p.EV_QTY_Event_Quantity,
    a.EV_QTY_PositedAt,
    a.EV_QTY_Positor,
    a.EV_QTY_Reliability,
    a.EV_QTY_Assertion
FROM
    EV_QTY_Event_Quantity_Posit p
JOIN
    EV_QTY_Event_Quantity_Annex a
ON
    a.EV_QTY_ID = p.EV_QTY_ID
;
CREATE OR REPLACE VIEW EV_PLC_Event_Place AS
SELECT
    a.Metadata_EV_PLC,
    p.EV_PLC_ID,
    p.EV_PLC_EV_ID,
    p.EV_PLC_Event_Place,
    p.EV_PLC_ChangedAt,
    a.EV_PLC_PositedAt,
    a.EV_PLC_Positor,
    a.EV_PLC_Reliability,
    a.EV_PLC_Assertion
FROM
    EV_PLC_Event_Place_Posit p
JOIN
    EV_PLC_Event_Place_Annex a
ON
    a.EV_PLC_ID = p.EV_PLC_ID
;
CREATE OR REPLACE VIEW SU_NAM_Subject_Name AS
SELECT
    a.Metadata_SU_NAM,
    p.SU_NAM_ID,
    p.SU_NAM_SU_ID,
    p.SU_NAM_Subject_Name,
    a.SU_NAM_PositedAt,
    a.SU_NAM_Positor,
    a.SU_NAM_Reliability,
    a.SU_NAM_Assertion
FROM
    SU_NAM_Subject_Name_Posit p
JOIN
    SU_NAM_Subject_Name_Annex a
ON
    a.SU_NAM_ID = p.SU_NAM_ID
;
CREATE OR REPLACE VIEW SU_COD_Subject_Code AS
SELECT
    a.Metadata_SU_COD,
    p.SU_COD_ID,
    p.SU_COD_SU_ID,
    p.SU_COD_Subject_Code,
    a.SU_COD_PositedAt,
    a.SU_COD_Positor,
    a.SU_COD_Reliability,
    a.SU_COD_Assertion
FROM
    SU_COD_Subject_Code_Posit p
JOIN
    SU_COD_Subject_Code_Annex a
ON
    a.SU_COD_ID = p.SU_COD_ID
;
CREATE OR REPLACE VIEW SU_GRD_Subject_Grade AS
SELECT
    a.Metadata_SU_GRD,
    p.SU_GRD_ID,
    p.SU_GRD_SU_ID,
    p.SU_GRD_GRD_ID,
    a.SU_GRD_PositedAt,
    a.SU_GRD_Positor,
    a.SU_GRD_Reliability,
    a.SU_GRD_Assertion
FROM
    SU_GRD_Subject_Grade_Posit p
JOIN
    SU_GRD_Subject_Grade_Annex a
ON
    a.SU_GRD_ID = p.SU_GRD_ID
;
CREATE OR REPLACE VIEW SU_NOT_Subject_Note AS
SELECT
    a.Metadata_SU_NOT,
    p.SU_NOT_ID,
    p.SU_NOT_SU_ID,
    p.SU_NOT_Subject_Note,
    a.SU_NOT_PositedAt,
    a.SU_NOT_Positor,
    a.SU_NOT_Reliability,
    a.SU_NOT_Assertion
FROM
    SU_NOT_Subject_Note_Posit p
JOIN
    SU_NOT_Subject_Note_Annex a
ON
    a.SU_NOT_ID = p.SU_NOT_ID
;
CREATE OR REPLACE VIEW SU_TTL_Subject_Title AS
SELECT
    a.Metadata_SU_TTL,
    p.SU_TTL_ID,
    p.SU_TTL_SU_ID,
    p.SU_TTL_Subject_Title,
    p.SU_TTL_ChangedAt,
    a.SU_TTL_PositedAt,
    a.SU_TTL_Positor,
    a.SU_TTL_Reliability,
    a.SU_TTL_Assertion
FROM
    SU_TTL_Subject_Title_Posit p
JOIN
    SU_TTL_Subject_Title_Annex a
ON
    a.SU_TTL_ID = p.SU_TTL_ID
;
CREATE OR REPLACE VIEW SU_STA_Subject_State AS
SELECT
    a.Metadata_SU_STA,
    p.SU_STA_ID,
    p.SU_STA_SU_ID,
    p.SU_STA_Subject_State,
    p.SU_STA_ChangedAt,
    a.SU_STA_PositedAt,
    a.SU_STA_Positor,
    a.SU_STA_Reliability,
    a.SU_STA_Assertion
FROM
    SU_STA_Subject_State_Posit p
JOIN
    SU_STA_Subject_State_Annex a
ON
    a.SU_STA_ID = p.SU_STA_ID
;
CREATE OR REPLACE VIEW SU_LBL_Subject_Label AS
SELECT
    a.Metadata_SU_LBL,
    p.SU_LBL_ID,
    p.SU_LBL_SU_ID,
    p.SU_LBL_Subject_Label,
    p.SU_LBL_ChangedAt,
    a.SU_LBL_PositedAt,
    a.SU_LBL_Positor,
    a.SU_LBL_Reliability,
    a.SU_LBL_Assertion
FROM
    SU_LBL_Subject_Label_Posit p
JOIN
    SU_LBL_Subject_Label_Annex a
ON
    a.SU_LBL_ID = p.SU_LBL_ID
;
CREATE OR REPLACE VIEW SU_TAG_Subject_Tag AS
SELECT
    a.Metadata_SU_TAG,
    p.SU_TAG_ID,
    p.SU_TAG_SU_ID,
    p.SU_TAG_Subject_Tag,
    p.SU_TAG_ChangedAt,
    a.SU_TAG_PositedAt,
    a.SU_TAG_Positor,
    a.SU_TAG_Reliability,
    a.SU_TAG_Assertion
FROM
    SU_TAG_Subject_Tag_Posit p
JOIN
    SU_TAG_Subject_Tag_Annex a
ON
    a.SU_TAG_ID = p.SU_TAG_ID
;
CREATE OR REPLACE VIEW SU_LVL_Subject_Level AS
SELECT
    a.Metadata_SU_LVL,
    p.SU_LVL_ID,
    p.SU_LVL_SU_ID,
    p.SU_LVL_GRD_ID,
    p.SU_LVL_ChangedAt,
    a.SU_LVL_PositedAt,
    a.SU_LVL_Positor,
    a.SU_LVL_Reliability,
    a.SU_LVL_Assertion
FROM
    SU_LVL_Subject_Level_Posit p
JOIN
    SU_LVL_Subject_Level_Annex a
ON
    a.SU_LVL_ID = p.SU_LVL_ID
;
CREATE OR REPLACE VIEW SU_TXT_Subject_Text AS
SELECT
    a.Metadata_SU_TXT,
    p.SU_TXT_ID,
    p.SU_TXT_SU_ID,
    p.SU_TXT_Subject_Text,
    p.SU_TXT_ChangedAt,
    a.SU_TXT_PositedAt,
    a.SU_TXT_Positor,
    a.SU_TXT_Reliability,
    a.SU_TXT_Assertion
FROM
    SU_TXT_Subject_Text_Posit p
JOIN
    SU_TXT_Subject_Text_Annex a
ON
    a.SU_TXT_ID = p.SU_TXT_ID
;
CREATE OR REPLACE VIEW SU_ASR_Subject_Assessment AS
SELECT
    a.Metadata_SU_ASR,
    p.SU_ASR_ID,
    p.SU_ASR_SU_ID,
    p.SU_ASR_Subject_Assessment,
    p.SU_ASR_ChangedAt,
    a.SU_ASR_PositedAt,
    a.SU_ASR_Positor,
    a.SU_ASR_Reliability,
    a.SU_ASR_Assertion
FROM
    SU_ASR_Subject_Assessment_Posit p
JOIN
    SU_ASR_Subject_Assessment_Annex a
ON
    a.SU_ASR_ID = p.SU_ASR_ID
;
CREATE OR REPLACE VIEW SU_ERS_Subject_Erasable AS
SELECT
    a.Metadata_SU_ERS,
    p.SU_ERS_ID,
    p.SU_ERS_SU_ID,
    p.SU_ERS_Subject_Erasable,
    p.SU_ERS_ChangedAt,
    a.SU_ERS_PositedAt,
    a.SU_ERS_Positor,
    a.SU_ERS_Reliability,
    a.SU_ERS_Assertion
FROM
    SU_ERS_Subject_Erasable_Posit p
JOIN
    SU_ERS_Subject_Erasable_Annex a
ON
    a.SU_ERS_ID = p.SU_ERS_ID
;
CREATE OR REPLACE VIEW OB_NAM_Object_Name AS
SELECT
    a.Metadata_OB_NAM,
    p.OB_NAM_ID,
    p.OB_NAM_OB_ID,
    p.OB_NAM_Object_Name,
    a.OB_NAM_PositedAt,
    a.OB_NAM_Positor,
    a.OB_NAM_Reliability,
    a.OB_NAM_Assertion
FROM
    OB_NAM_Object_Name_Posit p
JOIN
    OB_NAM_Object_Name_Annex a
ON
    a.OB_NAM_ID = p.OB_NAM_ID
;
