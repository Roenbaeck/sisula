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
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp" (
    "PAT_ID" tinyint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" integer not null,
    constraint "pkPAT_Föräldratyp" primary key (
        "PAT_ID"
    ),
    constraint "uqPAT_Föräldratyp" unique (
        "PAT_Föräldratyp"
    )
) ORDER BY "PAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Kön" (
    "GEN_ID" tinyint not null,
    "GEN_Kön" varchar(42) not null,
    "GEN_Checksum" int default hash("GEN_Kön"),
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Kön" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Kön" unique (
        "GEN_Checksum" 
    )
) ORDER BY "GEN_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå" (
    "PLV_ID" tinyint not null,
    "PLV_Yrkesnivå" long varchar(32000000) not null,
    "PLV_Checksum" int default hash("PLV_Yrkesnivå"),
    "Metadata_PLV" integer not null,
    constraint "pkPLV_Yrkesnivå" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_Yrkesnivå" unique (
        "PLV_Checksum" 
    )
) ORDER BY "PLV_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utnyttjande" (
    "UTL_ID" tinyint not null,
    "UTL_Utnyttjande" tinyint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utnyttjande" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utnyttjande" unique (
        "UTL_Utnyttjande"
    )
) ORDER BY "UTL_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående" (
    "ONG_ID" tinyint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" integer not null,
    constraint "pkONG_Pågående" primary key (
        "ONG_ID"
    ),
    constraint "uqONG_Pågående" unique (
        "ONG_Pågående"
    )
) ORDER BY "ONG_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg" (
    "RAT_ID" tinyint default nextval('knots."RAT_Betyg_ID_SEQ"') not null, 
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" int default hash("RAT_Betyg"),
    "Metadata_RAT" integer not null,
    constraint "pkRAT_Betyg" primary key (
        "RAT_ID"
    ),
    constraint "uqRAT_Betyg" unique (
        "RAT_Checksum" 
    )
) ORDER BY "RAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp" (
    "ETY_ID" tinyint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" int default hash("ETY_Händelsetyp"),
    "Metadata_ETY" integer not null,
    constraint "pkETY_Händelsetyp" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_Händelsetyp" unique (
        "ETY_Checksum" 
    )
) ORDER BY "ETY_ID" UNSEGMENTED ALL NODES;
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default nextval('anchors."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
) ORDER BY "PN_ID" SEGMENTED BY MODULARHASH("PN_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default nextval('anchors."AC_Skådespelare_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    )
) ORDER BY "AC_ID" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    )
) ORDER BY "PR_ID" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
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
    "ETY_ID_of" tinyint not null,
    constraint "EV_Händelse_fkST_hölls" foreign key (
        "ST_ID_hölls"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "EV_Händelse_fkPR_spelades" foreign key (
        "PR_ID_spelades"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "EV_Händelse_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_Händelsetyp"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Händelse" primary key (
        "EV_ID"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
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
) ORDER BY "EV_DAT_EV_ID" SEGMENTED BY MODULARHASH("EV_DAT_EV_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik" (
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Händelse_Publik" integer not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Händelse_Publik" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_AUD_Händelse_Publik" primary key (
        "EV_AUD_EV_ID"
    )
) ORDER BY "EV_AUD_EV_ID" SEGMENTED BY MODULARHASH("EV_AUD_EV_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt" (
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Händelse_Intäkt" decimal(19,4) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Händelse_Intäkt" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_REV_Händelse_Intäkt" primary key (
        "EV_REV_EV_ID"
    )
) ORDER BY "EV_REV_EV_ID" SEGMENTED BY MODULARHASH("EV_REV_EV_ID") ALL NODES;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status" (
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    "Metadata_EV_STA" integer not null,
    constraint "fkEV_STA_Händelse_Status" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_STA_Händelse_Status" primary key (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt"
    )
) ORDER BY "EV_STA_EV_ID", "EV_STA_ChangedAt" SEGMENTED BY MODULARHASH("EV_STA_EV_ID") ALL NODES;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande" (
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
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
) ORDER BY "EV_UTL_EV_ID" SEGMENTED BY MODULARHASH("EV_UTL_EV_ID") ALL NODES;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level" (
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    "Metadata_EV_LVL" integer not null,
    constraint "fk_A_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID"),
    constraint "pkEV_LVL_Händelse_Level" primary key (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt"
    )
) ORDER BY "EV_LVL_EV_ID", "EV_LVL_ChangedAt" SEGMENTED BY MODULARHASH("EV_LVL_EV_ID") ALL NODES;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn" (
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Scen_Namn" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_NAM_Scen_Namn" primary key (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    )
) ORDER BY "ST_NAM_ST_ID", "ST_NAM_ChangedAt" SEGMENTED BY MODULARHASH("ST_NAM_ST_ID") ALL NODES;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats" (
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Scen_Plats" geography not null,
    "ST_LOC_Checksum" int default hash("ST_LOC_Scen_Plats"),
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Scen_Plats" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_LOC_Scen_Plats" primary key (
        "ST_LOC_ST_ID"
    )
) ORDER BY "ST_LOC_ST_ID" SEGMENTED BY MODULARHASH("ST_LOC_ST_ID") ALL NODES;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel" (
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" tinyint not null,
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
) ORDER BY "ST_AVG_ST_ID", "ST_AVG_ChangedAt" SEGMENTED BY MODULARHASH("ST_AVG_ST_ID") ALL NODES;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum" (
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" tinyint not null,
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
) ORDER BY "ST_MIN_ST_ID" SEGMENTED BY MODULARHASH("ST_MIN_ST_ID") ALL NODES;
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
) ORDER BY "AC_NAM_AC_ID", "AC_NAM_ChangedAt" SEGMENTED BY MODULARHASH("AC_NAM_AC_ID") ALL NODES;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön" (
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" tinyint not null,
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
) ORDER BY "AC_GEN_AC_ID" SEGMENTED BY MODULARHASH("AC_GEN_AC_ID") ALL NODES;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå" (
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID"),
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    )
) ORDER BY "AC_PLV_AC_ID", "AC_PLV_ChangedAt" SEGMENTED BY MODULARHASH("AC_PLV_AC_ID") ALL NODES;
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
) ORDER BY "PR_NAM_PR_ID" SEGMENTED BY MODULARHASH("PR_NAM_PR_ID") ALL NODES;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd" (
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Föreställning_Längd" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_LEN_Föreställning_Längd" primary key (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt"
    )
) ORDER BY "PR_LEN_PR_ID", "PR_LEN_ChangedAt" SEGMENTED BY MODULARHASH("PR_LEN_PR_ID") ALL NODES;
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
    ) references knots."ONG_Pågående"("ONG_ID"),
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
)
ORDER BY
    "AC_ID_partner",
    "AC_ID_with"
