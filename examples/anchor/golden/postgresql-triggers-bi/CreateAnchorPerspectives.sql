-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tSU_Subject" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
SELECT
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_ID",
    "NAM"."SU_NAM_PositedAt",
    "NAM"."SU_NAM_Reliability",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_ID",
    "COD"."SU_COD_PositedAt",
    "COD"."SU_COD_Reliability",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "GRD"."SU_GRD_ID",
    "GRD"."SU_GRD_PositedAt",
    "GRD"."SU_GRD_Reliability",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_ID",
    "NOT"."SU_NOT_PositedAt",
    "NOT"."SU_NOT_Reliability",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ID",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_PositedAt",
    "TTL"."SU_TTL_Reliability",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ID",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_PositedAt",
    "STA"."SU_STA_Reliability",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ID",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_PositedAt",
    "LBL"."SU_LBL_Reliability",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ID",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_PositedAt",
    "TAG"."SU_TAG_Reliability",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ID",
    "LVL"."SU_LVL_ChangedAt",
    "LVL"."SU_LVL_PositedAt",
    "LVL"."SU_LVL_Reliability",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ID",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_PositedAt",
    "TXT"."SU_TXT_Reliability",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ID",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_PositedAt",
    "ASR"."SU_ASR_Reliability",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ID",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_PositedAt",
    "ERS"."SU_ERS_Reliability",
    "ERS"."SU_ERS_Subject_Erasable"
FROM
    public."SU_Subject" "SU"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_NAM_SU_ID")
        r.*
    FROM
        public."rSU_NAM_Subject_Name"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_NAM_Reliability" = 1
    ORDER BY
    r."SU_NAM_SU_ID",
    r."SU_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_COD_SU_ID")
        r.*
    FROM
        public."rSU_COD_Subject_Code"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_COD_Reliability" = 1
    ORDER BY
    r."SU_COD_SU_ID",
    r."SU_COD_PositedAt" DESC
) "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_GRD_SU_ID")
        r.*
    FROM
        public."rSU_GRD_Subject_Grade"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_GRD_Reliability" = 1
    ORDER BY
    r."SU_GRD_SU_ID",
    r."SU_GRD_PositedAt" DESC
) "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_NOT_SU_ID")
        r.*
    FROM
        public."rSU_NOT_Subject_Note"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_NOT_Reliability" = 1
    ORDER BY
    r."SU_NOT_SU_ID",
    r."SU_NOT_PositedAt" DESC
) "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_TTL_SU_ID")
        r.*
    FROM
        public."rSU_TTL_Subject_Title"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_TTL_Reliability" = 1
    ORDER BY
    r."SU_TTL_SU_ID",
    r."SU_TTL_ChangedAt" DESC,
    r."SU_TTL_PositedAt" DESC
) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_STA_SU_ID")
        r.*
    FROM
        public."rSU_STA_Subject_State"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_STA_Reliability" = 1
    ORDER BY
    r."SU_STA_SU_ID",
    r."SU_STA_ChangedAt" DESC,
    r."SU_STA_PositedAt" DESC
) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_LBL_SU_ID")
        r.*
    FROM
        public."rSU_LBL_Subject_Label"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_LBL_Reliability" = 1
    ORDER BY
    r."SU_LBL_SU_ID",
    r."SU_LBL_ChangedAt" DESC,
    r."SU_LBL_PositedAt" DESC
) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_TAG_SU_ID")
        r.*
    FROM
        public."rSU_TAG_Subject_Tag"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_TAG_Reliability" = 1
    ORDER BY
    r."SU_TAG_SU_ID",
    r."SU_TAG_ChangedAt" DESC,
    r."SU_TAG_PositedAt" DESC
) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_LVL_SU_ID")
        r.*
    FROM
        public."rSU_LVL_Subject_Level"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_LVL_Reliability" = 1
    ORDER BY
    r."SU_LVL_SU_ID",
    r."SU_LVL_ChangedAt" DESC,
    r."SU_LVL_PositedAt" DESC
) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_TXT_SU_ID")
        r.*
    FROM
        public."rSU_TXT_Subject_Text"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_TXT_Reliability" = 1
    ORDER BY
    r."SU_TXT_SU_ID",
    r."SU_TXT_ChangedAt" DESC,
    r."SU_TXT_PositedAt" DESC
) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_ASR_SU_ID")
        r.*
    FROM
        public."rSU_ASR_Subject_Assessment"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_ASR_Reliability" = 1
    ORDER BY
    r."SU_ASR_SU_ID",
    r."SU_ASR_ChangedAt" DESC,
    r."SU_ASR_PositedAt" DESC
) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_ERS_SU_ID")
        r.*
    FROM
        public."rSU_ERS_Subject_Erasable"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_ERS_Reliability" = 1
    ORDER BY
    r."SU_ERS_SU_ID",
    r."SU_ERS_ChangedAt" DESC,
    r."SU_ERS_PositedAt" DESC
) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_Subject" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "SU".*
FROM
    public."tSU_Subject"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "SU"
