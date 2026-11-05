-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_AUD_Event_Audience" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_EQ" smallint,
    "Metadata_EV_AUD" integer,
    "EV_AUD_Event_Audience" integer
)
AS
$$
    SELECT
        "EV_AUD_EV_ID",
        "EV_AUD_EQ",
        "Metadata_EV_AUD",
        "EV_AUD_Event_Audience"
    FROM
        attributes."EV_AUD_Event_Audience"
    WHERE
        "EV_AUD_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_REV_Event_Revenue" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_EQ" smallint,
    "Metadata_EV_REV" integer,
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
    SELECT
        "EV_REV_EV_ID",
        "EV_REV_EQ",
        "Metadata_EV_REV",
        "EV_REV_Event_Revenue"
    FROM
        attributes."EV_REV_Event_Revenue"
    WHERE
        "EV_REV_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_STA_Event_Status" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" smallint,
    "EV_STA_ChangedAt" timestamp,
    "Metadata_EV_STA" integer,
    "EV_STA_Event_Status" varchar(20)
)
AS
$$
    SELECT
        "EV_STA_EV_ID",
        "EV_STA_EQ",
        "EV_STA_ChangedAt",
        "Metadata_EV_STA",
        "EV_STA_Event_Status"
    FROM
        attributes."EV_STA_Event_Status"
    WHERE
        "EV_STA_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_NAM_Stage_Name" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_NAM_ST_ID" integer,
    "ST_NAM_EQ" smallint,
    "ST_NAM_ChangedAt" timestamp,
    "Metadata_ST_NAM" integer,
    "ST_NAM_Stage_Name" varchar(42)
)
AS
$$
    SELECT
        "ST_NAM_ST_ID",
        "ST_NAM_EQ",
        "ST_NAM_ChangedAt",
        "Metadata_ST_NAM",
        "ST_NAM_Stage_Name"
    FROM
        attributes."ST_NAM_Stage_Name"
    WHERE
        "ST_NAM_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_LOC_Stage_Location" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_LOC_ST_ID" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "Metadata_ST_LOC" integer,
    "ST_LOC_Stage_Location" text
)
AS
$$
    SELECT
        "ST_LOC_ST_ID",
        "ST_LOC_EQ",
        "ST_LOC_Checksum",
        "Metadata_ST_LOC",
        "ST_LOC_Stage_Location"
    FROM
        attributes."ST_LOC_Stage_Location"
    WHERE
        "ST_LOC_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."ePR_LEN_Program_Length" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_EQ" smallint,
    "PR_LEN_ChangedAt" date,
    "Metadata_PR_LEN" integer,
    "PR_LEN_Program_Length" time
)
AS
$$
    SELECT
        "PR_LEN_PR_ID",
        "PR_LEN_EQ",
        "PR_LEN_ChangedAt",
        "Metadata_PR_LEN",
        "PR_LEN_Program_Length"
    FROM
        attributes."PR_LEN_Program_Length"
    WHERE
        "PR_LEN_EQ" = equivalent
$$ LANGUAGE sql STABLE;
