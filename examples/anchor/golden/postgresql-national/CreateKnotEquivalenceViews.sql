-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PAT_Föräldratyp view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."PAT_Föräldratyp" (
    "Metadata_PAT",
    "PAT_ID",
    "PAT_EQ",
    "PAT_Föräldratyp"
)
AS
SELECT
    v."Metadata_PAT",
    i."PAT_ID",
    v."PAT_EQ",
    v."PAT_Föräldratyp"
FROM
    knots."PAT_Föräldratyp_ID" i
JOIN
    knots."PAT_Föräldratyp_EQ" v
ON
    v."PAT_ID" = i."PAT_ID"
;
CREATE OR REPLACE FUNCTION knots."ePAT_Föräldratyp" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PAT" integer,
    "PAT_ID" smallint,
    "PAT_EQ" smallint,
    "PAT_Föräldratyp" varchar(42)
)
AS
$$
    SELECT
        "Metadata_PAT",
        "PAT_ID",
        "PAT_EQ",
        "PAT_Föräldratyp"
    FROM
        knots."PAT_Föräldratyp"
    WHERE
        "PAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."PLV_Yrkesnivå" (
    "Metadata_PLV",
    "PLV_ID",
    "PLV_EQ",
    "PLV_Checksum",
    "PLV_Yrkesnivå"
)
AS
SELECT
    v."Metadata_PLV",
    i."PLV_ID",
    v."PLV_EQ",
    v."PLV_Checksum",
    v."PLV_Yrkesnivå"
FROM
    knots."PLV_Yrkesnivå_ID" i
JOIN
    knots."PLV_Yrkesnivå_EQ" v
ON
    v."PLV_ID" = i."PLV_ID"
;
CREATE OR REPLACE FUNCTION knots."ePLV_Yrkesnivå" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PLV" integer,
    "PLV_ID" smallint,
    "PLV_EQ" smallint,
    "PLV_Checksum" bytea,
    "PLV_Yrkesnivå" text
)
AS
$$
    SELECT
        "Metadata_PLV",
        "PLV_ID",
        "PLV_EQ",
        "PLV_Checksum",
        "PLV_Yrkesnivå"
    FROM
        knots."PLV_Yrkesnivå"
    WHERE
        "PLV_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Pågående view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ONG_Pågående" (
    "Metadata_ONG",
    "ONG_ID",
    "ONG_EQ",
    "ONG_Pågående"
)
AS
SELECT
    v."Metadata_ONG",
    i."ONG_ID",
    v."ONG_EQ",
    v."ONG_Pågående"
FROM
    knots."ONG_Pågående_ID" i
JOIN
    knots."ONG_Pågående_EQ" v
ON
    v."ONG_ID" = i."ONG_ID"
;
CREATE OR REPLACE FUNCTION knots."eONG_Pågående" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ONG" integer,
    "ONG_ID" smallint,
    "ONG_EQ" smallint,
    "ONG_Pågående" varchar(3)
)
AS
$$
    SELECT
        "Metadata_ONG",
        "ONG_ID",
        "ONG_EQ",
        "ONG_Pågående"
    FROM
        knots."ONG_Pågående"
    WHERE
        "ONG_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Betyg view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."RAT_Betyg" (
    "Metadata_RAT",
    "RAT_ID",
    "RAT_EQ",
    "RAT_Checksum",
    "RAT_Betyg"
)
AS
SELECT
    v."Metadata_RAT",
    i."RAT_ID",
    v."RAT_EQ",
    v."RAT_Checksum",
    v."RAT_Betyg"
FROM
    knots."RAT_Betyg_ID" i
JOIN
    knots."RAT_Betyg_EQ" v
ON
    v."RAT_ID" = i."RAT_ID"
;
CREATE OR REPLACE FUNCTION knots."eRAT_Betyg" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_RAT" integer,
    "RAT_ID" smallint,
    "RAT_EQ" smallint,
    "RAT_Checksum" bytea,
    "RAT_Betyg" varchar(42)
)
AS
$$
    SELECT
        "Metadata_RAT",
        "RAT_ID",
        "RAT_EQ",
        "RAT_Checksum",
        "RAT_Betyg"
    FROM
        knots."RAT_Betyg"
    WHERE
        "RAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ETY_Händelsetyp view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ETY_Händelsetyp" (
    "Metadata_ETY",
    "ETY_ID",
    "ETY_EQ",
    "ETY_Checksum",
    "ETY_Händelsetyp"
)
AS
SELECT
    v."Metadata_ETY",
    i."ETY_ID",
    v."ETY_EQ",
    v."ETY_Checksum",
    v."ETY_Händelsetyp"
FROM
    knots."ETY_Händelsetyp_ID" i
JOIN
    knots."ETY_Händelsetyp_EQ" v
ON
    v."ETY_ID" = i."ETY_ID"
;
CREATE OR REPLACE FUNCTION knots."eETY_Händelsetyp" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ETY" integer,
    "ETY_ID" smallint,
    "ETY_EQ" smallint,
    "ETY_Checksum" bytea,
    "ETY_Händelsetyp" varchar(42)
)
AS
$$
    SELECT
        "Metadata_ETY",
        "ETY_ID",
        "ETY_EQ",
        "ETY_Checksum",
        "ETY_Händelsetyp"
    FROM
        knots."ETY_Händelsetyp"
    WHERE
        "ETY_EQ" = equivalent
$$ LANGUAGE sql STABLE;