SEGMENTED BY MODULARHASH(
    "AC_ID_partner",
    "AC_ID_with"
) ALL NODES;
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
)
ORDER BY
    "AC_ID_subset",
    "PN_ID_of"
SEGMENTED BY MODULARHASH(
    "AC_ID_subset",
    "PN_ID_of"
) ALL NODES;
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
)
ORDER BY
    "AC_ID_rollsattes"
SEGMENTED BY MODULARHASH(
    "AC_ID_rollsattes"
) ALL NODES;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick" (
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" bigint not null, 
    "RAT_ID_fick" tinyint not null,
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
    ) references knots."RAT_Betyg"("RAT_ID"),
    constraint "pkAC_deltar_PR_in_RAT_fick" primary key (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt"
    )
)
ORDER BY
    "AC_ID_deltar",
    "PR_ID_in"
SEGMENTED BY MODULARHASH(
    "AC_ID_deltar",
    "PR_ID_in"
) ALL NODES;
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
)
ORDER BY
    "ST_ID_at",
    "PR_ID_spelas"
SEGMENTED BY MODULARHASH(
    "ST_ID_at",
    "PR_ID_spelas"
) ALL NODES;
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har" (
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" tinyint not null,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer not null,
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_förälder_AC_barn_PAT_har_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_förälder_AC_barn_PAT_har_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp"("PAT_ID"),
    constraint "pkAC_förälder_AC_barn_PAT_har" primary key (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    )
)
ORDER BY
    "AC_ID_förälder",
    "AC_ID_barn"
SEGMENTED BY MODULARHASH(
    "AC_ID_förälder",
    "AC_ID_barn"
) ALL NODES;
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
)
ORDER BY
    "PR_ID_innehåll",
    "ST_ID_plats"
