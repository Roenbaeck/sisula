-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_AUD_Händelse_Publik" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_EQ" tinyint,
    "Metadata_EV_AUD" int,
    "EV_AUD_Händelse_Publik" int
)
AS
$$
    SELECT
        "EV_AUD_EV_ID",
        "EV_AUD_EQ",
        "Metadata_EV_AUD",
        "EV_AUD_Händelse_Publik"
    FROM
        attributes."EV_AUD_Händelse_Publik"
    WHERE
        "EV_AUD_EQ" = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_REV_Händelse_Intäkt" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_EQ" tinyint,
    "Metadata_EV_REV" int,
    "EV_REV_Händelse_Intäkt" number(19,4)
)
AS
$$
    SELECT
        "EV_REV_EV_ID",
        "EV_REV_EQ",
        "Metadata_EV_REV",
        "EV_REV_Händelse_Intäkt"
    FROM
        attributes."EV_REV_Händelse_Intäkt"
    WHERE
        "EV_REV_EQ" = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_STA_Händelse_Status" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" tinyint,
    "EV_STA_ChangedAt" datetime,
    "Metadata_EV_STA" int,
    "EV_STA_Händelse_Status" varchar(20)
)
AS
$$
    SELECT
        "EV_STA_EV_ID",
        "EV_STA_EQ",
        "EV_STA_ChangedAt",
        "Metadata_EV_STA",
        "EV_STA_Händelse_Status"
    FROM
        attributes."EV_STA_Händelse_Status"
    WHERE
        "EV_STA_EQ" = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_NAM_Scen_Namn" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_NAM_ST_ID" int,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_ChangedAt" datetime,
    "Metadata_ST_NAM" int,
    "ST_NAM_Scen_Namn" varchar(42)
)
AS
$$
    SELECT
        "ST_NAM_ST_ID",
        "ST_NAM_EQ",
        "ST_NAM_ChangedAt",
        "Metadata_ST_NAM",
        "ST_NAM_Scen_Namn"
    FROM
        attributes."ST_NAM_Scen_Namn"
    WHERE
        "ST_NAM_EQ" = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_LOC_Scen_Plats" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "Metadata_ST_LOC" int,
    "ST_LOC_Scen_Plats" geography
)
AS
$$
    SELECT
        "ST_LOC_ST_ID",
        "ST_LOC_EQ",
        "ST_LOC_Checksum",
        "Metadata_ST_LOC",
        "ST_LOC_Scen_Plats"
    FROM
        attributes."ST_LOC_Scen_Plats"
    WHERE
        "ST_LOC_EQ" = equivalent
$$
;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."ePR_LEN_Föreställning_Längd" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_LEN_PR_ID" number(10,0),
    "PR_LEN_EQ" tinyint,
    "PR_LEN_ChangedAt" date,
    "Metadata_PR_LEN" int,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
    SELECT
        "PR_LEN_PR_ID",
        "PR_LEN_EQ",
        "PR_LEN_ChangedAt",
        "Metadata_PR_LEN",
        "PR_LEN_Föreställning_Längd"
    FROM
        attributes."PR_LEN_Föreställning_Längd"
    WHERE
        "PR_LEN_EQ" = equivalent
$$
;
