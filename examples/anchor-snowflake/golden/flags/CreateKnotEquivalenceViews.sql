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
CREATE OR REPLACE VIEW knots.PAT_ParentalType (
    Metadata_PAT,
    PAT_ID,
    PAT_EQ,
    PAT_ParentalType COMMENT 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
) COPY GRANTS COMMENT = 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
AS
SELECT
    v.Metadata_PAT,
    i.PAT_ID,
    v.PAT_EQ,
    v.PAT_ParentalType
FROM
    knots.PAT_ParentalType_ID i
JOIN
    knots.PAT_ParentalType_EQ v
ON
    v.PAT_ID = i.PAT_ID
;
CREATE OR REPLACE FUNCTION knots.ePAT_ParentalType (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PAT int,
    PAT_ID tinyint,
    PAT_EQ tinyint,
    PAT_ParentalType varchar(42)
)
AS
$$
    SELECT
        Metadata_PAT,
        PAT_ID,
        PAT_EQ,
        PAT_ParentalType
    FROM
        knots.PAT_ParentalType
    WHERE
        PAT_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.PLV_ProfessionalLevel (
    Metadata_PLV,
    PLV_ID,
    PLV_EQ,
    PLV_Checksum,
    PLV_ProfessionalLevel COMMENT 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.'
) COPY GRANTS COMMENT = 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.'
AS
SELECT
    v.Metadata_PLV,
    i.PLV_ID,
    v.PLV_EQ,
    v.PLV_Checksum,
    v.PLV_ProfessionalLevel
FROM
    knots.PLV_ProfessionalLevel_ID i
JOIN
    knots.PLV_ProfessionalLevel_EQ v
ON
    v.PLV_ID = i.PLV_ID
;
CREATE OR REPLACE FUNCTION knots.ePLV_ProfessionalLevel (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    Metadata_PLV int,
    PLV_ID tinyint,
    PLV_EQ tinyint,
    PLV_Checksum numeric(19,0),
    PLV_ProfessionalLevel string
)
AS
$$
    SELECT
        Metadata_PLV,
        PLV_ID,
        PLV_EQ,
        PLV_Checksum,
        PLV_ProfessionalLevel
    FROM
        knots.PLV_ProfessionalLevel
    WHERE
        PLV_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.ONG_Ongoing (
    Metadata_ONG,
    ONG_ID,
    ONG_EQ,
    ONG_Ongoing COMMENT 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
) COPY GRANTS COMMENT = 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
AS
SELECT
    v.Metadata_ONG,
    i.ONG_ID,
    v.ONG_EQ,
    v.ONG_Ongoing
FROM
    knots.ONG_Ongoing_ID i
JOIN
    knots.ONG_Ongoing_EQ v
ON
    v.ONG_ID = i.ONG_ID
;
CREATE OR REPLACE FUNCTION knots.eONG_Ongoing (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ONG int,
    ONG_ID tinyint,
    ONG_EQ tinyint,
    ONG_Ongoing varchar(3)
)
AS
$$
    SELECT
        Metadata_ONG,
        ONG_ID,
        ONG_EQ,
        ONG_Ongoing
    FROM
        knots.ONG_Ongoing
    WHERE
        ONG_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.RAT_Rating (
    Metadata_RAT,
    RAT_ID,
    RAT_EQ,
    RAT_Checksum,
    RAT_Rating COMMENT 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
) COPY GRANTS COMMENT = 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
AS
SELECT
    v.Metadata_RAT,
    i.RAT_ID,
    v.RAT_EQ,
    v.RAT_Checksum,
    v.RAT_Rating
FROM
    knots.RAT_Rating_ID i
JOIN
    knots.RAT_Rating_EQ v
ON
    v.RAT_ID = i.RAT_ID
;
CREATE OR REPLACE FUNCTION knots.eRAT_Rating (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    Metadata_RAT int,
    RAT_ID tinyint,
    RAT_EQ tinyint,
    RAT_Checksum numeric(19,0),
    RAT_Rating varchar(42)
)
AS
$$
    SELECT
        Metadata_RAT,
        RAT_ID,
        RAT_EQ,
        RAT_Checksum,
        RAT_Rating
    FROM
        knots.RAT_Rating
    WHERE
        RAT_EQ = equivalent
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ETY_EventType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.ETY_EventType (
    Metadata_ETY,
    ETY_ID,
    ETY_EQ,
    ETY_Checksum,
    ETY_EventType
) COPY GRANTS 
AS
SELECT
    v.Metadata_ETY,
    i.ETY_ID,
    v.ETY_EQ,
    v.ETY_Checksum,
    v.ETY_EventType
FROM
    knots.ETY_EventType_ID i
JOIN
    knots.ETY_EventType_EQ v
ON
    v.ETY_ID = i.ETY_ID
;
CREATE OR REPLACE FUNCTION knots.eETY_EventType (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    Metadata_ETY int,
    ETY_ID tinyint,
    ETY_EQ tinyint,
    ETY_Checksum numeric(19,0),
    ETY_EventType varchar(42)
)
AS
$$
    SELECT
        Metadata_ETY,
        ETY_ID,
        ETY_EQ,
        ETY_Checksum,
        ETY_EventType
    FROM
        knots.ETY_EventType
    WHERE
        ETY_EQ = equivalent
$$
;
