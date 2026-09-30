-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eEV_AUD_Event_Audience (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID numeric(12,0),
    EV_AUD_EQ tinyint,
    Metadata_EV_AUD int,
    EV_AUD_Event_Audience int
)
AS
$$
    SELECT
        EV_ID,
        EV_AUD_EQ,
        Metadata_EV_AUD,
        EV_AUD_Event_Audience
    FROM
        attributes.EV_AUD_Event_Audience
    WHERE
        EV_AUD_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eEV_REV_Event_Revenue (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID numeric(12,0),
    EV_REV_EQ tinyint,
    Metadata_EV_REV int,
    EV_REV_Event_Revenue number(19,4)
)
AS
$$
    SELECT
        EV_ID,
        EV_REV_EQ,
        Metadata_EV_REV,
        EV_REV_Event_Revenue
    FROM
        attributes.EV_REV_Event_Revenue
    WHERE
        EV_REV_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eEV_STA_Event_Status (
    equivalent tinyint
)
RETURNS TABLE (
    EV_ID numeric(12,0),
    EV_STA_EQ tinyint,
    EV_STA_ChangedAt datetime,
    Metadata_EV_STA int,
    EV_STA_Event_Status varchar(20)
)
AS
$$
    SELECT
        EV_ID,
        EV_STA_EQ,
        EV_STA_ChangedAt,
        Metadata_EV_STA,
        EV_STA_Event_Status
    FROM
        attributes.EV_STA_Event_Status
    WHERE
        EV_STA_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eST_NAM_Stage_Name (
    equivalent tinyint
)
RETURNS TABLE (
    ST_ID int,
    ST_NAM_EQ tinyint,
    ST_NAM_ChangedAt datetime,
    Metadata_ST_NAM int,
    ST_NAM_Stage_Name varchar(42)
)
AS
$$
    SELECT
        ST_ID,
        ST_NAM_EQ,
        ST_NAM_ChangedAt,
        Metadata_ST_NAM,
        ST_NAM_Stage_Name
    FROM
        attributes.ST_NAM_Stage_Name
    WHERE
        ST_NAM_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eST_LOC_Stage_Location (
    equivalent tinyint
)
RETURNS TABLE (
    ST_ID int,
    ST_LOC_EQ tinyint,
    ST_LOC_Checksum numeric(19,0),
    Metadata_ST_LOC int,
    ST_LOC_Stage_Location geography
)
AS
$$
    SELECT
        ST_ID,
        ST_LOC_EQ,
        ST_LOC_Checksum,
        Metadata_ST_LOC,
        ST_LOC_Stage_Location
    FROM
        attributes.ST_LOC_Stage_Location
    WHERE
        ST_LOC_EQ = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.ePR_LEN_Program_Length (
    equivalent tinyint
)
RETURNS TABLE (
    PR_ID number(10,0),
    PR_LEN_EQ tinyint,
    PR_LEN_ChangedAt date,
    Metadata_PR_LEN int,
    PR_LEN_Program_Length time
)
AS
$$
    SELECT
        PR_ID,
        PR_LEN_EQ,
        PR_LEN_ChangedAt,
        Metadata_PR_LEN,
        PR_LEN_Program_Length
    FROM
        attributes.PR_LEN_Program_Length
    WHERE
        PR_LEN_EQ = equivalent
$$
;
