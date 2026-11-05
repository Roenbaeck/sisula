-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PAT_ParentalType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."PAT_ParentalType" (
    "Metadata_PAT",
    "PAT_ID",
    "PAT_EQ",
    "PAT_ParentalType"
)
AS
SELECT
    v."Metadata_PAT",
    i."PAT_ID",
    v."PAT_EQ",
    v."PAT_ParentalType"
FROM
    public."PAT_ParentalType_ID" i
JOIN
    public."PAT_ParentalType_EQ" v
ON
    v."PAT_ID" = i."PAT_ID"
;
CREATE OR REPLACE FUNCTION public."ePAT_ParentalType" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PAT" integer,
    "PAT_ID" smallint,
    "PAT_EQ" smallint,
    "PAT_ParentalType" varchar(42)
)
AS
$$
    SELECT
        "Metadata_PAT",
        "PAT_ID",
        "PAT_EQ",
        "PAT_ParentalType"
    FROM
        public."PAT_ParentalType"
    WHERE
        "PAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- GEN_Gender view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."GEN_Gender" (
    "Metadata_GEN",
    "GEN_ID",
    "GEN_EQ",
    "GEN_Gender"
)
AS
SELECT
    v."Metadata_GEN",
    i."GEN_ID",
    v."GEN_EQ",
    v."GEN_Gender"
FROM
    public."GEN_Gender_ID" i
JOIN
    public."GEN_Gender_EQ" v
ON
    v."GEN_ID" = i."GEN_ID"
;
CREATE OR REPLACE FUNCTION public."eGEN_Gender" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_GEN" integer,
    "GEN_ID" smallint,
    "GEN_EQ" smallint,
    "GEN_Gender" varchar(42)
)
AS
$$
    SELECT
        "Metadata_GEN",
        "GEN_ID",
        "GEN_EQ",
        "GEN_Gender"
    FROM
        public."GEN_Gender"
    WHERE
        "GEN_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ONG_Ongoing" (
    "Metadata_ONG",
    "ONG_ID",
    "ONG_EQ",
    "ONG_Ongoing"
)
AS
SELECT
    v."Metadata_ONG",
    i."ONG_ID",
    v."ONG_EQ",
    v."ONG_Ongoing"
FROM
    public."ONG_Ongoing_ID" i
JOIN
    public."ONG_Ongoing_EQ" v
ON
    v."ONG_ID" = i."ONG_ID"
;
CREATE OR REPLACE FUNCTION public."eONG_Ongoing" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ONG" integer,
    "ONG_ID" smallint,
    "ONG_EQ" smallint,
    "ONG_Ongoing" varchar(3)
)
AS
$$
    SELECT
        "Metadata_ONG",
        "ONG_ID",
        "ONG_EQ",
        "ONG_Ongoing"
    FROM
        public."ONG_Ongoing"
    WHERE
        "ONG_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."RAT_Rating" (
    "Metadata_RAT",
    "RAT_ID",
    "RAT_EQ",
    "RAT_Rating"
)
AS
SELECT
    v."Metadata_RAT",
    i."RAT_ID",
    v."RAT_EQ",
    v."RAT_Rating"
FROM
    public."RAT_Rating_ID" i
JOIN
    public."RAT_Rating_EQ" v
ON
    v."RAT_ID" = i."RAT_ID"
;
CREATE OR REPLACE FUNCTION public."eRAT_Rating" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_RAT" integer,
    "RAT_ID" smallint,
    "RAT_EQ" smallint,
    "RAT_Rating" varchar(42)
)
AS
$$
    SELECT
        "Metadata_RAT",
        "RAT_ID",
        "RAT_EQ",
        "RAT_Rating"
    FROM
        public."RAT_Rating"
    WHERE
        "RAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