;
CREATE OR REPLACE FUNCTION public."pSU_Subject" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "SU"."SU_NAM_SU_ID",
    "SU"."Metadata_SU_NAM",
    "SU"."SU_NAM_ID",
    "SU"."SU_NAM_PositedAt",
    "SU"."SU_NAM_Reliability",
    "SU"."SU_NAM_Subject_Name",
    "SU"."SU_COD_SU_ID",
    "SU"."Metadata_SU_COD",
    "SU"."SU_COD_ID",
    "SU"."SU_COD_PositedAt",
    "SU"."SU_COD_Reliability",
    "SU"."SU_COD_Subject_Code",
    "SU"."SU_GRD_SU_ID",
    "SU"."Metadata_SU_GRD",
    "SU"."SU_GRD_ID",
    "SU"."SU_GRD_PositedAt",
    "SU"."SU_GRD_Reliability",
    "SU"."SU_GRD_GRD_Grade",
    "SU"."SU_GRD_Metadata_GRD",
    "SU"."SU_GRD_GRD_ID",
    "SU"."SU_NOT_SU_ID",
    "SU"."Metadata_SU_NOT",
    "SU"."SU_NOT_ID",
    "SU"."SU_NOT_PositedAt",
    "SU"."SU_NOT_Reliability",
    "SU"."SU_NOT_Checksum",
    "SU"."SU_NOT_Subject_Note",
    "SU"."SU_TTL_SU_ID",
    "SU"."Metadata_SU_TTL",
    "SU"."SU_TTL_ID",
    "SU"."SU_TTL_ChangedAt",
    "SU"."SU_TTL_PositedAt",
    "SU"."SU_TTL_Reliability",
    "SU"."SU_TTL_Subject_Title",
    "SU"."SU_STA_SU_ID",
    "SU"."Metadata_SU_STA",
    "SU"."SU_STA_ID",
    "SU"."SU_STA_ChangedAt",
    "SU"."SU_STA_PositedAt",
    "SU"."SU_STA_Reliability",
    "SU"."SU_STA_Subject_State",
    "SU"."SU_LBL_SU_ID",
    "SU"."Metadata_SU_LBL",
    "SU"."SU_LBL_ID",
    "SU"."SU_LBL_ChangedAt",
    "SU"."SU_LBL_PositedAt",
    "SU"."SU_LBL_Reliability",
    "SU"."SU_LBL_Subject_Label",
    "SU"."SU_TAG_SU_ID",
    "SU"."Metadata_SU_TAG",
    "SU"."SU_TAG_ID",
    "SU"."SU_TAG_ChangedAt",
    "SU"."SU_TAG_PositedAt",
    "SU"."SU_TAG_Reliability",
    "SU"."SU_TAG_Subject_Tag",
    "SU"."SU_LVL_SU_ID",
    "SU"."Metadata_SU_LVL",
    "SU"."SU_LVL_ID",
    "SU"."SU_LVL_ChangedAt",
    "SU"."SU_LVL_PositedAt",
    "SU"."SU_LVL_Reliability",
    "SU"."SU_LVL_GRD_Grade",
    "SU"."SU_LVL_Metadata_GRD",
    "SU"."SU_LVL_GRD_ID",
    "SU"."SU_TXT_SU_ID",
    "SU"."Metadata_SU_TXT",
    "SU"."SU_TXT_ID",
    "SU"."SU_TXT_ChangedAt",
    "SU"."SU_TXT_PositedAt",
    "SU"."SU_TXT_Reliability",
    "SU"."SU_TXT_Checksum",
    "SU"."SU_TXT_Subject_Text",
    "SU"."SU_ASR_SU_ID",
    "SU"."Metadata_SU_ASR",
    "SU"."SU_ASR_ID",
    "SU"."SU_ASR_ChangedAt",
    "SU"."SU_ASR_PositedAt",
    "SU"."SU_ASR_Reliability",
    "SU"."SU_ASR_Subject_Assessment",
    "SU"."SU_ERS_SU_ID",
    "SU"."Metadata_SU_ERS",
    "SU"."SU_ERS_ID",
    "SU"."SU_ERS_ChangedAt",
    "SU"."SU_ERS_PositedAt",
    "SU"."SU_ERS_Reliability",
    "SU"."SU_ERS_Subject_Erasable"
