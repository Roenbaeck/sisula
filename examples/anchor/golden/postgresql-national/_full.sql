-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS knots;
CREATE SCHEMA IF NOT EXISTS anchors;
CREATE SCHEMA IF NOT EXISTS nexuses;
CREATE SCHEMA IF NOT EXISTS attributes;
CREATE SCHEMA IF NOT EXISTS ties;
-- EQUIVALENTS METADATA -----------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available equivalents. Since at least one equivalent
-- must be available the table is set up with a default equivalent with identity 0.
--
-- Equivalent table ---------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw."_EQ" (
    "EQ" smallint not null,
    constraint "pk_EQ" primary key (
        "EQ" 
    )
);
INSERT INTO dw."_EQ" (
    "EQ"
)
VALUES (
    0
)
ON CONFLICT DO NOTHING;
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
    "PAT_ID" smallint not null,
    "Metadata_PAT" integer not null, 
    constraint "pkPAT_Föräldratyp_ID" primary key (
        "PAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp_EQ" (
    "PAT_ID" smallint not null,
    "PAT_EQ" smallint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" integer not null, 
    constraint "fkPAT_Föräldratyp_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID"),
    constraint "pkPAT_Föräldratyp_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ),
    constraint "uqPAT_Föräldratyp_EQ" unique (
        "PAT_EQ",
        "PAT_Föräldratyp"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Kön" (
    "GEN_ID" smallint not null,
    "GEN_Kön" varchar(42) not null,
    "GEN_Checksum" bytea generated always as (decode(md5("GEN_Kön"::text), 'hex')) stored,
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Kön" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Kön" unique (
        "GEN_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_ID" (
    "PLV_ID" smallint not null,
    "Metadata_PLV" integer not null, 
    constraint "pkPLV_Yrkesnivå_ID" primary key (
        "PLV_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå_EQ" (
    "PLV_ID" smallint not null,
    "PLV_EQ" smallint not null,
    "PLV_Yrkesnivå" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_Yrkesnivå"::text), 'hex')) stored,
    "Metadata_PLV" integer not null, 
    constraint "fkPLV_Yrkesnivå_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID"),
    constraint "pkPLV_Yrkesnivå_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ),
    constraint "uqPLV_Yrkesnivå_EQ" unique (
        "PLV_EQ",
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utnyttjande" (
    "UTL_ID" smallint not null,
    "UTL_Utnyttjande" smallint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utnyttjande" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utnyttjande" unique (
        "UTL_Utnyttjande"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Pågående_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_ID" (
    "ONG_ID" smallint not null,
    "Metadata_ONG" integer not null, 
    constraint "pkONG_Pågående_ID" primary key (
        "ONG_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Pågående_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående_EQ" (
    "ONG_ID" smallint not null,
    "ONG_EQ" smallint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" integer not null, 
    constraint "fkONG_Pågående_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Pågående_ID"("ONG_ID"),
    constraint "pkONG_Pågående_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ),
    constraint "uqONG_Pågående_EQ" unique (
        "ONG_EQ",
        "ONG_Pågående"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Betyg_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_ID" (
    "RAT_ID" smallint default nextval('knots."RAT_Betyg_ID_SEQ"') not null, 
    "Metadata_RAT" integer not null, 
    constraint "pkRAT_Betyg_ID" primary key (
        "RAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Betyg_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg_EQ" (
    "RAT_ID" smallint not null,
    "RAT_EQ" smallint not null,
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Betyg"::text), 'hex')) stored,
    "Metadata_RAT" integer not null, 
    constraint "fkRAT_Betyg_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Betyg_ID"("RAT_ID"),
    constraint "pkRAT_Betyg_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ),
    constraint "uqRAT_Betyg_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_ID" (
    "ETY_ID" smallint not null,
    "Metadata_ETY" integer not null, 
    constraint "pkETY_Händelsetyp_ID" primary key (
        "ETY_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp_EQ" (
    "ETY_ID" smallint not null,
    "ETY_EQ" smallint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_Händelsetyp"::text), 'hex')) stored,
    "Metadata_ETY" integer not null, 
    constraint "fkETY_Händelsetyp_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_Händelsetyp_ID"("ETY_ID"),
    constraint "pkETY_Händelsetyp_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ),
    constraint "uqETY_Händelsetyp_EQ" unique (
        "ETY_EQ",
        "ETY_Checksum" 
    )
);
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
    "PN_ID" bigint default nextval('anchors."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default nextval('anchors."AC_Skådespelare_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    )
);
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
    "ST_ID_hölls" integer not null, 
    "PR_ID_spelades" bigint not null, 
    "ETY_ID_of" smallint not null,
    constraint "EV_Händelse_fkST_hölls" foreign key (
        "ST_ID_hölls"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "EV_Händelse_fkPR_spelades" foreign key (
        "PR_ID_spelades"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "EV_Händelse_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_Händelsetyp_ID"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Händelse" primary key (
        "EV_ID"
    )
);
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
    "EV_DAT_Händelse_Datum" timestamp not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Händelse_Datum" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_DAT_Händelse_Datum" primary key (
        "EV_DAT_EV_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik" (
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_EQ" smallint not null,
    "EV_AUD_Händelse_Publik" integer not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Händelse_Publik" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_AUD_Händelse_Publik" primary key (
        "EV_AUD_EQ",
        "EV_AUD_EV_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt" (
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_EQ" smallint not null,
    "EV_REV_Händelse_Intäkt" decimal(19,4) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Händelse_Intäkt" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_REV_Händelse_Intäkt" primary key (
        "EV_REV_EQ",
        "EV_REV_EV_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status" (
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_EQ" smallint not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    "Metadata_EV_STA" integer not null,
    constraint "fkEV_STA_Händelse_Status" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_STA_Händelse_Status" primary key (
        "EV_STA_EQ",
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande" (
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" smallint not null,
    "Metadata_EV_UTL" integer not null,
    constraint "fk_A_EV_UTL_Händelse_Utnyttjande" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_UTL_Händelse_Utnyttjande" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkEV_UTL_Händelse_Utnyttjande" primary key (
        "EV_UTL_EV_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level" (
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" smallint not null,
    "EV_LVL_ChangedAt" date not null,
    "Metadata_EV_LVL" integer not null,
    constraint "fk_A_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID"),
    constraint "pkEV_LVL_Händelse_Level" primary key (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn" (
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_EQ" smallint not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Scen_Namn" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_NAM_Scen_Namn" primary key (
        "ST_NAM_EQ",
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats" (
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_EQ" smallint not null,
    "ST_LOC_Scen_Plats" text not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Scen_Plats"::text), 'hex')) stored,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Scen_Plats" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_LOC_Scen_Plats" primary key (
        "ST_LOC_EQ",
        "ST_LOC_ST_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel" (
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fk_A_ST_AVG_Scen_Medel" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "fk_K_ST_AVG_Scen_Medel" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkST_AVG_Scen_Medel" primary key (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum" (
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fk_A_ST_MIN_Scen_Minimum" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "fk_K_ST_MIN_Scen_Minimum" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkST_MIN_Scen_Minimum" primary key (
        "ST_MIN_ST_ID"
    )
);
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn" (
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Skådespelare_Namn" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Skådespelare_Namn" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "pkAC_NAM_Skådespelare_Namn" primary key (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön" (
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" smallint not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fk_A_AC_GEN_Skådespelare_Kön" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_GEN_Skådespelare_Kön" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Kön"("GEN_ID"),
    constraint "pkAC_GEN_Skådespelare_Kön" primary key (
        "AC_GEN_AC_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå" (
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID"),
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn" (
    "PR_NAM_PR_ID" bigint not null,
    "PR_NAM_Föreställning_Namn" varchar(42) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Föreställning_Namn" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_NAM_Föreställning_Namn" primary key (
        "PR_NAM_PR_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd" (
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_EQ" smallint not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Föreställning_Längd" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_LEN_Föreställning_Längd" primary key (
        "PR_LEN_EQ",
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt"
    )
);
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
    "ONG_ID_currently" smallint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    "Metadata_AC_partner_AC_with_ONG_currently" integer not null,
    constraint "AC_partner_AC_with_ONG_currently_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Pågående_ID"("ONG_ID"),
    constraint "AC_partner_AC_with_ONG_currently_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "AC_partner_AC_with_ONG_currently_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "pkAC_partner_AC_with_ONG_currently" primary key (
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    )
);
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of" (
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    "Metadata_AC_subset_PN_of" integer not null,
    constraint "AC_subset_PN_of_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_subset_PN_of_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID"), 
    constraint "AC_subset_PN_of_uqAC_subset" unique (
        "AC_ID_subset"
    ),
    constraint "AC_subset_PN_of_uqPN_of" unique (
        "PN_ID_of"
    ),
    constraint "pkAC_subset_PN_of" primary key (
        "AC_ID_subset",
        "PN_ID_of"
    )
);
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes" (
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_rollsattes" smallint not null, 
    "Metadata_EV_in_AC_rollsattes" integer not null,
    constraint "EV_in_AC_rollsattes_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Händelse"("EV_ID"), 
    constraint "EV_in_AC_rollsattes_fkAC_rollsattes" foreign key (
        "AC_ID_rollsattes"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "pkEV_in_AC_rollsattes" primary key (
        "EV_ID_in",
        "AC_ID_rollsattes"
    )
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick" (
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" bigint not null, 
    "RAT_ID_fick" smallint not null,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp not null,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer not null,
    constraint "AC_deltar_PR_in_RAT_fick_fkAC_deltar" foreign key (
        "AC_ID_deltar"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_deltar_PR_in_RAT_fick_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "AC_deltar_PR_in_RAT_fick_fkRAT_fick" foreign key (
        "RAT_ID_fick"
    ) references knots."RAT_Betyg_ID"("RAT_ID"),
    constraint "pkAC_deltar_PR_in_RAT_fick" primary key (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas" (
    "ST_ID_at" integer not null, 
    "PR_ID_spelas" bigint not null, 
    "ST_at_PR_spelas_ChangedAt" timestamp not null,
    "Metadata_ST_at_PR_spelas" integer not null,
    constraint "ST_at_PR_spelas_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "ST_at_PR_spelas_fkPR_spelas" foreign key (
        "PR_ID_spelas"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "pkST_at_PR_spelas" primary key (
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt"
    )
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har" (
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" smallint not null,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer not null,
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_förälder_AC_barn_PAT_har_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp_ID"("PAT_ID"),
    constraint "pkAC_förälder_AC_barn_PAT_har" primary key (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of" (
    "PR_ID_innehåll" bigint not null, 
    "ST_ID_plats" integer not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp not null,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer not null,
    constraint "PR_innehåll_ST_plats_EV_of_fkPR_innehåll" foreign key (
        "PR_ID_innehåll"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "PR_innehåll_ST_plats_EV_of_fkST_plats" foreign key (
        "ST_ID_plats"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "PR_innehåll_ST_plats_EV_of_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Händelse"("EV_ID"), 
    constraint "PR_innehåll_ST_plats_EV_of_uqPR_innehåll" unique (
        "PR_ID_innehåll",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    constraint "PR_innehåll_ST_plats_EV_of_uqST_plats" unique (
        "ST_ID_plats",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    constraint "pkPR_innehåll_ST_plats_EV_of" primary key (
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    )
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
    equivalent smallint
)
RETURNS TABLE (
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_EQ" smallint,
    "Metadata_EV_AUD" integer,
    "EV_AUD_Händelse_Publik" integer
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
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_REV_Händelse_Intäkt" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_EQ" smallint,
    "Metadata_EV_REV" integer,
    "EV_REV_Händelse_Intäkt" decimal(19,4)
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
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_STA_Händelse_Status" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" smallint,
    "EV_STA_ChangedAt" timestamp,
    "Metadata_EV_STA" integer,
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
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_NAM_Scen_Namn" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_NAM_ST_ID" integer,
    "ST_NAM_EQ" smallint,
    "ST_NAM_ChangedAt" timestamp,
    "Metadata_ST_NAM" integer,
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
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_LOC_Scen_Plats" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_LOC_ST_ID" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "Metadata_ST_LOC" integer,
    "ST_LOC_Scen_Plats" text
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
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."ePR_LEN_Föreställning_Längd" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_EQ" smallint,
    "PR_LEN_ChangedAt" date,
    "Metadata_PR_LEN" integer,
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
$$ LANGUAGE sql STABLE;
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
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
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
        attributes."eEV_STA_Händelse_Status"(equivalent) 
    WHERE
        "EV_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Händelse_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level" (
    changingTimepoint date
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
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
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Scen_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" timestamp
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
        attributes."eST_NAM_Scen_Namn"(equivalent) 
    WHERE
        "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Scen_Medel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
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
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Skådespelare_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_NAM_ChangedAt" timestamp
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
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Skådespelare_Yrkesnivå rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
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
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Föreställning_Längd rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd" (
    equivalent smallint,
    changingTimepoint date
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_EQ" smallint,
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
        attributes."ePR_LEN_Föreställning_Längd"(equivalent) 
    WHERE
        "PR_LEN_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
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
    "ST_NAM_Scen_Namn",
    "ST_LOC_ST_ID",
    "Metadata_ST_LOC",
    "ST_LOC_EQ",
    "ST_LOC_Checksum",
    "ST_LOC_Scen_Plats",
    "ST_AVG_ST_ID",
    "Metadata_ST_AVG",
    "ST_AVG_ChangedAt",
    "ST_AVG_UTL_Utnyttjande",
    "ST_AVG_Metadata_UTL",
    "ST_AVG_UTL_ID",
    "ST_MIN_ST_ID",
    "Metadata_ST_MIN",
    "ST_MIN_UTL_Utnyttjande",
    "ST_MIN_Metadata_UTL",
    "ST_MIN_UTL_ID"
)
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
    attributes."eST_NAM_Scen_Namn"(0::smallint) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            attributes."eST_NAM_Scen_Namn"(0::smallint) sub 
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    attributes."eST_LOC_Scen_Plats"(0::smallint) "LOC"
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
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
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
    attributes."rST_NAM_Scen_Namn"(0::smallint, changingTimepoint::timestamp) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            attributes."rST_NAM_Scen_Namn"(0::smallint, changingTimepoint::timestamp) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    attributes."eST_LOC_Scen_Plats"(0::smallint) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."rST_AVG_Scen_Medel"(changingTimepoint::timestamp) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."rST_AVG_Scen_Medel"(changingTimepoint::timestamp) sub
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
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Scen"
AS
SELECT
    *
FROM
    anchors."pST_Scen"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Scen" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."ST_NAM_ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."eST_NAM_Scen_Namn"(0::smallint) h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."ST_AVG_ST_ID" AS "ST_ID",
        h."ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Scen_Medel" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Scen" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."ST_NAM_ChangedAt") OVER (
            PARTITION BY h."ST_NAM_ST_ID"
            ORDER BY h."ST_NAM_ChangedAt"
        ) AS "until"
    FROM
        attributes."eST_NAM_Scen_Namn"(0::smallint) h
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    attributes."eST_LOC_Scen_Plats"(0::smallint) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."ST_AVG_ChangedAt") OVER (
            PARTITION BY h."ST_AVG_ST_ID"
            ORDER BY h."ST_AVG_ChangedAt"
        ) AS "until"
    FROM
        attributes."ST_AVG_Scen_Medel" h
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
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
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epST_Scen" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
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
    attributes."rST_NAM_Scen_Namn"(equivalent, changingTimepoint::timestamp) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            attributes."rST_NAM_Scen_Namn"(equivalent, changingTimepoint::timestamp) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    attributes."eST_LOC_Scen_Plats"(equivalent) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."rST_AVG_Scen_Medel"(changingTimepoint::timestamp) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."rST_AVG_Scen_Medel"(changingTimepoint::timestamp) sub
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
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elST_Scen" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epST_Scen"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enST_Scen" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epST_Scen"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edST_Scen" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."ST_NAM_ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."eST_NAM_Scen_Namn"(equivalent) h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."ST_AVG_ST_ID" AS "ST_ID",
        h."ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Scen_Medel" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Scen" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."ST_NAM_ChangedAt") OVER (
            PARTITION BY h."ST_NAM_ST_ID"
            ORDER BY h."ST_NAM_ChangedAt"
        ) AS "until"
    FROM
        attributes."eST_NAM_Scen_Namn"(equivalent) h
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    attributes."eST_LOC_Scen_Plats"(equivalent) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."ST_AVG_ChangedAt") OVER (
            PARTITION BY h."ST_AVG_ST_ID"
            ORDER BY h."ST_AVG_ChangedAt"
        ) AS "until"
    FROM
        attributes."ST_AVG_Scen_Medel" h
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
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
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Skådespelare" (
    "AC_ID",
    "Metadata_AC",
    "AC_NAM_AC_ID",
    "Metadata_AC_NAM",
    "AC_NAM_ChangedAt",
    "AC_NAM_Skådespelare_Namn",
    "AC_GEN_AC_ID",
    "Metadata_AC_GEN",
    "AC_GEN_GEN_Checksum",
    "AC_GEN_GEN_Kön",
    "AC_GEN_Metadata_GEN",
    "AC_GEN_GEN_ID",
    "AC_PLV_AC_ID",
    "Metadata_AC_PLV",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_Checksum",
    "AC_PLV_PLV_EQ",
    "AC_PLV_PLV_Yrkesnivå",
    "AC_PLV_Metadata_PLV",
    "AC_PLV_PLV_ID"
)
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
    knots."ePLV_Yrkesnivå"(0::smallint) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Skådespelare" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
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
    attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::timestamp) sub
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
    attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::timestamp) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(0::smallint) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Skådespelare"
AS
SELECT
    *
FROM
    anchors."pAC_Skådespelare"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Skådespelare" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."AC_NAM_AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Skådespelare_Namn" h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."AC_PLV_AC_ID" AS "AC_ID",
        h."AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Skådespelare" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."AC_NAM_ChangedAt") OVER (
            PARTITION BY h."AC_NAM_AC_ID"
            ORDER BY h."AC_NAM_ChangedAt"
        ) AS "until"
    FROM
        attributes."AC_NAM_Skådespelare_Namn" h
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."AC_PLV_ChangedAt") OVER (
            PARTITION BY h."AC_PLV_AC_ID"
            ORDER BY h."AC_PLV_ChangedAt"
        ) AS "until"
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" h
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."ePLV_Yrkesnivå"(0::smallint) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epAC_Skådespelare" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
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
    attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint::timestamp) sub
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
    attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::timestamp) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(equivalent) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elAC_Skådespelare" (
    equivalent smallint
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epAC_Skådespelare"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enAC_Skådespelare" (
    equivalent smallint
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epAC_Skådespelare"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edAC_Skådespelare" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."AC_NAM_AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Skådespelare_Namn" h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."AC_PLV_AC_ID" AS "AC_ID",
        h."AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Skådespelare" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."AC_NAM_ChangedAt") OVER (
            PARTITION BY h."AC_NAM_AC_ID"
            ORDER BY h."AC_NAM_ChangedAt"
        ) AS "until"
    FROM
        attributes."AC_NAM_Skådespelare_Namn" h
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."AC_PLV_ChangedAt") OVER (
            PARTITION BY h."AC_PLV_AC_ID"
            ORDER BY h."AC_PLV_ChangedAt"
        ) AS "until"
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" h
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."ePLV_Yrkesnivå"(equivalent) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Föreställning" (
    "PR_ID",
    "Metadata_PR",
    "PR_NAM_PR_ID",
    "Metadata_PR_NAM",
    "PR_NAM_Föreställning_Namn",
    "PR_LEN_PR_ID",
    "Metadata_PR_LEN",
    "PR_LEN_ChangedAt",
    "PR_LEN_EQ",
    "PR_LEN_Föreställning_Längd"
)
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
    attributes."ePR_LEN_Föreställning_Längd"(0::smallint) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            attributes."ePR_LEN_Föreställning_Längd"(0::smallint) sub 
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Föreställning" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
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
    attributes."rPR_LEN_Föreställning_Längd"(0::smallint, changingTimepoint::date) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            attributes."rPR_LEN_Föreställning_Längd"(0::smallint, changingTimepoint::date) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Föreställning"
AS
SELECT
    *
FROM
    anchors."pPR_Föreställning"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Föreställning" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."PR_LEN_PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."ePR_LEN_Föreställning_Längd"(0::smallint) h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Föreställning" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."PR_LEN_ChangedAt") OVER (
            PARTITION BY h."PR_LEN_PR_ID"
            ORDER BY h."PR_LEN_ChangedAt"
        ) AS "until"
    FROM
        attributes."ePR_LEN_Föreställning_Längd"(0::smallint) h
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LEN"."until" IS NULL
OR
    "LEN"."until" > timepoints.inspectedTimepoint::date
)
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epPR_Föreställning" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
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
    attributes."rPR_LEN_Föreställning_Längd"(equivalent, changingTimepoint::date) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            attributes."rPR_LEN_Föreställning_Längd"(equivalent, changingTimepoint::date) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elPR_Föreställning" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    *
FROM
    anchors."epPR_Föreställning"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enPR_Föreställning" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    *
FROM
    anchors."epPR_Föreställning"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edPR_Föreställning" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."PR_LEN_PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."ePR_LEN_Föreställning_Längd"(equivalent) h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Föreställning" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."PR_LEN_ChangedAt") OVER (
            PARTITION BY h."PR_LEN_PR_ID"
            ORDER BY h."PR_LEN_ChangedAt"
        ) AS "until"
    FROM
        attributes."ePR_LEN_Föreställning_Längd"(equivalent) h
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LEN"."until" IS NULL
OR
    "LEN"."until" > timepoints.inspectedTimepoint::date
)
$$ LANGUAGE sql STABLE;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- nexus perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" (
    "EV_ID",
    "Metadata_EV",
    "ST_ID_hölls",
    "PR_ID_spelades",
    "of_ETY_Checksum",
    "of_ETY_Händelsetyp",
    "of_ETY_EQ",
    "of_Metadata_ETY",
    "ETY_ID_of",
    "EV_DAT_EV_ID",
    "Metadata_EV_DAT",
    "EV_DAT_Händelse_Datum",
    "EV_AUD_EV_ID",
    "Metadata_EV_AUD",
    "EV_AUD_EQ",
    "EV_AUD_Händelse_Publik",
    "EV_REV_EV_ID",
    "Metadata_EV_REV",
    "EV_REV_EQ",
    "EV_REV_Händelse_Intäkt",
    "EV_STA_EV_ID",
    "Metadata_EV_STA",
    "EV_STA_ChangedAt",
    "EV_STA_EQ",
    "EV_STA_Händelse_Status",
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
    "EV_LVL_PLV_Yrkesnivå",
    "EV_LVL_Metadata_PLV",
    "EV_LVL_PLV_ID"
)
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
    knots."eETY_Händelsetyp"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_STA_Händelse_Status"(0::smallint) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."eEV_STA_Händelse_Status"(0::smallint) sub 
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
    knots."ePLV_Yrkesnivå"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Händelse" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
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
    knots."eETY_Händelsetyp"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."rEV_STA_Händelse_Status"(0::smallint, changingTimepoint::timestamp) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."rEV_STA_Händelse_Status"(0::smallint, changingTimepoint::timestamp) sub
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
    attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" AS
SELECT
    *
FROM
    nexuses."pEV_Händelse"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Händelse" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."EV_STA_EV_ID" AS "EV_ID",
        h."EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."eEV_STA_Händelse_Status"(0::smallint) h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h."EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."EV_LVL_EV_ID" AS "EV_ID",
        h."EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Händelse" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."eETY_Händelsetyp"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_STA_ChangedAt") OVER (
            PARTITION BY h."EV_STA_EV_ID"
            ORDER BY h."EV_STA_ChangedAt"
        ) AS "until"
    FROM
        attributes."eEV_STA_Händelse_Status"(0::smallint) h
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_LVL_ChangedAt") OVER (
            PARTITION BY h."EV_LVL_EV_ID"
            ORDER BY h."EV_LVL_ChangedAt"
        ) AS "until"
    FROM
        attributes."EV_LVL_Händelse_Level" h
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::date
)
LEFT JOIN
    knots."ePLV_Yrkesnivå"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."elEV_Händelse" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
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
    knots."eETY_Händelsetyp"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_STA_Händelse_Status"(equivalent) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."eEV_STA_Händelse_Status"(equivalent) sub 
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
    knots."ePLV_Yrkesnivå"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."epEV_Händelse" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
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
    knots."eETY_Händelsetyp"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."rEV_STA_Händelse_Status"(equivalent, changingTimepoint::timestamp) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."rEV_STA_Händelse_Status"(equivalent, changingTimepoint::timestamp) sub
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
    attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."rEV_LVL_Händelse_Level"(changingTimepoint::date) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_Yrkesnivå"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."enEV_Händelse" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    nexuses."epEV_Händelse"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."edEV_Händelse" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."EV_STA_EV_ID" AS "EV_ID",
        h."EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."eEV_STA_Händelse_Status"(equivalent) h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h."EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."EV_LVL_EV_ID" AS "EV_ID",
        h."EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Händelse" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."eETY_Händelsetyp"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Händelse_Datum" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Händelse_Publik"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Händelse_Intäkt"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_STA_ChangedAt") OVER (
            PARTITION BY h."EV_STA_EV_ID"
            ORDER BY h."EV_STA_ChangedAt"
        ) AS "until"
    FROM
        attributes."eEV_STA_Händelse_Status"(equivalent) h
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    attributes."EV_UTL_Händelse_Utnyttjande" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_LVL_ChangedAt") OVER (
            PARTITION BY h."EV_LVL_EV_ID"
            ORDER BY h."EV_LVL_ChangedAt"
        ) AS "until"
    FROM
        attributes."EV_LVL_Händelse_Level" h
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::date
)
LEFT JOIN
    knots."ePLV_Yrkesnivå"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" (
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_ID_partner",
    "AC_ID_with",
    "currently_ONG_Pågående",
    "currently_ONG_EQ",
    "currently_Metadata_ONG",
    "ONG_ID_currently"
)
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_partner") AS "latestAC_ID_partner",
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_with") AS "latestAC_ID_with"
        FROM
            ties."AC_partner_AC_with_ONG_currently" t
    ) tie
LEFT JOIN
    knots."eONG_Pågående"(0::smallint) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_partner") AS "latestAC_ID_partner",
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_with") AS "latestAC_ID_with"
        FROM
            ties."AC_partner_AC_with_ONG_currently" t
        WHERE
            t."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eONG_Pågående"(0::smallint) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    ties."pAC_partner_AC_with_ONG_currently"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    knots."eONG_Pågående"(0::smallint) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_partner_AC_with_ONG_currently" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_partner") AS "latestAC_ID_partner",
            max(t."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (PARTITION BY t."AC_ID_with") AS "latestAC_ID_with"
        FROM
            ties."AC_partner_AC_with_ONG_currently" t
        WHERE
            t."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eONG_Pågående"(equivalent) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_partner_AC_with_ONG_currently" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_partner_AC_with_ONG_currently"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_partner_AC_with_ONG_currently" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_partner_AC_with_ONG_currently"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_partner_AC_with_ONG_currently" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_ONG_EQ" smallint,
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
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
    knots."eONG_Pågående"(equivalent) "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" (
    "Metadata_AC_subset_PN_of",
    "AC_ID_subset",
    "PN_ID_of"
)
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
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
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
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    *
FROM
    ties."pAC_subset_PN_of"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_subset_PN_of" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
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
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_subset_PN_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_subset_PN_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_subset_PN_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_subset_PN_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" (
    "Metadata_EV_in_AC_rollsattes",
    "EV_ID_in",
    "AC_ID_rollsattes"
)
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
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
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
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    *
FROM
    ties."pEV_in_AC_rollsattes"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epEV_in_AC_rollsattes" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
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
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elEV_in_AC_rollsattes" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epEV_in_AC_rollsattes"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enEV_in_AC_rollsattes" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epEV_in_AC_rollsattes"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" (
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt",
    "AC_ID_deltar",
    "PR_ID_in",
    "fick_RAT_Checksum",
    "fick_RAT_Betyg",
    "fick_RAT_EQ",
    "fick_Metadata_RAT",
    "RAT_ID_fick"
)
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_deltar_PR_in_RAT_fick_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_deltar",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_deltar_PR_in_RAT_fick" t
    ) tie
LEFT JOIN
    knots."eRAT_Betyg"(0::smallint) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_deltar_PR_in_RAT_fick_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_deltar",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_deltar_PR_in_RAT_fick" t
        WHERE
            t."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eRAT_Betyg"(0::smallint) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" AS
SELECT
    *
FROM
    ties."pAC_deltar_PR_in_RAT_fick"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    knots."eRAT_Betyg"(0::smallint) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_deltar_PR_in_RAT_fick" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_deltar_PR_in_RAT_fick_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_deltar",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_deltar_PR_in_RAT_fick" t
        WHERE
            t."AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eRAT_Betyg"(equivalent) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_deltar_PR_in_RAT_fick" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_deltar_PR_in_RAT_fick"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_deltar_PR_in_RAT_fick" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_deltar_PR_in_RAT_fick"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_deltar_PR_in_RAT_fick" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Checksum" bytea,
    "fick_RAT_Betyg" varchar(42),
    "fick_RAT_EQ" smallint,
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
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
    knots."eRAT_Betyg"(equivalent) "RAT_fick"
ON
    "RAT_fick"."RAT_ID" = tie."RAT_ID_fick"
WHERE
    tie."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" (
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ChangedAt",
    "ST_ID_at",
    "PR_ID_spelas"
)
AS
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_spelas_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_spelas"
            ) AS "latest"
        FROM
            ties."ST_at_PR_spelas" t
    ) tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_spelas_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_spelas"
            ) AS "latest"
        FROM
            ties."ST_at_PR_spelas" t
        WHERE
            t."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    *
