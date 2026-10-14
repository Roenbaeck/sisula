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
    "PAT_ID",
    "PAT_EQ",
    "PAT_ParentalType" COMMENT 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
) COPY GRANTS COMMENT = 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
AS
SELECT
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PAT_ID" tinyint,
    "PAT_EQ" tinyint,
    "PAT_ParentalType" varchar(42)
)
AS
$$
    SELECT
        "PAT_ID",
        "PAT_EQ",
        "PAT_ParentalType"
    FROM
        public."PAT_ParentalType"
    WHERE
        "PAT_EQ" = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- GEN_Gender view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."GEN_Gender" (
    "GEN_ID",
    "GEN_EQ",
    "GEN_Gender" COMMENT 'Gender of an actor.'
) COPY GRANTS COMMENT = 'Gender of an actor.'
AS
SELECT
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "GEN_ID" number(1,0),
    "GEN_EQ" tinyint,
    "GEN_Gender" varchar(42)
)
AS
$$
    SELECT
        "GEN_ID",
        "GEN_EQ",
        "GEN_Gender"
    FROM
        public."GEN_Gender"
    WHERE
        "GEN_EQ" = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."ONG_Ongoing" (
    "ONG_ID",
    "ONG_EQ",
    "ONG_Ongoing" COMMENT 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
) COPY GRANTS COMMENT = 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
AS
SELECT
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ONG_ID" tinyint,
    "ONG_EQ" tinyint,
    "ONG_Ongoing" varchar(3)
)
AS
$$
    SELECT
        "ONG_ID",
        "ONG_EQ",
        "ONG_Ongoing"
    FROM
        public."ONG_Ongoing"
    WHERE
        "ONG_EQ" = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."RAT_Rating" (
    "RAT_ID",
    "RAT_EQ",
    "RAT_Rating" COMMENT 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
) COPY GRANTS COMMENT = 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
AS
SELECT
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "RAT_ID" tinyint,
    "RAT_EQ" tinyint,
    "RAT_Rating" varchar(42)
)
AS
$$
    SELECT
        "RAT_ID",
        "RAT_EQ",
        "RAT_Rating"
    FROM
        public."RAT_Rating"
    WHERE
        "RAT_EQ" = equivalent
$$
;