FROM
    public."tSU_Subject"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "SU"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_Subject" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "SU".*
FROM
    public."tSU_Subject"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "SU"
;
CREATE OR REPLACE FUNCTION public."dSU_Subject" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_ID",
    "NAM"."SU_NAM_PositedAt",
    "NAM"."SU_NAM_Reliability",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_ID",
    "COD"."SU_COD_PositedAt",
    "COD"."SU_COD_Reliability",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "GRD"."SU_GRD_ID",
    "GRD"."SU_GRD_PositedAt",
    "GRD"."SU_GRD_Reliability",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_ID",
    "NOT"."SU_NOT_PositedAt",
    "NOT"."SU_NOT_Reliability",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ID",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_PositedAt",
    "TTL"."SU_TTL_Reliability",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ID",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_PositedAt",
    "STA"."SU_STA_Reliability",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ID",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_PositedAt",
    "LBL"."SU_LBL_Reliability",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ID",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_PositedAt",
    "TAG"."SU_TAG_Reliability",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ID",
    "LVL"."SU_LVL_ChangedAt",
    "LVL"."SU_LVL_PositedAt",
    "LVL"."SU_LVL_Reliability",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ID",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_PositedAt",
    "TXT"."SU_TXT_Reliability",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ID",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_PositedAt",
    "ASR"."SU_ASR_Reliability",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ID",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_PositedAt",
    "ERS"."SU_ERS_Reliability",
    "ERS"."SU_ERS_Subject_Erasable"
