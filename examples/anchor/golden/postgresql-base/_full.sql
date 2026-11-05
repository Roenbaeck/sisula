-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS public;
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
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PAT_ParentalType" (
    "PAT_ID" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" integer not null,
    constraint "pkPAT_ParentalType" primary key (
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType" unique (
        "PAT_ParentalType"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GEN_Gender" (
    "GEN_ID" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Gender"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PLV_ProfessionalLevel" (
    "PLV_ID" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" integer not null,
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."UTL_Utilization" (
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
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ONG_Ongoing" (
    "ONG_ID" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" integer not null,
    constraint "pkONG_Ongoing" primary key (
        "ONG_ID"
    ),
    constraint "uqONG_Ongoing" unique (
        "ONG_Ongoing"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."RAT_Rating" (
    "RAT_ID" smallint not null,
    "RAT_Rating" varchar(42) not null,
    "Metadata_RAT" integer not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID"
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Rating"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ETY_EventType" (
    "ETY_ID" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "Metadata_ETY" integer not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_EventType" unique (
        "ETY_EventType"
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
CREATE SEQUENCE IF NOT EXISTS public."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PN_Person" (
    "PN_ID" integer default nextval('public."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_Stage_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_Stage" (
    "ST_ID" integer default nextval('public."ST_Stage_ID_SEQ"') not null, 
    "Metadata_ST" integer not null,
    constraint "pkST_Stage" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_Actor_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_Actor" (
    "AC_ID" integer default nextval('public."AC_Actor_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_Program_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_Program" (
    "PR_ID" integer default nextval('public."PR_Program_ID_SEQ"') not null, 
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
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_Event_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_Event" (
    "EV_ID" integer default nextval('public."EV_Event_ID_SEQ"') not null, 
    "ST_ID_wasHeldAt" integer not null, 
    "PR_ID_wasPlayed" integer not null, 
    "ETY_ID_of" smallint not null,
    constraint "EV_Event_fkST_wasHeldAt" foreign key (
        "ST_ID_wasHeldAt"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "EV_Event_fkPR_wasPlayed" foreign key (
        "PR_ID_wasPlayed"
    ) references public."PR_Program"("PR_ID"), 
    constraint "EV_Event_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references public."ETY_EventType"("ETY_ID"),
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
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date" (
    "EV_DAT_EV_ID" integer not null,
    "EV_DAT_Event_Date" timestamp not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Event_Date" foreign key (
        "EV_DAT_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date" primary key (
        "EV_DAT_EV_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience" (
    "EV_AUD_EV_ID" integer not null,
    "EV_AUD_Event_Audience" integer not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Event_Audience" foreign key (
        "EV_AUD_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience" primary key (
        "EV_AUD_EV_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue" (
    "EV_REV_EV_ID" integer not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Event_Revenue" foreign key (
        "EV_REV_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue" primary key (
        "EV_REV_EV_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name" (
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Stage_Name" foreign key (
        "ST_NAM_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name" primary key (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location" (
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Stage_Location" text not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Stage_Location"::text), 'hex')) stored,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Stage_Location" foreign key (
        "ST_LOC_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location" primary key (
        "ST_LOC_ST_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average" (
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fk_A_ST_AVG_Stage_Average" foreign key (
        "ST_AVG_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average" foreign key (
        "ST_AVG_UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average" primary key (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum" (
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fk_A_ST_MIN_Stage_Minimum" foreign key (
        "ST_MIN_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum" foreign key (
        "ST_MIN_UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum" primary key (
        "ST_MIN_ST_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name" (
    "AC_NAM_AC_ID" integer not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Actor_Name" foreign key (
        "AC_NAM_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name" primary key (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender" (
    "AC_GEN_AC_ID" integer not null,
    "AC_GEN_GEN_ID" smallint not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fk_A_AC_GEN_Actor_Gender" foreign key (
        "AC_GEN_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender" foreign key (
        "AC_GEN_GEN_ID"
    ) references public."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender" primary key (
        "AC_GEN_AC_ID"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel" (
    "AC_PLV_AC_ID" integer not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_PLV_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel" foreign key (
        "AC_PLV_PLV_ID"
    ) references public."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name" (
    "PR_NAM_PR_ID" integer not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Program_Name" foreign key (
        "PR_NAM_PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name" primary key (
        "PR_NAM_PR_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length" (
    "PR_LEN_PR_ID" integer not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Program_Length" foreign key (
        "PR_LEN_PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length" primary key (
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
CREATE TABLE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently" (
    "AC_ID_partner" integer not null, 
    "AC_ID_with" integer not null, 
    "ONG_ID_currently" smallint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    "Metadata_AC_partner_AC_with_ONG_currently" integer not null,
    constraint "AC_partner_AC_with_ONG_currently_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_fkAC_with" foreign key (
        "AC_ID_with"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references public."ONG_Ongoing"("ONG_ID"),
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
CREATE TABLE IF NOT EXISTS public."AC_subset_PN_of" (
    "AC_ID_subset" integer not null, 
    "PN_ID_of" integer not null, 
    "Metadata_AC_subset_PN_of" integer not null,
    constraint "AC_subset_PN_of_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_subset_PN_of_fkPN_of" foreign key (
        "PN_ID_of"
    ) references public."PN_Person"("PN_ID"), 
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
CREATE TABLE IF NOT EXISTS public."EV_in_AC_wasCast" (
    "EV_ID_in" integer not null, 
    "AC_ID_wasCast" integer not null, 
    "Metadata_EV_in_AC_wasCast" integer not null,
    constraint "EV_in_AC_wasCast_fkEV_in" foreign key (
        "EV_ID_in"
    ) references public."EV_Event"("EV_ID"), 
    constraint "EV_in_AC_wasCast_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "pkEV_in_AC_wasCast" primary key (
        "EV_ID_in",
        "AC_ID_wasCast"
    )
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_part_PR_in_RAT_got" (
    "AC_ID_part" integer not null, 
    "PR_ID_in" integer not null, 
    "RAT_ID_got" smallint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp not null,
    "Metadata_AC_part_PR_in_RAT_got" integer not null,
    constraint "AC_part_PR_in_RAT_got_fkAC_part" foreign key (
        "AC_ID_part"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_part_PR_in_RAT_got_fkPR_in" foreign key (
        "PR_ID_in"
    ) references public."PR_Program"("PR_ID"), 
    constraint "AC_part_PR_in_RAT_got_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references public."RAT_Rating"("RAT_ID"),
    constraint "pkAC_part_PR_in_RAT_got" primary key (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_at_PR_isPlaying" (
    "ST_ID_at" integer not null, 
    "PR_ID_isPlaying" integer not null, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp not null,
    "Metadata_ST_at_PR_isPlaying" integer not null,
    constraint "ST_at_PR_isPlaying_fkST_at" foreign key (
        "ST_ID_at"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "ST_at_PR_isPlaying_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references public."PR_Program"("PR_ID"), 
    constraint "pkST_at_PR_isPlaying" primary key (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    )
);
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_parent_AC_child_PAT_having" (
    "AC_ID_parent" integer not null, 
    "AC_ID_child" integer not null, 
    "PAT_ID_having" smallint not null,
    "Metadata_AC_parent_AC_child_PAT_having" integer not null,
    constraint "AC_parent_AC_child_PAT_having_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_fkAC_child" foreign key (
        "AC_ID_child"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references public."PAT_ParentalType"("PAT_ID"),
    constraint "pkAC_parent_AC_child_PAT_having" primary key (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
);
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_content_ST_location_EV_of" (
    "PR_ID_content" integer not null, 
    "ST_ID_location" integer not null, 
    "EV_ID_of" integer not null, 
    "Metadata_PR_content_ST_location_EV_of" integer not null,
    constraint "PR_content_ST_location_EV_of_fkPR_content" foreign key (
        "PR_ID_content"
    ) references public."PR_Program"("PR_ID"), 
    constraint "PR_content_ST_location_EV_of_fkST_location" foreign key (
        "ST_ID_location"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "PR_content_ST_location_EV_of_fkEV_of" foreign key (
        "EV_ID_of"
    ) references public."EV_Event"("EV_ID"), 
    constraint "pkPR_content_ST_location_EV_of" primary key (
        "EV_ID_of"
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
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
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
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_NAM_Stage_Name" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_ST_NAM",
        "ST_NAM_ST_ID",
        "ST_NAM_Stage_Name",
        "ST_NAM_ChangedAt"
    FROM
        public."ST_NAM_Stage_Name"
    WHERE
        "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_AVG_Stage_Average" (
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
        public."ST_AVG_Stage_Average"
    WHERE
        "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_NAM_Actor_Name" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_AC_ID" integer,
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
        public."AC_NAM_Actor_Name"
    WHERE
        "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_PLV_Actor_ProfessionalLevel" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_AC_ID" integer,
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
        public."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_LEN_Program_Length" (
    changingTimepoint date
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_PR_ID" integer,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
    SELECT
        "Metadata_PR_LEN",
        "PR_LEN_PR_ID",
        "PR_LEN_Program_Length",
        "PR_LEN_ChangedAt"
    FROM
        public."PR_LEN_Program_Length"
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
CREATE OR REPLACE VIEW public."lST_Stage" (
    "ST_ID",
    "Metadata_ST",
    "ST_NAM_ST_ID",
    "Metadata_ST_NAM",
    "ST_NAM_ChangedAt",
    "ST_NAM_Stage_Name",
    "ST_LOC_ST_ID",
    "Metadata_ST_LOC",
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
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
    public."ST_Stage" "ST"
LEFT JOIN
    public."ST_NAM_Stage_Name" "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            public."ST_NAM_Stage_Name" sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_AVG_Stage_Average" "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            public."ST_AVG_Stage_Average" sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
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
    public."ST_Stage" "ST"
LEFT JOIN
    public."rST_NAM_Stage_Name"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            public."rST_NAM_Stage_Name"(changingTimepoint::timestamp) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."rST_AVG_Stage_Average"(changingTimepoint::timestamp) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            public."rST_AVG_Stage_Average"(changingTimepoint::timestamp) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_Stage"
AS
SELECT
    *
FROM
    public."pST_Stage"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_Stage" (
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
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
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
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
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
        public."ST_NAM_Stage_Name" h
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
        public."ST_AVG_Stage_Average" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."ST_Stage" "ST"
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
        public."ST_NAM_Stage_Name" h
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
    public."ST_LOC_Stage_Location" "LOC"
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
        public."ST_AVG_Stage_Average" h
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
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_Actor" (
    "AC_ID",
    "Metadata_AC",
    "AC_NAM_AC_ID",
    "Metadata_AC_NAM",
    "AC_NAM_ChangedAt",
    "AC_NAM_Actor_Name",
    "AC_GEN_AC_ID",
    "Metadata_AC_GEN",
    "AC_GEN_GEN_Gender",
    "AC_GEN_Metadata_GEN",
    "AC_GEN_GEN_ID",
    "AC_PLV_AC_ID",
    "Metadata_AC_PLV",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_Checksum",
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
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN
    public."AC_NAM_Actor_Name" "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            public."AC_NAM_Actor_Name" sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    public."AC_PLV_Actor_ProfessionalLevel" "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            public."AC_PLV_Actor_ProfessionalLevel" sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" integer,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" integer,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" integer,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" integer,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
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
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN
    public."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            public."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_Actor"
AS
SELECT
    *
FROM
    public."pAC_Actor"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_Actor" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "AC_ID" integer,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" integer,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" integer,
    "Metadata_AC_GEN" integer,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" integer,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PLV_Checksum" bytea,
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
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM (
    SELECT DISTINCT
        h."AC_NAM_AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."AC_NAM_Actor_Name" h
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
        public."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."AC_Actor" "AC"
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
        public."AC_NAM_Actor_Name" h
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
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
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
        public."AC_PLV_Actor_ProfessionalLevel" h
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
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_Program" (
    "PR_ID",
    "Metadata_PR",
    "PR_NAM_PR_ID",
    "Metadata_PR_NAM",
    "PR_NAM_Program_Name",
    "PR_LEN_PR_ID",
    "Metadata_PR_LEN",
    "PR_LEN_ChangedAt",
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
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    public."PR_LEN_Program_Length" "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            public."PR_LEN_Program_Length" sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" integer,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" integer,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" integer,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
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
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    public."rPR_LEN_Program_Length"(changingTimepoint::date) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            public."rPR_LEN_Program_Length"(changingTimepoint::date) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_Program"
AS
SELECT
    *
FROM
    public."pPR_Program"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dPR_Program" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "PR_ID" integer,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" integer,
    "Metadata_PR_NAM" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" integer,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ChangedAt" date,
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
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        h."PR_LEN_PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public."PR_LEN_Program_Length" h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
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
        public."PR_LEN_Program_Length" h
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
CREATE OR REPLACE VIEW public."lEV_Event" (
    "EV_ID",
    "Metadata_EV",
    "ST_ID_wasHeldAt",
    "PR_ID_wasPlayed",
    "of_ETY_EventType",
    "of_Metadata_ETY",
    "ETY_ID_of",
    "EV_DAT_EV_ID",
    "Metadata_EV_DAT",
    "EV_DAT_Event_Date",
    "EV_AUD_EV_ID",
    "Metadata_EV_AUD",
    "EV_AUD_Event_Audience",
    "EV_REV_EV_ID",
    "Metadata_EV_REV",
    "EV_REV_Event_Revenue"
)
AS
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."ETY_EventType" "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    public."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_AUD_Event_Audience" "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_REV_Event_Revenue" "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" integer,
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" integer,
    "Metadata_EV_DAT" integer,
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" integer,
    "Metadata_EV_AUD" integer,
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" integer,
    "Metadata_EV_REV" integer,
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "ETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "ETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."ETY_EventType" "ETY_of"
ON
    "ETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN
    public."EV_DAT_Event_Date" "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_AUD_Event_Audience" "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_REV_Event_Revenue" "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    *
FROM
    public."pEV_Event"(current_timestamp::timestamp)
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" (
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt",
    "AC_ID_partner",
    "AC_ID_with",
    "currently_ONG_Ongoing",
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
            public."AC_partner_AC_with_ONG_currently" t
    ) tie
LEFT JOIN
    public."ONG_Ongoing" "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
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
            public."AC_partner_AC_with_ONG_currently" t
        WHERE
            t."AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    public."ONG_Ongoing" "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_partner"
AND
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" = tie."latestAC_ID_with"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    public."pAC_partner_AC_with_ONG_currently"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
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
    "ONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    tie."ONG_ID_currently"
FROM
    public."AC_partner_AC_with_ONG_currently" tie
LEFT JOIN
    public."ONG_Ongoing" "ONG_currently"
ON
    "ONG_currently"."ONG_ID" = tie."ONG_ID_currently"
WHERE
    tie."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_subset_PN_of" (
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
    public."AC_subset_PN_of" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_subset_PN_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" integer,
    "PN_ID_of" integer
)
AS
$$
SELECT
    tie."Metadata_AC_subset_PN_of",
    tie."AC_ID_subset",
    tie."PN_ID_of"
FROM
    public."AC_subset_PN_of" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" AS
SELECT
    *
FROM
    public."pAC_subset_PN_of"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" (
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
    public."EV_in_AC_wasCast" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_in_AC_wasCast" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" integer,
    "AC_ID_wasCast" integer
)
AS
$$
SELECT
    tie."Metadata_EV_in_AC_wasCast",
    tie."EV_ID_in",
    tie."AC_ID_wasCast"
FROM
    public."EV_in_AC_wasCast" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" AS
SELECT
    *
FROM
    public."pEV_in_AC_wasCast"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" (
    "Metadata_AC_part_PR_in_RAT_got",
    "AC_part_PR_in_RAT_got_ChangedAt",
    "AC_ID_part",
    "PR_ID_in",
    "got_RAT_Rating",
    "got_Metadata_RAT",
    "RAT_ID_got"
)
AS
SELECT
    tie."Metadata_AC_part_PR_in_RAT_got",
    tie."AC_part_PR_in_RAT_got_ChangedAt",
    tie."AC_ID_part",
    tie."PR_ID_in",
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
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
            public."AC_part_PR_in_RAT_got" t
    ) tie
LEFT JOIN
    public."RAT_Rating" "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
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
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
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
            public."AC_part_PR_in_RAT_got" t
        WHERE
            t."AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    public."RAT_Rating" "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_part_PR_in_RAT_got" AS
SELECT
    *
FROM
    public."pAC_part_PR_in_RAT_got"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
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
    "RAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "RAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    tie."RAT_ID_got"
FROM
    public."AC_part_PR_in_RAT_got" tie
LEFT JOIN
    public."RAT_Rating" "RAT_got"
ON
    "RAT_got"."RAT_ID" = tie."RAT_ID_got"
WHERE
    tie."AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_at_PR_isPlaying" (
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
            public."ST_at_PR_isPlaying" t
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_at_PR_isPlaying" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer
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
            public."ST_at_PR_isPlaying" t
        WHERE
            t."ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" AS
SELECT
    *
FROM
    public."pST_at_PR_isPlaying"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_at_PR_isPlaying" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer
)
AS
$$
SELECT
    tie."Metadata_ST_at_PR_isPlaying",
    tie."ST_at_PR_isPlaying_ChangedAt",
    tie."ST_ID_at",
    tie."PR_ID_isPlaying"
FROM
    public."ST_at_PR_isPlaying" tie
WHERE
    tie."ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" (
    "Metadata_AC_parent_AC_child_PAT_having",
    "AC_ID_parent",
    "AC_ID_child",
    "having_PAT_ParentalType",
    "having_Metadata_PAT",
    "PAT_ID_having"
)
AS
SELECT
    tie."Metadata_AC_parent_AC_child_PAT_having",
    tie."AC_ID_parent",
    tie."AC_ID_child",
    "PAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    public."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    public."PAT_ParentalType" "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" integer,
    "AC_ID_child" integer,
    "having_PAT_ParentalType" varchar(42),
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
    "PAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    tie."PAT_ID_having"
FROM
    public."AC_parent_AC_child_PAT_having" tie
LEFT JOIN
    public."PAT_ParentalType" "PAT_having"
ON
    "PAT_having"."PAT_ID" = tie."PAT_ID_having"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" AS
SELECT
    *
FROM
    public."pAC_parent_AC_child_PAT_having"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" (
    "Metadata_PR_content_ST_location_EV_of",
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of"
)
AS
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    public."PR_content_ST_location_EV_of" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_ID_content" integer,
    "ST_ID_location" integer,
    "EV_ID_of" integer
)
AS
$$
SELECT
    tie."Metadata_PR_content_ST_location_EV_of",
    tie."PR_ID_content",
    tie."ST_ID_location",
    tie."EV_ID_of"
FROM
    public."PR_content_ST_location_EV_of" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" AS
SELECT
    *
FROM
    public."pPR_content_ST_location_EV_of"(current_timestamp::timestamp)
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA public IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE public."PAT_ParentalType" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN public."PAT_ParentalType"."PAT_ParentalType" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE public."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON COLUMN public."GEN_Gender"."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON TABLE public."PLV_ProfessionalLevel" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN public."PLV_ProfessionalLevel"."PLV_ProfessionalLevel" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE public."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN public."UTL_Utilization"."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE public."ONG_Ongoing" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN public."ONG_Ongoing"."ONG_Ongoing" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE public."RAT_Rating" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN public."RAT_Rating"."RAT_Rating" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON TABLE public."ETY_EventType" IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public."ETY_EventType"."ETY_EventType" IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public."EV_DAT_Event_Date"."EV_DAT_Event_Date" IS 'Date and time when the event took place.';
COMMENT ON COLUMN public."EV_AUD_Event_Audience"."EV_AUD_Event_Audience" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public."EV_REV_Event_Revenue"."EV_REV_Event_Revenue" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public."ST_NAM_Stage_Name"."ST_NAM_Stage_Name" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public."ST_LOC_Stage_Location"."ST_LOC_Stage_Location" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public."ST_AVG_Stage_Average"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public."ST_MIN_Stage_Minimum"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public."AC_NAM_Actor_Name"."AC_NAM_Actor_Name" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public."AC_GEN_Actor_Gender"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN public."AC_PLV_Actor_ProfessionalLevel"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN public."PR_NAM_Program_Name"."PR_NAM_Program_Name" IS 'Name or title of the program.';
COMMENT ON COLUMN public."PR_LEN_Program_Length"."PR_LEN_Program_Length" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE public."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE public."ST_Stage" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE public."AC_Actor" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE public."PR_Program" IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE public."EV_Event" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN public."EV_Event"."ST_ID_wasHeldAt" IS 'The stage at which the event was held.';
COMMENT ON COLUMN public."EV_Event"."PR_ID_wasPlayed" IS 'The program that was played at the event.';
COMMENT ON COLUMN public."EV_Event"."ETY_ID_of" IS 'The type of the event.';
COMMENT ON TABLE public."AC_partner_AC_with_ONG_currently" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE public."AC_subset_PN_of" IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN public."AC_subset_PN_of"."AC_ID_subset" IS 'The actor.';
COMMENT ON COLUMN public."AC_subset_PN_of"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE public."EV_in_AC_wasCast" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN public."EV_in_AC_wasCast"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN public."EV_in_AC_wasCast"."AC_ID_wasCast" IS 'An actor cast in the event.';
COMMENT ON TABLE public."AC_part_PR_in_RAT_got" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got"."AC_ID_part" IS 'The actor having a part in the program.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got"."RAT_ID_got" IS 'The rating the actor got for the part.';
COMMENT ON TABLE public."ST_at_PR_isPlaying" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN public."ST_at_PR_isPlaying"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN public."ST_at_PR_isPlaying"."PR_ID_isPlaying" IS 'The program playing at the stage.';
COMMENT ON TABLE public."AC_parent_AC_child_PAT_having" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having"."AC_ID_parent" IS 'The actor who is the parent.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having"."AC_ID_child" IS 'The actor who is the child.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having"."PAT_ID_having" IS 'The type of parental relationship.';
COMMENT ON TABLE public."PR_content_ST_location_EV_of" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of"."PR_ID_content" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of"."ST_ID_location" IS 'The stage where the event was located.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of"."EV_ID_of" IS 'The event.';
