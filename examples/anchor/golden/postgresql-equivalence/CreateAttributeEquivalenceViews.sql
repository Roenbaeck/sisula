-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_DAT_Event_Date parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eEV_DAT_Event_Date" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_DAT_EV_ID" integer,
    "EV_DAT_EQ" smallint,
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp
)
AS
$$
    SELECT
        "EV_DAT_EV_ID",
        "EV_DAT_EQ",
        "Metadata_EV_DAT",
        "EV_DAT_Event_Date"
    FROM
        public."EV_DAT_Event_Date"
    WHERE
        "EV_DAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eEV_REV_Event_Revenue" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_REV_EV_ID" integer,
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
        public."EV_REV_Event_Revenue"
    WHERE
        "EV_REV_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eST_NAM_Stage_Name" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_NAM_ST_ID" integer,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Checksum" bytea,
    "ST_NAM_ChangedAt" timestamp,
    "Metadata_ST_NAM" integer,
    "ST_NAM_Stage_Name" varchar(42)
)
AS
$$
    SELECT
        "ST_NAM_ST_ID",
        "ST_NAM_EQ",
        "ST_NAM_Checksum",
        "ST_NAM_ChangedAt",
        "Metadata_ST_NAM",
        "ST_NAM_Stage_Name"
    FROM
        public."ST_NAM_Stage_Name"
    WHERE
        "ST_NAM_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eST_LOC_Stage_Location" (
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
        public."ST_LOC_Stage_Location"
    WHERE
        "ST_LOC_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eAC_NAM_Actor_Name" (
    equivalent smallint
)
RETURNS TABLE (
    "AC_NAM_AC_ID" integer,
    "AC_NAM_EQ" smallint,
    "AC_NAM_Checksum" bytea,
    "AC_NAM_ChangedAt" timestamp,
    "Metadata_AC_NAM" integer,
    "AC_NAM_Actor_Name" varchar(42)
)
AS
$$
    SELECT
        "AC_NAM_AC_ID",
        "AC_NAM_EQ",
        "AC_NAM_Checksum",
        "AC_NAM_ChangedAt",
        "Metadata_AC_NAM",
        "AC_NAM_Actor_Name"
    FROM
        public."AC_NAM_Actor_Name"
    WHERE
        "AC_NAM_EQ" = equivalent
$$ LANGUAGE sql STABLE;
