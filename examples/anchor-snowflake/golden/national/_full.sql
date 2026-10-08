-- EQUIVALENTS METADATA -----------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available equivalents. Since at least one equivalent
-- must be available the table is set up with a default equivalent with identity 0.
--
-- Equivalent table ---------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw."_EQ" (
    "EQ" tinyint not null,
    constraint "pk_EQ" primary key (
        "EQ" 
    ) RELY
);
MERGE INTO dw."_EQ" e
USING ( SELECT 0 AS _defaultEquivalent ) d
ON (
    d._defaultEquivalent = e."EQ"
)
WHEN NOT MATCHED THEN
INSERT (
    "EQ"
)
VALUES (
    d._defaultEquivalent
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp_ID" (
    "PAT_ID" tinyint not null,
    "Metadata_PAT" int not null, 
    constraint "pkPAT_Föräldratyp_ID" primary key (
        "PAT_ID"
    ) RELY
) CLUSTER BY ("PAT_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp_EQ" (
    "PAT_ID" tinyint not null,
    "PAT_EQ" tinyint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" int not null, 
    constraint "fkPAT_Föräldratyp_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID") RELY,
    constraint "pkPAT_Föräldratyp_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ) RELY,
    constraint "uqPAT_Föräldratyp_EQ" unique (
        "PAT_EQ",
        "PAT_Föräldratyp"
    ) RELY
) CLUSTER BY ("PAT_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Kön" (
    "GEN_ID" number(1,0) not null,
    "GEN_Kön" varchar(42) not null,
    "GEN_Checksum" numeric(19,0) default hash("GEN_Kön"),
    "Metadata_GEN" int not null,
    constraint "pkGEN_Kön" primary key (
        "GEN_ID"
    ) RELY,
    constraint "uqGEN_Kön" unique (
        "GEN_Checksum" 
    ) RELY
) CLUSTER BY ("GEN_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_ID" (
    "PLV_ID" tinyint not null,
    "Metadata_PLV" int not null, 
    constraint "pkPLV_Yrkesnivå_ID" primary key (
        "PLV_ID"
    ) RELY
) CLUSTER BY ("PLV_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_EQ" (
    "PLV_ID" tinyint not null,
    "PLV_EQ" tinyint not null,
    "PLV_Yrkesnivå" string not null,
    "PLV_Checksum" numeric(19,0) default hash("PLV_Yrkesnivå"),
    "Metadata_PLV" int not null, 
    constraint "fkPLV_Yrkesnivå_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID") RELY,
    constraint "pkPLV_Yrkesnivå_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ) RELY,
    constraint "uqPLV_Yrkesnivå_EQ" unique (
        "PLV_EQ",
        "PLV_Checksum" 
    ) RELY
) CLUSTER BY ("PLV_ID");
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utnyttjande" (
    "UTL_ID" tinyint not null,
    "UTL_Utnyttjande" tinyint not null,
    "Metadata_UTL" int not null,
    constraint "pkUTL_Utnyttjande" primary key (
        "UTL_ID"
    ) RELY,
    constraint "uqUTL_Utnyttjande" unique (
        "UTL_Utnyttjande"
    ) RELY
) CLUSTER BY ("UTL_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Pågående_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_ID" (
    "ONG_ID" tinyint not null,
    "Metadata_ONG" int not null, 
    constraint "pkONG_Pågående_ID" primary key (
        "ONG_ID"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Pågående_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_EQ" (
    "ONG_ID" tinyint not null,
    "ONG_EQ" tinyint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" int not null, 
    constraint "fkONG_Pågående_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Pågående_ID"("ONG_ID") RELY,
    constraint "pkONG_Pågående_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ) RELY,
    constraint "uqONG_Pågående_EQ" unique (
        "ONG_EQ",
        "ONG_Pågående"
    ) RELY
) CLUSTER BY ("ONG_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Betyg_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_ID" (
    "RAT_ID" tinyint default knots."RAT_Betyg_ID_SEQ".nextval not null, 
    "Metadata_RAT" int not null, 
    constraint "pkRAT_Betyg_ID" primary key (
        "RAT_ID"
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Betyg_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_EQ" (
    "RAT_ID" tinyint not null,
    "RAT_EQ" tinyint not null,
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" numeric(19,0) default hash("RAT_Betyg"),
    "Metadata_RAT" int not null, 
    constraint "fkRAT_Betyg_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Betyg_ID"("RAT_ID") RELY,
    constraint "pkRAT_Betyg_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ) RELY,
    constraint "uqRAT_Betyg_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    ) RELY
) CLUSTER BY ("RAT_ID");
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_ID" (
    "ETY_ID" tinyint not null,
    "Metadata_ETY" int not null, 
    constraint "pkETY_Händelsetyp_ID" primary key (
        "ETY_ID"
    ) RELY
) CLUSTER BY ("ETY_ID");
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_EQ" (
    "ETY_ID" tinyint not null,
    "ETY_EQ" tinyint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" numeric(19,0) default hash("ETY_Händelsetyp"),
    "Metadata_ETY" int not null, 
    constraint "fkETY_Händelsetyp_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_Händelsetyp_ID"("ETY_ID") RELY,
    constraint "pkETY_Händelsetyp_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ) RELY,
    constraint "uqETY_Händelsetyp_EQ" unique (
        "ETY_EQ",
        "ETY_Checksum" 
    ) RELY
) CLUSTER BY ("ETY_ID");
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default anchors."PN_Person_ID_SEQ".nextval not null, 
    "Metadata_PN" int not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    ) RELY
) CLUSTER BY ("PN_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" int not null,
    "Metadata_ST" int not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default anchors."AC_Skådespelare_ID_SEQ".nextval not null, 
    "Metadata_AC" int not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" number(10,0) not null,
    "Metadata_PR" int not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    ) RELY
) CLUSTER BY ("PR_ID");
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Händelse table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses."EV_Händelse" (
    "EV_ID" numeric(12,0) not null,
    "ST_ID_hölls" int not null, 
    "PR_ID_spelades" number(10,0) not null, 
    "ETY_ID_of" tinyint not null,
    constraint "EV_Händelse_fkST_hölls" foreign key (
        "ST_ID_hölls"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "EV_Händelse_fkPR_spelades" foreign key (
        "PR_ID_spelades"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "EV_Händelse_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_Händelsetyp_ID"("ETY_ID") RELY,
    "Metadata_EV" int not null, 
    constraint "pkEV_Händelse" primary key (
        "EV_ID"
    ) RELY
) CLUSTER BY ("EV_ID");
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum" (
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Händelse_Datum" datetime not null,
    "Metadata_EV_DAT" int not null,
    constraint "fkEV_DAT_Händelse_Datum" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_DAT_Händelse_Datum" primary key (
        "EV_DAT_EV_ID"
    ) RELY
) CLUSTER BY ("EV_DAT_EV_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik" (
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_EQ" tinyint not null,
    "EV_AUD_Händelse_Publik" int not null,
    "Metadata_EV_AUD" int not null,
    constraint "fkEV_AUD_Händelse_Publik" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_AUD_Händelse_Publik" primary key (
        "EV_AUD_EQ",
        "EV_AUD_EV_ID"
    ) RELY
) CLUSTER BY ("EV_AUD_EV_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt" (
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_EQ" tinyint not null,
    "EV_REV_Händelse_Intäkt" number(19,4) not null,
    "Metadata_EV_REV" int not null,
    constraint "fkEV_REV_Händelse_Intäkt" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_REV_Händelse_Intäkt" primary key (
        "EV_REV_EQ",
        "EV_REV_EV_ID"
    ) RELY
) CLUSTER BY ("EV_REV_EV_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status" (
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_EQ" tinyint not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" datetime not null,
    "Metadata_EV_STA" int not null,
    constraint "fkEV_STA_Händelse_Status" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_STA_Händelse_Status" primary key (
        "EV_STA_EQ",
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt"
    ) RELY
) CLUSTER BY ("EV_STA_EV_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande" (
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
    "Metadata_EV_UTL" int not null,
    constraint "fk_A_EV_UTL_Händelse_Utnyttjande" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "fk_K_EV_UTL_Händelse_Utnyttjande" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkEV_UTL_Händelse_Utnyttjande" primary key (
        "EV_UTL_EV_ID"
    ) RELY
) CLUSTER BY ("EV_UTL_EV_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level" (
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    "Metadata_EV_LVL" int not null,
    constraint "fk_A_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "fk_K_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID") RELY,
    constraint "pkEV_LVL_Händelse_Level" primary key (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt"
    ) RELY
) CLUSTER BY ("EV_LVL_EV_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn" (
    "ST_NAM_ST_ID" int not null,
    "ST_NAM_EQ" tinyint not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" datetime not null,
    "Metadata_ST_NAM" int not null,
    constraint "fkST_NAM_Scen_Namn" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "pkST_NAM_Scen_Namn" primary key (
        "ST_NAM_EQ",
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    ) RELY
) CLUSTER BY ("ST_NAM_ST_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats" (
    "ST_LOC_ST_ID" int not null,
    "ST_LOC_EQ" tinyint not null,
    "ST_LOC_Scen_Plats" geography not null,
    "ST_LOC_Checksum" numeric(19,0) default hash("ST_LOC_Scen_Plats"),
    "Metadata_ST_LOC" int not null,
    constraint "fkST_LOC_Scen_Plats" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "pkST_LOC_Scen_Plats" primary key (
        "ST_LOC_EQ",
        "ST_LOC_ST_ID"
    ) RELY
) CLUSTER BY ("ST_LOC_ST_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel" (
    "ST_AVG_ST_ID" int not null,
    "ST_AVG_UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" datetime not null,
    "Metadata_ST_AVG" int not null,
    constraint "fk_A_ST_AVG_Scen_Medel" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "fk_K_ST_AVG_Scen_Medel" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkST_AVG_Scen_Medel" primary key (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt"
    ) RELY
) CLUSTER BY ("ST_AVG_ST_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum" (
    "ST_MIN_ST_ID" int not null,
    "ST_MIN_UTL_ID" tinyint not null,
    "Metadata_ST_MIN" int not null,
    constraint "fk_A_ST_MIN_Scen_Minimum" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "fk_K_ST_MIN_Scen_Minimum" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkST_MIN_Scen_Minimum" primary key (
        "ST_MIN_ST_ID"
    ) RELY
) CLUSTER BY ("ST_MIN_ST_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn" (
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Skådespelare_Namn" varbinary(max) not null,
    "AC_NAM_ChangedAt" datetime not null,
    "Metadata_AC_NAM" int not null,
    constraint "fkAC_NAM_Skådespelare_Namn" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "pkAC_NAM_Skådespelare_Namn" primary key (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt"
    ) RELY
) CLUSTER BY ("AC_NAM_AC_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön" (
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" number(1,0) not null,
    "Metadata_AC_GEN" int not null,
    constraint "fk_A_AC_GEN_Skådespelare_Kön" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "fk_K_AC_GEN_Skådespelare_Kön" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Kön"("GEN_ID") RELY,
    constraint "pkAC_GEN_Skådespelare_Kön" primary key (
        "AC_GEN_AC_ID"
    ) RELY
) CLUSTER BY ("AC_GEN_AC_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå" (
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" datetime not null,
    "Metadata_AC_PLV" int not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID") RELY,
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    ) RELY
) CLUSTER BY ("AC_PLV_AC_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn" (
    "PR_NAM_PR_ID" number(10,0) not null,
    "PR_NAM_Föreställning_Namn" varchar(42) not null,
    "Metadata_PR_NAM" int not null,
    constraint "fkPR_NAM_Föreställning_Namn" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID") RELY,
    constraint "pkPR_NAM_Föreställning_Namn" primary key (
        "PR_NAM_PR_ID"
    ) RELY
) CLUSTER BY ("PR_NAM_PR_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd" (
    "PR_LEN_PR_ID" number(10,0) not null,
    "PR_LEN_EQ" tinyint not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" int not null,
    constraint "fkPR_LEN_Föreställning_Längd" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID") RELY,
    constraint "pkPR_LEN_Föreställning_Längd" primary key (
        "PR_LEN_EQ",
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt"
    ) RELY
) CLUSTER BY ("PR_LEN_PR_ID");
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently" (
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" tinyint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime not null,
    "Metadata_AC_partner_AC_with_ONG_currently" int not null,
    constraint "AC_partner_AC_with_ONG_currently_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_partner_AC_with_ONG_currently_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Pågående_ID"("ONG_ID") RELY,
    constraint "AC_partner_AC_with_ONG_currently_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "AC_partner_AC_with_ONG_currently_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY,
    constraint "pkAC_partner_AC_with_ONG_currently" primary key (
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ) RELY
) CLUSTER BY (
    "AC_ID_partner",
    "AC_ID_with"
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of" (
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    "Metadata_AC_subset_PN_of" int not null,
    constraint "AC_subset_PN_of_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_subset_PN_of_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID") RELY, 
    constraint "AC_subset_PN_of_uqAC_subset" unique (
        "AC_ID_subset"
    ) RELY,
    constraint "AC_subset_PN_of_uqPN_of" unique (
        "PN_ID_of"
    ) RELY,
    constraint "pkAC_subset_PN_of" primary key (
        "AC_ID_subset",
        "PN_ID_of"
    ) RELY
) CLUSTER BY (
    "AC_ID_subset",
    "PN_ID_of"
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes" (
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_rollsattes" smallint not null, 
    "Metadata_EV_in_AC_rollsattes" int not null,
    constraint "EV_in_AC_rollsattes_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "EV_in_AC_rollsattes_fkAC_rollsattes" foreign key (
        "AC_ID_rollsattes"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "pkEV_in_AC_rollsattes" primary key (
        "EV_ID_in",
        "AC_ID_rollsattes"
    ) RELY
) CLUSTER BY (
    "AC_ID_rollsattes"
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick" (
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" number(10,0) not null, 
    "RAT_ID_fick" tinyint not null,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime not null,
    "Metadata_AC_deltar_PR_in_RAT_fick" int not null,
    constraint "AC_deltar_PR_in_RAT_fick_fkAC_deltar" foreign key (
        "AC_ID_deltar"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "AC_deltar_PR_in_RAT_fick_fkRAT_fick" foreign key (
        "RAT_ID_fick"
    ) references knots."RAT_Betyg_ID"("RAT_ID") RELY,
    constraint "pkAC_deltar_PR_in_RAT_fick" primary key (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt"
    ) RELY
) CLUSTER BY (
    "AC_ID_deltar",
    "PR_ID_in"
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas" (
    "ST_ID_at" int not null, 
    "PR_ID_spelas" number(10,0) not null, 
    "ST_at_PR_spelas_ChangedAt" datetime not null,
    "Metadata_ST_at_PR_spelas" int not null,
    constraint "ST_at_PR_spelas_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "ST_at_PR_spelas_fkPR_spelas" foreign key (
        "PR_ID_spelas"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "pkST_at_PR_spelas" primary key (
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt"
    ) RELY
) CLUSTER BY (
    "ST_ID_at",
    "PR_ID_spelas"
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har" (
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" tinyint not null,
    "Metadata_AC_förälder_AC_barn_PAT_har" int not null,
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY, 
    constraint "AC_förälder_AC_barn_PAT_har_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID") RELY,
    constraint "pkAC_förälder_AC_barn_PAT_har" primary key (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    ) RELY
) CLUSTER BY (
    "AC_ID_förälder",
    "AC_ID_barn"
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of" (
    "PR_ID_innehåll" number(10,0) not null, 
    "ST_ID_plats" int not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime not null,
    "Metadata_PR_innehåll_ST_plats_EV_of" int not null,
    constraint "PR_innehåll_ST_plats_EV_of_fkPR_innehåll" foreign key (
        "PR_ID_innehåll"
    ) references anchors."PR_Föreställning"("PR_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_fkST_plats" foreign key (
        "ST_ID_plats"
    ) references anchors."ST_Scen"("ST_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Händelse"("EV_ID") RELY, 
    constraint "PR_innehåll_ST_plats_EV_of_uqPR_innehåll" unique (
        "PR_ID_innehåll",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "PR_innehåll_ST_plats_EV_of_uqST_plats" unique (
        "ST_ID_plats",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY,
    constraint "pkPR_innehåll_ST_plats_EV_of" primary key (
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ) RELY
) CLUSTER BY (
    "PR_ID_innehåll",
    "ST_ID_plats"
);
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
    "PAT_Föräldratyp" COMMENT 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
) COPY GRANTS COMMENT = 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.'
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PAT" int,
    "PAT_ID" tinyint,
    "PAT_EQ" tinyint,
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
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."PLV_Yrkesnivå" (
    "Metadata_PLV",
    "PLV_ID",
    "PLV_EQ",
    "PLV_Checksum",
    "PLV_Yrkesnivå" COMMENT 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.'
) COPY GRANTS COMMENT = 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.'
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PLV" int,
    "PLV_ID" tinyint,
    "PLV_EQ" tinyint,
    "PLV_Checksum" numeric(19,0),
    "PLV_Yrkesnivå" string
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
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Pågående view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ONG_Pågående" (
    "Metadata_ONG",
    "ONG_ID",
    "ONG_EQ",
    "ONG_Pågående" COMMENT 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
) COPY GRANTS COMMENT = 'Yes or No flag indicating whether a relationship is still ongoing or has ended.'
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ONG" int,
    "ONG_ID" tinyint,
    "ONG_EQ" tinyint,
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
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Betyg view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."RAT_Betyg" (
    "Metadata_RAT",
    "RAT_ID",
    "RAT_EQ",
    "RAT_Checksum",
    "RAT_Betyg" COMMENT 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
) COPY GRANTS COMMENT = 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.'
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_RAT" int,
    "RAT_ID" tinyint,
    "RAT_EQ" tinyint,
    "RAT_Checksum" numeric(19,0),
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
$$
;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ETY_Händelsetyp view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ETY_Händelsetyp" (
    "Metadata_ETY",
    "ETY_ID",
    "ETY_EQ",
    "ETY_Checksum",
    "ETY_Händelsetyp"
) COPY GRANTS 
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
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ETY" int,
    "ETY_ID" tinyint,
    "ETY_EQ" tinyint,
    "ETY_Checksum" numeric(19,0),
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
$$
;
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
-- rEV_STA_Händelse_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status" (
    equivalent tinyint,
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_STA" int,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" datetime
)
AS
$$
    SELECT
        "Metadata_EV_STA",
        "EV_STA_EV_ID",
        "EV_STA_EQ",
        "EV_STA_Händelse_Status",
        "EV_STA_ChangedAt"
    FROM
        TABLE(attributes."eEV_STA_Händelse_Status"(equivalent)) 
    WHERE
        "EV_STA_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Händelse_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level" (
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_LVL" int,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" tinyint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
    SELECT
        "Metadata_EV_LVL",
        "EV_LVL_EV_ID",
        "EV_LVL_PLV_ID",
        "EV_LVL_ChangedAt"
    FROM
        attributes."EV_LVL_Händelse_Level"
    WHERE
        "EV_LVL_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Scen_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn" (
    equivalent tinyint,
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_NAM" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" datetime
)
AS
$$
    SELECT
        "Metadata_ST_NAM",
        "ST_NAM_ST_ID",
        "ST_NAM_EQ",
        "ST_NAM_Scen_Namn",
        "ST_NAM_ChangedAt"
    FROM
        TABLE(attributes."eST_NAM_Scen_Namn"(equivalent)) 
    WHERE
        "ST_NAM_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Scen_Medel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_AVG" int,
    "ST_AVG_ST_ID" int,
    "ST_AVG_UTL_ID" tinyint, 
    "ST_AVG_ChangedAt" datetime
)
AS
$$
    SELECT
        "Metadata_ST_AVG",
        "ST_AVG_ST_ID",
        "ST_AVG_UTL_ID",
        "ST_AVG_ChangedAt"
    FROM
        attributes."ST_AVG_Scen_Medel"
    WHERE
        "ST_AVG_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Skådespelare_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_NAM" int,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_NAM_ChangedAt" datetime
)
AS
$$
    SELECT
        "Metadata_AC_NAM",
        "AC_NAM_AC_ID",
        "AC_NAM_Skådespelare_Namn",
        "AC_NAM_ChangedAt"
    FROM
        attributes."AC_NAM_Skådespelare_Namn"
    WHERE
        "AC_NAM_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Skådespelare_Yrkesnivå rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå" (
    changingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_PLV" int,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" tinyint, 
    "AC_PLV_ChangedAt" datetime
)
AS
$$
    SELECT
        "Metadata_AC_PLV",
        "AC_PLV_AC_ID",
        "AC_PLV_PLV_ID",
        "AC_PLV_ChangedAt"
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå"
    WHERE
        "AC_PLV_ChangedAt" <= changingTimepoint
$$
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Föreställning_Längd rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd" (
    equivalent tinyint,
    changingTimepoint date
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_LEN" int,
    "PR_LEN_PR_ID" number(10,0),
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
    SELECT
        "Metadata_PR_LEN",
        "PR_LEN_PR_ID",
        "PR_LEN_EQ",
        "PR_LEN_Föreställning_Längd",
        "PR_LEN_ChangedAt"
    FROM
        TABLE(attributes."ePR_LEN_Föreställning_Längd"(equivalent)) 
    WHERE
        "PR_LEN_ChangedAt" <= changingTimepoint
$$
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lST_Scen" (
    "ST_ID",
    "Metadata_ST",
    "ST_NAM_ST_ID",
    "Metadata_ST_NAM",
    "ST_NAM_ChangedAt",
    "ST_NAM_EQ",
    "ST_NAM_Scen_Namn" COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    "ST_LOC_ST_ID",
    "Metadata_ST_LOC",
    "ST_LOC_EQ",
    "ST_LOC_Checksum",
    "ST_LOC_Scen_Plats" COMMENT 'Geographic location of the stage as a geography point.',
    "ST_AVG_ST_ID",
    "Metadata_ST_AVG",
    "ST_AVG_ChangedAt",
    "ST_AVG_UTL_Utnyttjande" COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    "ST_AVG_Metadata_UTL",
    "ST_AVG_UTL_ID" COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    "ST_MIN_ST_ID",
    "Metadata_ST_MIN",
    "ST_MIN_UTL_Utnyttjande" COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    "ST_MIN_Metadata_UTL",
    "ST_MIN_UTL_ID" COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COPY GRANTS COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Scen" "ST"
LEFT JOIN
    TABLE(attributes."eST_NAM_Scen_Namn"(0)) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(attributes."eST_NAM_Scen_Namn"(0)) sub 
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(attributes."eST_LOC_Scen_Plats"(0)) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."ST_AVG_Scen_Medel" "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."ST_AVG_Scen_Medel" sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Scen_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pST_Scen" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Scen" "ST"
LEFT JOIN
    TABLE(attributes."rST_NAM_Scen_Namn"(0, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(attributes."rST_NAM_Scen_Namn"(0, changingTimepoint::datetime)) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(attributes."eST_LOC_Scen_Plats"(0)) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    TABLE(attributes."rST_AVG_Scen_Medel"(changingTimepoint::datetime)) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            TABLE(attributes."rST_AVG_Scen_Medel"(changingTimepoint::datetime)) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Scen_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Scen" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(anchors."pST_Scen"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Scen" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pST"."ST_ID",
    "pST"."Metadata_ST",
    "pST"."ST_NAM_ST_ID",
    "pST"."Metadata_ST_NAM",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Scen_Namn",
    "pST"."ST_LOC_ST_ID",
    "pST"."Metadata_ST_LOC",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Scen_Plats",
    "pST"."ST_AVG_ST_ID",
    "pST"."Metadata_ST_AVG",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utnyttjande",
    "pST"."ST_AVG_Metadata_UTL",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."Metadata_ST_MIN",
    "pST"."ST_MIN_UTL_Utnyttjande",
    "pST"."ST_MIN_Metadata_UTL",
    "pST"."ST_MIN_UTL_ID"
FROM
    TABLE(attributes."eST_NAM_Scen_Namn"(0)) "hNAM", 
    TABLE(anchors."pST_Scen"("hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hNAM"."ST_NAM_ST_ID"
UNION
SELECT DISTINCT
    "hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    "pST"."ST_ID",
    "pST"."Metadata_ST",
    "pST"."ST_NAM_ST_ID",
    "pST"."Metadata_ST_NAM",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Scen_Namn",
    "pST"."ST_LOC_ST_ID",
    "pST"."Metadata_ST_LOC",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Scen_Plats",
    "pST"."ST_AVG_ST_ID",
    "pST"."Metadata_ST_AVG",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utnyttjande",
    "pST"."ST_AVG_Metadata_UTL",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."Metadata_ST_MIN",
    "pST"."ST_MIN_UTL_Utnyttjande",
    "pST"."ST_MIN_Metadata_UTL",
    "pST"."ST_MIN_UTL_ID"
FROM
    attributes."ST_AVG_Scen_Medel" "hAVG",
    TABLE(anchors."pST_Scen"("hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    "hAVG"."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hAVG"."ST_AVG_ST_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epST_Scen" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Scen" "ST"
LEFT JOIN
    TABLE(attributes."rST_NAM_Scen_Namn"(equivalent, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(attributes."rST_NAM_Scen_Namn"(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(attributes."eST_LOC_Scen_Plats"(equivalent)) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    TABLE(attributes."rST_AVG_Scen_Medel"(changingTimepoint::datetime)) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            TABLE(attributes."rST_AVG_Scen_Medel"(changingTimepoint::datetime)) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Scen_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elST_Scen" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epST_Scen"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enST_Scen" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epST_Scen"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edST_Scen" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pST"."ST_ID",
    "pST"."Metadata_ST",
    "pST"."ST_NAM_ST_ID",
    "pST"."Metadata_ST_NAM",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Scen_Namn",
    "pST"."ST_LOC_ST_ID",
    "pST"."Metadata_ST_LOC",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Scen_Plats",
    "pST"."ST_AVG_ST_ID",
    "pST"."Metadata_ST_AVG",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utnyttjande",
    "pST"."ST_AVG_Metadata_UTL",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."Metadata_ST_MIN",
    "pST"."ST_MIN_UTL_Utnyttjande",
    "pST"."ST_MIN_Metadata_UTL",
    "pST"."ST_MIN_UTL_ID"
FROM
    TABLE(attributes."eST_NAM_Scen_Namn"(equivalent)) "hNAM", 
    TABLE(anchors."epST_Scen"(equivalent, "hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hNAM"."ST_NAM_ST_ID"
UNION
SELECT DISTINCT
    "hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    "pST"."ST_ID",
    "pST"."Metadata_ST",
    "pST"."ST_NAM_ST_ID",
    "pST"."Metadata_ST_NAM",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Scen_Namn",
    "pST"."ST_LOC_ST_ID",
    "pST"."Metadata_ST_LOC",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Scen_Plats",
    "pST"."ST_AVG_ST_ID",
    "pST"."Metadata_ST_AVG",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utnyttjande",
    "pST"."ST_AVG_Metadata_UTL",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."Metadata_ST_MIN",
    "pST"."ST_MIN_UTL_Utnyttjande",
    "pST"."ST_MIN_Metadata_UTL",
    "pST"."ST_MIN_UTL_ID"
FROM
    attributes."ST_AVG_Scen_Medel" "hAVG",
    TABLE(anchors."epST_Scen"(equivalent, "hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    "hAVG"."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hAVG"."ST_AVG_ST_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Skådespelare" (
    "AC_ID",
    "Metadata_AC",
    "AC_NAM_AC_ID",
    "Metadata_AC_NAM",
    "AC_NAM_ChangedAt",
    "AC_NAM_Skådespelare_Namn" COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    "AC_GEN_AC_ID",
    "Metadata_AC_GEN",
    "AC_GEN_GEN_Checksum",
    "AC_GEN_GEN_Kön" COMMENT 'Gender of the actor.',
    "AC_GEN_Metadata_GEN",
    "AC_GEN_GEN_ID" COMMENT 'Gender of the actor.',
    "AC_PLV_AC_ID",
    "Metadata_AC_PLV",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_Checksum",
    "AC_PLV_PLV_EQ",
    "AC_PLV_PLV_Yrkesnivå" COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    "AC_PLV_Metadata_PLV",
    "AC_PLV_PLV_ID" COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COPY GRANTS COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
AS
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN
    attributes."AC_NAM_Skådespelare_Namn" "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."AC_NAM_Skådespelare_Namn" sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå" "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå" sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(0)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Skådespelare" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_EQ" tinyint,
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN
    TABLE(attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::datetime)) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::datetime)) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(0)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Skådespelare" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(anchors."pAC_Skådespelare"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Skådespelare" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_EQ" tinyint,
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."Metadata_AC",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."Metadata_AC_NAM",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_Skådespelare_Namn",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."Metadata_AC_GEN",
    "pAC"."AC_GEN_GEN_Checksum",
    "pAC"."AC_GEN_GEN_Kön",
    "pAC"."AC_GEN_Metadata_GEN",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."Metadata_AC_PLV",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_EQ",
    "pAC"."AC_PLV_PLV_Yrkesnivå",
    "pAC"."AC_PLV_Metadata_PLV",
    "pAC"."AC_PLV_PLV_ID"
FROM
    attributes."AC_NAM_Skådespelare_Namn" "hNAM",
    TABLE(anchors."pAC_Skådespelare"("hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hNAM"."AC_NAM_AC_ID"
UNION
SELECT DISTINCT
    "hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."Metadata_AC",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."Metadata_AC_NAM",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_Skådespelare_Namn",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."Metadata_AC_GEN",
    "pAC"."AC_GEN_GEN_Checksum",
    "pAC"."AC_GEN_GEN_Kön",
    "pAC"."AC_GEN_Metadata_GEN",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."Metadata_AC_PLV",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_EQ",
    "pAC"."AC_PLV_PLV_Yrkesnivå",
    "pAC"."AC_PLV_Metadata_PLV",
    "pAC"."AC_PLV_PLV_ID"
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå" "hPLV",
    TABLE(anchors."pAC_Skådespelare"("hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    "hPLV"."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hPLV"."AC_PLV_AC_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epAC_Skådespelare" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_EQ" tinyint,
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN
    TABLE(attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::datetime)) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::datetime)) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(equivalent)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elAC_Skådespelare" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_EQ" tinyint,
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epAC_Skådespelare"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enAC_Skådespelare" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_EQ" tinyint,
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epAC_Skådespelare"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edAC_Skådespelare" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_EQ" tinyint,
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."Metadata_AC",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."Metadata_AC_NAM",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_Skådespelare_Namn",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."Metadata_AC_GEN",
    "pAC"."AC_GEN_GEN_Checksum",
    "pAC"."AC_GEN_GEN_Kön",
    "pAC"."AC_GEN_Metadata_GEN",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."Metadata_AC_PLV",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_EQ",
    "pAC"."AC_PLV_PLV_Yrkesnivå",
    "pAC"."AC_PLV_Metadata_PLV",
    "pAC"."AC_PLV_PLV_ID"
FROM
    attributes."AC_NAM_Skådespelare_Namn" "hNAM",
    TABLE(anchors."epAC_Skådespelare"(equivalent, "hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hNAM"."AC_NAM_AC_ID"
UNION
SELECT DISTINCT
    "hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."Metadata_AC",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."Metadata_AC_NAM",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_Skådespelare_Namn",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."Metadata_AC_GEN",
    "pAC"."AC_GEN_GEN_Checksum",
    "pAC"."AC_GEN_GEN_Kön",
    "pAC"."AC_GEN_Metadata_GEN",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."Metadata_AC_PLV",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_EQ",
    "pAC"."AC_PLV_PLV_Yrkesnivå",
    "pAC"."AC_PLV_Metadata_PLV",
    "pAC"."AC_PLV_PLV_ID"
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå" "hPLV",
    TABLE(anchors."epAC_Skådespelare"(equivalent, "hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    "hPLV"."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hPLV"."AC_PLV_AC_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Föreställning" (
    "PR_ID",
    "Metadata_PR",
    "PR_NAM_PR_ID",
    "Metadata_PR_NAM",
    "PR_NAM_Föreställning_Namn" COMMENT 'Name or title of the program.',
    "PR_LEN_PR_ID",
    "Metadata_PR_LEN",
    "PR_LEN_ChangedAt",
    "PR_LEN_EQ",
    "PR_LEN_Föreställning_Längd" COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) COPY GRANTS 
AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(attributes."ePR_LEN_Föreställning_Längd"(0)) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(attributes."ePR_LEN_Föreställning_Längd"(0)) sub 
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Föreställning" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(attributes."rPR_LEN_Föreställning_Längd"(0, changingTimepoint::date)) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(attributes."rPR_LEN_Föreställning_Längd"(0, changingTimepoint::date)) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Föreställning" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(anchors."pPR_Föreställning"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Föreställning" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT DISTINCT
    "hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    "pPR"."PR_ID",
    "pPR"."Metadata_PR",
    "pPR"."PR_NAM_PR_ID",
    "pPR"."Metadata_PR_NAM",
    "pPR"."PR_NAM_Föreställning_Namn",
    "pPR"."PR_LEN_PR_ID",
    "pPR"."Metadata_PR_LEN",
    "pPR"."PR_LEN_ChangedAt",
    "pPR"."PR_LEN_EQ",
    "pPR"."PR_LEN_Föreställning_Längd"
FROM
    TABLE(attributes."ePR_LEN_Föreställning_Längd"(0)) "hLEN", 
    TABLE(anchors."pPR_Föreställning"("hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9))) "pPR"
WHERE
    (selection IS NULL OR selection LIKE '%LEN%')
AND
    "hLEN"."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pPR"."PR_ID" = "hLEN"."PR_LEN_PR_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epPR_Föreställning" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(attributes."rPR_LEN_Föreställning_Längd"(equivalent, changingTimepoint::date)) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(attributes."rPR_LEN_Föreställning_Längd"(equivalent, changingTimepoint::date)) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elPR_Föreställning" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epPR_Föreställning"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enPR_Föreställning" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epPR_Föreställning"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edPR_Föreställning" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT DISTINCT
    "hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    "pPR"."PR_ID",
    "pPR"."Metadata_PR",
    "pPR"."PR_NAM_PR_ID",
    "pPR"."Metadata_PR_NAM",
    "pPR"."PR_NAM_Föreställning_Namn",
    "pPR"."PR_LEN_PR_ID",
    "pPR"."Metadata_PR_LEN",
    "pPR"."PR_LEN_ChangedAt",
    "pPR"."PR_LEN_EQ",
    "pPR"."PR_LEN_Föreställning_Längd"
FROM
    TABLE(attributes."ePR_LEN_Föreställning_Längd"(equivalent)) "hLEN", 
    TABLE(anchors."epPR_Föreställning"(equivalent, "hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9))) "pPR"
WHERE
    (selection IS NULL OR selection LIKE '%LEN%')
AND
    "hLEN"."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pPR"."PR_ID" = "hLEN"."PR_LEN_PR_ID"
$$
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Snowflake-native nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" (
    "EV_ID",
    "Metadata_EV",
    "ST_ID_hölls" COMMENT 'The stage at which the event was held.',
    "PR_ID_spelades" COMMENT 'The program that was played at the event.',
    "of_ETY_Checksum",
    "of_ETY_Händelsetyp",
    "of_ETY_EQ",
    "of_Metadata_ETY",
    "ETY_ID_of",
    "EV_DAT_EV_ID",
    "Metadata_EV_DAT",
    "EV_DAT_Händelse_Datum" COMMENT 'Date and time when the event took place.',
    "EV_AUD_EV_ID",
    "Metadata_EV_AUD",
    "EV_AUD_EQ",
    "EV_AUD_Händelse_Publik" COMMENT 'Number of people in the audience at the event.',
    "EV_REV_EV_ID",
    "Metadata_EV_REV",
    "EV_REV_EQ",
    "EV_REV_Händelse_Intäkt" COMMENT 'Revenue from ticket sales for the event.',
    "EV_STA_EV_ID",
    "Metadata_EV_STA",
    "EV_STA_ChangedAt",
    "EV_STA_EQ",
    "EV_STA_Händelse_Status" COMMENT 'Status of the event, which may change until it has taken place.',
    "EV_UTL_EV_ID",
    "Metadata_EV_UTL",
    "EV_UTL_UTL_Utnyttjande",
    "EV_UTL_Metadata_UTL",
    "EV_UTL_UTL_ID",
    "EV_LVL_EV_ID",
    "Metadata_EV_LVL",
    "EV_LVL_ChangedAt",
    "EV_LVL_PLV_Checksum",
    "EV_LVL_PLV_EQ",
    "EV_LVL_PLV_Yrkesnivå" COMMENT 'Professional level required for the event, over time.',
    "EV_LVL_Metadata_PLV",
    "EV_LVL_PLV_ID" COMMENT 'Professional level required for the event, over time.'
) COPY GRANTS COMMENT = 'An event, a single performance of a program held at a stage at a specific date and time.'
AS
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    TABLE(knots."eETY_Händelsetyp"(0)) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_AUD_Händelse_Publik"(0)) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_REV_Händelse_Intäkt"(0)) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_STA_Händelse_Status"(0)) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            TABLE(attributes."eEV_STA_Händelse_Status"(0)) sub 
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."EV_LVL_Händelse_Level" "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."EV_LVL_Händelse_Level" sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(0)) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Händelse" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" tinyint,
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_EQ" tinyint,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_EQ" tinyint,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_EQ" tinyint,
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    TABLE(knots."eETY_Händelsetyp"(0)) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_AUD_Händelse_Publik"(0)) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_REV_Händelse_Intäkt"(0)) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."rEV_STA_Händelse_Status"(0, changingTimepoint::datetime)) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            TABLE(attributes."rEV_STA_Händelse_Status"(0, changingTimepoint::datetime)) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    TABLE(attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date)) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            TABLE(attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date)) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(0)) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(nexuses."pEV_Händelse"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Händelse" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" tinyint,
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_EQ" tinyint,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_EQ" tinyint,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_EQ" tinyint,
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hSTA"."EV_STA_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'STA' AS mnemonic,
    "pEV"."EV_ID",
    "pEV"."Metadata_EV",
    "pEV"."ST_ID_hölls",
    "pEV"."PR_ID_spelades",
    "pEV"."of_ETY_Checksum",
    "pEV"."of_ETY_Händelsetyp",
    "pEV"."of_ETY_EQ",
    "pEV"."of_Metadata_ETY",
    "pEV"."ETY_ID_of",
    "pEV"."EV_DAT_EV_ID",
    "pEV"."Metadata_EV_DAT",
    "pEV"."EV_DAT_Händelse_Datum",
    "pEV"."EV_AUD_EV_ID",
    "pEV"."Metadata_EV_AUD",
    "pEV"."EV_AUD_EQ",
    "pEV"."EV_AUD_Händelse_Publik",
    "pEV"."EV_REV_EV_ID",
    "pEV"."Metadata_EV_REV",
    "pEV"."EV_REV_EQ",
    "pEV"."EV_REV_Händelse_Intäkt",
    "pEV"."EV_STA_EV_ID",
    "pEV"."Metadata_EV_STA",
    "pEV"."EV_STA_ChangedAt",
    "pEV"."EV_STA_EQ",
    "pEV"."EV_STA_Händelse_Status",
    "pEV"."EV_UTL_EV_ID",
    "pEV"."Metadata_EV_UTL",
    "pEV"."EV_UTL_UTL_Utnyttjande",
    "pEV"."EV_UTL_Metadata_UTL",
    "pEV"."EV_UTL_UTL_ID",
    "pEV"."EV_LVL_EV_ID",
    "pEV"."Metadata_EV_LVL",
    "pEV"."EV_LVL_ChangedAt",
    "pEV"."EV_LVL_PLV_Checksum",
    "pEV"."EV_LVL_PLV_EQ",
    "pEV"."EV_LVL_PLV_Yrkesnivå",
    "pEV"."EV_LVL_Metadata_PLV",
    "pEV"."EV_LVL_PLV_ID"
FROM
    TABLE(attributes."eEV_STA_Händelse_Status"(0)) "hSTA", 
    TABLE(nexuses."pEV_Händelse"("hSTA"."EV_STA_ChangedAt"::timestamp_ntz(9))) "pEV"
WHERE
    (selection IS NULL OR selection LIKE '%STA%')
AND
    "hSTA"."EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pEV"."EV_ID" = "hSTA"."EV_STA_EV_ID"
UNION
SELECT DISTINCT
    "hLVL"."EV_LVL_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'LVL' AS mnemonic,
    "pEV"."EV_ID",
    "pEV"."Metadata_EV",
    "pEV"."ST_ID_hölls",
    "pEV"."PR_ID_spelades",
    "pEV"."of_ETY_Checksum",
    "pEV"."of_ETY_Händelsetyp",
    "pEV"."of_ETY_EQ",
    "pEV"."of_Metadata_ETY",
    "pEV"."ETY_ID_of",
    "pEV"."EV_DAT_EV_ID",
    "pEV"."Metadata_EV_DAT",
    "pEV"."EV_DAT_Händelse_Datum",
    "pEV"."EV_AUD_EV_ID",
    "pEV"."Metadata_EV_AUD",
    "pEV"."EV_AUD_EQ",
    "pEV"."EV_AUD_Händelse_Publik",
    "pEV"."EV_REV_EV_ID",
    "pEV"."Metadata_EV_REV",
    "pEV"."EV_REV_EQ",
    "pEV"."EV_REV_Händelse_Intäkt",
    "pEV"."EV_STA_EV_ID",
    "pEV"."Metadata_EV_STA",
    "pEV"."EV_STA_ChangedAt",
    "pEV"."EV_STA_EQ",
    "pEV"."EV_STA_Händelse_Status",
    "pEV"."EV_UTL_EV_ID",
    "pEV"."Metadata_EV_UTL",
    "pEV"."EV_UTL_UTL_Utnyttjande",
    "pEV"."EV_UTL_Metadata_UTL",
    "pEV"."EV_UTL_UTL_ID",
    "pEV"."EV_LVL_EV_ID",
    "pEV"."Metadata_EV_LVL",
    "pEV"."EV_LVL_ChangedAt",
    "pEV"."EV_LVL_PLV_Checksum",
    "pEV"."EV_LVL_PLV_EQ",
    "pEV"."EV_LVL_PLV_Yrkesnivå",
    "pEV"."EV_LVL_Metadata_PLV",
    "pEV"."EV_LVL_PLV_ID"
FROM
    attributes."EV_LVL_Händelse_Level" "hLVL",
    TABLE(nexuses."pEV_Händelse"("hLVL"."EV_LVL_ChangedAt"::timestamp_ntz(9))) "pEV"
WHERE
    (selection IS NULL OR selection LIKE '%LVL%')
AND
    "hLVL"."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pEV"."EV_ID" = "hLVL"."EV_LVL_EV_ID"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."elEV_Händelse" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" tinyint,
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_EQ" tinyint,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_EQ" tinyint,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_EQ" tinyint,
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    TABLE(knots."eETY_Händelsetyp"(equivalent)) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_AUD_Händelse_Publik"(equivalent)) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_REV_Händelse_Intäkt"(equivalent)) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_STA_Händelse_Status"(equivalent)) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            TABLE(attributes."eEV_STA_Händelse_Status"(equivalent)) sub 
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."EV_LVL_Händelse_Level" "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."EV_LVL_Händelse_Level" sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(equivalent)) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."epEV_Händelse" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" tinyint,
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_EQ" tinyint,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_EQ" tinyint,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_EQ" tinyint,
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    TABLE(knots."eETY_Händelsetyp"(equivalent)) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_AUD_Händelse_Publik"(equivalent)) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."eEV_REV_Händelse_Intäkt"(equivalent)) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    TABLE(attributes."rEV_STA_Händelse_Status"(equivalent, changingTimepoint::datetime)) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            TABLE(attributes."rEV_STA_Händelse_Status"(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    TABLE(attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date)) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            TABLE(attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date)) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_Yrkesnivå"(equivalent)) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."enEV_Händelse" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" tinyint,
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_EQ" tinyint,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_EQ" tinyint,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_EQ" tinyint,
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(nexuses."epEV_Händelse"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."edEV_Händelse" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "EV_ID" numeric(12,0),
    "Metadata_EV" int,
    "ST_ID_hölls" int,
    "PR_ID_spelades" number(10,0),
    "of_ETY_Checksum" numeric(19,0),
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" tinyint,
    "of_Metadata_ETY" int,
    "ETY_ID_of" tinyint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" int,
    "EV_DAT_Händelse_Datum" datetime,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" int,
    "EV_AUD_EQ" tinyint,
    "EV_AUD_Händelse_Publik" int,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" int,
    "EV_REV_EQ" tinyint,
    "EV_REV_Händelse_Intäkt" number(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" int,
    "EV_STA_ChangedAt" datetime,
    "EV_STA_EQ" tinyint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" int,
    "EV_UTL_UTL_Utnyttjande" tinyint,
    "EV_UTL_Metadata_UTL" int,
    "EV_UTL_UTL_ID" tinyint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" int,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" numeric(19,0),
    "EV_LVL_PLV_EQ" tinyint,
    "EV_LVL_PLV_Yrkesnivå" string,
    "EV_LVL_Metadata_PLV" int,
    "EV_LVL_PLV_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hSTA"."EV_STA_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'STA' AS mnemonic,
    "pEV"."EV_ID",
    "pEV"."Metadata_EV",
    "pEV"."ST_ID_hölls",
    "pEV"."PR_ID_spelades",
    "pEV"."of_ETY_Checksum",
    "pEV"."of_ETY_Händelsetyp",
    "pEV"."of_ETY_EQ",
    "pEV"."of_Metadata_ETY",
    "pEV"."ETY_ID_of",
    "pEV"."EV_DAT_EV_ID",
    "pEV"."Metadata_EV_DAT",
    "pEV"."EV_DAT_Händelse_Datum",
    "pEV"."EV_AUD_EV_ID",
    "pEV"."Metadata_EV_AUD",
    "pEV"."EV_AUD_EQ",
    "pEV"."EV_AUD_Händelse_Publik",
    "pEV"."EV_REV_EV_ID",
    "pEV"."Metadata_EV_REV",
    "pEV"."EV_REV_EQ",
    "pEV"."EV_REV_Händelse_Intäkt",
    "pEV"."EV_STA_EV_ID",
    "pEV"."Metadata_EV_STA",
    "pEV"."EV_STA_ChangedAt",
    "pEV"."EV_STA_EQ",
    "pEV"."EV_STA_Händelse_Status",
    "pEV"."EV_UTL_EV_ID",
    "pEV"."Metadata_EV_UTL",
    "pEV"."EV_UTL_UTL_Utnyttjande",
    "pEV"."EV_UTL_Metadata_UTL",
    "pEV"."EV_UTL_UTL_ID",
    "pEV"."EV_LVL_EV_ID",
    "pEV"."Metadata_EV_LVL",
    "pEV"."EV_LVL_ChangedAt",
    "pEV"."EV_LVL_PLV_Checksum",
    "pEV"."EV_LVL_PLV_EQ",
    "pEV"."EV_LVL_PLV_Yrkesnivå",
    "pEV"."EV_LVL_Metadata_PLV",
    "pEV"."EV_LVL_PLV_ID"
FROM
    TABLE(attributes."eEV_STA_Händelse_Status"(equivalent)) "hSTA", 
    TABLE(nexuses."epEV_Händelse"(equivalent, "hSTA"."EV_STA_ChangedAt"::timestamp_ntz(9))) "pEV"
WHERE
    (selection IS NULL OR selection LIKE '%STA%')
AND
    "hSTA"."EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pEV"."EV_ID" = "hSTA"."EV_STA_EV_ID"
UNION
SELECT DISTINCT
    "hLVL"."EV_LVL_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'LVL' AS mnemonic,
    "pEV"."EV_ID",
    "pEV"."Metadata_EV",
    "pEV"."ST_ID_hölls",
    "pEV"."PR_ID_spelades",
    "pEV"."of_ETY_Checksum",
    "pEV"."of_ETY_Händelsetyp",
    "pEV"."of_ETY_EQ",
    "pEV"."of_Metadata_ETY",
    "pEV"."ETY_ID_of",
    "pEV"."EV_DAT_EV_ID",
    "pEV"."Metadata_EV_DAT",
    "pEV"."EV_DAT_Händelse_Datum",
    "pEV"."EV_AUD_EV_ID",
    "pEV"."Metadata_EV_AUD",
    "pEV"."EV_AUD_EQ",
    "pEV"."EV_AUD_Händelse_Publik",
    "pEV"."EV_REV_EV_ID",
    "pEV"."Metadata_EV_REV",
    "pEV"."EV_REV_EQ",
    "pEV"."EV_REV_Händelse_Intäkt",
    "pEV"."EV_STA_EV_ID",
    "pEV"."Metadata_EV_STA",
    "pEV"."EV_STA_ChangedAt",
    "pEV"."EV_STA_EQ",
    "pEV"."EV_STA_Händelse_Status",
    "pEV"."EV_UTL_EV_ID",
    "pEV"."Metadata_EV_UTL",
    "pEV"."EV_UTL_UTL_Utnyttjande",
    "pEV"."EV_UTL_Metadata_UTL",
    "pEV"."EV_UTL_UTL_ID",
    "pEV"."EV_LVL_EV_ID",
    "pEV"."Metadata_EV_LVL",
    "pEV"."EV_LVL_ChangedAt",
    "pEV"."EV_LVL_PLV_Checksum",
    "pEV"."EV_LVL_PLV_EQ",
    "pEV"."EV_LVL_PLV_Yrkesnivå",
    "pEV"."EV_LVL_Metadata_PLV",
    "pEV"."EV_LVL_PLV_ID"
FROM
    attributes."EV_LVL_Händelse_Level" "hLVL",
    TABLE(nexuses."epEV_Händelse"(equivalent, "hLVL"."EV_LVL_ChangedAt"::timestamp_ntz(9))) "pEV"
WHERE
    (selection IS NULL OR selection LIKE '%LVL%')
AND
    "hLVL"."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pEV"."EV_ID" = "hLVL"."EV_LVL_EV_ID"
$$
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Snowflake-native tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" (
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_ID_partner" COMMENT 'One of the actors in the partnership.',
    "AC_ID_with" COMMENT 'The other actor in the partnership.',
    "currently_ONG_Pågående" COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).',
    "currently_ONG_EQ",
    "currently_Metadata_ONG",
    "ONG_ID_currently" COMMENT 'Whether the partnership is still ongoing (Yes) or has ended (No).'
) COPY GRANTS COMMENT = 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.'
AS
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(0)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = (
        SELECT
            max(sub."AC_partner_AC_with_ONG_currently_ChangedAt")
        FROM
            ties."AC_partner_AC_with_ONG_currently" sub
        WHERE
            sub."AC_ID_partner" = tie."AC_ID_partner"
        OR
            sub."AC_ID_with" = tie."AC_ID_with"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(0)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = (
        SELECT
            max(sub."AC_partner_AC_with_ONG_currently_ChangedAt")
        FROM
            ties."AC_partner_AC_with_ONG_currently" sub
        WHERE
        (
            sub."AC_ID_partner" = tie."AC_ID_partner"
        OR
            sub."AC_ID_with" = tie."AC_ID_with"
        )
        AND
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_partner_AC_with_ONG_currently"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(0)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_partner_AC_with_ONG_currently" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(equivalent)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = (
        SELECT
            max(sub."AC_partner_AC_with_ONG_currently_ChangedAt")
        FROM
            ties."AC_partner_AC_with_ONG_currently" sub
        WHERE
        (
            sub."AC_ID_partner" = tie."AC_ID_partner"
        OR
            sub."AC_ID_with" = tie."AC_ID_with"
        )
        AND
            sub."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_partner_AC_with_ONG_currently" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_partner_AC_with_ONG_currently"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_partner_AC_with_ONG_currently" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_partner_AC_with_ONG_currently"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_partner_AC_with_ONG_currently" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" int,
    "AC_partner_AC_with_ONG_currently_ChangedAt" datetime,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" tinyint,
    "currently_Metadata_ONG" int,
    "ONG_ID_currently" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_partner_AC_with_ONG_currently",
    tie."AC_partner_AC_with_ONG_currently_ChangedAt",
    tie."AC_ID_partner",
    tie."AC_ID_with",
    "ONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    TABLE(knots."eONG_Pågående"(equivalent)) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" (
    "Metadata_AC_subset_PN_of",
    "AC_ID_subset" COMMENT 'An actor, a person who performs parts in programs and is cast in events.',
    "PN_ID_of" COMMENT 'The person who is the actor.'
) COPY GRANTS 
AS
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    ties."AC_subset_PN_of" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    ties."AC_subset_PN_of" tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_subset_PN_of"(sysdate()::timestamp_ntz(9)))
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_subset_PN_of" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    ties."AC_subset_PN_of" tie
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_subset_PN_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_subset_PN_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_subset_PN_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" int,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_subset_PN_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" (
    "Metadata_EV_in_AC_rollsattes",
    "EV_ID_in" COMMENT 'The event the actor was cast in.',
    "AC_ID_rollsattes" COMMENT 'An actor cast in the event.'
) COPY GRANTS COMMENT = 'The actors that were cast in an event, meaning those who performed at that performance.'
AS
SELECT
    tie."Metadata_EV_in_AC_rollsattes",
    tie."EV_ID_in",
    tie."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_rollsattes",
    tie."EV_ID_in",
    tie."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" tie
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pEV_in_AC_rollsattes"(sysdate()::timestamp_ntz(9)))
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epEV_in_AC_rollsattes" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_rollsattes",
    tie."EV_ID_in",
    tie."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" tie
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elEV_in_AC_rollsattes" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epEV_in_AC_rollsattes"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enEV_in_AC_rollsattes" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" int,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epEV_in_AC_rollsattes"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" (
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt",
    "AC_ID_deltar" COMMENT 'The actor having a part in the program.',
    "PR_ID_in" COMMENT 'The program the actor has a part in.',
    "fick_RAT_Checksum",
    "fick_RAT_Betyg" COMMENT 'The rating the actor got for the part.',
    "fick_RAT_EQ",
    "fick_Metadata_RAT",
    "RAT_ID_fick" COMMENT 'The rating the actor got for the part.'
) COPY GRANTS COMMENT = 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.'
AS
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(0)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = (
        SELECT
            max(sub."AC_deltar_PR_in_RAT_fick_ChangedAt")
        FROM
            ties."AC_deltar_PR_in_RAT_fick" sub
        WHERE
            sub."AC_ID_deltar" = tie."AC_ID_deltar"
        AND
            sub."PR_ID_in" = tie."PR_ID_in"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(0)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = (
        SELECT
            max(sub."AC_deltar_PR_in_RAT_fick_ChangedAt")
        FROM
            ties."AC_deltar_PR_in_RAT_fick" sub
        WHERE
            sub."AC_ID_deltar" = tie."AC_ID_deltar"
        AND
            sub."PR_ID_in" = tie."PR_ID_in"
        AND
            sub."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_deltar_PR_in_RAT_fick"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(0)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(equivalent)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = (
        SELECT
            max(sub."AC_deltar_PR_in_RAT_fick_ChangedAt")
        FROM
            ties."AC_deltar_PR_in_RAT_fick" sub
        WHERE
            sub."AC_ID_deltar" = tie."AC_ID_deltar"
        AND
            sub."PR_ID_in" = tie."PR_ID_in"
        AND
            sub."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_deltar_PR_in_RAT_fick"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_deltar_PR_in_RAT_fick"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_deltar_PR_in_RAT_fick" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" int,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" datetime,
    "AC_ID_deltar" smallint,
    "PR_ID_in" number(10,0),
    "fick_RAT_Checksum" numeric(19,0),
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" tinyint,
    "fick_Metadata_RAT" int,
    "RAT_ID_fick" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_deltar_PR_in_RAT_fick",
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt",
    tie."AC_ID_deltar",
    tie."PR_ID_in",
    "RAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "RAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "RAT_fick"."RAT_EQ" AS "fick_RAT_EQ",
    "RAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    tie."RAT_ID_fick"
FROM
    ties."AC_deltar_PR_in_RAT_fick" tie
LEFT JOIN
    TABLE(knots."eRAT_Betyg"(equivalent)) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" (
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ChangedAt",
    "ST_ID_at" COMMENT 'The stage where the program is playing.',
    "PR_ID_spelas" COMMENT 'The program playing at the stage.'
) COPY GRANTS COMMENT = 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.'
AS
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = (
        SELECT
            max(sub."ST_at_PR_spelas_ChangedAt")
        FROM
            ties."ST_at_PR_spelas" sub
        WHERE
            sub."ST_ID_at" = tie."ST_ID_at"
        AND
            sub."PR_ID_spelas" = tie."PR_ID_spelas"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = (
        SELECT
            max(sub."ST_at_PR_spelas_ChangedAt")
        FROM
            ties."ST_at_PR_spelas" sub
        WHERE
            sub."ST_ID_at" = tie."ST_ID_at"
        AND
            sub."PR_ID_spelas" = tie."PR_ID_spelas"
        AND
            sub."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pST_at_PR_spelas"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epST_at_PR_spelas" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = (
        SELECT
            max(sub."ST_at_PR_spelas_ChangedAt")
        FROM
            ties."ST_at_PR_spelas" sub
        WHERE
            sub."ST_ID_at" = tie."ST_ID_at"
        AND
            sub."PR_ID_spelas" = tie."PR_ID_spelas"
        AND
            sub."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elST_at_PR_spelas" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epST_at_PR_spelas"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enST_at_PR_spelas" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epST_at_PR_spelas"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edST_at_PR_spelas" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" int,
    "ST_at_PR_spelas_ChangedAt" datetime,
    "ST_ID_at" int,
    "PR_ID_spelas" number(10,0)
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    ties."ST_at_PR_spelas" tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" (
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_ID_förälder" COMMENT 'The actor who is the parent.',
    "AC_ID_barn" COMMENT 'The actor who is the child.',
    "har_PAT_Föräldratyp" COMMENT 'The type of parental relationship.',
    "har_PAT_EQ",
    "har_Metadata_PAT",
    "PAT_ID_har" COMMENT 'The type of parental relationship.'
) COPY GRANTS COMMENT = 'Parent-child relationships between actors, along with the type of parental relationship.'
AS
SELECT
    tie."Metadata_AC_förälder_AC_barn_PAT_har",
    tie."AC_ID_förälder",
    tie."AC_ID_barn",
    "PAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "PAT_har"."PAT_EQ" AS "har_PAT_EQ",
    "PAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    tie."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" tie
LEFT JOIN
    TABLE(knots."ePAT_Föräldratyp"(0)) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_förälder_AC_barn_PAT_har",
    tie."AC_ID_förälder",
    tie."AC_ID_barn",
    "PAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "PAT_har"."PAT_EQ" AS "har_PAT_EQ",
    "PAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    tie."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" tie
LEFT JOIN
    TABLE(knots."ePAT_Föräldratyp"(0)) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pAC_förälder_AC_barn_PAT_har"(sysdate()::timestamp_ntz(9)))
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_förälder_AC_barn_PAT_har" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    tie."Metadata_AC_förälder_AC_barn_PAT_har",
    tie."AC_ID_förälder",
    tie."AC_ID_barn",
    "PAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "PAT_har"."PAT_EQ" AS "har_PAT_EQ",
    "PAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    tie."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" tie
LEFT JOIN
    TABLE(knots."ePAT_Föräldratyp"(equivalent)) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_förälder_AC_barn_PAT_har" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_förälder_AC_barn_PAT_har"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_förälder_AC_barn_PAT_har" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" int,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" tinyint,
    "har_Metadata_PAT" int,
    "PAT_ID_har" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epAC_förälder_AC_barn_PAT_har"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" (
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt",
    "PR_ID_innehåll" COMMENT 'The program that made up the content of the event.',
    "ST_ID_plats" COMMENT 'The stage where the event was located.',
    "EV_ID_of" COMMENT 'The event.'
) COPY GRANTS COMMENT = 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.'
AS
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = (
        SELECT
            max(sub."PR_innehåll_ST_plats_EV_of_ChangedAt")
        FROM
            ties."PR_innehåll_ST_plats_EV_of" sub
        WHERE
            sub."PR_ID_innehåll" = tie."PR_ID_innehåll"
        OR
            sub."ST_ID_plats" = tie."ST_ID_plats"
   )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = (
        SELECT
            max(sub."PR_innehåll_ST_plats_EV_of_ChangedAt")
        FROM
            ties."PR_innehåll_ST_plats_EV_of" sub
        WHERE
        (
            sub."PR_ID_innehåll" = tie."PR_ID_innehåll"
        OR
            sub."ST_ID_plats" = tie."ST_ID_plats"
        )
        AND
            sub."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    *
FROM
    TABLE(ties."pPR_innehåll_ST_plats_EV_of"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = (
        SELECT
            max(sub."PR_innehåll_ST_plats_EV_of_ChangedAt")
        FROM
            ties."PR_innehåll_ST_plats_EV_of" sub
        WHERE
        (
            sub."PR_ID_innehåll" = tie."PR_ID_innehåll"
        OR
            sub."ST_ID_plats" = tie."ST_ID_plats"
        )
        AND
            sub."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epPR_innehåll_ST_plats_EV_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    TABLE(ties."epPR_innehåll_ST_plats_EV_of"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edPR_innehåll_ST_plats_EV_of" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" int,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" datetime,
    "PR_ID_innehåll" number(10,0),
    "ST_ID_plats" int,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    ties."PR_innehåll_ST_plats_EV_of" tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$
;
-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- Snowflake does not enforce primary, unique or foreign keys, and every key here is declared RELY, which tells the
-- optimizer to trust it. A violation is therefore not an error, but wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--   restatement                                   in an attribute or a tie that may not store them, a value
--                                                 that is the same as the one before it in changing time
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a RELY foreign key cannot make the optimizer drop the join.
--
-- PAT_Föräldratyp_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PAT_Föräldratyp_ID" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_Föräldratyp_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_ID', "PAT_ID"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp_ID"
GROUP BY
    "PAT_ID"
HAVING
    COUNT(*) > 1;
-- PAT_Föräldratyp_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PAT_Föräldratyp_EQ" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PAT_Föräldratyp_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PAT_EQ', "PAT_EQ", 'PAT_ID', "PAT_ID"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp_EQ"
GROUP BY
    "PAT_EQ",
    "PAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_Föräldratyp_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PAT_EQ', "PAT_EQ", 'PAT_Föräldratyp', "PAT_Föräldratyp"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp_EQ"
GROUP BY
    "PAT_EQ",
    "PAT_Föräldratyp"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_Föräldratyp_EQ',
    'no row in PAT_Föräldratyp_ID for PAT_ID',
    OBJECT_CONSTRUCT('PAT_ID', c."PAT_ID"),
    COUNT(*)
FROM
    knots."PAT_Föräldratyp_EQ" c
LEFT JOIN
    knots."PAT_Föräldratyp_ID" p
ON
    p."PAT_ID" = c."PAT_ID"
WHERE
    p."PAT_ID" IS NULL
GROUP BY
    c."PAT_ID";
-- GEN_Kön integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_GEN_Kön" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'GEN_Kön',
    'duplicate primary key',
    OBJECT_CONSTRUCT('GEN_ID', "GEN_ID"),
    COUNT(*)
FROM
    knots."GEN_Kön"
GROUP BY
    "GEN_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Kön',
    'duplicate unique key',
    OBJECT_CONSTRUCT('GEN_Checksum', "GEN_Checksum"),
    COUNT(*)
FROM
    knots."GEN_Kön"
GROUP BY
    "GEN_Checksum"
HAVING
    COUNT(*) > 1;
-- PLV_Yrkesnivå_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PLV_Yrkesnivå_ID" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PLV_Yrkesnivå_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PLV_ID', "PLV_ID"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå_ID"
GROUP BY
    "PLV_ID"
HAVING
    COUNT(*) > 1;
-- PLV_Yrkesnivå_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_PLV_Yrkesnivå_EQ" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PLV_Yrkesnivå_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PLV_EQ', "PLV_EQ", 'PLV_ID', "PLV_ID"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå_EQ"
GROUP BY
    "PLV_EQ",
    "PLV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_Yrkesnivå_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('PLV_EQ', "PLV_EQ", 'PLV_Checksum', "PLV_Checksum"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå_EQ"
GROUP BY
    "PLV_EQ",
    "PLV_Checksum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_Yrkesnivå_EQ',
    'no row in PLV_Yrkesnivå_ID for PLV_ID',
    OBJECT_CONSTRUCT('PLV_ID', c."PLV_ID"),
    COUNT(*)
FROM
    knots."PLV_Yrkesnivå_EQ" c
LEFT JOIN
    knots."PLV_Yrkesnivå_ID" p
ON
    p."PLV_ID" = c."PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."PLV_ID";
-- UTL_Utnyttjande integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_UTL_Utnyttjande" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'UTL_Utnyttjande',
    'duplicate primary key',
    OBJECT_CONSTRUCT('UTL_ID', "UTL_ID"),
    COUNT(*)
FROM
    knots."UTL_Utnyttjande"
GROUP BY
    "UTL_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utnyttjande',
    'duplicate unique key',
    OBJECT_CONSTRUCT('UTL_Utnyttjande', "UTL_Utnyttjande"),
    COUNT(*)
FROM
    knots."UTL_Utnyttjande"
GROUP BY
    "UTL_Utnyttjande"
HAVING
    COUNT(*) > 1;
-- ONG_Pågående_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ONG_Pågående_ID" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Pågående_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_ID', "ONG_ID"),
    COUNT(*)
FROM
    knots."ONG_Pågående_ID"
GROUP BY
    "ONG_ID"
HAVING
    COUNT(*) > 1;
-- ONG_Pågående_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ONG_Pågående_EQ" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ONG_Pågående_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ONG_EQ', "ONG_EQ", 'ONG_ID', "ONG_ID"),
    COUNT(*)
FROM
    knots."ONG_Pågående_EQ"
GROUP BY
    "ONG_EQ",
    "ONG_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Pågående_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ONG_EQ', "ONG_EQ", 'ONG_Pågående', "ONG_Pågående"),
    COUNT(*)
FROM
    knots."ONG_Pågående_EQ"
GROUP BY
    "ONG_EQ",
    "ONG_Pågående"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Pågående_EQ',
    'no row in ONG_Pågående_ID for ONG_ID',
    OBJECT_CONSTRUCT('ONG_ID', c."ONG_ID"),
    COUNT(*)
FROM
    knots."ONG_Pågående_EQ" c
LEFT JOIN
    knots."ONG_Pågående_ID" p
ON
    p."ONG_ID" = c."ONG_ID"
WHERE
    p."ONG_ID" IS NULL
GROUP BY
    c."ONG_ID";
-- RAT_Betyg_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_RAT_Betyg_ID" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Betyg_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_ID', "RAT_ID"),
    COUNT(*)
FROM
    knots."RAT_Betyg_ID"
GROUP BY
    "RAT_ID"
HAVING
    COUNT(*) > 1;
-- RAT_Betyg_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_RAT_Betyg_EQ" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'RAT_Betyg_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('RAT_EQ', "RAT_EQ", 'RAT_ID', "RAT_ID"),
    COUNT(*)
FROM
    knots."RAT_Betyg_EQ"
GROUP BY
    "RAT_EQ",
    "RAT_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Betyg_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('RAT_EQ', "RAT_EQ", 'RAT_Checksum', "RAT_Checksum"),
    COUNT(*)
FROM
    knots."RAT_Betyg_EQ"
GROUP BY
    "RAT_EQ",
    "RAT_Checksum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Betyg_EQ',
    'no row in RAT_Betyg_ID for RAT_ID',
    OBJECT_CONSTRUCT('RAT_ID', c."RAT_ID"),
    COUNT(*)
FROM
    knots."RAT_Betyg_EQ" c
LEFT JOIN
    knots."RAT_Betyg_ID" p
ON
    p."RAT_ID" = c."RAT_ID"
WHERE
    p."RAT_ID" IS NULL
GROUP BY
    c."RAT_ID";
-- ETY_Händelsetyp_ID integrity ------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ETY_Händelsetyp_ID" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ETY_Händelsetyp_ID',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ETY_ID', "ETY_ID"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp_ID"
GROUP BY
    "ETY_ID"
HAVING
    COUNT(*) > 1;
-- ETY_Händelsetyp_EQ integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ic_ETY_Händelsetyp_EQ" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ETY_Händelsetyp_EQ',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ETY_EQ', "ETY_EQ", 'ETY_ID', "ETY_ID"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp_EQ"
GROUP BY
    "ETY_EQ",
    "ETY_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_Händelsetyp_EQ',
    'duplicate unique key',
    OBJECT_CONSTRUCT('ETY_EQ', "ETY_EQ", 'ETY_Checksum', "ETY_Checksum"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp_EQ"
GROUP BY
    "ETY_EQ",
    "ETY_Checksum"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_Händelsetyp_EQ',
    'no row in ETY_Händelsetyp_ID for ETY_ID',
    OBJECT_CONSTRUCT('ETY_ID', c."ETY_ID"),
    COUNT(*)
FROM
    knots."ETY_Händelsetyp_EQ" c
LEFT JOIN
    knots."ETY_Händelsetyp_ID" p
ON
    p."ETY_ID" = c."ETY_ID"
WHERE
    p."ETY_ID" IS NULL
GROUP BY
    c."ETY_ID";
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PN_Person" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PN_ID', "PN_ID"),
    COUNT(*)
FROM
    anchors."PN_Person"
GROUP BY
    "PN_ID"
HAVING
    COUNT(*) > 1;
-- ST_Scen integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_ST_Scen" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_Scen',
    'duplicate primary key',
    OBJECT_CONSTRUCT('ST_ID', "ST_ID"),
    COUNT(*)
FROM
    anchors."ST_Scen"
GROUP BY
    "ST_ID"
HAVING
    COUNT(*) > 1;
-- AC_Skådespelare integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_AC_Skådespelare" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_Skådespelare',
    'duplicate primary key',
    OBJECT_CONSTRUCT('AC_ID', "AC_ID"),
    COUNT(*)
FROM
    anchors."AC_Skådespelare"
GROUP BY
    "AC_ID"
HAVING
    COUNT(*) > 1;
-- PR_Föreställning integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."ic_PR_Föreställning" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_Föreställning',
    'duplicate primary key',
    OBJECT_CONSTRUCT('PR_ID', "PR_ID"),
    COUNT(*)
FROM
    anchors."PR_Föreställning"
GROUP BY
    "PR_ID"
HAVING
    COUNT(*) > 1;
-- EV_Händelse integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."ic_EV_Händelse" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_Händelse',
    'duplicate primary key',
    OBJECT_CONSTRUCT('EV_ID', "EV_ID"),
    COUNT(*)
FROM
    nexuses."EV_Händelse"
GROUP BY
    "EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ST_Scen for ST_ID_hölls',
    OBJECT_CONSTRUCT('ST_ID_hölls', c."ST_ID_hölls"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_hölls"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_hölls"
UNION ALL
SELECT
    'EV_Händelse',
    'no row in PR_Föreställning for PR_ID_spelades',
    OBJECT_CONSTRUCT('PR_ID_spelades', c."PR_ID_spelades"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_spelades"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_spelades"
UNION ALL
SELECT
    'EV_Händelse',
    'no row in ETY_Händelsetyp_ID for ETY_ID_of',
    OBJECT_CONSTRUCT('ETY_ID_of', c."ETY_ID_of"),
    COUNT(*)
FROM
    nexuses."EV_Händelse" c
LEFT JOIN
    knots."ETY_Händelsetyp_ID" p
ON
    p."ETY_ID" = c."ETY_ID_of"
WHERE
    p."ETY_ID" IS NULL
GROUP BY
    c."ETY_ID_of"
;
-- EV_DAT_Händelse_Datum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_DAT_Händelse_Datum" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_DAT_Händelse_Datum',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_DAT_EV_ID', "EV_DAT_EV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum"
GROUP BY
    "EV_DAT_EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Händelse_Datum',
    'no row in EV_Händelse for EV_DAT_EV_ID',
    OBJECT_CONSTRUCT('EV_DAT_EV_ID', c."EV_DAT_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_DAT_Händelse_Datum" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_DAT_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_DAT_EV_ID"
;
-- EV_AUD_Händelse_Publik integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_AUD_Händelse_Publik" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_AUD_Händelse_Publik',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_AUD_EQ', "EV_AUD_EQ",
        'EV_AUD_EV_ID', "EV_AUD_EV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik"
GROUP BY
    "EV_AUD_EQ",
    "EV_AUD_EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Händelse_Publik',
    'no row in EV_Händelse for EV_AUD_EV_ID',
    OBJECT_CONSTRUCT('EV_AUD_EV_ID', c."EV_AUD_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_AUD_Händelse_Publik" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_AUD_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_AUD_EV_ID"
;
-- EV_REV_Händelse_Intäkt integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_REV_Händelse_Intäkt" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_REV_Händelse_Intäkt',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_REV_EQ', "EV_REV_EQ",
        'EV_REV_EV_ID', "EV_REV_EV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt"
GROUP BY
    "EV_REV_EQ",
    "EV_REV_EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Händelse_Intäkt',
    'no row in EV_Händelse for EV_REV_EV_ID',
    OBJECT_CONSTRUCT('EV_REV_EV_ID', c."EV_REV_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_REV_Händelse_Intäkt" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_REV_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_REV_EV_ID"
;
-- EV_STA_Händelse_Status integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_STA_Händelse_Status" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_STA_Händelse_Status',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_STA_EQ', "EV_STA_EQ",
        'EV_STA_EV_ID', "EV_STA_EV_ID",
        'EV_STA_ChangedAt', "EV_STA_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status"
GROUP BY
    "EV_STA_EQ",
    "EV_STA_EV_ID",
    "EV_STA_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Händelse_Status',
    'no row in EV_Händelse for EV_STA_EV_ID',
    OBJECT_CONSTRUCT('EV_STA_EV_ID', c."EV_STA_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_STA_Händelse_Status" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_STA_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_STA_EV_ID"
;
-- EV_UTL_Händelse_Utnyttjande integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_UTL_Händelse_Utnyttjande" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_UTL_Händelse_Utnyttjande',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_UTL_EV_ID', "EV_UTL_EV_ID"
    ),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande"
GROUP BY
    "EV_UTL_EV_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande',
    'no row in EV_Händelse for EV_UTL_EV_ID',
    OBJECT_CONSTRUCT('EV_UTL_EV_ID', c."EV_UTL_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_UTL_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_UTL_EV_ID"
UNION ALL
SELECT
    'EV_UTL_Händelse_Utnyttjande',
    'no row in UTL_Utnyttjande for EV_UTL_UTL_ID',
    OBJECT_CONSTRUCT('EV_UTL_UTL_ID', c."EV_UTL_UTL_ID"),
    COUNT(*)
FROM
    attributes."EV_UTL_Händelse_Utnyttjande" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."EV_UTL_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."EV_UTL_UTL_ID"
;
-- EV_LVL_Händelse_Level integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_EV_LVL_Händelse_Level" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_LVL_Händelse_Level',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_LVL_EV_ID', "EV_LVL_EV_ID",
        'EV_LVL_ChangedAt', "EV_LVL_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level"
GROUP BY
    "EV_LVL_EV_ID",
    "EV_LVL_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Händelse_Level',
    'no row in EV_Händelse for EV_LVL_EV_ID',
    OBJECT_CONSTRUCT('EV_LVL_EV_ID', c."EV_LVL_EV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_LVL_EV_ID"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_LVL_EV_ID"
UNION ALL
SELECT
    'EV_LVL_Händelse_Level',
    'no row in PLV_Yrkesnivå_ID for EV_LVL_PLV_ID',
    OBJECT_CONSTRUCT('EV_LVL_PLV_ID', c."EV_LVL_PLV_ID"),
    COUNT(*)
FROM
    attributes."EV_LVL_Händelse_Level" c
LEFT JOIN
    knots."PLV_Yrkesnivå_ID" p
ON
    p."PLV_ID" = c."EV_LVL_PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."EV_LVL_PLV_ID"
;
-- ST_NAM_Scen_Namn integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_NAM_Scen_Namn" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_NAM_Scen_Namn',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_NAM_EQ', "ST_NAM_EQ",
        'ST_NAM_ST_ID', "ST_NAM_ST_ID",
        'ST_NAM_ChangedAt', "ST_NAM_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn"
GROUP BY
    "ST_NAM_EQ",
    "ST_NAM_ST_ID",
    "ST_NAM_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Scen_Namn',
    'no row in ST_Scen for ST_NAM_ST_ID',
    OBJECT_CONSTRUCT('ST_NAM_ST_ID', c."ST_NAM_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_NAM_Scen_Namn" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_NAM_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_NAM_ST_ID"
;
-- ST_LOC_Scen_Plats integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_LOC_Scen_Plats" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_LOC_Scen_Plats',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_LOC_EQ', "ST_LOC_EQ",
        'ST_LOC_ST_ID', "ST_LOC_ST_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats"
GROUP BY
    "ST_LOC_EQ",
    "ST_LOC_ST_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Scen_Plats',
    'no row in ST_Scen for ST_LOC_ST_ID',
    OBJECT_CONSTRUCT('ST_LOC_ST_ID', c."ST_LOC_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_LOC_Scen_Plats" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_LOC_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_LOC_ST_ID"
;
-- ST_AVG_Scen_Medel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_AVG_Scen_Medel" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_AVG_Scen_Medel',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', "ST_AVG_ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel"
GROUP BY
    "ST_AVG_ST_ID",
    "ST_AVG_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Scen_Medel',
    'no row in ST_Scen for ST_AVG_ST_ID',
    OBJECT_CONSTRUCT('ST_AVG_ST_ID', c."ST_AVG_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_AVG_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_AVG_ST_ID"
UNION ALL
SELECT
    'ST_AVG_Scen_Medel',
    'no row in UTL_Utnyttjande for ST_AVG_UTL_ID',
    OBJECT_CONSTRUCT('ST_AVG_UTL_ID', c."ST_AVG_UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_AVG_Scen_Medel" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."ST_AVG_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."ST_AVG_UTL_ID"
UNION ALL
SELECT
    'ST_AVG_Scen_Medel',
    'restatement',
    OBJECT_CONSTRUCT(
        'ST_AVG_ST_ID', "ST_AVG_ST_ID",
        'ST_AVG_ChangedAt', "ST_AVG_ChangedAt"
    ),
    1
FROM (
    SELECT
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID" AS compared,
        LAG("ST_AVG_UTL_ID") OVER (
            PARTITION BY
                "ST_AVG_ST_ID"
            ORDER BY
                "ST_AVG_ChangedAt"
        ) AS previous
    FROM
        attributes."ST_AVG_Scen_Medel"
)
WHERE
    compared = previous
;
-- ST_MIN_Scen_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_ST_MIN_Scen_Minimum" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_MIN_Scen_Minimum',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_MIN_ST_ID', "ST_MIN_ST_ID"
    ),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum"
GROUP BY
    "ST_MIN_ST_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum',
    'no row in ST_Scen for ST_MIN_ST_ID',
    OBJECT_CONSTRUCT('ST_MIN_ST_ID', c."ST_MIN_ST_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_MIN_ST_ID"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_MIN_ST_ID"
UNION ALL
SELECT
    'ST_MIN_Scen_Minimum',
    'no row in UTL_Utnyttjande for ST_MIN_UTL_ID',
    OBJECT_CONSTRUCT('ST_MIN_UTL_ID', c."ST_MIN_UTL_ID"),
    COUNT(*)
FROM
    attributes."ST_MIN_Scen_Minimum" c
LEFT JOIN
    knots."UTL_Utnyttjande" p
ON
    p."UTL_ID" = c."ST_MIN_UTL_ID"
WHERE
    p."UTL_ID" IS NULL
GROUP BY
    c."ST_MIN_UTL_ID"
;
-- AC_NAM_Skådespelare_Namn integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_NAM_Skådespelare_Namn" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_NAM_Skådespelare_Namn',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', "AC_NAM_AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn"
GROUP BY
    "AC_NAM_AC_ID",
    "AC_NAM_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn',
    'no row in AC_Skådespelare for AC_NAM_AC_ID',
    OBJECT_CONSTRUCT('AC_NAM_AC_ID', c."AC_NAM_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_NAM_Skådespelare_Namn" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_NAM_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_NAM_AC_ID"
UNION ALL
SELECT
    'AC_NAM_Skådespelare_Namn',
    'restatement',
    OBJECT_CONSTRUCT(
        'AC_NAM_AC_ID', "AC_NAM_AC_ID",
        'AC_NAM_ChangedAt', "AC_NAM_ChangedAt"
    ),
    1
FROM (
    SELECT
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Skådespelare_Namn" AS compared,
        LAG("AC_NAM_Skådespelare_Namn") OVER (
            PARTITION BY
                "AC_NAM_AC_ID"
            ORDER BY
                "AC_NAM_ChangedAt"
        ) AS previous
    FROM
        attributes."AC_NAM_Skådespelare_Namn"
)
WHERE
    compared = previous
;
-- AC_GEN_Skådespelare_Kön integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_GEN_Skådespelare_Kön" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_GEN_Skådespelare_Kön',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_GEN_AC_ID', "AC_GEN_AC_ID"
    ),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön"
GROUP BY
    "AC_GEN_AC_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön',
    'no row in AC_Skådespelare for AC_GEN_AC_ID',
    OBJECT_CONSTRUCT('AC_GEN_AC_ID', c."AC_GEN_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_GEN_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_GEN_AC_ID"
UNION ALL
SELECT
    'AC_GEN_Skådespelare_Kön',
    'no row in GEN_Kön for AC_GEN_GEN_ID',
    OBJECT_CONSTRUCT('AC_GEN_GEN_ID', c."AC_GEN_GEN_ID"),
    COUNT(*)
FROM
    attributes."AC_GEN_Skådespelare_Kön" c
LEFT JOIN
    knots."GEN_Kön" p
ON
    p."GEN_ID" = c."AC_GEN_GEN_ID"
WHERE
    p."GEN_ID" IS NULL
GROUP BY
    c."AC_GEN_GEN_ID"
;
-- AC_PLV_Skådespelare_Yrkesnivå integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_AC_PLV_Skådespelare_Yrkesnivå" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_PLV_AC_ID', "AC_PLV_AC_ID",
        'AC_PLV_ChangedAt', "AC_PLV_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå"
GROUP BY
    "AC_PLV_AC_ID",
    "AC_PLV_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå',
    'no row in AC_Skådespelare for AC_PLV_AC_ID',
    OBJECT_CONSTRUCT('AC_PLV_AC_ID', c."AC_PLV_AC_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_PLV_AC_ID"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_PLV_AC_ID"
UNION ALL
SELECT
    'AC_PLV_Skådespelare_Yrkesnivå',
    'no row in PLV_Yrkesnivå_ID for AC_PLV_PLV_ID',
    OBJECT_CONSTRUCT('AC_PLV_PLV_ID', c."AC_PLV_PLV_ID"),
    COUNT(*)
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå" c
LEFT JOIN
    knots."PLV_Yrkesnivå_ID" p
ON
    p."PLV_ID" = c."AC_PLV_PLV_ID"
WHERE
    p."PLV_ID" IS NULL
GROUP BY
    c."AC_PLV_PLV_ID"
;
-- PR_NAM_Föreställning_Namn integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_NAM_Föreställning_Namn" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_NAM_Föreställning_Namn',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_NAM_PR_ID', "PR_NAM_PR_ID"
    ),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn"
GROUP BY
    "PR_NAM_PR_ID"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Föreställning_Namn',
    'no row in PR_Föreställning for PR_NAM_PR_ID',
    OBJECT_CONSTRUCT('PR_NAM_PR_ID', c."PR_NAM_PR_ID"),
    COUNT(*)
FROM
    attributes."PR_NAM_Föreställning_Namn" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_NAM_PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_NAM_PR_ID"
;
-- PR_LEN_Föreställning_Längd integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes."ic_PR_LEN_Föreställning_Längd" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_LEN_Föreställning_Längd',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_LEN_EQ', "PR_LEN_EQ",
        'PR_LEN_PR_ID', "PR_LEN_PR_ID",
        'PR_LEN_ChangedAt', "PR_LEN_ChangedAt"
    ),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd"
GROUP BY
    "PR_LEN_EQ",
    "PR_LEN_PR_ID",
    "PR_LEN_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Föreställning_Längd',
    'no row in PR_Föreställning for PR_LEN_PR_ID',
    OBJECT_CONSTRUCT('PR_LEN_PR_ID', c."PR_LEN_PR_ID"),
    COUNT(*)
FROM
    attributes."PR_LEN_Föreställning_Längd" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_LEN_PR_ID"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_LEN_PR_ID"
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_partner_AC_with_ONG_currently" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_ID_with', "AC_ID_with",
        'ONG_ID_currently', "ONG_ID_currently",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently"
GROUP BY
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_partner)',
    OBJECT_CONSTRUCT(
        'AC_ID_partner', "AC_ID_partner",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently"
GROUP BY
    "AC_ID_partner",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_with)',
    OBJECT_CONSTRUCT(
        'AC_ID_with', "AC_ID_with",
        'AC_partner_AC_with_ONG_currently_ChangedAt', "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently"
GROUP BY
    "AC_ID_with",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Skådespelare for AC_ID_partner',
    OBJECT_CONSTRUCT('AC_ID_partner', c."AC_ID_partner"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_partner"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_partner"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Skådespelare for AC_ID_with',
    OBJECT_CONSTRUCT('AC_ID_with', c."AC_ID_with"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_with"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_with"
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Pågående_ID for ONG_ID_currently',
    OBJECT_CONSTRUCT('ONG_ID_currently', c."ONG_ID_currently"),
    COUNT(*)
FROM
    ties."AC_partner_AC_with_ONG_currently" c
LEFT JOIN
    knots."ONG_Pågående_ID" p
ON
    p."ONG_ID" = c."ONG_ID_currently"
WHERE
    p."ONG_ID" IS NULL
GROUP BY
    c."ONG_ID_currently"
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_subset_PN_of" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_subset_PN_of',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset",
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of"
GROUP BY
    "AC_ID_subset",
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (AC_subset)',
    OBJECT_CONSTRUCT(
        'AC_ID_subset', "AC_ID_subset"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of"
GROUP BY
    "AC_ID_subset"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (PN_of)',
    OBJECT_CONSTRUCT(
        'PN_ID_of', "PN_ID_of"
    ),
    COUNT(*)
FROM
    ties."AC_subset_PN_of"
GROUP BY
    "PN_ID_of"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in AC_Skådespelare for AC_ID_subset',
    OBJECT_CONSTRUCT('AC_ID_subset', c."AC_ID_subset"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_subset"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_subset"
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in PN_Person for PN_ID_of',
    OBJECT_CONSTRUCT('PN_ID_of', c."PN_ID_of"),
    COUNT(*)
FROM
    ties."AC_subset_PN_of" c
LEFT JOIN
    anchors."PN_Person" p
ON
    p."PN_ID" = c."PN_ID_of"
WHERE
    p."PN_ID" IS NULL
GROUP BY
    c."PN_ID_of"
;
-- EV_in_AC_rollsattes integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_EV_in_AC_rollsattes" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'EV_in_AC_rollsattes',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'EV_ID_in', "EV_ID_in",
        'AC_ID_rollsattes', "AC_ID_rollsattes"
    ),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes"
GROUP BY
    "EV_ID_in",
    "AC_ID_rollsattes"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_rollsattes',
    'no row in EV_Händelse for EV_ID_in',
    OBJECT_CONSTRUCT('EV_ID_in', c."EV_ID_in"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_ID_in"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_in"
UNION ALL
SELECT
    'EV_in_AC_rollsattes',
    'no row in AC_Skådespelare for AC_ID_rollsattes',
    OBJECT_CONSTRUCT('AC_ID_rollsattes', c."AC_ID_rollsattes"),
    COUNT(*)
FROM
    ties."EV_in_AC_rollsattes" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_rollsattes"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_rollsattes"
;
-- AC_deltar_PR_in_RAT_fick integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_deltar_PR_in_RAT_fick" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_deltar', "AC_ID_deltar",
        'PR_ID_in', "PR_ID_in",
        'AC_deltar_PR_in_RAT_fick_ChangedAt', "AC_deltar_PR_in_RAT_fick_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick"
GROUP BY
    "AC_ID_deltar",
    "PR_ID_in",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'no row in AC_Skådespelare for AC_ID_deltar',
    OBJECT_CONSTRUCT('AC_ID_deltar', c."AC_ID_deltar"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_deltar"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_deltar"
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'no row in PR_Föreställning for PR_ID_in',
    OBJECT_CONSTRUCT('PR_ID_in', c."PR_ID_in"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_in"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_in"
UNION ALL
SELECT
    'AC_deltar_PR_in_RAT_fick',
    'no row in RAT_Betyg_ID for RAT_ID_fick',
    OBJECT_CONSTRUCT('RAT_ID_fick', c."RAT_ID_fick"),
    COUNT(*)
FROM
    ties."AC_deltar_PR_in_RAT_fick" c
LEFT JOIN
    knots."RAT_Betyg_ID" p
ON
    p."RAT_ID" = c."RAT_ID_fick"
WHERE
    p."RAT_ID" IS NULL
GROUP BY
    c."RAT_ID_fick"
;
-- ST_at_PR_spelas integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_ST_at_PR_spelas" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'ST_at_PR_spelas',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'ST_ID_at', "ST_ID_at",
        'PR_ID_spelas', "PR_ID_spelas",
        'ST_at_PR_spelas_ChangedAt', "ST_at_PR_spelas_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas"
GROUP BY
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_spelas',
    'no row in ST_Scen for ST_ID_at',
    OBJECT_CONSTRUCT('ST_ID_at', c."ST_ID_at"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_at"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_at"
UNION ALL
SELECT
    'ST_at_PR_spelas',
    'no row in PR_Föreställning for PR_ID_spelas',
    OBJECT_CONSTRUCT('PR_ID_spelas', c."PR_ID_spelas"),
    COUNT(*)
FROM
    ties."ST_at_PR_spelas" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_spelas"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_spelas"
;
-- AC_förälder_AC_barn_PAT_har integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_AC_förälder_AC_barn_PAT_har" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'AC_ID_förälder', "AC_ID_förälder",
        'AC_ID_barn', "AC_ID_barn",
        'PAT_ID_har', "PAT_ID_har"
    ),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har"
GROUP BY
    "AC_ID_förälder",
    "AC_ID_barn",
    "PAT_ID_har"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'no row in AC_Skådespelare for AC_ID_förälder',
    OBJECT_CONSTRUCT('AC_ID_förälder', c."AC_ID_förälder"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_förälder"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_förälder"
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'no row in AC_Skådespelare for AC_ID_barn',
    OBJECT_CONSTRUCT('AC_ID_barn', c."AC_ID_barn"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har" c
LEFT JOIN
    anchors."AC_Skådespelare" p
ON
    p."AC_ID" = c."AC_ID_barn"
WHERE
    p."AC_ID" IS NULL
GROUP BY
    c."AC_ID_barn"
UNION ALL
SELECT
    'AC_förälder_AC_barn_PAT_har',
    'no row in PAT_Föräldratyp_ID for PAT_ID_har',
    OBJECT_CONSTRUCT('PAT_ID_har', c."PAT_ID_har"),
    COUNT(*)
FROM
    ties."AC_förälder_AC_barn_PAT_har" c
LEFT JOIN
    knots."PAT_Föräldratyp_ID" p
ON
    p."PAT_ID" = c."PAT_ID_har"
WHERE
    p."PAT_ID" IS NULL
GROUP BY
    c."PAT_ID_har"
;
-- PR_innehåll_ST_plats_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."ic_PR_innehåll_ST_plats_EV_of" (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'duplicate primary key',
    OBJECT_CONSTRUCT(
        'PR_ID_innehåll', "PR_ID_innehåll",
        'ST_ID_plats', "ST_ID_plats",
        'EV_ID_of', "EV_ID_of",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of"
GROUP BY
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'duplicate unique key (PR_innehåll)',
    OBJECT_CONSTRUCT(
        'PR_ID_innehåll', "PR_ID_innehåll",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of"
GROUP BY
    "PR_ID_innehåll",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'duplicate unique key (ST_plats)',
    OBJECT_CONSTRUCT(
        'ST_ID_plats', "ST_ID_plats",
        'PR_innehåll_ST_plats_EV_of_ChangedAt', "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of"
GROUP BY
    "ST_ID_plats",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'no row in PR_Föreställning for PR_ID_innehåll',
    OBJECT_CONSTRUCT('PR_ID_innehåll', c."PR_ID_innehåll"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of" c
LEFT JOIN
    anchors."PR_Föreställning" p
ON
    p."PR_ID" = c."PR_ID_innehåll"
WHERE
    p."PR_ID" IS NULL
GROUP BY
    c."PR_ID_innehåll"
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'no row in ST_Scen for ST_ID_plats',
    OBJECT_CONSTRUCT('ST_ID_plats', c."ST_ID_plats"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of" c
LEFT JOIN
    anchors."ST_Scen" p
ON
    p."ST_ID" = c."ST_ID_plats"
WHERE
    p."ST_ID" IS NULL
GROUP BY
    c."ST_ID_plats"
UNION ALL
SELECT
    'PR_innehåll_ST_plats_EV_of',
    'no row in EV_Händelse for EV_ID_of',
    OBJECT_CONSTRUCT('EV_ID_of', c."EV_ID_of"),
    COUNT(*)
FROM
    ties."PR_innehåll_ST_plats_EV_of" c
LEFT JOIN
    nexuses."EV_Händelse" p
ON
    p."EV_ID" = c."EV_ID_of"
WHERE
    p."EV_ID" IS NULL
GROUP BY
    c."EV_ID_of"
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW dw.IntegrityViolations (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
COPY GRANTS
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM knots."ic_PAT_Föräldratyp_ID"
UNION ALL SELECT * FROM knots."ic_PAT_Föräldratyp_EQ"
UNION ALL SELECT * FROM knots."ic_GEN_Kön"
UNION ALL SELECT * FROM knots."ic_PLV_Yrkesnivå_ID"
UNION ALL SELECT * FROM knots."ic_PLV_Yrkesnivå_EQ"
UNION ALL SELECT * FROM knots."ic_UTL_Utnyttjande"
UNION ALL SELECT * FROM knots."ic_ONG_Pågående_ID"
UNION ALL SELECT * FROM knots."ic_ONG_Pågående_EQ"
UNION ALL SELECT * FROM knots."ic_RAT_Betyg_ID"
UNION ALL SELECT * FROM knots."ic_RAT_Betyg_EQ"
UNION ALL SELECT * FROM knots."ic_ETY_Händelsetyp_ID"
UNION ALL SELECT * FROM knots."ic_ETY_Händelsetyp_EQ"
UNION ALL SELECT * FROM anchors."ic_PN_Person"
UNION ALL SELECT * FROM anchors."ic_ST_Scen"
UNION ALL SELECT * FROM anchors."ic_AC_Skådespelare"
UNION ALL SELECT * FROM anchors."ic_PR_Föreställning"
UNION ALL SELECT * FROM nexuses."ic_EV_Händelse"
UNION ALL SELECT * FROM attributes."ic_EV_DAT_Händelse_Datum"
UNION ALL SELECT * FROM attributes."ic_EV_AUD_Händelse_Publik"
UNION ALL SELECT * FROM attributes."ic_EV_REV_Händelse_Intäkt"
UNION ALL SELECT * FROM attributes."ic_EV_STA_Händelse_Status"
UNION ALL SELECT * FROM attributes."ic_EV_UTL_Händelse_Utnyttjande"
UNION ALL SELECT * FROM attributes."ic_EV_LVL_Händelse_Level"
UNION ALL SELECT * FROM attributes."ic_ST_NAM_Scen_Namn"
UNION ALL SELECT * FROM attributes."ic_ST_LOC_Scen_Plats"
UNION ALL SELECT * FROM attributes."ic_ST_AVG_Scen_Medel"
UNION ALL SELECT * FROM attributes."ic_ST_MIN_Scen_Minimum"
UNION ALL SELECT * FROM attributes."ic_AC_NAM_Skådespelare_Namn"
UNION ALL SELECT * FROM attributes."ic_AC_GEN_Skådespelare_Kön"
UNION ALL SELECT * FROM attributes."ic_AC_PLV_Skådespelare_Yrkesnivå"
UNION ALL SELECT * FROM attributes."ic_PR_NAM_Föreställning_Namn"
UNION ALL SELECT * FROM attributes."ic_PR_LEN_Föreställning_Längd"
UNION ALL SELECT * FROM ties."ic_AC_partner_AC_with_ONG_currently"
UNION ALL SELECT * FROM ties."ic_AC_subset_PN_of"
UNION ALL SELECT * FROM ties."ic_EV_in_AC_rollsattes"
UNION ALL SELECT * FROM ties."ic_AC_deltar_PR_in_RAT_fick"
UNION ALL SELECT * FROM ties."ic_ST_at_PR_spelas"
UNION ALL SELECT * FROM ties."ic_AC_förälder_AC_barn_PAT_har"
UNION ALL SELECT * FROM ties."ic_PR_innehåll_ST_plats_EV_of"
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots."PAT_Föräldratyp_ID" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots."GEN_Kön" IS 'Gender of an actor.';
COMMENT ON COLUMN knots."GEN_Kön"."GEN_Kön" IS 'Gender of an actor.';
COMMENT ON TABLE knots."PLV_Yrkesnivå_ID" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots."UTL_Utnyttjande" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots."UTL_Utnyttjande"."UTL_Utnyttjande" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots."ONG_Pågående_ID" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots."RAT_Betyg_ID" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes."EV_DAT_Händelse_Datum"."EV_DAT_Händelse_Datum" IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes."EV_AUD_Händelse_Publik"."EV_AUD_Händelse_Publik" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes."EV_REV_Händelse_Intäkt"."EV_REV_Händelse_Intäkt" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes."EV_STA_Händelse_Status"."EV_STA_Händelse_Status" IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes."EV_LVL_Händelse_Level"."EV_LVL_PLV_ID" IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes."ST_NAM_Scen_Namn"."ST_NAM_Scen_Namn" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes."ST_LOC_Scen_Plats"."ST_LOC_Scen_Plats" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes."ST_AVG_Scen_Medel"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes."ST_MIN_Scen_Minimum"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes."AC_NAM_Skådespelare_Namn"."AC_NAM_Skådespelare_Namn" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes."AC_GEN_Skådespelare_Kön"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN attributes."AC_PLV_Skådespelare_Yrkesnivå"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes."PR_NAM_Föreställning_Namn"."PR_NAM_Föreställning_Namn" IS 'Name or title of the program.';
COMMENT ON COLUMN attributes."PR_LEN_Föreställning_Längd"."PR_LEN_Föreställning_Längd" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors."ST_Scen" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors."AC_Skådespelare" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses."EV_Händelse" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses."EV_Händelse"."ST_ID_hölls" IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses."EV_Händelse"."PR_ID_spelades" IS 'The program that was played at the event.';
COMMENT ON TABLE ties."AC_partner_AC_with_ONG_currently" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties."AC_subset_PN_of"."AC_ID_subset" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties."AC_subset_PN_of"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE ties."EV_in_AC_rollsattes" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties."EV_in_AC_rollsattes"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties."EV_in_AC_rollsattes"."AC_ID_rollsattes" IS 'An actor cast in the event.';
COMMENT ON TABLE ties."AC_deltar_PR_in_RAT_fick" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties."AC_deltar_PR_in_RAT_fick"."AC_ID_deltar" IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties."AC_deltar_PR_in_RAT_fick"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties."AC_deltar_PR_in_RAT_fick"."RAT_ID_fick" IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties."ST_at_PR_spelas" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties."ST_at_PR_spelas"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties."ST_at_PR_spelas"."PR_ID_spelas" IS 'The program playing at the stage.';
COMMENT ON TABLE ties."AC_förälder_AC_barn_PAT_har" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties."AC_förälder_AC_barn_PAT_har"."AC_ID_förälder" IS 'The actor who is the parent.';
COMMENT ON COLUMN ties."AC_förälder_AC_barn_PAT_har"."AC_ID_barn" IS 'The actor who is the child.';
COMMENT ON COLUMN ties."AC_förälder_AC_barn_PAT_har"."PAT_ID_har" IS 'The type of parental relationship.';
COMMENT ON TABLE ties."PR_innehåll_ST_plats_EV_of" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties."PR_innehåll_ST_plats_EV_of"."PR_ID_innehåll" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties."PR_innehåll_ST_plats_EV_of"."ST_ID_plats" IS 'The stage where the event was located.';
COMMENT ON COLUMN ties."PR_innehåll_ST_plats_EV_of"."EV_ID_of" IS 'The event.';
