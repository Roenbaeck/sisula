-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_Subject" (
    "SU_ID",
    "Metadata_SU",
    "SU_NAM_SU_ID",
    "Metadata_SU_NAM",
    "Deletable_SU_NAM",
    "SU_NAM_Subject_Name",
    "SU_COD_SU_ID",
    "Metadata_SU_COD",
    "SU_COD_Subject_Code",
    "SU_GRD_SU_ID",
    "Metadata_SU_GRD",
    "SU_GRD_GRD_Grade",
    "SU_GRD_Metadata_GRD",
    "SU_GRD_GRD_ID",
    "SU_NOT_SU_ID",
    "Metadata_SU_NOT",
    "SU_NOT_Checksum",
    "SU_NOT_Subject_Note",
    "SU_TTL_SU_ID",
    "Metadata_SU_TTL",
    "SU_TTL_ChangedAt",
    "SU_TTL_Subject_Title",
    "SU_STA_SU_ID",
    "Metadata_SU_STA",
    "SU_STA_ChangedAt",
    "SU_STA_Subject_State",
    "SU_LBL_SU_ID",
    "Metadata_SU_LBL",
    "SU_LBL_ChangedAt",
    "SU_LBL_Subject_Label",
    "SU_TAG_SU_ID",
    "Metadata_SU_TAG",
    "SU_TAG_ChangedAt",
    "SU_TAG_Subject_Tag",
    "SU_LVL_SU_ID",
    "Metadata_SU_LVL",
    "Deletable_SU_LVL",
    "SU_LVL_ChangedAt",
    "SU_LVL_GRD_Grade",
    "SU_LVL_Metadata_GRD",
    "SU_LVL_GRD_ID",
    "SU_TXT_SU_ID",
    "Metadata_SU_TXT",
    "SU_TXT_ChangedAt",
    "SU_TXT_Checksum",
    "SU_TXT_Subject_Text",
    "SU_ASR_SU_ID",
    "Metadata_SU_ASR",
    "SU_ASR_ChangedAt",
    "SU_ASR_Subject_Assessment",
    "SU_ERS_SU_ID",
    "Metadata_SU_ERS",
    "Deletable_SU_ERS",
    "SU_ERS_ChangedAt",
    "SU_ERS_Subject_Erasable"
)
AS
SELECT
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    NULL::boolean,
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    NULL::boolean,
    "LVL"."SU_LVL_ChangedAt",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    NULL::boolean,
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_Subject_Erasable"
FROM
    public."SU_Subject" "SU"
