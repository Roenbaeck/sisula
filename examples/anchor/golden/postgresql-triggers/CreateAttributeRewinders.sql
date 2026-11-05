-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_EV_PLC",
        "EV_PLC_EV_ID",
        "EV_PLC_Event_Place",
        "EV_PLC_ChangedAt"
    FROM
        public."EV_PLC_Event_Place"
    WHERE
        "EV_PLC_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_TTL",
        "SU_TTL_SU_ID",
        "SU_TTL_Subject_Title",
        "SU_TTL_ChangedAt"
    FROM
        public."SU_TTL_Subject_Title"
    WHERE
        "SU_TTL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_STA",
        "SU_STA_SU_ID",
        "SU_STA_Subject_State",
        "SU_STA_ChangedAt"
    FROM
        public."SU_STA_Subject_State"
    WHERE
        "SU_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_LBL",
        "SU_LBL_SU_ID",
        "SU_LBL_Subject_Label",
        "SU_LBL_ChangedAt"
    FROM
        public."SU_LBL_Subject_Label"
    WHERE
        "SU_LBL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_TAG",
        "SU_TAG_SU_ID",
        "SU_TAG_Subject_Tag",
        "SU_TAG_ChangedAt"
    FROM
        public."SU_TAG_Subject_Tag"
    WHERE
        "SU_TAG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_LVL",
        "SU_LVL_SU_ID",
        "SU_LVL_GRD_ID",
        "SU_LVL_ChangedAt"
    FROM
        public."SU_LVL_Subject_Level"
    WHERE
        "SU_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_TXT",
        "SU_TXT_SU_ID",
        "SU_TXT_Checksum",
        "SU_TXT_Subject_Text",
        "SU_TXT_ChangedAt"
    FROM
        public."SU_TXT_Subject_Text"
    WHERE
        "SU_TXT_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_ASR",
        "SU_ASR_SU_ID",
        "SU_ASR_Subject_Assessment",
        "SU_ASR_ChangedAt"
    FROM
        public."SU_ASR_Subject_Assessment"
    WHERE
        "SU_ASR_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_ERS",
        "SU_ERS_SU_ID",
        "SU_ERS_Subject_Erasable",
        "SU_ERS_ChangedAt"
    FROM
        public."SU_ERS_Subject_Erasable"
    WHERE
        "SU_ERS_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