FROM
    ties."pST_at_PR_spelas"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
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
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epST_at_PR_spelas" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_spelas",
    tie."ST_at_PR_spelas_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_spelas"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_spelas_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_spelas"
            ) AS "latest"
        FROM
            ties."ST_at_PR_spelas" t
        WHERE
            t."ST_at_PR_spelas_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_spelas_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elST_at_PR_spelas" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epST_at_PR_spelas"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enST_at_PR_spelas" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epST_at_PR_spelas"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edST_at_PR_spelas" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
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
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" (
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_ID_förälder",
    "AC_ID_barn",
    "har_PAT_Föräldratyp",
    "har_PAT_EQ",
    "har_Metadata_PAT",
    "PAT_ID_har"
)
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
    knots."ePAT_Föräldratyp"(0::smallint) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
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
    knots."ePAT_Föräldratyp"(0::smallint) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    *
FROM
    ties."pAC_förälder_AC_barn_PAT_har"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_förälder_AC_barn_PAT_har" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
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
    knots."ePAT_Föräldratyp"(equivalent) "PAT_har"
ON
    "PAT_har"."PAT_ID" = tie."PAT_ID_har"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_förälder_AC_barn_PAT_har" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_förälder_AC_barn_PAT_har"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_förälder_AC_barn_PAT_har" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_PAT_EQ" smallint,
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_förälder_AC_barn_PAT_har"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" (
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt",
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of"
)
AS
SELECT
    tie."Metadata_PR_innehåll_ST_plats_EV_of",
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt",
    tie."PR_ID_innehåll",
    tie."ST_ID_plats",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_innehåll") AS "latestPR_ID_innehåll",
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_plats") AS "latestST_ID_plats"
        FROM
            ties."PR_innehåll_ST_plats_EV_of" t
    ) tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestPR_ID_innehåll"
AND
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestST_ID_plats"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_innehåll") AS "latestPR_ID_innehåll",
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_plats") AS "latestST_ID_plats"
        FROM
            ties."PR_innehåll_ST_plats_EV_of" t
        WHERE
            t."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestPR_ID_innehåll"
AND
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestST_ID_plats"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    *
FROM
    ties."pPR_innehåll_ST_plats_EV_of"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epPR_innehåll_ST_plats_EV_of" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_innehåll") AS "latestPR_ID_innehåll",
            max(t."PR_innehåll_ST_plats_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_plats") AS "latestST_ID_plats"
        FROM
            ties."PR_innehåll_ST_plats_EV_of" t
        WHERE
            t."PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestPR_ID_innehåll"
AND
    tie."PR_innehåll_ST_plats_EV_of_ChangedAt" = tie."latestST_ID_plats"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elPR_innehåll_ST_plats_EV_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    ties."epPR_innehåll_ST_plats_EV_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enPR_innehåll_ST_plats_EV_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    ties."epPR_innehåll_ST_plats_EV_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edPR_innehåll_ST_plats_EV_of" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
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
$$ LANGUAGE sql STABLE;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
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
