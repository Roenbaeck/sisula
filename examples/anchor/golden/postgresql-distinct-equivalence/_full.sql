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
-- PAT_ParentalType_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType_ID" (
    "PAT_ID" smallint not null,
    "Metadata_PAT" integer not null, 
    constraint "pkPAT_ParentalType_ID" primary key (
        "PAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PAT_ParentalType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType_EQ" (
    "PAT_ID" smallint not null,
    "PAT_EQ" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" integer not null, 
    constraint "fkPAT_ParentalType_EQ" foreign key (
        "PAT_ID"
    ) references knots."PAT_ParentalType_ID"("PAT_ID"),
    constraint "pkPAT_ParentalType_EQ" primary key (
        "PAT_EQ",
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType_EQ" unique (
        "PAT_EQ",
        "PAT_ParentalType"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Gender" (
    "GEN_ID" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "GEN_Checksum" bytea generated always as (decode(md5("GEN_Gender"::text), 'hex')) stored,
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel_ID" (
    "PLV_ID" smallint not null,
    "Metadata_PLV" integer not null, 
    constraint "pkPLV_ProfessionalLevel_ID" primary key (
        "PLV_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel_EQ" (
    "PLV_ID" smallint not null,
    "PLV_EQ" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" integer not null, 
    constraint "fkPLV_ProfessionalLevel_EQ" foreign key (
        "PLV_ID"
    ) references knots."PLV_ProfessionalLevel_ID"("PLV_ID"),
    constraint "pkPLV_ProfessionalLevel_EQ" primary key (
        "PLV_EQ",
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel_EQ" unique (
        "PLV_EQ",
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utilization" (
    "UTL_ID" smallint not null,
    "UTL_Utilization" smallint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ONG_Ongoing_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing_ID" (
    "ONG_ID" smallint not null,
    "Metadata_ONG" integer not null, 
    constraint "pkONG_Ongoing_ID" primary key (
        "ONG_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ONG_Ongoing_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing_EQ" (
    "ONG_ID" smallint not null,
    "ONG_EQ" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" integer not null, 
    constraint "fkONG_Ongoing_EQ" foreign key (
        "ONG_ID"
    ) references knots."ONG_Ongoing_ID"("ONG_ID"),
    constraint "pkONG_Ongoing_EQ" primary key (
        "ONG_EQ",
        "ONG_ID"
    ),
    constraint "uqONG_Ongoing_EQ" unique (
        "ONG_EQ",
        "ONG_Ongoing"
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- RAT_Rating_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Rating_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Rating_ID" (
    "RAT_ID" smallint default nextval('knots."RAT_Rating_ID_SEQ"') not null, 
    "Metadata_RAT" integer not null, 
    constraint "pkRAT_Rating_ID" primary key (
        "RAT_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- RAT_Rating_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."RAT_Rating_EQ" (
    "RAT_ID" smallint not null,
    "RAT_EQ" smallint not null,
    "RAT_Rating" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Rating"::text), 'hex')) stored,
    "Metadata_RAT" integer not null, 
    constraint "fkRAT_Rating_EQ" foreign key (
        "RAT_ID"
    ) references knots."RAT_Rating_ID"("RAT_ID"),
    constraint "pkRAT_Rating_EQ" primary key (
        "RAT_EQ",
        "RAT_ID"
    ),
    constraint "uqRAT_Rating_EQ" unique (
        "RAT_EQ",
        "RAT_Checksum" 
    )
);
-- Knot identity table ------------------------------------------------------------------------------------------------
-- ETY_EventType_ID table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType_ID" (
    "ETY_ID" smallint not null,
    "Metadata_ETY" integer not null, 
    constraint "pkETY_EventType_ID" primary key (
        "ETY_ID"
    )
);
-- Knot value table ---------------------------------------------------------------------------------------------------
-- ETY_EventType_EQ table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType_EQ" (
    "ETY_ID" smallint not null,
    "ETY_EQ" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_EventType"::text), 'hex')) stored,
    "Metadata_ETY" integer not null, 
    constraint "fkETY_EventType_EQ" foreign key (
        "ETY_ID"
    ) references knots."ETY_EventType_ID"("ETY_ID"),
    constraint "pkETY_EventType_EQ" primary key (
        "ETY_EQ",
        "ETY_ID"
    ),
    constraint "uqETY_EventType_EQ" unique (
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
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Stage" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Stage" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Actor_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Actor" (
    "AC_ID" smallint default nextval('anchors."AC_Actor_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Program" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Program" primary key (
        "PR_ID"
    )
);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses."EV_Event" (
    "EV_ID" numeric(12,0) not null,
    "ST_ID_wasHeldAt" integer not null, 
    "PR_ID_wasPlayed" bigint not null, 
    "ETY_ID_of" smallint not null,
    constraint "EV_Event_fkST_wasHeldAt" foreign key (
        "ST_ID_wasHeldAt"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "EV_Event_fkPR_wasPlayed" foreign key (
        "PR_ID_wasPlayed"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "EV_Event_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_EventType_ID"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Event" primary key (
        "EV_ID"
    )
);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date" (
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Event_Date" timestamp not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Event_Date" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date" primary key (
        "EV_DAT_EV_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience" (
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_EQ" smallint not null,
    "EV_AUD_Event_Audience" integer not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Event_Audience" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience" primary key (
        "EV_AUD_EQ",
        "EV_AUD_EV_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue" (
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_EQ" smallint not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Event_Revenue" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue" primary key (
        "EV_REV_EQ",
        "EV_REV_EV_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status" (
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_EQ" smallint not null,
    "EV_STA_Event_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    "Metadata_EV_STA" integer not null,
    constraint "fkEV_STA_Event_Status" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_STA_Event_Status" primary key (
        "EV_STA_EQ",
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization" (
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" smallint not null,
    "Metadata_EV_UTL" integer not null,
    constraint "fk_A_EV_UTL_Event_Utilization" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "fk_K_EV_UTL_Event_Utilization" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkEV_UTL_Event_Utilization" primary key (
        "EV_UTL_EV_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Event_Level table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level" (
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" smallint not null,
    "EV_LVL_ChangedAt" date not null,
    "Metadata_EV_LVL" integer not null,
    constraint "fk_A_EV_LVL_Event_Level" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "fk_K_EV_LVL_Event_Level" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_ProfessionalLevel_ID"("PLV_ID"),
    constraint "pkEV_LVL_Event_Level" primary key (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name" (
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_EQ" smallint not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Stage_Name" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name" primary key (
        "ST_NAM_EQ",
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location" (
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_EQ" smallint not null,
    "ST_LOC_Stage_Location" text not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Stage_Location"::text), 'hex')) stored,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Stage_Location" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location" primary key (
        "ST_LOC_EQ",
        "ST_LOC_ST_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average" (
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fk_A_ST_AVG_Stage_Average" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average" primary key (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum" (
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fk_A_ST_MIN_Stage_Minimum" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum" primary key (
        "ST_MIN_ST_ID"
    )
);
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name" (
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Actor_Name" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name" primary key (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender" (
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" smallint not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fk_A_AC_GEN_Actor_Gender" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender" primary key (
        "AC_GEN_AC_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel" (
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_ProfessionalLevel_ID"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name" (
    "PR_NAM_PR_ID" bigint not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Program_Name" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name" primary key (
        "PR_NAM_PR_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length" (
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_EQ" smallint not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Program_Length" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length" primary key (
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
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Ongoing_ID"("ONG_ID"),
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
    ) references anchors."AC_Actor"("AC_ID"), 
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
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast" (
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_wasCast" smallint not null, 
    "Metadata_EV_in_AC_wasCast" integer not null,
    constraint "EV_in_AC_wasCast_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Event"("EV_ID"), 
    constraint "EV_in_AC_wasCast_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "pkEV_in_AC_wasCast" primary key (
        "EV_ID_in",
        "AC_ID_wasCast"
    )
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got" (
    "AC_ID_part" smallint not null, 
    "PR_ID_in" bigint not null, 
    "RAT_ID_got" smallint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp not null,
    "Metadata_AC_part_PR_in_RAT_got" integer not null,
    constraint "AC_part_PR_in_RAT_got_fkAC_part" foreign key (
        "AC_ID_part"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_part_PR_in_RAT_got_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "AC_part_PR_in_RAT_got_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references knots."RAT_Rating_ID"("RAT_ID"),
    constraint "pkAC_part_PR_in_RAT_got" primary key (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying" (
    "ST_ID_at" integer not null, 
    "PR_ID_isPlaying" bigint not null, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp not null,
    "Metadata_ST_at_PR_isPlaying" integer not null,
    constraint "ST_at_PR_isPlaying_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "ST_at_PR_isPlaying_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "pkST_at_PR_isPlaying" primary key (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    )
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having" (
    "AC_ID_parent" smallint not null, 
    "AC_ID_child" smallint not null, 
    "PAT_ID_having" smallint not null,
    "Metadata_AC_parent_AC_child_PAT_having" integer not null,
    constraint "AC_parent_AC_child_PAT_having_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_fkAC_child" foreign key (
        "AC_ID_child"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references knots."PAT_ParentalType_ID"("PAT_ID"),
    constraint "pkAC_parent_AC_child_PAT_having" primary key (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of" (
    "PR_ID_content" bigint not null, 
    "ST_ID_location" integer not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp not null,
    "Metadata_PR_content_ST_location_EV_of" integer not null,
    constraint "PR_content_ST_location_EV_of_fkPR_content" foreign key (
        "PR_ID_content"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "PR_content_ST_location_EV_of_fkST_location" foreign key (
        "ST_ID_location"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "PR_content_ST_location_EV_of_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Event"("EV_ID"), 
    constraint "PR_content_ST_location_EV_of_uqPR_content" unique (
        "PR_ID_content",
        "PR_content_ST_location_EV_of_ChangedAt"
    ),
    constraint "PR_content_ST_location_EV_of_uqST_location" unique (
        "ST_ID_location",
        "PR_content_ST_location_EV_of_ChangedAt"
    ),
    constraint "pkPR_content_ST_location_EV_of" primary key (
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of",
        "PR_content_ST_location_EV_of_ChangedAt"
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
-- PAT_ParentalType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."PAT_ParentalType" (
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
    knots."PAT_ParentalType_ID" i
JOIN
    knots."PAT_ParentalType_EQ" v
ON
    v."PAT_ID" = i."PAT_ID"
;
CREATE OR REPLACE FUNCTION knots."ePAT_ParentalType" (
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
        knots."PAT_ParentalType"
    WHERE
        "PAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."PLV_ProfessionalLevel" (
    "Metadata_PLV",
    "PLV_ID",
    "PLV_EQ",
    "PLV_Checksum",
    "PLV_ProfessionalLevel"
)
AS
SELECT
    v."Metadata_PLV",
    i."PLV_ID",
    v."PLV_EQ",
    v."PLV_Checksum",
    v."PLV_ProfessionalLevel"
FROM
    knots."PLV_ProfessionalLevel_ID" i
JOIN
    knots."PLV_ProfessionalLevel_EQ" v
ON
    v."PLV_ID" = i."PLV_ID"
;
CREATE OR REPLACE FUNCTION knots."ePLV_ProfessionalLevel" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PLV" integer,
    "PLV_ID" smallint,
    "PLV_EQ" smallint,
    "PLV_Checksum" bytea,
    "PLV_ProfessionalLevel" text
)
AS
$$
    SELECT
        "Metadata_PLV",
        "PLV_ID",
        "PLV_EQ",
        "PLV_Checksum",
        "PLV_ProfessionalLevel"
    FROM
        knots."PLV_ProfessionalLevel"
    WHERE
        "PLV_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ONG_Ongoing view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ONG_Ongoing" (
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
    knots."ONG_Ongoing_ID" i
JOIN
    knots."ONG_Ongoing_EQ" v
ON
    v."ONG_ID" = i."ONG_ID"
;
CREATE OR REPLACE FUNCTION knots."eONG_Ongoing" (
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
        knots."ONG_Ongoing"
    WHERE
        "ONG_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- RAT_Rating view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."RAT_Rating" (
    "Metadata_RAT",
    "RAT_ID",
    "RAT_EQ",
    "RAT_Checksum",
    "RAT_Rating"
)
AS
SELECT
    v."Metadata_RAT",
    i."RAT_ID",
    v."RAT_EQ",
    v."RAT_Checksum",
    v."RAT_Rating"
FROM
    knots."RAT_Rating_ID" i
JOIN
    knots."RAT_Rating_EQ" v
ON
    v."RAT_ID" = i."RAT_ID"
;
CREATE OR REPLACE FUNCTION knots."eRAT_Rating" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_RAT" integer,
    "RAT_ID" smallint,
    "RAT_EQ" smallint,
    "RAT_Checksum" bytea,
    "RAT_Rating" varchar(42)
)
AS
$$
    SELECT
        "Metadata_RAT",
        "RAT_ID",
        "RAT_EQ",
        "RAT_Checksum",
        "RAT_Rating"
    FROM
        knots."RAT_Rating"
    WHERE
        "RAT_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Knot equivalence view ----------------------------------------------------------------------------------------------
-- ETY_EventType view and parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots."ETY_EventType" (
    "Metadata_ETY",
    "ETY_ID",
    "ETY_EQ",
    "ETY_Checksum",
    "ETY_EventType"
)
AS
SELECT
    v."Metadata_ETY",
    i."ETY_ID",
    v."ETY_EQ",
    v."ETY_Checksum",
    v."ETY_EventType"
FROM
    knots."ETY_EventType_ID" i
JOIN
    knots."ETY_EventType_EQ" v
ON
    v."ETY_ID" = i."ETY_ID"
;
CREATE OR REPLACE FUNCTION knots."eETY_EventType" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ETY" integer,
    "ETY_ID" smallint,
    "ETY_EQ" smallint,
    "ETY_Checksum" bytea,
    "ETY_EventType" varchar(42)
)
AS
$$
    SELECT
        "Metadata_ETY",
        "ETY_ID",
        "ETY_EQ",
        "ETY_Checksum",
        "ETY_EventType"
    FROM
        knots."ETY_EventType"
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
-- EV_AUD_Event_Audience parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_AUD_Event_Audience" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_EQ" smallint,
    "Metadata_EV_AUD" integer,
    "EV_AUD_Event_Audience" integer
)
AS
$$
    SELECT
        "EV_AUD_EV_ID",
        "EV_AUD_EQ",
        "Metadata_EV_AUD",
        "EV_AUD_Event_Audience"
    FROM
        attributes."EV_AUD_Event_Audience"
    WHERE
        "EV_AUD_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_REV_Event_Revenue" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_REV_EV_ID" numeric(12,0),
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
        attributes."EV_REV_Event_Revenue"
    WHERE
        "EV_REV_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eEV_STA_Event_Status" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" smallint,
    "EV_STA_ChangedAt" timestamp,
    "Metadata_EV_STA" integer,
    "EV_STA_Event_Status" varchar(20)
)
AS
$$
    SELECT
        "EV_STA_EV_ID",
        "EV_STA_EQ",
        "EV_STA_ChangedAt",
        "Metadata_EV_STA",
        "EV_STA_Event_Status"
    FROM
        attributes."EV_STA_Event_Status"
    WHERE
        "EV_STA_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_NAM_Stage_Name" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_NAM_ST_ID" integer,
    "ST_NAM_EQ" smallint,
    "ST_NAM_ChangedAt" timestamp,
    "Metadata_ST_NAM" integer,
    "ST_NAM_Stage_Name" varchar(42)
)
AS
$$
    SELECT
        "ST_NAM_ST_ID",
        "ST_NAM_EQ",
        "ST_NAM_ChangedAt",
        "Metadata_ST_NAM",
        "ST_NAM_Stage_Name"
    FROM
        attributes."ST_NAM_Stage_Name"
    WHERE
        "ST_NAM_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eST_LOC_Stage_Location" (
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
        attributes."ST_LOC_Stage_Location"
    WHERE
        "ST_LOC_EQ" = equivalent
$$ LANGUAGE sql STABLE;
-- Attribute equivalence view -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length parametrized view
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."ePR_LEN_Program_Length" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_EQ" smallint,
    "PR_LEN_ChangedAt" date,
    "Metadata_PR_LEN" integer,
    "PR_LEN_Program_Length" time
)
AS
$$
    SELECT
        "PR_LEN_PR_ID",
        "PR_LEN_EQ",
        "PR_LEN_ChangedAt",
        "Metadata_PR_LEN",
        "PR_LEN_Program_Length"
    FROM
        attributes."PR_LEN_Program_Length"
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
-- rEV_STA_Event_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_EV_STA",
        "EV_STA_EV_ID",
        "EV_STA_EQ",
        "EV_STA_Event_Status",
        "EV_STA_ChangedAt"
    FROM
        attributes."eEV_STA_Event_Status"(equivalent) 
    WHERE
        "EV_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level" (
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
        attributes."EV_LVL_Event_Level"
    WHERE
        "EV_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_ST_NAM",
        "ST_NAM_ST_ID",
        "ST_NAM_EQ",
        "ST_NAM_Stage_Name",
        "ST_NAM_ChangedAt"
    FROM
        attributes."eST_NAM_Stage_Name"(equivalent) 
    WHERE
        "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average" (
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
        attributes."ST_AVG_Stage_Average"
    WHERE
        "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_AC_NAM",
        "AC_NAM_AC_ID",
        "AC_NAM_Actor_Name",
        "AC_NAM_ChangedAt"
    FROM
        attributes."AC_NAM_Actor_Name"
    WHERE
        "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel" (
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
        attributes."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length" (
    equivalent smallint,
    changingTimepoint date
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
    SELECT
        "Metadata_PR_LEN",
        "PR_LEN_PR_ID",
        "PR_LEN_EQ",
        "PR_LEN_Program_Length",
        "PR_LEN_ChangedAt"
    FROM
        attributes."ePR_LEN_Program_Length"(equivalent) 
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
CREATE OR REPLACE VIEW anchors."lST_Stage" (
    "ST_ID",
    "Metadata_ST",
    "ST_NAM_ST_ID",
    "Metadata_ST_NAM",
    "ST_NAM_ChangedAt",
    "ST_NAM_EQ",
    "ST_NAM_Stage_Name",
    "ST_LOC_ST_ID",
    "Metadata_ST_LOC",
    "ST_LOC_EQ",
    "ST_LOC_Checksum",
    "ST_LOC_Stage_Location",
    "ST_AVG_ST_ID",
    "Metadata_ST_AVG",
    "ST_AVG_ChangedAt",
    "ST_AVG_UTL_Utilization",
    "ST_AVG_Metadata_UTL",
    "ST_AVG_UTL_ID",
    "ST_MIN_ST_ID",
    "Metadata_ST_MIN",
    "ST_MIN_UTL_Utilization",
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN
    attributes."eST_NAM_Stage_Name"(0::smallint) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            attributes."eST_NAM_Stage_Name"(0::smallint) sub 
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    attributes."eST_LOC_Stage_Location"(0::smallint) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."ST_AVG_Stage_Average" "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."ST_AVG_Stage_Average" sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utilization" smallint,
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN
    attributes."rST_NAM_Stage_Name"(0::smallint, changingTimepoint::timestamp) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            attributes."rST_NAM_Stage_Name"(0::smallint, changingTimepoint::timestamp) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    attributes."eST_LOC_Stage_Location"(0::smallint) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."rST_AVG_Stage_Average"(changingTimepoint::timestamp) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."rST_AVG_Stage_Average"(changingTimepoint::timestamp) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Stage"
AS
SELECT
    *
FROM
    anchors."pST_Stage"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Stage" (
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
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utilization" smallint,
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM (
    SELECT DISTINCT
        h."ST_NAM_ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."eST_NAM_Stage_Name"(0::smallint) h
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
        attributes."ST_AVG_Stage_Average" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Stage" "ST"
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
        attributes."eST_NAM_Stage_Name"(0::smallint) h
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
    attributes."eST_LOC_Stage_Location"(0::smallint) "LOC"
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
        attributes."ST_AVG_Stage_Average" h
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
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epST_Stage" (
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
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utilization" smallint,
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN
    attributes."rST_NAM_Stage_Name"(equivalent, changingTimepoint::timestamp) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            attributes."rST_NAM_Stage_Name"(equivalent, changingTimepoint::timestamp) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    attributes."eST_LOC_Stage_Location"(equivalent) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."rST_AVG_Stage_Average"(changingTimepoint::timestamp) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."rST_AVG_Stage_Average"(changingTimepoint::timestamp) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elST_Stage" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epST_Stage"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enST_Stage" (
    equivalent smallint
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_EQ" smallint,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epST_Stage"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edST_Stage" (
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
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_EQ" smallint,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_UTL_Utilization" smallint,
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM (
    SELECT DISTINCT
        h."ST_NAM_ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."eST_NAM_Stage_Name"(equivalent) h
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
        attributes."ST_AVG_Stage_Average" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Stage" "ST"
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
        attributes."eST_NAM_Stage_Name"(equivalent) h
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
    attributes."eST_LOC_Stage_Location"(equivalent) "LOC"
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
        attributes."ST_AVG_Stage_Average" h
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
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Actor" (
    "AC_ID",
    "Metadata_AC",
    "AC_NAM_AC_ID",
    "Metadata_AC_NAM",
    "AC_NAM_ChangedAt",
    "AC_NAM_Actor_Name",
    "AC_GEN_AC_ID",
    "Metadata_AC_GEN",
    "AC_GEN_GEN_Checksum",
    "AC_GEN_GEN_Gender",
    "AC_GEN_Metadata_GEN",
    "AC_GEN_GEN_ID",
    "AC_PLV_AC_ID",
    "Metadata_AC_PLV",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_Checksum",
    "AC_PLV_PLV_EQ",
    "AC_PLV_PLV_ProfessionalLevel",
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
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN
    attributes."AC_NAM_Actor_Name" "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."AC_NAM_Actor_Name" sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel" "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel" sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(0::smallint) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_ProfessionalLevel" text,
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
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN
    attributes."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(0::smallint) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Actor"
AS
SELECT
    *
FROM
    anchors."pAC_Actor"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Actor" (
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
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_ProfessionalLevel" text,
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
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM (
    SELECT DISTINCT
        h."AC_NAM_AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name" h
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
        attributes."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Actor" "AC"
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
        attributes."AC_NAM_Actor_Name" h
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
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
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
        attributes."AC_PLV_Actor_ProfessionalLevel" h
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
    knots."ePLV_ProfessionalLevel"(0::smallint) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epAC_Actor" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_ProfessionalLevel" text,
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
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN
    attributes."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(equivalent) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elAC_Actor" (
    equivalent smallint
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epAC_Actor"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enAC_Actor" (
    equivalent smallint
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    anchors."epAC_Actor"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edAC_Actor" (
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
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_EQ" smallint,
    "AC_PLV_PLV_ProfessionalLevel" text,
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
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_EQ" AS "AC_PLV_PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM (
    SELECT DISTINCT
        h."AC_NAM_AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name" h
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
        attributes."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Actor" "AC"
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
        attributes."AC_NAM_Actor_Name" h
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
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
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
        attributes."AC_PLV_Actor_ProfessionalLevel" h
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
    knots."ePLV_ProfessionalLevel"(equivalent) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Program" (
    "PR_ID",
    "Metadata_PR",
    "PR_NAM_PR_ID",
    "Metadata_PR_NAM",
    "PR_NAM_Program_Name",
    "PR_LEN_PR_ID",
    "Metadata_PR_LEN",
    "PR_LEN_ChangedAt",
    "PR_LEN_EQ",
    "PR_LEN_Program_Length"
)
AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    attributes."ePR_LEN_Program_Length"(0::smallint) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            attributes."ePR_LEN_Program_Length"(0::smallint) sub 
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    attributes."rPR_LEN_Program_Length"(0::smallint, changingTimepoint::date) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            attributes."rPR_LEN_Program_Length"(0::smallint, changingTimepoint::date) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Program"
AS
SELECT
    *
FROM
    anchors."pPR_Program"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Program" (
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
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time
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
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        h."PR_LEN_PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."ePR_LEN_Program_Length"(0::smallint) h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
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
        attributes."ePR_LEN_Program_Length"(0::smallint) h
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
CREATE OR REPLACE FUNCTION anchors."epPR_Program" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    attributes."rPR_LEN_Program_Length"(equivalent, changingTimepoint::date) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            attributes."rPR_LEN_Program_Length"(equivalent, changingTimepoint::date) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elPR_Program" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    *
FROM
    anchors."epPR_Program"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enPR_Program" (
    equivalent smallint
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    *
FROM
    anchors."epPR_Program"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edPR_Program" (
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
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" smallint,
    "PR_LEN_Program_Length" time
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
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        h."PR_LEN_PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."ePR_LEN_Program_Length"(equivalent) h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
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
        attributes."ePR_LEN_Program_Length"(equivalent) h
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
CREATE OR REPLACE VIEW nexuses."lEV_Event" (
    "EV_ID",
    "Metadata_EV",
    "ST_ID_wasHeldAt",
    "PR_ID_wasPlayed",
    "of_ETY_Checksum",
    "of_ETY_EventType",
    "of_ETY_EQ",
    "of_Metadata_ETY",
    "ETY_ID_of",
    "EV_DAT_EV_ID",
    "Metadata_EV_DAT",
    "EV_DAT_Event_Date",
    "EV_AUD_EV_ID",
    "Metadata_EV_AUD",
    "EV_AUD_EQ",
    "EV_AUD_Event_Audience",
    "EV_REV_EV_ID",
    "Metadata_EV_REV",
    "EV_REV_EQ",
    "EV_REV_Event_Revenue",
    "EV_STA_EV_ID",
    "Metadata_EV_STA",
    "EV_STA_ChangedAt",
    "EV_STA_EQ",
    "EV_STA_Event_Status",
    "EV_UTL_EV_ID",
    "Metadata_EV_UTL",
    "EV_UTL_UTL_Utilization",
    "EV_UTL_Metadata_UTL",
    "EV_UTL_UTL_ID",
    "EV_LVL_EV_ID",
    "Metadata_EV_LVL",
    "EV_LVL_ChangedAt",
    "EV_LVL_PLV_Checksum",
    "EV_LVL_PLV_EQ",
    "EV_LVL_PLV_ProfessionalLevel",
    "EV_LVL_Metadata_PLV",
    "EV_LVL_PLV_ID"
)
AS
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
LEFT JOIN
    knots."eETY_EventType"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Event_Audience"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Event_Revenue"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_STA_Event_Status"(0::smallint) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."eEV_STA_Event_Status"(0::smallint) sub 
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Event_Utilization" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."EV_LVL_Event_Level" "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."EV_LVL_Event_Level" sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
LEFT JOIN
    knots."eETY_EventType"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Event_Audience"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Event_Revenue"(0::smallint) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."rEV_STA_Event_Status"(0::smallint, changingTimepoint::timestamp) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."rEV_STA_Event_Status"(0::smallint, changingTimepoint::timestamp) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Event_Utilization" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."rEV_LVL_Event_Level"(changingTimepoint::date) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."rEV_LVL_Event_Level"(changingTimepoint::date) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Event" AS
SELECT
    *
FROM
    nexuses."pEV_Event"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_ProfessionalLevel" text,
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
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        h."EV_STA_EV_ID" AS "EV_ID",
        h."EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."eEV_STA_Event_Status"(0::smallint) h
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
        attributes."EV_LVL_Event_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."eETY_EventType"(0::smallint) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Event_Audience"(0::smallint) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Event_Revenue"(0::smallint) "REV"
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
        attributes."eEV_STA_Event_Status"(0::smallint) h
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
    attributes."EV_UTL_Event_Utilization" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
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
        attributes."EV_LVL_Event_Level" h
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
    knots."ePLV_ProfessionalLevel"(0::smallint) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."elEV_Event" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
LEFT JOIN
    knots."eETY_EventType"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Event_Audience"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Event_Revenue"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_STA_Event_Status"(equivalent) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."eEV_STA_Event_Status"(equivalent) sub 
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Event_Utilization" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."EV_LVL_Event_Level" "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."EV_LVL_Event_Level" sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."epEV_Event" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
LEFT JOIN
    knots."eETY_EventType"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Event_Audience"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Event_Revenue"(equivalent) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."rEV_STA_Event_Status"(equivalent, changingTimepoint::timestamp) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" = (
        SELECT
            max(sub."EV_STA_ChangedAt")
        FROM
            attributes."rEV_STA_Event_Status"(equivalent, changingTimepoint::timestamp) sub
        WHERE
            sub."EV_STA_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    attributes."EV_UTL_Event_Utilization" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN
    attributes."rEV_LVL_Event_Level"(changingTimepoint::date) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" = (
        SELECT
            max(sub."EV_LVL_ChangedAt")
        FROM
            attributes."rEV_LVL_Event_Level"(changingTimepoint::date) sub
        WHERE
            sub."EV_LVL_EV_ID" = "EV"."EV_ID"
   )
LEFT JOIN
    knots."ePLV_ProfessionalLevel"(equivalent) "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."enEV_Event" (
    equivalent smallint
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    *
FROM
    nexuses."epEV_Event"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."edEV_Event" (
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
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_ETY_EQ" smallint,
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_EQ" smallint,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_EQ" smallint,
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_EQ" smallint,
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_EQ" smallint,
    "EV_LVL_PLV_ProfessionalLevel" text,
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
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."ETY_EQ" AS "of_ETY_EQ",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_EQ",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_EQ",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_EQ",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ChangedAt",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_EQ" AS "EV_LVL_PLV_EQ",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        h."EV_STA_EV_ID" AS "EV_ID",
        h."EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."eEV_STA_Event_Status"(equivalent) h
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
        attributes."EV_LVL_Event_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."eETY_EventType"(equivalent) "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    attributes."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_AUD_Event_Audience"(equivalent) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    attributes."eEV_REV_Event_Revenue"(equivalent) "REV"
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
        attributes."eEV_STA_Event_Status"(equivalent) h
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
    attributes."EV_UTL_Event_Utilization" "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
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
        attributes."EV_LVL_Event_Level" h
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
    knots."ePLV_ProfessionalLevel"(equivalent) "kLVL"
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
    "currently_ONG_Ongoing",
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
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
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
    knots."eONG_Ongoing"(0::smallint) "ONG_currently"
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
    "currently_ONG_Ongoing" varchar(3),
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
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
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
    knots."eONG_Ongoing"(0::smallint) "ONG_currently"
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
    "currently_ONG_Ongoing" varchar(3),
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
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    knots."eONG_Ongoing"(0::smallint) "ONG_currently"
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
    "currently_ONG_Ongoing" varchar(3),
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
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
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
    knots."eONG_Ongoing"(equivalent) "ONG_currently"
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
    "currently_ONG_Ongoing" varchar(3),
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
    "currently_ONG_Ongoing" varchar(3),
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
    "currently_ONG_Ongoing" varchar(3),
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
    "ONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "ONG_currently"."ONG_EQ" AS "currently_ONG_EQ",
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    ties."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    knots."eONG_Ongoing"(equivalent) "ONG_currently"
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
CREATE OR REPLACE VIEW ties."lEV_in_AC_wasCast" (
    "Metadata_EV_in_AC_wasCast",
    "EV_ID_in",
    "AC_ID_wasCast"
)
AS
SELECT
    tie."Metadata_EV_in_AC_wasCast",
    tie."EV_ID_in",
    tie."AC_ID_wasCast"
FROM
    ties."EV_in_AC_wasCast" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_wasCast" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_wasCast",
    tie."EV_ID_in",
    tie."AC_ID_wasCast"
FROM
    ties."EV_in_AC_wasCast" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_wasCast" AS
SELECT
    *
FROM
    ties."pEV_in_AC_wasCast"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epEV_in_AC_wasCast" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_wasCast",
    tie."EV_ID_in",
    tie."AC_ID_wasCast"
FROM
    ties."EV_in_AC_wasCast" tie
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elEV_in_AC_wasCast" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epEV_in_AC_wasCast"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enEV_in_AC_wasCast" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epEV_in_AC_wasCast"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_part_PR_in_RAT_got" (
    "Metadata_AC_part_PR_in_RAT_got",
    "AC_part_PR_in_RAT_got_ChangedAt",
    "AC_ID_part",
    "PR_ID_in",
    "got_RAT_Checksum",
    "got_RAT_Rating",
    "got_RAT_EQ",
    "got_Metadata_RAT",
    "RAT_ID_got"
)
AS
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."RAT_EQ" AS "got_RAT_EQ",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_part_PR_in_RAT_got_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_part",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_part_PR_in_RAT_got" t
    ) tie
LEFT JOIN
    knots."eRAT_Rating"(0::smallint) "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_RAT_EQ" smallint,
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."RAT_EQ" AS "got_RAT_EQ",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_part_PR_in_RAT_got_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_part",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_part_PR_in_RAT_got" t
        WHERE
            t."AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eRAT_Rating"(0::smallint) "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_part_PR_in_RAT_got" AS
SELECT
    *
FROM
    ties."pAC_part_PR_in_RAT_got"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_RAT_EQ" smallint,
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."RAT_EQ" AS "got_RAT_EQ",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    ties."AC_part_PR_in_RAT_got" tie
LEFT JOIN
    knots."eRAT_Rating"(0::smallint) "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_part_PR_in_RAT_got" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_RAT_EQ" smallint,
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."RAT_EQ" AS "got_RAT_EQ",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."AC_part_PR_in_RAT_got_ChangedAt") OVER (
                PARTITION BY
                    t."AC_ID_part",
                    t."PR_ID_in"
            ) AS "latest"
        FROM
            ties."AC_part_PR_in_RAT_got" t
        WHERE
            t."AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    knots."eRAT_Rating"(equivalent) "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_part_PR_in_RAT_got" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_RAT_EQ" smallint,
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_part_PR_in_RAT_got"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_part_PR_in_RAT_got" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_RAT_EQ" smallint,
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_part_PR_in_RAT_got"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edAC_part_PR_in_RAT_got" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_RAT_EQ" smallint,
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."RAT_EQ" AS "got_RAT_EQ",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    ties."AC_part_PR_in_RAT_got" tie
LEFT JOIN
    knots."eRAT_Rating"(equivalent) "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_isPlaying" (
    "Metadata_ST_at_PR_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt",
    "ST_ID_at",
    "PR_ID_isPlaying"
)
AS
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_isPlaying_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_isPlaying"
            ) AS "latest"
        FROM
            ties."ST_at_PR_isPlaying" t
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_isPlaying" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_isPlaying_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_isPlaying"
            ) AS "latest"
        FROM
            ties."ST_at_PR_isPlaying" t
        WHERE
            t."ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_isPlaying" AS
SELECT
    *
FROM
    ties."pST_at_PR_isPlaying"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_isPlaying" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    ties."ST_at_PR_isPlaying" tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epST_at_PR_isPlaying" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."ST_at_PR_isPlaying_ChangedAt") OVER (
                PARTITION BY
                    t."ST_ID_at",
                    t."PR_ID_isPlaying"
            ) AS "latest"
        FROM
            ties."ST_at_PR_isPlaying" t
        WHERE
            t."ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elST_at_PR_isPlaying" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epST_at_PR_isPlaying"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enST_at_PR_isPlaying" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    *
FROM
    ties."epST_at_PR_isPlaying"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edST_at_PR_isPlaying" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    ties."ST_at_PR_isPlaying" tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_parent_AC_child_PAT_having" (
    "Metadata_AC_parent_AC_child_PAT_having",
    "AC_ID_parent",
    "AC_ID_child",
    "having_PAT_ParentalType",
    "having_PAT_EQ",
    "having_Metadata_PAT",
    "PAT_ID_having"
)
AS
SELECT
    tie."Metadata_AC_parent_AC_child_PAT_having",
    tie."AC_ID_parent",
    tie."AC_ID_child",
    "PAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "PAT_having"."PAT_EQ" AS "having_PAT_EQ",
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    ties."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    knots."ePAT_ParentalType"(0::smallint) "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_PAT_EQ" smallint,
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_parent_AC_child_PAT_having",
    tie."AC_ID_parent",
    tie."AC_ID_child",
    "PAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "PAT_having"."PAT_EQ" AS "having_PAT_EQ",
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    ties."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    knots."ePAT_ParentalType"(0::smallint) "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_parent_AC_child_PAT_having" AS
SELECT
    *
FROM
    ties."pAC_parent_AC_child_PAT_having"(current_timestamp::timestamp)
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epAC_parent_AC_child_PAT_having" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_PAT_EQ" smallint,
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    tie."Metadata_AC_parent_AC_child_PAT_having",
    tie."AC_ID_parent",
    tie."AC_ID_child",
    "PAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "PAT_having"."PAT_EQ" AS "having_PAT_EQ",
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    ties."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    knots."ePAT_ParentalType"(equivalent) "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elAC_parent_AC_child_PAT_having" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_PAT_EQ" smallint,
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_parent_AC_child_PAT_having"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enAC_parent_AC_child_PAT_having" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_PAT_EQ" smallint,
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    *
FROM
    ties."epAC_parent_AC_child_PAT_having"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_content_ST_location_EV_of" (
    "Metadata_PR_content_ST_location_EV_of",
    "PR_content_ST_location_EV_of_ChangedAt",
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of"
)
AS
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_content") AS "latestPR_ID_content",
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_location") AS "latestST_ID_location"
        FROM
            ties."PR_content_ST_location_EV_of" t
    ) tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestPR_ID_content"
AND
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestST_ID_location"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_content") AS "latestPR_ID_content",
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_location") AS "latestST_ID_location"
        FROM
            ties."PR_content_ST_location_EV_of" t
        WHERE
            t."PR_content_ST_location_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestPR_ID_content"
AND
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestST_ID_location"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_content_ST_location_EV_of" AS
SELECT
    *
FROM
    ties."pPR_content_ST_location_EV_of"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_content_ST_location_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    ties."PR_content_ST_location_EV_of" tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."epPR_content_ST_location_EV_of" (
    equivalent smallint,
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."PR_ID_content") AS "latestPR_ID_content",
            max(t."PR_content_ST_location_EV_of_ChangedAt") OVER (PARTITION BY t."ST_ID_location") AS "latestST_ID_location"
        FROM
            ties."PR_content_ST_location_EV_of" t
        WHERE
            t."PR_content_ST_location_EV_of_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestPR_ID_content"
AND
    tie."PR_content_ST_location_EV_of_ChangedAt" = tie."latestST_ID_location"
$$ LANGUAGE sql STABLE;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."elPR_content_ST_location_EV_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    ties."epPR_content_ST_location_EV_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."enPR_content_ST_location_EV_of" (
    equivalent smallint
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    *
FROM
    ties."epPR_content_ST_location_EV_of"(equivalent, current_timestamp::timestamp)
$$ LANGUAGE sql STABLE;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."edPR_content_ST_location_EV_of" (
    equivalent smallint,
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_content_ST_location_EV_of_ChangedAt",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    ties."PR_content_ST_location_EV_of" tie
WHERE
    tie."PR_content_ST_location_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots."PAT_ParentalType_ID" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON COLUMN knots."GEN_Gender"."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON TABLE knots."PLV_ProfessionalLevel_ID" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots."UTL_Utilization"."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots."ONG_Ongoing_ID" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots."RAT_Rating_ID" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes."EV_DAT_Event_Date"."EV_DAT_Event_Date" IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes."EV_AUD_Event_Audience"."EV_AUD_Event_Audience" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes."EV_REV_Event_Revenue"."EV_REV_Event_Revenue" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes."EV_STA_Event_Status"."EV_STA_Event_Status" IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes."EV_LVL_Event_Level"."EV_LVL_PLV_ID" IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes."ST_NAM_Stage_Name"."ST_NAM_Stage_Name" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes."ST_LOC_Stage_Location"."ST_LOC_Stage_Location" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes."ST_AVG_Stage_Average"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes."ST_MIN_Stage_Minimum"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes."AC_NAM_Actor_Name"."AC_NAM_Actor_Name" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes."AC_GEN_Actor_Gender"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN attributes."AC_PLV_Actor_ProfessionalLevel"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes."PR_NAM_Program_Name"."PR_NAM_Program_Name" IS 'Name or title of the program.';
COMMENT ON COLUMN attributes."PR_LEN_Program_Length"."PR_LEN_Program_Length" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors."ST_Stage" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors."AC_Actor" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses."EV_Event" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses."EV_Event"."ST_ID_wasHeldAt" IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses."EV_Event"."PR_ID_wasPlayed" IS 'The program that was played at the event.';
COMMENT ON TABLE ties."AC_partner_AC_with_ONG_currently" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties."AC_subset_PN_of"."AC_ID_subset" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties."AC_subset_PN_of"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE ties."EV_in_AC_wasCast" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties."EV_in_AC_wasCast"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties."EV_in_AC_wasCast"."AC_ID_wasCast" IS 'An actor cast in the event.';
COMMENT ON TABLE ties."AC_part_PR_in_RAT_got" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got"."AC_ID_part" IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got"."RAT_ID_got" IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties."ST_at_PR_isPlaying" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties."ST_at_PR_isPlaying"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties."ST_at_PR_isPlaying"."PR_ID_isPlaying" IS 'The program playing at the stage.';
COMMENT ON TABLE ties."AC_parent_AC_child_PAT_having" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having"."AC_ID_parent" IS 'The actor who is the parent.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having"."AC_ID_child" IS 'The actor who is the child.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having"."PAT_ID_having" IS 'The type of parental relationship.';
COMMENT ON TABLE ties."PR_content_ST_location_EV_of" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of"."PR_ID_content" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of"."ST_ID_location" IS 'The stage where the event was located.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of"."EV_ID_of" IS 'The event.';