SEGMENTED BY MODULARHASH(
    "PR_ID_innehåll",
    "ST_ID_plats"
) ALL NODES;
-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Uni-temporal anchor perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the
-- perspectives that take a time (point-in-time and difference) are not made; the latest and the now perspectives take
-- none, and are views. The latest shows the value with the latest changing time of every historized attribute, which may
-- be in the future; the now shows the latest that is not.
--
CREATE OR REPLACE VIEW anchors."lST_Scen" AS
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
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
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."ST_NAM_Scen_Namn" h
    LIMIT 1 OVER (
        PARTITION BY h."ST_NAM_ST_ID"
        ORDER BY h."ST_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."ST_LOC_Scen_Plats" "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."ST_AVG_Scen_Medel" h
    LIMIT 1 OVER (
        PARTITION BY h."ST_AVG_ST_ID"
        ORDER BY h."ST_AVG_ChangedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
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
;
CREATE OR REPLACE VIEW anchors."nST_Scen" AS
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
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
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."ST_NAM_Scen_Namn" h
    WHERE
        h."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."ST_NAM_ST_ID"
        ORDER BY h."ST_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."ST_LOC_Scen_Plats" "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."ST_AVG_Scen_Medel" h
    WHERE
        h."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."ST_AVG_ST_ID"
        ORDER BY h."ST_AVG_ChangedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
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
;
CREATE OR REPLACE VIEW anchors."lAC_Skådespelare" AS
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
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."AC_NAM_Skådespelare_Namn" h
    LIMIT 1 OVER (
        PARTITION BY h."AC_NAM_AC_ID"
        ORDER BY h."AC_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" h
    LIMIT 1 OVER (
        PARTITION BY h."AC_PLV_AC_ID"
        ORDER BY h."AC_PLV_ChangedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW anchors."nAC_Skådespelare" AS
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
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."AC_NAM_Skådespelare_Namn" h
    WHERE
        h."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."AC_NAM_AC_ID"
        ORDER BY h."AC_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    attributes."AC_GEN_Skådespelare_Kön" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå" h
    WHERE
        h."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."AC_PLV_AC_ID"
        ORDER BY h."AC_PLV_ChangedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW anchors."lPR_Föreställning" AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."PR_LEN_Föreställning_Längd" h
    LIMIT 1 OVER (
        PARTITION BY h."PR_LEN_PR_ID"
        ORDER BY h."PR_LEN_ChangedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
CREATE OR REPLACE VIEW anchors."nPR_Föreställning" AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    attributes."PR_NAM_Föreställning_Namn" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        attributes."PR_LEN_Föreställning_Längd" h
    WHERE
        h."PR_LEN_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY h."PR_LEN_PR_ID"
        ORDER BY h."PR_LEN_ChangedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Uni-temporal nexus perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (point-in-time and difference) are not made; the latest and the now perspectives take none, and are views.
--
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Uni-temporal tie perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the
-- perspectives that take a time (point-in-time and difference) are not made; the latest and the now perspectives take
-- none, and are views. The latest shows the version with the latest changing time of every historized tie, which may be in
-- the future; the now shows the latest that is not.
--
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_with"
    FROM
        ties."AC_partner_AC_with_ONG_currently" r
) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_with"
    FROM
        ties."AC_partner_AC_with_ONG_currently" r
    WHERE
        r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" AS
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    ties."AC_subset_PN_of" t
;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    ties."AC_subset_PN_of" t
;
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" AS
SELECT
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" t
;
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" t
;
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" AS
SELECT
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_deltar",
                r."PR_ID_in"
            ORDER BY
                r."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."AC_deltar_PR_in_RAT_fick" r
) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" AS
SELECT
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_deltar",
                r."PR_ID_in"
            ORDER BY
                r."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."AC_deltar_PR_in_RAT_fick" r
    WHERE
        r."AC_deltar_PR_in_RAT_fick_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" AS
SELECT
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_spelas"
            ORDER BY
                r."ST_at_PR_spelas_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."ST_at_PR_spelas" r
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_spelas"
            ORDER BY
                r."ST_at_PR_spelas_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."ST_at_PR_spelas" r
    WHERE
        r."ST_at_PR_spelas_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" AS
SELECT
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
;
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
;
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" AS
SELECT
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_innehåll"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY r."ST_ID_plats"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestST_ID_plats"
    FROM
        ties."PR_innehåll_ST_plats_EV_of" r
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
;
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_innehåll"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY r."ST_ID_plats"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestST_ID_plats"
    FROM
        ties."PR_innehåll_ST_plats_EV_of" r
    WHERE
        r."PR_innehåll_ST_plats_EV_of_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots."PAT_Föräldratyp" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN knots."PAT_Föräldratyp"."PAT_Föräldratyp" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots."GEN_Kön" IS 'Gender of an actor.';
COMMENT ON COLUMN knots."GEN_Kön"."GEN_Kön" IS 'Gender of an actor.';
COMMENT ON TABLE knots."PLV_Yrkesnivå" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN knots."PLV_Yrkesnivå"."PLV_Yrkesnivå" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots."UTL_Utnyttjande" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots."UTL_Utnyttjande"."UTL_Utnyttjande" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots."ONG_Pågående" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots."ONG_Pågående"."ONG_Pågående" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots."RAT_Betyg" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN knots."RAT_Betyg"."RAT_Betyg" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
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