LEFT JOIN
    public."SU_NAM_Subject_Name" "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_COD_Subject_Code" "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_GRD_Subject_Grade" "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN
    public."SU_NOT_Subject_Note" "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_TTL_Subject_Title" "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" = (
        SELECT
            max(sub."SU_TTL_ChangedAt")
        FROM
            public."SU_TTL_Subject_Title" sub
        WHERE
            sub."SU_TTL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_STA_Subject_State" "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" = (
        SELECT
            max(sub."SU_STA_ChangedAt")
        FROM
            public."SU_STA_Subject_State" sub
        WHERE
            sub."SU_STA_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_LBL_Subject_Label" "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" = (
        SELECT
            max(sub."SU_LBL_ChangedAt")
        FROM
            public."SU_LBL_Subject_Label" sub
        WHERE
            sub."SU_LBL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_TAG_Subject_Tag" "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" = (
        SELECT
            max(sub."SU_TAG_ChangedAt")
        FROM
            public."SU_TAG_Subject_Tag" sub
        WHERE
            sub."SU_TAG_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_LVL_Subject_Level" "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" = (
        SELECT
            max(sub."SU_LVL_ChangedAt")
        FROM
            public."SU_LVL_Subject_Level" sub
        WHERE
            sub."SU_LVL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN
    public."SU_TXT_Subject_Text" "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" = (
        SELECT
            max(sub."SU_TXT_ChangedAt")
        FROM
            public."SU_TXT_Subject_Text" sub
        WHERE
            sub."SU_TXT_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_ASR_Subject_Assessment" "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" = (
        SELECT
            max(sub."SU_ASR_ChangedAt")
        FROM
            public."SU_ASR_Subject_Assessment" sub
        WHERE
            sub."SU_ASR_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_ERS_Subject_Erasable" "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" = (
        SELECT
            max(sub."SU_ERS_ChangedAt")
        FROM
            public."SU_ERS_Subject_Erasable" sub
        WHERE
            sub."SU_ERS_SU_ID" = "SU"."SU_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_Subject" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
SELECT
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ChangedAt",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_Subject_Erasable"
FROM
    public."SU_Subject" "SU"
LEFT JOIN
    public."SU_NAM_Subject_Name" "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_COD_Subject_Code" "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_GRD_Subject_Grade" "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN
    public."SU_NOT_Subject_Note" "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."rSU_TTL_Subject_Title"(changingTimepoint::timestamp) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" = (
        SELECT
            max(sub."SU_TTL_ChangedAt")
        FROM
            public."rSU_TTL_Subject_Title"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_TTL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_STA_Subject_State"(changingTimepoint::timestamp) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" = (
        SELECT
            max(sub."SU_STA_ChangedAt")
        FROM
            public."rSU_STA_Subject_State"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_STA_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_LBL_Subject_Label"(changingTimepoint::timestamp) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" = (
        SELECT
            max(sub."SU_LBL_ChangedAt")
        FROM
            public."rSU_LBL_Subject_Label"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_LBL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_TAG_Subject_Tag"(changingTimepoint::timestamp) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" = (
        SELECT
            max(sub."SU_TAG_ChangedAt")
        FROM
            public."rSU_TAG_Subject_Tag"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_TAG_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_LVL_Subject_Level"(changingTimepoint::timestamp) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" = (
        SELECT
            max(sub."SU_LVL_ChangedAt")
        FROM
            public."rSU_LVL_Subject_Level"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_LVL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN
    public."rSU_TXT_Subject_Text"(changingTimepoint::timestamp) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" = (
        SELECT
            max(sub."SU_TXT_ChangedAt")
        FROM
            public."rSU_TXT_Subject_Text"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_TXT_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_ASR_Subject_Assessment"(changingTimepoint::timestamp) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" = (
        SELECT
            max(sub."SU_ASR_ChangedAt")
        FROM
            public."rSU_ASR_Subject_Assessment"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_ASR_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_ERS_Subject_Erasable"(changingTimepoint::timestamp) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" = (
        SELECT
            max(sub."SU_ERS_ChangedAt")
        FROM
            public."rSU_ERS_Subject_Erasable"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_ERS_SU_ID" = "SU"."SU_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_Subject"
AS
SELECT
    *
FROM
    public."pSU_Subject"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_Subject" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ChangedAt",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_Subject_Erasable"
FROM (
    SELECT DISTINCT
        h."SU_TTL_SU_ID" AS "SU_ID",
        h."SU_TTL_ChangedAt"::timestamp AS inspectedTimepoint,
        'TTL' AS mnemonic
    FROM
        public."SU_TTL_Subject_Title" h
    WHERE
        (selection IS NULL OR selection LIKE '%TTL%')
    AND
        h."SU_TTL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_STA_SU_ID" AS "SU_ID",
        h."SU_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        public."SU_STA_Subject_State" h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h."SU_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_LBL_SU_ID" AS "SU_ID",
        h."SU_LBL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LBL' AS mnemonic
    FROM
        public."SU_LBL_Subject_Label" h
    WHERE
        (selection IS NULL OR selection LIKE '%LBL%')
    AND
        h."SU_LBL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_TAG_SU_ID" AS "SU_ID",
        h."SU_TAG_ChangedAt"::timestamp AS inspectedTimepoint,
        'TAG' AS mnemonic
    FROM
        public."SU_TAG_Subject_Tag" h
    WHERE
        (selection IS NULL OR selection LIKE '%TAG%')
    AND
        h."SU_TAG_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_LVL_SU_ID" AS "SU_ID",
        h."SU_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        public."SU_LVL_Subject_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."SU_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_TXT_SU_ID" AS "SU_ID",
        h."SU_TXT_ChangedAt"::timestamp AS inspectedTimepoint,
        'TXT' AS mnemonic
    FROM
        public."SU_TXT_Subject_Text" h
    WHERE
        (selection IS NULL OR selection LIKE '%TXT%')
    AND
        h."SU_TXT_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_ASR_SU_ID" AS "SU_ID",
        h."SU_ASR_ChangedAt"::timestamp AS inspectedTimepoint,
        'ASR' AS mnemonic
    FROM
        public."SU_ASR_Subject_Assessment" h
    WHERE
        (selection IS NULL OR selection LIKE '%ASR%')
    AND
        h."SU_ASR_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_ERS_SU_ID" AS "SU_ID",
        h."SU_ERS_ChangedAt"::timestamp AS inspectedTimepoint,
        'ERS' AS mnemonic
    FROM
        public."SU_ERS_Subject_Erasable" h
    WHERE
        (selection IS NULL OR selection LIKE '%ERS%')
    AND
        h."SU_ERS_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."SU_Subject" "SU"
ON
    "SU"."SU_ID" = timepoints."SU_ID"
LEFT JOIN
    public."SU_NAM_Subject_Name" "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_COD_Subject_Code" "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_GRD_Subject_Grade" "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN
    public."SU_NOT_Subject_Note" "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_TTL_ChangedAt") OVER (
            PARTITION BY h."SU_TTL_SU_ID"
            ORDER BY h."SU_TTL_ChangedAt"
        ) AS "until"
    FROM
        public."SU_TTL_Subject_Title" h
) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TTL"."until" IS NULL
OR
    "TTL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_STA_ChangedAt") OVER (
            PARTITION BY h."SU_STA_SU_ID"
            ORDER BY h."SU_STA_ChangedAt"
        ) AS "until"
    FROM
        public."SU_STA_Subject_State" h
) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_LBL_ChangedAt") OVER (
            PARTITION BY h."SU_LBL_SU_ID"
            ORDER BY h."SU_LBL_ChangedAt"
        ) AS "until"
    FROM
        public."SU_LBL_Subject_Label" h
) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "LBL"."until" IS NULL
OR
    "LBL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_TAG_ChangedAt") OVER (
            PARTITION BY h."SU_TAG_SU_ID"
            ORDER BY h."SU_TAG_ChangedAt"
        ) AS "until"
    FROM
        public."SU_TAG_Subject_Tag" h
) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TAG"."until" IS NULL
OR
    "TAG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_LVL_ChangedAt") OVER (
            PARTITION BY h."SU_LVL_SU_ID"
            ORDER BY h."SU_LVL_ChangedAt"
        ) AS "until"
    FROM
        public."SU_LVL_Subject_Level" h
) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_TXT_ChangedAt") OVER (
            PARTITION BY h."SU_TXT_SU_ID"
            ORDER BY h."SU_TXT_ChangedAt"
        ) AS "until"
    FROM
        public."SU_TXT_Subject_Text" h
) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TXT"."until" IS NULL
OR
    "TXT"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_ASR_ChangedAt") OVER (
            PARTITION BY h."SU_ASR_SU_ID"
            ORDER BY h."SU_ASR_ChangedAt"
        ) AS "until"
    FROM
        public."SU_ASR_Subject_Assessment" h
) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "ASR"."until" IS NULL
OR
    "ASR"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_ERS_ChangedAt") OVER (
            PARTITION BY h."SU_ERS_SU_ID"
            ORDER BY h."SU_ERS_ChangedAt"
        ) AS "until"
    FROM
        public."SU_ERS_Subject_Erasable" h
) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "ERS"."until" IS NULL
OR
    "ERS"."until" > timepoints.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lOB_Object" (
    "OB_ID",
    "Metadata_OB",
    "OB_NAM_OB_ID",
    "Metadata_OB_NAM",
    "OB_NAM_Object_Name"
)
AS
SELECT
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "NAM"."OB_NAM_OB_ID",
    "NAM"."Metadata_OB_NAM",
    "NAM"."OB_NAM_Object_Name"
FROM
    public."OB_Object" "OB"
LEFT JOIN
    public."OB_NAM_Object_Name" "NAM"
ON
    "NAM"."OB_NAM_OB_ID" = "OB"."OB_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pOB_Object" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "OB_ID" integer,
    "Metadata_OB" integer,
    "OB_NAM_OB_ID" integer,
    "Metadata_OB_NAM" integer,
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "NAM"."OB_NAM_OB_ID",
    "NAM"."Metadata_OB_NAM",
    "NAM"."OB_NAM_Object_Name"
FROM
    public."OB_Object" "OB"
LEFT JOIN
    public."OB_NAM_Object_Name" "NAM"
ON
    "NAM"."OB_NAM_OB_ID" = "OB"."OB_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nOB_Object"
AS
SELECT
    *
FROM
    public."pOB_Object"(current_timestamp::timestamp)
;