FROM (
    SELECT DISTINCT
        "SU_TTL_SU_ID" AS "SU_ID",
        "SU_TTL_ChangedAt"::timestamp AS inspectedTimepoint,
        'TTL' AS mnemonic
    FROM
        public."SU_TTL_Subject_Title"
    WHERE
        (selection IS NULL OR selection LIKE '%TTL%')
    AND
        "SU_TTL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_STA_SU_ID" AS "SU_ID",
        "SU_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        public."SU_STA_Subject_State"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "SU_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_LBL_SU_ID" AS "SU_ID",
        "SU_LBL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LBL' AS mnemonic
    FROM
        public."SU_LBL_Subject_Label"
    WHERE
        (selection IS NULL OR selection LIKE '%LBL%')
    AND
        "SU_LBL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_TAG_SU_ID" AS "SU_ID",
        "SU_TAG_ChangedAt"::timestamp AS inspectedTimepoint,
        'TAG' AS mnemonic
    FROM
        public."SU_TAG_Subject_Tag"
    WHERE
        (selection IS NULL OR selection LIKE '%TAG%')
    AND
        "SU_TAG_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_LVL_SU_ID" AS "SU_ID",
        "SU_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        public."SU_LVL_Subject_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "SU_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_TXT_SU_ID" AS "SU_ID",
        "SU_TXT_ChangedAt"::timestamp AS inspectedTimepoint,
        'TXT' AS mnemonic
    FROM
        public."SU_TXT_Subject_Text"
    WHERE
        (selection IS NULL OR selection LIKE '%TXT%')
    AND
        "SU_TXT_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_ASR_SU_ID" AS "SU_ID",
        "SU_ASR_ChangedAt"::timestamp AS inspectedTimepoint,
        'ASR' AS mnemonic
    FROM
        public."SU_ASR_Subject_Assessment"
    WHERE
        (selection IS NULL OR selection LIKE '%ASR%')
    AND
        "SU_ASR_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_ERS_SU_ID" AS "SU_ID",
        "SU_ERS_ChangedAt"::timestamp AS inspectedTimepoint,
        'ERS' AS mnemonic
    FROM
        public."SU_ERS_Subject_Erasable"
    WHERE
        (selection IS NULL OR selection LIKE '%ERS%')
    AND
        "SU_ERS_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."SU_Subject" "SU"
ON
    "SU"."SU_ID" = timepoints."SU_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_NAM_SU_ID")
        r.*
    FROM
        public."rSU_NAM_Subject_Name"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_NAM_Reliability" = 1
    ORDER BY
    r."SU_NAM_SU_ID",
    r."SU_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_COD_SU_ID")
        r.*
    FROM
        public."rSU_COD_Subject_Code"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_COD_Reliability" = 1
    ORDER BY
    r."SU_COD_SU_ID",
    r."SU_COD_PositedAt" DESC
) "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_GRD_SU_ID")
        r.*
    FROM
        public."rSU_GRD_Subject_Grade"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_GRD_Reliability" = 1
    ORDER BY
    r."SU_GRD_SU_ID",
    r."SU_GRD_PositedAt" DESC
) "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_NOT_SU_ID")
        r.*
    FROM
        public."rSU_NOT_Subject_Note"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_NOT_Reliability" = 1
    ORDER BY
    r."SU_NOT_SU_ID",
    r."SU_NOT_PositedAt" DESC
) "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_TTL_ChangedAt") OVER (
            PARTITION BY x."SU_TTL_SU_ID"
            ORDER BY x."SU_TTL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_TTL_SU_ID", r."SU_TTL_ChangedAt")
            r.*
        FROM
            public."rSU_TTL_Subject_Title"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_TTL_Reliability" = 1
        ORDER BY
    r."SU_TTL_SU_ID", r."SU_TTL_ChangedAt",
    r."SU_TTL_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_STA_ChangedAt") OVER (
            PARTITION BY x."SU_STA_SU_ID"
            ORDER BY x."SU_STA_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_STA_SU_ID", r."SU_STA_ChangedAt")
            r.*
        FROM
            public."rSU_STA_Subject_State"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_STA_Reliability" = 1
        ORDER BY
    r."SU_STA_SU_ID", r."SU_STA_ChangedAt",
    r."SU_STA_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_LBL_ChangedAt") OVER (
            PARTITION BY x."SU_LBL_SU_ID"
            ORDER BY x."SU_LBL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_LBL_SU_ID", r."SU_LBL_ChangedAt")
            r.*
        FROM
            public."rSU_LBL_Subject_Label"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_LBL_Reliability" = 1
        ORDER BY
    r."SU_LBL_SU_ID", r."SU_LBL_ChangedAt",
    r."SU_LBL_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_TAG_ChangedAt") OVER (
            PARTITION BY x."SU_TAG_SU_ID"
            ORDER BY x."SU_TAG_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_TAG_SU_ID", r."SU_TAG_ChangedAt")
            r.*
        FROM
            public."rSU_TAG_Subject_Tag"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_TAG_Reliability" = 1
        ORDER BY
    r."SU_TAG_SU_ID", r."SU_TAG_ChangedAt",
    r."SU_TAG_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_LVL_ChangedAt") OVER (
            PARTITION BY x."SU_LVL_SU_ID"
            ORDER BY x."SU_LVL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_LVL_SU_ID", r."SU_LVL_ChangedAt")
            r.*
        FROM
            public."rSU_LVL_Subject_Level"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_LVL_Reliability" = 1
        ORDER BY
    r."SU_LVL_SU_ID", r."SU_LVL_ChangedAt",
    r."SU_LVL_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_TXT_ChangedAt") OVER (
            PARTITION BY x."SU_TXT_SU_ID"
            ORDER BY x."SU_TXT_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_TXT_SU_ID", r."SU_TXT_ChangedAt")
            r.*
        FROM
            public."rSU_TXT_Subject_Text"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_TXT_Reliability" = 1
        ORDER BY
    r."SU_TXT_SU_ID", r."SU_TXT_ChangedAt",
    r."SU_TXT_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_ASR_ChangedAt") OVER (
            PARTITION BY x."SU_ASR_SU_ID"
            ORDER BY x."SU_ASR_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_ASR_SU_ID", r."SU_ASR_ChangedAt")
            r.*
        FROM
            public."rSU_ASR_Subject_Assessment"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_ASR_Reliability" = 1
        ORDER BY
    r."SU_ASR_SU_ID", r."SU_ASR_ChangedAt",
    r."SU_ASR_PositedAt" DESC
    ) x
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
        x.*,
        lead(x."SU_ERS_ChangedAt") OVER (
            PARTITION BY x."SU_ERS_SU_ID"
            ORDER BY x."SU_ERS_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_ERS_SU_ID", r."SU_ERS_ChangedAt")
            r.*
        FROM
            public."rSU_ERS_Subject_Erasable"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_ERS_Reliability" = 1
        ORDER BY
    r."SU_ERS_SU_ID", r."SU_ERS_ChangedAt",
    r."SU_ERS_PositedAt" DESC
    ) x
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
CREATE OR REPLACE FUNCTION public."tOB_Object" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "OB_ID" integer,
    "Metadata_OB" integer,
    "OB_NAM_OB_ID" integer,
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "NAM"."OB_NAM_OB_ID",
    "NAM"."Metadata_OB_NAM",
    "NAM"."OB_NAM_ID",
    "NAM"."OB_NAM_PositedAt",
    "NAM"."OB_NAM_Reliability",
    "NAM"."OB_NAM_Object_Name"
FROM
    public."OB_Object" "OB"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."OB_NAM_OB_ID")
        r.*
    FROM
        public."rOB_NAM_Object_Name"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."OB_NAM_Reliability" = 1
    ORDER BY
    r."OB_NAM_OB_ID",
    r."OB_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."OB_NAM_OB_ID" = "OB"."OB_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lOB_Object" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "OB".*
FROM
    public."tOB_Object"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "OB"
;
CREATE OR REPLACE FUNCTION public."pOB_Object" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "OB_ID" integer,
    "Metadata_OB" integer,
    "OB_NAM_OB_ID" integer,
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "OB"."OB_NAM_OB_ID",
    "OB"."Metadata_OB_NAM",
    "OB"."OB_NAM_ID",
    "OB"."OB_NAM_PositedAt",
    "OB"."OB_NAM_Reliability",
    "OB"."OB_NAM_Object_Name"
FROM
    public."tOB_Object"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "OB"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nOB_Object" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "OB".*
FROM
    public."tOB_Object"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "OB"
;
