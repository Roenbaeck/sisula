-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."EV_QTY_Event_Quantity" AS
SELECT
    a."Metadata_EV_QTY",
    p."EV_QTY_ID",
    p."EV_QTY_EV_ID",
    p."EV_QTY_Event_Quantity",
    a."EV_QTY_PositedAt",
    a."EV_QTY_Reliability"
FROM
    public."EV_QTY_Event_Quantity_Posit" p
JOIN
    public."EV_QTY_Event_Quantity_Annex" a
ON
    a."EV_QTY_ID" = p."EV_QTY_ID"
;
CREATE OR REPLACE VIEW public."EV_PLC_Event_Place" AS
SELECT
    a."Metadata_EV_PLC",
    p."EV_PLC_ID",
    p."EV_PLC_EV_ID",
    p."EV_PLC_Event_Place",
    p."EV_PLC_ChangedAt",
    a."EV_PLC_PositedAt",
    a."EV_PLC_Reliability"
FROM
    public."EV_PLC_Event_Place_Posit" p
JOIN
    public."EV_PLC_Event_Place_Annex" a
ON
    a."EV_PLC_ID" = p."EV_PLC_ID"
;
CREATE OR REPLACE VIEW public."SU_NAM_Subject_Name" AS
SELECT
    a."Metadata_SU_NAM",
    p."SU_NAM_ID",
    p."SU_NAM_SU_ID",
    p."SU_NAM_Subject_Name",
    a."SU_NAM_PositedAt",
    a."SU_NAM_Reliability"
FROM
    public."SU_NAM_Subject_Name_Posit" p
JOIN
    public."SU_NAM_Subject_Name_Annex" a
ON
    a."SU_NAM_ID" = p."SU_NAM_ID"
;
CREATE OR REPLACE VIEW public."SU_COD_Subject_Code" AS
SELECT
    a."Metadata_SU_COD",
    p."SU_COD_ID",
    p."SU_COD_SU_ID",
    p."SU_COD_Subject_Code",
    a."SU_COD_PositedAt",
    a."SU_COD_Reliability"
FROM
    public."SU_COD_Subject_Code_Posit" p
JOIN
    public."SU_COD_Subject_Code_Annex" a
ON
    a."SU_COD_ID" = p."SU_COD_ID"
;
CREATE OR REPLACE VIEW public."SU_GRD_Subject_Grade" AS
SELECT
    a."Metadata_SU_GRD",
    p."SU_GRD_ID",
    p."SU_GRD_SU_ID",
    p."SU_GRD_GRD_ID",
    a."SU_GRD_PositedAt",
    a."SU_GRD_Reliability"
FROM
    public."SU_GRD_Subject_Grade_Posit" p
JOIN
    public."SU_GRD_Subject_Grade_Annex" a
ON
    a."SU_GRD_ID" = p."SU_GRD_ID"
;
CREATE OR REPLACE VIEW public."SU_NOT_Subject_Note" AS
SELECT
    a."Metadata_SU_NOT",
    p."SU_NOT_ID",
    p."SU_NOT_SU_ID",
    p."SU_NOT_Checksum",
    p."SU_NOT_Subject_Note",
    a."SU_NOT_PositedAt",
    a."SU_NOT_Reliability"
FROM
    public."SU_NOT_Subject_Note_Posit" p
JOIN
    public."SU_NOT_Subject_Note_Annex" a
ON
    a."SU_NOT_ID" = p."SU_NOT_ID"
;
CREATE OR REPLACE VIEW public."SU_TTL_Subject_Title" AS
SELECT
    a."Metadata_SU_TTL",
    p."SU_TTL_ID",
    p."SU_TTL_SU_ID",
    p."SU_TTL_Subject_Title",
    p."SU_TTL_ChangedAt",
    a."SU_TTL_PositedAt",
    a."SU_TTL_Reliability"
FROM
    public."SU_TTL_Subject_Title_Posit" p
JOIN
    public."SU_TTL_Subject_Title_Annex" a
ON
    a."SU_TTL_ID" = p."SU_TTL_ID"
;
CREATE OR REPLACE VIEW public."SU_STA_Subject_State" AS
SELECT
    a."Metadata_SU_STA",
    p."SU_STA_ID",
    p."SU_STA_SU_ID",
    p."SU_STA_Subject_State",
    p."SU_STA_ChangedAt",
    a."SU_STA_PositedAt",
    a."SU_STA_Reliability"
FROM
    public."SU_STA_Subject_State_Posit" p
JOIN
    public."SU_STA_Subject_State_Annex" a
ON
    a."SU_STA_ID" = p."SU_STA_ID"
;
CREATE OR REPLACE VIEW public."SU_LBL_Subject_Label" AS
SELECT
    a."Metadata_SU_LBL",
    p."SU_LBL_ID",
    p."SU_LBL_SU_ID",
    p."SU_LBL_Subject_Label",
    p."SU_LBL_ChangedAt",
    a."SU_LBL_PositedAt",
    a."SU_LBL_Reliability"
FROM
    public."SU_LBL_Subject_Label_Posit" p
JOIN
    public."SU_LBL_Subject_Label_Annex" a
ON
    a."SU_LBL_ID" = p."SU_LBL_ID"
;
CREATE OR REPLACE VIEW public."SU_TAG_Subject_Tag" AS
SELECT
    a."Metadata_SU_TAG",
    p."SU_TAG_ID",
    p."SU_TAG_SU_ID",
    p."SU_TAG_Subject_Tag",
    p."SU_TAG_ChangedAt",
    a."SU_TAG_PositedAt",
    a."SU_TAG_Reliability"
FROM
    public."SU_TAG_Subject_Tag_Posit" p
JOIN
    public."SU_TAG_Subject_Tag_Annex" a
ON
    a."SU_TAG_ID" = p."SU_TAG_ID"
;
CREATE OR REPLACE VIEW public."SU_LVL_Subject_Level" AS
SELECT
    a."Metadata_SU_LVL",
    p."SU_LVL_ID",
    p."SU_LVL_SU_ID",
    p."SU_LVL_GRD_ID",
    p."SU_LVL_ChangedAt",
    a."SU_LVL_PositedAt",
    a."SU_LVL_Reliability"
FROM
    public."SU_LVL_Subject_Level_Posit" p
JOIN
    public."SU_LVL_Subject_Level_Annex" a
ON
    a."SU_LVL_ID" = p."SU_LVL_ID"
;
CREATE OR REPLACE VIEW public."SU_TXT_Subject_Text" AS
SELECT
    a."Metadata_SU_TXT",
    p."SU_TXT_ID",
    p."SU_TXT_SU_ID",
    p."SU_TXT_Checksum",
    p."SU_TXT_Subject_Text",
    p."SU_TXT_ChangedAt",
    a."SU_TXT_PositedAt",
    a."SU_TXT_Reliability"
FROM
    public."SU_TXT_Subject_Text_Posit" p
JOIN
    public."SU_TXT_Subject_Text_Annex" a
ON
    a."SU_TXT_ID" = p."SU_TXT_ID"
;
CREATE OR REPLACE VIEW public."SU_ASR_Subject_Assessment" AS
SELECT
    a."Metadata_SU_ASR",
    p."SU_ASR_ID",
    p."SU_ASR_SU_ID",
    p."SU_ASR_Subject_Assessment",
    p."SU_ASR_ChangedAt",
    a."SU_ASR_PositedAt",
    a."SU_ASR_Reliability"
FROM
    public."SU_ASR_Subject_Assessment_Posit" p
JOIN
    public."SU_ASR_Subject_Assessment_Annex" a
ON
    a."SU_ASR_ID" = p."SU_ASR_ID"
;
CREATE OR REPLACE VIEW public."SU_ERS_Subject_Erasable" AS
SELECT
    a."Metadata_SU_ERS",
    p."SU_ERS_ID",
    p."SU_ERS_SU_ID",
    p."SU_ERS_Subject_Erasable",
    p."SU_ERS_ChangedAt",
    a."SU_ERS_PositedAt",
    a."SU_ERS_Reliability"
FROM
    public."SU_ERS_Subject_Erasable_Posit" p
JOIN
    public."SU_ERS_Subject_Erasable_Annex" a
ON
    a."SU_ERS_ID" = p."SU_ERS_ID"
;
CREATE OR REPLACE VIEW public."OB_NAM_Object_Name" AS
SELECT
    a."Metadata_OB_NAM",
    p."OB_NAM_ID",
    p."OB_NAM_OB_ID",
    p."OB_NAM_Object_Name",
    a."OB_NAM_PositedAt",
    a."OB_NAM_Reliability"
FROM
    public."OB_NAM_Object_Name_Posit" p
JOIN
    public."OB_NAM_Object_Name_Annex" a
ON
    a."OB_NAM_ID" = p."OB_NAM_ID"
;
