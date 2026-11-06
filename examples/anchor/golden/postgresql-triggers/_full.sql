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
-- GRD_Grade table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GRD_Grade" (
    "GRD_ID" smallint not null,
    "GRD_Grade" varchar(42) not null,
    "Metadata_GRD" integer not null,
    constraint "pkGRD_Grade" primary key (
        "GRD_ID"
    ),
    constraint "uqGRD_Grade" unique (
        "GRD_Grade"
    )
);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- SU_Subject table (with 12 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."SU_Subject_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_Subject" (
    "SU_ID" integer default nextval('public."SU_Subject_ID_SEQ"') not null, 
    "Metadata_SU" integer not null,
    constraint "pkSU_Subject" primary key (
        "SU_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- OB_Object table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."OB_Object_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."OB_Object" (
    "OB_ID" integer default nextval('public."OB_Object_ID_SEQ"') not null, 
    "Metadata_OB" integer not null,
    constraint "pkOB_Object" primary key (
        "OB_ID"
    )
);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 2 attributes and 1 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_Event_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_Event" (
    "EV_ID" integer default nextval('public."EV_Event_ID_SEQ"') not null, 
    "SU_ID_for" integer not null, 
    constraint "EV_Event_fkSU_for" foreign key (
        "SU_ID_for"
    ) references public."SU_Subject"("SU_ID"), 
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
-- EV_QTY_Event_Quantity table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_QTY_Event_Quantity" (
    "EV_QTY_EV_ID" integer not null,
    "EV_QTY_Event_Quantity" integer not null,
    "Metadata_EV_QTY" integer not null,
    constraint "fkEV_QTY_Event_Quantity" foreign key (
        "EV_QTY_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_QTY_Event_Quantity" primary key (
        "EV_QTY_EV_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_PLC_Event_Place table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_PLC_Event_Place" (
    "EV_PLC_EV_ID" integer not null,
    "EV_PLC_Event_Place" varchar(42) not null,
    "EV_PLC_ChangedAt" timestamp not null,
    "Metadata_EV_PLC" integer not null,
    constraint "fkEV_PLC_Event_Place" foreign key (
        "EV_PLC_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_PLC_Event_Place" primary key (
        "EV_PLC_EV_ID",
        "EV_PLC_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_NAM_Subject_Name" (
    "SU_NAM_SU_ID" integer not null,
    "SU_NAM_Subject_Name" varchar(42) not null,
    "Metadata_SU_NAM" integer not null,
    constraint "fkSU_NAM_Subject_Name" foreign key (
        "SU_NAM_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_NAM_Subject_Name" primary key (
        "SU_NAM_SU_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_COD_Subject_Code" (
    "SU_COD_SU_ID" integer not null,
    "SU_COD_Subject_Code" varchar(42) not null,
    "Metadata_SU_COD" integer not null,
    constraint "fkSU_COD_Subject_Code" foreign key (
        "SU_COD_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_COD_Subject_Code" primary key (
        "SU_COD_SU_ID"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_GRD_Subject_Grade" (
    "SU_GRD_SU_ID" integer not null,
    "SU_GRD_GRD_ID" smallint not null,
    "Metadata_SU_GRD" integer not null,
    constraint "fk_A_SU_GRD_Subject_Grade" foreign key (
        "SU_GRD_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "fk_K_SU_GRD_Subject_Grade" foreign key (
        "SU_GRD_GRD_ID"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_GRD_Subject_Grade" primary key (
        "SU_GRD_SU_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_NOT_Subject_Note" (
    "SU_NOT_SU_ID" integer not null,
    "SU_NOT_Subject_Note" text not null,
    "SU_NOT_Checksum" bytea generated always as (decode(md5("SU_NOT_Subject_Note"::text), 'hex')) stored,
    "Metadata_SU_NOT" integer not null,
    constraint "fkSU_NOT_Subject_Note" foreign key (
        "SU_NOT_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_NOT_Subject_Note" primary key (
        "SU_NOT_SU_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TTL_Subject_Title" (
    "SU_TTL_SU_ID" integer not null,
    "SU_TTL_Subject_Title" varchar(42) not null,
    "SU_TTL_ChangedAt" timestamp not null,
    "Metadata_SU_TTL" integer not null,
    constraint "fkSU_TTL_Subject_Title" foreign key (
        "SU_TTL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TTL_Subject_Title" primary key (
        "SU_TTL_SU_ID",
        "SU_TTL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_STA_Subject_State table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_STA_Subject_State" (
    "SU_STA_SU_ID" integer not null,
    "SU_STA_Subject_State" varchar(42) not null,
    "SU_STA_ChangedAt" timestamp not null,
    "Metadata_SU_STA" integer not null,
    constraint "fkSU_STA_Subject_State" foreign key (
        "SU_STA_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_STA_Subject_State" primary key (
        "SU_STA_SU_ID",
        "SU_STA_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_LBL_Subject_Label" (
    "SU_LBL_SU_ID" integer not null,
    "SU_LBL_Subject_Label" varchar(42) not null,
    "SU_LBL_ChangedAt" timestamp not null,
    "Metadata_SU_LBL" integer not null,
    constraint "fkSU_LBL_Subject_Label" foreign key (
        "SU_LBL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_LBL_Subject_Label" primary key (
        "SU_LBL_SU_ID",
        "SU_LBL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TAG_Subject_Tag" (
    "SU_TAG_SU_ID" integer not null,
    "SU_TAG_Subject_Tag" varchar(42) not null,
    "SU_TAG_ChangedAt" timestamp not null,
    "Metadata_SU_TAG" integer not null,
    constraint "fkSU_TAG_Subject_Tag" foreign key (
        "SU_TAG_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TAG_Subject_Tag" primary key (
        "SU_TAG_SU_ID",
        "SU_TAG_ChangedAt"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- SU_LVL_Subject_Level table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_LVL_Subject_Level" (
    "SU_LVL_SU_ID" integer not null,
    "SU_LVL_GRD_ID" smallint not null,
    "SU_LVL_ChangedAt" timestamp not null,
    "Metadata_SU_LVL" integer not null,
    constraint "fk_A_SU_LVL_Subject_Level" foreign key (
        "SU_LVL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "fk_K_SU_LVL_Subject_Level" foreign key (
        "SU_LVL_GRD_ID"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_LVL_Subject_Level" primary key (
        "SU_LVL_SU_ID",
        "SU_LVL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TXT_Subject_Text" (
    "SU_TXT_SU_ID" integer not null,
    "SU_TXT_Subject_Text" text not null,
    "SU_TXT_Checksum" bytea generated always as (decode(md5("SU_TXT_Subject_Text"::text), 'hex')) stored,
    "SU_TXT_ChangedAt" timestamp not null,
    "Metadata_SU_TXT" integer not null,
    constraint "fkSU_TXT_Subject_Text" foreign key (
        "SU_TXT_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TXT_Subject_Text" primary key (
        "SU_TXT_SU_ID",
        "SU_TXT_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_ASR_Subject_Assessment" (
    "SU_ASR_SU_ID" integer not null,
    "SU_ASR_Subject_Assessment" varchar(42) not null,
    "SU_ASR_ChangedAt" timestamp not null,
    "Metadata_SU_ASR" integer not null,
    constraint "fkSU_ASR_Subject_Assessment" foreign key (
        "SU_ASR_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_ASR_Subject_Assessment" primary key (
        "SU_ASR_SU_ID",
        "SU_ASR_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_ERS_Subject_Erasable" (
    "SU_ERS_SU_ID" integer not null,
    "SU_ERS_Subject_Erasable" varchar(42) not null,
    "SU_ERS_ChangedAt" timestamp not null,
    "Metadata_SU_ERS" integer not null,
    constraint "fkSU_ERS_Subject_Erasable" foreign key (
        "SU_ERS_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_ERS_Subject_Erasable" primary key (
        "SU_ERS_SU_ID",
        "SU_ERS_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."OB_NAM_Object_Name" (
    "OB_NAM_OB_ID" integer not null,
    "OB_NAM_Object_Name" varchar(42) not null,
    "Metadata_OB_NAM" integer not null,
    constraint "fkOB_NAM_Object_Name" foreign key (
        "OB_NAM_OB_ID"
    ) references public."OB_Object"("OB_ID"),
    constraint "pkOB_NAM_Object_Name" primary key (
        "OB_NAM_OB_ID"
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
-- SU_holder_OB_item_GRD_grade table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade" (
    "SU_ID_holder" integer not null, 
    "OB_ID_item" integer not null, 
    "GRD_ID_grade" smallint not null,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp not null,
    "Metadata_SU_holder_OB_item_GRD_grade" integer not null,
    constraint "SU_holder_OB_item_GRD_grade_fkSU_holder" foreign key (
        "SU_ID_holder"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_fkOB_item" foreign key (
        "OB_ID_item"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_fkGRD_grade" foreign key (
        "GRD_ID_grade"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_holder_OB_item_GRD_grade" primary key (
        "SU_ID_holder",
        "OB_ID_item",
        "SU_holder_OB_item_GRD_grade_ChangedAt"
    )
);
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank" (
    "SU_ID_keeper" integer not null, 
    "OB_ID_thing" integer not null, 
    "GRD_ID_rank" smallint not null,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp not null,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer not null,
    constraint "SU_keeper_OB_thing_GRD_rank_fkSU_keeper" foreign key (
        "SU_ID_keeper"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_fkOB_thing" foreign key (
        "OB_ID_thing"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_fkGRD_rank" foreign key (
        "GRD_ID_rank"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_keeper_OB_thing_GRD_rank" primary key (
        "SU_ID_keeper",
        "OB_ID_thing",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt"
    )
);
-- Static tie table ---------------------------------------------------------------------------------------------------
-- OB_part_SU_owner table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."OB_part_SU_owner" (
    "OB_ID_part" integer not null, 
    "SU_ID_owner" integer not null, 
    "Metadata_OB_part_SU_owner" integer not null,
    constraint "OB_part_SU_owner_fkOB_part" foreign key (
        "OB_ID_part"
    ) references public."OB_Object"("OB_ID"), 
    constraint "OB_part_SU_owner_fkSU_owner" foreign key (
        "SU_ID_owner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "pkOB_part_SU_owner" primary key (
        "OB_ID_part"
    )
);
-- Historized tie table -----------------------------------------------------------------------------------------------
-- SU_partner_SU_with table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_partner_SU_with" (
    "SU_ID_partner" integer not null, 
    "SU_ID_with" integer not null, 
    "SU_partner_SU_with_ChangedAt" timestamp not null,
    "Metadata_SU_partner_SU_with" integer not null,
    constraint "SU_partner_SU_with_fkSU_partner" foreign key (
        "SU_ID_partner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_fkSU_with" foreign key (
        "SU_ID_with"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_uqSU_partner" unique (
        "SU_ID_partner",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "SU_partner_SU_with_uqSU_with" unique (
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "pkSU_partner_SU_with" primary key (
        "SU_ID_partner",
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt"
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
-- rEV_PLC_Event_Place rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_EV_PLC",
        "EV_PLC_EV_ID",
        "EV_PLC_Event_Place",
        "EV_PLC_ChangedAt"
    FROM
        public."EV_PLC_Event_Place"
    WHERE
        "EV_PLC_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_TTL",
        "SU_TTL_SU_ID",
        "SU_TTL_Subject_Title",
        "SU_TTL_ChangedAt"
    FROM
        public."SU_TTL_Subject_Title"
    WHERE
        "SU_TTL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_STA",
        "SU_STA_SU_ID",
        "SU_STA_Subject_State",
        "SU_STA_ChangedAt"
    FROM
        public."SU_STA_Subject_State"
    WHERE
        "SU_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_LBL",
        "SU_LBL_SU_ID",
        "SU_LBL_Subject_Label",
        "SU_LBL_ChangedAt"
    FROM
        public."SU_LBL_Subject_Label"
    WHERE
        "SU_LBL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_TAG",
        "SU_TAG_SU_ID",
        "SU_TAG_Subject_Tag",
        "SU_TAG_ChangedAt"
    FROM
        public."SU_TAG_Subject_Tag"
    WHERE
        "SU_TAG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_LVL",
        "SU_LVL_SU_ID",
        "SU_LVL_GRD_ID",
        "SU_LVL_ChangedAt"
    FROM
        public."SU_LVL_Subject_Level"
    WHERE
        "SU_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_TXT",
        "SU_TXT_SU_ID",
        "SU_TXT_Checksum",
        "SU_TXT_Subject_Text",
        "SU_TXT_ChangedAt"
    FROM
        public."SU_TXT_Subject_Text"
    WHERE
        "SU_TXT_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_ASR",
        "SU_ASR_SU_ID",
        "SU_ASR_Subject_Assessment",
        "SU_ASR_ChangedAt"
    FROM
        public."SU_ASR_Subject_Assessment"
    WHERE
        "SU_ASR_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
    SELECT
        "Metadata_SU_ERS",
        "SU_ERS_SU_ID",
        "SU_ERS_Subject_Erasable",
        "SU_ERS_ChangedAt"
    FROM
        public."SU_ERS_Subject_Erasable"
    WHERE
        "SU_ERS_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_Subject" (
    "SU_ID",
    "Metadata_SU",
    "SU_NAM_SU_ID",
    "Metadata_SU_NAM",
    "Deletable_SU_NAM",
    "SU_NAM_Subject_Name",
    "SU_COD_SU_ID",
    "Metadata_SU_COD",
    "SU_COD_Subject_Code",
    "SU_GRD_SU_ID",
    "Metadata_SU_GRD",
    "SU_GRD_GRD_Grade",
    "SU_GRD_Metadata_GRD",
    "SU_GRD_GRD_ID",
    "SU_NOT_SU_ID",
    "Metadata_SU_NOT",
    "SU_NOT_Checksum",
    "SU_NOT_Subject_Note",
    "SU_TTL_SU_ID",
    "Metadata_SU_TTL",
    "SU_TTL_ChangedAt",
    "SU_TTL_Subject_Title",
    "SU_STA_SU_ID",
    "Metadata_SU_STA",
    "SU_STA_ChangedAt",
    "SU_STA_Subject_State",
    "SU_LBL_SU_ID",
    "Metadata_SU_LBL",
    "SU_LBL_ChangedAt",
    "SU_LBL_Subject_Label",
    "SU_TAG_SU_ID",
    "Metadata_SU_TAG",
    "SU_TAG_ChangedAt",
    "SU_TAG_Subject_Tag",
    "SU_LVL_SU_ID",
    "Metadata_SU_LVL",
    "Deletable_SU_LVL",
    "SU_LVL_ChangedAt",
    "SU_LVL_GRD_Grade",
    "SU_LVL_Metadata_GRD",
    "SU_LVL_GRD_ID",
    "SU_TXT_SU_ID",
    "Metadata_SU_TXT",
    "SU_TXT_ChangedAt",
    "SU_TXT_Checksum",
    "SU_TXT_Subject_Text",
    "SU_ASR_SU_ID",
    "Metadata_SU_ASR",
    "SU_ASR_ChangedAt",
    "SU_ASR_Subject_Assessment",
    "SU_ERS_SU_ID",
    "Metadata_SU_ERS",
    "Deletable_SU_ERS",
    "SU_ERS_ChangedAt",
    "SU_ERS_Subject_Erasable"
)
AS
SELECT
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    NULL::boolean,
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    NULL::boolean,
    "LVL"."SU_LVL_ChangedAt",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    NULL::boolean,
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_Subject_Erasable"
FROM
    public."SU_Subject" "SU"
LEFT JOIN
    public."SU_NAM_Subject_Name" "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_COD_Subject_Code" "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_GRD_Subject_Grade" "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN
    public."SU_NOT_Subject_Note" "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_TTL_Subject_Title" "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" = (
        SELECT
            max(sub."SU_TTL_ChangedAt")
        FROM
            public."SU_TTL_Subject_Title" sub
        WHERE
            sub."SU_TTL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_STA_Subject_State" "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" = (
        SELECT
            max(sub."SU_STA_ChangedAt")
        FROM
            public."SU_STA_Subject_State" sub
        WHERE
            sub."SU_STA_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_LBL_Subject_Label" "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" = (
        SELECT
            max(sub."SU_LBL_ChangedAt")
        FROM
            public."SU_LBL_Subject_Label" sub
        WHERE
            sub."SU_LBL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_TAG_Subject_Tag" "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" = (
        SELECT
            max(sub."SU_TAG_ChangedAt")
        FROM
            public."SU_TAG_Subject_Tag" sub
        WHERE
            sub."SU_TAG_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_LVL_Subject_Level" "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" = (
        SELECT
            max(sub."SU_LVL_ChangedAt")
        FROM
            public."SU_LVL_Subject_Level" sub
        WHERE
            sub."SU_LVL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN
    public."SU_TXT_Subject_Text" "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" = (
        SELECT
            max(sub."SU_TXT_ChangedAt")
        FROM
            public."SU_TXT_Subject_Text" sub
        WHERE
            sub."SU_TXT_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_ASR_Subject_Assessment" "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" = (
        SELECT
            max(sub."SU_ASR_ChangedAt")
        FROM
            public."SU_ASR_Subject_Assessment" sub
        WHERE
            sub."SU_ASR_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."SU_ERS_Subject_Erasable" "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" = (
        SELECT
            max(sub."SU_ERS_ChangedAt")
        FROM
            public."SU_ERS_Subject_Erasable" sub
        WHERE
            sub."SU_ERS_SU_ID" = "SU"."SU_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_Subject" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
SELECT
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ChangedAt",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_Subject_Erasable"
FROM
    public."SU_Subject" "SU"
LEFT JOIN
    public."SU_NAM_Subject_Name" "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_COD_Subject_Code" "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_GRD_Subject_Grade" "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN
    public."SU_NOT_Subject_Note" "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."rSU_TTL_Subject_Title"(changingTimepoint::timestamp) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" = (
        SELECT
            max(sub."SU_TTL_ChangedAt")
        FROM
            public."rSU_TTL_Subject_Title"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_TTL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_STA_Subject_State"(changingTimepoint::timestamp) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" = (
        SELECT
            max(sub."SU_STA_ChangedAt")
        FROM
            public."rSU_STA_Subject_State"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_STA_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_LBL_Subject_Label"(changingTimepoint::timestamp) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" = (
        SELECT
            max(sub."SU_LBL_ChangedAt")
        FROM
            public."rSU_LBL_Subject_Label"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_LBL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_TAG_Subject_Tag"(changingTimepoint::timestamp) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" = (
        SELECT
            max(sub."SU_TAG_ChangedAt")
        FROM
            public."rSU_TAG_Subject_Tag"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_TAG_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_LVL_Subject_Level"(changingTimepoint::timestamp) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" = (
        SELECT
            max(sub."SU_LVL_ChangedAt")
        FROM
            public."rSU_LVL_Subject_Level"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_LVL_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN
    public."rSU_TXT_Subject_Text"(changingTimepoint::timestamp) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" = (
        SELECT
            max(sub."SU_TXT_ChangedAt")
        FROM
            public."rSU_TXT_Subject_Text"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_TXT_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_ASR_Subject_Assessment"(changingTimepoint::timestamp) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" = (
        SELECT
            max(sub."SU_ASR_ChangedAt")
        FROM
            public."rSU_ASR_Subject_Assessment"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_ASR_SU_ID" = "SU"."SU_ID"
   )
LEFT JOIN
    public."rSU_ERS_Subject_Erasable"(changingTimepoint::timestamp) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" = (
        SELECT
            max(sub."SU_ERS_ChangedAt")
        FROM
            public."rSU_ERS_Subject_Erasable"(changingTimepoint::timestamp) sub
        WHERE
            sub."SU_ERS_SU_ID" = "SU"."SU_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_Subject"
AS
SELECT
    *
FROM
    public."pSU_Subject"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_Subject" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ChangedAt",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_Subject_Erasable"
FROM (
    SELECT DISTINCT
        h."SU_TTL_SU_ID" AS "SU_ID",
        h."SU_TTL_ChangedAt"::timestamp AS inspectedTimepoint,
        'TTL' AS mnemonic
    FROM
        public."SU_TTL_Subject_Title" h
    WHERE
        (selection IS NULL OR selection LIKE '%TTL%')
    AND
        h."SU_TTL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_STA_SU_ID" AS "SU_ID",
        h."SU_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        public."SU_STA_Subject_State" h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h."SU_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_LBL_SU_ID" AS "SU_ID",
        h."SU_LBL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LBL' AS mnemonic
    FROM
        public."SU_LBL_Subject_Label" h
    WHERE
        (selection IS NULL OR selection LIKE '%LBL%')
    AND
        h."SU_LBL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_TAG_SU_ID" AS "SU_ID",
        h."SU_TAG_ChangedAt"::timestamp AS inspectedTimepoint,
        'TAG' AS mnemonic
    FROM
        public."SU_TAG_Subject_Tag" h
    WHERE
        (selection IS NULL OR selection LIKE '%TAG%')
    AND
        h."SU_TAG_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_LVL_SU_ID" AS "SU_ID",
        h."SU_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        public."SU_LVL_Subject_Level" h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h."SU_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_TXT_SU_ID" AS "SU_ID",
        h."SU_TXT_ChangedAt"::timestamp AS inspectedTimepoint,
        'TXT' AS mnemonic
    FROM
        public."SU_TXT_Subject_Text" h
    WHERE
        (selection IS NULL OR selection LIKE '%TXT%')
    AND
        h."SU_TXT_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_ASR_SU_ID" AS "SU_ID",
        h."SU_ASR_ChangedAt"::timestamp AS inspectedTimepoint,
        'ASR' AS mnemonic
    FROM
        public."SU_ASR_Subject_Assessment" h
    WHERE
        (selection IS NULL OR selection LIKE '%ASR%')
    AND
        h."SU_ASR_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."SU_ERS_SU_ID" AS "SU_ID",
        h."SU_ERS_ChangedAt"::timestamp AS inspectedTimepoint,
        'ERS' AS mnemonic
    FROM
        public."SU_ERS_Subject_Erasable" h
    WHERE
        (selection IS NULL OR selection LIKE '%ERS%')
    AND
        h."SU_ERS_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."SU_Subject" "SU"
ON
    "SU"."SU_ID" = timepoints."SU_ID"
LEFT JOIN
    public."SU_NAM_Subject_Name" "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_COD_Subject_Code" "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."SU_GRD_Subject_Grade" "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN
    public."SU_NOT_Subject_Note" "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_TTL_ChangedAt") OVER (
            PARTITION BY h."SU_TTL_SU_ID"
            ORDER BY h."SU_TTL_ChangedAt"
        ) AS "until"
    FROM
        public."SU_TTL_Subject_Title" h
) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TTL"."until" IS NULL
OR
    "TTL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_STA_ChangedAt") OVER (
            PARTITION BY h."SU_STA_SU_ID"
            ORDER BY h."SU_STA_ChangedAt"
        ) AS "until"
    FROM
        public."SU_STA_Subject_State" h
) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_LBL_ChangedAt") OVER (
            PARTITION BY h."SU_LBL_SU_ID"
            ORDER BY h."SU_LBL_ChangedAt"
        ) AS "until"
    FROM
        public."SU_LBL_Subject_Label" h
) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "LBL"."until" IS NULL
OR
    "LBL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_TAG_ChangedAt") OVER (
            PARTITION BY h."SU_TAG_SU_ID"
            ORDER BY h."SU_TAG_ChangedAt"
        ) AS "until"
    FROM
        public."SU_TAG_Subject_Tag" h
) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TAG"."until" IS NULL
OR
    "TAG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_LVL_ChangedAt") OVER (
            PARTITION BY h."SU_LVL_SU_ID"
            ORDER BY h."SU_LVL_ChangedAt"
        ) AS "until"
    FROM
        public."SU_LVL_Subject_Level" h
) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_TXT_ChangedAt") OVER (
            PARTITION BY h."SU_TXT_SU_ID"
            ORDER BY h."SU_TXT_ChangedAt"
        ) AS "until"
    FROM
        public."SU_TXT_Subject_Text" h
) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TXT"."until" IS NULL
OR
    "TXT"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_ASR_ChangedAt") OVER (
            PARTITION BY h."SU_ASR_SU_ID"
            ORDER BY h."SU_ASR_ChangedAt"
        ) AS "until"
    FROM
        public."SU_ASR_Subject_Assessment" h
) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "ASR"."until" IS NULL
OR
    "ASR"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        h.*,
        lead(h."SU_ERS_ChangedAt") OVER (
            PARTITION BY h."SU_ERS_SU_ID"
            ORDER BY h."SU_ERS_ChangedAt"
        ) AS "until"
    FROM
        public."SU_ERS_Subject_Erasable" h
) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "ERS"."until" IS NULL
OR
    "ERS"."until" > timepoints.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lOB_Object" (
    "OB_ID",
    "Metadata_OB",
    "OB_NAM_OB_ID",
    "Metadata_OB_NAM",
    "OB_NAM_Object_Name"
)
AS
SELECT
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "NAM"."OB_NAM_OB_ID",
    "NAM"."Metadata_OB_NAM",
    "NAM"."OB_NAM_Object_Name"
FROM
    public."OB_Object" "OB"
LEFT JOIN
    public."OB_NAM_Object_Name" "NAM"
ON
    "NAM"."OB_NAM_OB_ID" = "OB"."OB_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pOB_Object" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "OB_ID" integer,
    "Metadata_OB" integer,
    "OB_NAM_OB_ID" integer,
    "Metadata_OB_NAM" integer,
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "NAM"."OB_NAM_OB_ID",
    "NAM"."Metadata_OB_NAM",
    "NAM"."OB_NAM_Object_Name"
FROM
    public."OB_Object" "OB"
LEFT JOIN
    public."OB_NAM_Object_Name" "NAM"
ON
    "NAM"."OB_NAM_OB_ID" = "OB"."OB_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nOB_Object"
AS
SELECT
    *
FROM
    public."pOB_Object"(current_timestamp::timestamp)
;
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
    "SU_ID_for",
    "EV_QTY_EV_ID",
    "Metadata_EV_QTY",
    "Deletable_EV_QTY",
    "EV_QTY_Event_Quantity",
    "EV_PLC_EV_ID",
    "Metadata_EV_PLC",
    "Deletable_EV_PLC",
    "EV_PLC_ChangedAt",
    "EV_PLC_Event_Place"
)
AS
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    NULL::boolean,
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    NULL::boolean,
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."EV_QTY_Event_Quantity" "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."EV_PLC_Event_Place" "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" = (
        SELECT
            max(sub."EV_PLC_ChangedAt")
        FROM
            public."EV_PLC_Event_Place" sub
        WHERE
            sub."EV_PLC_EV_ID" = "EV"."EV_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
LEFT JOIN
    public."EV_QTY_Event_Quantity" "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    public."rEV_PLC_Event_Place"(changingTimepoint::timestamp) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" = (
        SELECT
            max(sub."EV_PLC_ChangedAt")
        FROM
            public."rEV_PLC_Event_Place"(changingTimepoint::timestamp) sub
        WHERE
            sub."EV_PLC_EV_ID" = "EV"."EV_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    *
FROM
    public."pEV_Event"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_Event_Place" varchar(42)
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
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_Event_Place"
FROM (
    SELECT DISTINCT
        h."EV_PLC_EV_ID" AS "EV_ID",
        h."EV_PLC_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        public."EV_PLC_Event_Place" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLC%')
    AND
        h."EV_PLC_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    public."EV_QTY_Event_Quantity" "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."EV_PLC_ChangedAt") OVER (
            PARTITION BY h."EV_PLC_EV_ID"
            ORDER BY h."EV_PLC_ChangedAt"
        ) AS "until"
    FROM
        public."EV_PLC_Event_Place" h
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLC"."until" IS NULL
OR
    "PLC"."until" > timepoints.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_holder_OB_item_GRD_grade" (
    "Metadata_SU_holder_OB_item_GRD_grade",
    "Deletable_SU_holder_OB_item_GRD_grade",
    "SU_holder_OB_item_GRD_grade_ChangedAt",
    "SU_ID_holder",
    "OB_ID_item",
    "grade_GRD_Grade",
    "grade_Metadata_GRD",
    "GRD_ID_grade"
)
AS
SELECT
    tie."Metadata_SU_holder_OB_item_GRD_grade",
    NULL::boolean,
    tie."SU_holder_OB_item_GRD_grade_ChangedAt",
    tie."SU_ID_holder",
    tie."OB_ID_item",
    "GRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "GRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    tie."GRD_ID_grade"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_holder_OB_item_GRD_grade_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_holder",
                    t."OB_ID_item"
            ) AS "latest"
        FROM
            public."SU_holder_OB_item_GRD_grade" t
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_grade"
ON
    "GRD_grade"."GRD_ID" = tie."GRD_ID_grade"
WHERE
    tie."SU_holder_OB_item_GRD_grade_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_holder_OB_item_GRD_grade",
    tie."SU_holder_OB_item_GRD_grade_ChangedAt",
    tie."SU_ID_holder",
    tie."OB_ID_item",
    "GRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "GRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    tie."GRD_ID_grade"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_holder_OB_item_GRD_grade_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_holder",
                    t."OB_ID_item"
            ) AS "latest"
        FROM
            public."SU_holder_OB_item_GRD_grade" t
        WHERE
            t."SU_holder_OB_item_GRD_grade_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_grade"
ON
    "GRD_grade"."GRD_ID" = tie."GRD_ID_grade"
WHERE
    tie."SU_holder_OB_item_GRD_grade_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_holder_OB_item_GRD_grade" AS
SELECT
    *
FROM
    public."pSU_holder_OB_item_GRD_grade"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_holder_OB_item_GRD_grade" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_holder_OB_item_GRD_grade",
    tie."SU_holder_OB_item_GRD_grade_ChangedAt",
    tie."SU_ID_holder",
    tie."OB_ID_item",
    "GRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "GRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    tie."GRD_ID_grade"
FROM
    public."SU_holder_OB_item_GRD_grade" tie
LEFT JOIN
    public."GRD_Grade" "GRD_grade"
ON
    "GRD_grade"."GRD_ID" = tie."GRD_ID_grade"
WHERE
    tie."SU_holder_OB_item_GRD_grade_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_keeper_OB_thing_GRD_rank" (
    "Metadata_SU_keeper_OB_thing_GRD_rank",
    "SU_keeper_OB_thing_GRD_rank_ChangedAt",
    "SU_ID_keeper",
    "OB_ID_thing",
    "rank_GRD_Grade",
    "rank_Metadata_GRD",
    "GRD_ID_rank"
)
AS
SELECT
    tie."Metadata_SU_keeper_OB_thing_GRD_rank",
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    tie."SU_ID_keeper",
    tie."OB_ID_thing",
    "GRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "GRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    tie."GRD_ID_rank"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_keeper_OB_thing_GRD_rank_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_keeper",
                    t."OB_ID_thing"
            ) AS "latest"
        FROM
            public."SU_keeper_OB_thing_GRD_rank" t
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_rank"
ON
    "GRD_rank"."GRD_ID" = tie."GRD_ID_rank"
WHERE
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_keeper_OB_thing_GRD_rank",
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    tie."SU_ID_keeper",
    tie."OB_ID_thing",
    "GRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "GRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    tie."GRD_ID_rank"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_keeper_OB_thing_GRD_rank_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_keeper",
                    t."OB_ID_thing"
            ) AS "latest"
        FROM
            public."SU_keeper_OB_thing_GRD_rank" t
        WHERE
            t."SU_keeper_OB_thing_GRD_rank_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_rank"
ON
    "GRD_rank"."GRD_ID" = tie."GRD_ID_rank"
WHERE
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_keeper_OB_thing_GRD_rank" AS
SELECT
    *
FROM
    public."pSU_keeper_OB_thing_GRD_rank"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_keeper_OB_thing_GRD_rank" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_keeper_OB_thing_GRD_rank",
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    tie."SU_ID_keeper",
    tie."OB_ID_thing",
    "GRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "GRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    tie."GRD_ID_rank"
FROM
    public."SU_keeper_OB_thing_GRD_rank" tie
LEFT JOIN
    public."GRD_Grade" "GRD_rank"
ON
    "GRD_rank"."GRD_ID" = tie."GRD_ID_rank"
WHERE
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lOB_part_SU_owner" (
    "Metadata_OB_part_SU_owner",
    "Deletable_OB_part_SU_owner",
    "OB_ID_part",
    "SU_ID_owner"
)
AS
SELECT
    tie."Metadata_OB_part_SU_owner",
    NULL::boolean,
    tie."OB_ID_part",
    tie."SU_ID_owner"
FROM
    public."OB_part_SU_owner" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pOB_part_SU_owner" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_ID_part" integer,
    "SU_ID_owner" integer
)
AS
$$
SELECT
    tie."Metadata_OB_part_SU_owner",
    tie."OB_ID_part",
    tie."SU_ID_owner"
FROM
    public."OB_part_SU_owner" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nOB_part_SU_owner" AS
SELECT
    *
FROM
    public."pOB_part_SU_owner"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_partner_SU_with" (
    "Metadata_SU_partner_SU_with",
    "SU_partner_SU_with_ChangedAt",
    "SU_ID_partner",
    "SU_ID_with"
)
AS
SELECT
    tie."Metadata_SU_partner_SU_with",
    tie."SU_partner_SU_with_ChangedAt",
    tie."SU_ID_partner",
    tie."SU_ID_with"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_partner") AS "latestSU_ID_partner",
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_with") AS "latestSU_ID_with"
        FROM
            public."SU_partner_SU_with" t
    ) tie
WHERE
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_partner"
AND
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_with"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_partner_SU_with" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    tie."Metadata_SU_partner_SU_with",
    tie."SU_partner_SU_with_ChangedAt",
    tie."SU_ID_partner",
    tie."SU_ID_with"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_partner") AS "latestSU_ID_partner",
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_with") AS "latestSU_ID_with"
        FROM
            public."SU_partner_SU_with" t
        WHERE
            t."SU_partner_SU_with_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_partner"
AND
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_with"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_partner_SU_with" AS
SELECT
    *
FROM
    public."pSU_partner_SU_with"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_partner_SU_with" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    tie."Metadata_SU_partner_SU_with",
    tie."SU_partner_SU_with_ChangedAt",
    tie."SU_ID_partner",
    tie."SU_ID_with"
FROM
    public."SU_partner_SU_with" tie
WHERE
    tie."SU_partner_SU_with_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attribute tables make them behave as the model says: a row that is already there is
-- not stored again, another value at a time that has a value is a contradiction, and a value that is the same as the
-- one before it (a restatement) is skipped by an idempotent attribute and refused by one that may not be restated.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_QTY_Event_Quantity before INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_QTY_Event_Quantity"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity" x
        WHERE
            x."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
        AND
            x."EV_QTY_Event_Quantity" = NEW."EV_QTY_Event_Quantity"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity" x
        WHERE
            x."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_QTY_Event_Quantity for: %', NEW."EV_QTY_EV_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_QTY_Event_Quantity" ON public."EV_QTY_Event_Quantity";
CREATE TRIGGER "it_EV_QTY_Event_Quantity"
BEFORE INSERT ON public."EV_QTY_Event_Quantity"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_QTY_Event_Quantity"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place before INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_PLC_Event_Place"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place" x
        WHERE
            x."EV_PLC_ChangedAt" = NEW."EV_PLC_ChangedAt"
        AND
            x."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            x."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place" x
        WHERE
            x."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            x."EV_PLC_ChangedAt" = NEW."EV_PLC_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", NEW."EV_PLC_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."EV_PLC_Event_Place"
            FROM
                public."EV_PLC_Event_Place" p
            WHERE
                p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
            AND
                p."EV_PLC_ChangedAt" < NEW."EV_PLC_ChangedAt"
            ORDER BY
                p."EV_PLC_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place"
    ) THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", NEW."EV_PLC_ChangedAt");
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."EV_PLC_Event_Place"
            FROM
                public."EV_PLC_Event_Place" f
            WHERE
                f."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
            AND
                f."EV_PLC_ChangedAt" > NEW."EV_PLC_ChangedAt"
            ORDER BY
                f."EV_PLC_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place"
    ) THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", NEW."EV_PLC_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_PLC_Event_Place" ON public."EV_PLC_Event_Place";
CREATE TRIGGER "it_EV_PLC_Event_Place"
BEFORE INSERT ON public."EV_PLC_Event_Place"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_PLC_Event_Place"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name before INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NAM_Subject_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name" x
        WHERE
            x."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
        AND
            x."SU_NAM_Subject_Name" = NEW."SU_NAM_Subject_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name" x
        WHERE
            x."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NAM_Subject_Name for: %', NEW."SU_NAM_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NAM_Subject_Name" ON public."SU_NAM_Subject_Name";
CREATE TRIGGER "it_SU_NAM_Subject_Name"
BEFORE INSERT ON public."SU_NAM_Subject_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NAM_Subject_Name"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code before INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_COD_Subject_Code"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code" x
        WHERE
            x."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
        AND
            x."SU_COD_Subject_Code" = NEW."SU_COD_Subject_Code"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code" x
        WHERE
            x."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_COD_Subject_Code for: %', NEW."SU_COD_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_COD_Subject_Code" ON public."SU_COD_Subject_Code";
CREATE TRIGGER "it_SU_COD_Subject_Code"
BEFORE INSERT ON public."SU_COD_Subject_Code"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_COD_Subject_Code"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade before INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_GRD_Subject_Grade"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade" x
        WHERE
            x."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
        AND
            x."SU_GRD_GRD_ID" = NEW."SU_GRD_GRD_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade" x
        WHERE
            x."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_GRD_Subject_Grade for: %', NEW."SU_GRD_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_GRD_Subject_Grade" ON public."SU_GRD_Subject_Grade";
CREATE TRIGGER "it_SU_GRD_Subject_Grade"
BEFORE INSERT ON public."SU_GRD_Subject_Grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_GRD_Subject_Grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note before INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NOT_Subject_Note"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note" x
        WHERE
            x."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
        AND
            md5(x."SU_NOT_Subject_Note"::text) = md5(NEW."SU_NOT_Subject_Note"::text)
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note" x
        WHERE
            x."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NOT_Subject_Note for: %', NEW."SU_NOT_SU_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NOT_Subject_Note" ON public."SU_NOT_Subject_Note";
CREATE TRIGGER "it_SU_NOT_Subject_Note"
BEFORE INSERT ON public."SU_NOT_Subject_Note"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NOT_Subject_Note"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title before INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TTL_Subject_Title"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title" x
        WHERE
            x."SU_TTL_ChangedAt" = NEW."SU_TTL_ChangedAt"
        AND
            x."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            x."SU_TTL_Subject_Title" = NEW."SU_TTL_Subject_Title"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title" x
        WHERE
            x."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            x."SU_TTL_ChangedAt" = NEW."SU_TTL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TTL_Subject_Title for: %', concat_ws(', ', NEW."SU_TTL_SU_ID", NEW."SU_TTL_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TTL_Subject_Title" ON public."SU_TTL_Subject_Title";
CREATE TRIGGER "it_SU_TTL_Subject_Title"
BEFORE INSERT ON public."SU_TTL_Subject_Title"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TTL_Subject_Title"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State before INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_STA_Subject_State"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State" x
        WHERE
            x."SU_STA_ChangedAt" = NEW."SU_STA_ChangedAt"
        AND
            x."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            x."SU_STA_Subject_State" = NEW."SU_STA_Subject_State"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State" x
        WHERE
            x."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            x."SU_STA_ChangedAt" = NEW."SU_STA_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", NEW."SU_STA_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_STA_Subject_State"
            FROM
                public."SU_STA_Subject_State" p
            WHERE
                p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
            AND
                p."SU_STA_ChangedAt" < NEW."SU_STA_ChangedAt"
            ORDER BY
                p."SU_STA_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_STA_Subject_State" = NEW."SU_STA_Subject_State"
    ) THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", NEW."SU_STA_ChangedAt");
    END IF;
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                f."SU_STA_Subject_State"
            FROM
                public."SU_STA_Subject_State" f
            WHERE
                f."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
            AND
                f."SU_STA_ChangedAt" > NEW."SU_STA_ChangedAt"
            ORDER BY
                f."SU_STA_ChangedAt" ASC
            LIMIT 1
        ) fol
        WHERE
            fol."SU_STA_Subject_State" = NEW."SU_STA_Subject_State"
    ) THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", NEW."SU_STA_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_STA_Subject_State" ON public."SU_STA_Subject_State";
CREATE TRIGGER "it_SU_STA_Subject_State"
BEFORE INSERT ON public."SU_STA_Subject_State"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_STA_Subject_State"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label before INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LBL_Subject_Label"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label" x
        WHERE
            x."SU_LBL_ChangedAt" = NEW."SU_LBL_ChangedAt"
        AND
            x."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            x."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label" x
        WHERE
            x."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            x."SU_LBL_ChangedAt" = NEW."SU_LBL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LBL_Subject_Label for: %', concat_ws(', ', NEW."SU_LBL_SU_ID", NEW."SU_LBL_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_LBL_Subject_Label"
            FROM
                public."SU_LBL_Subject_Label" p
            WHERE
                p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
            AND
                p."SU_LBL_ChangedAt" < NEW."SU_LBL_ChangedAt"
            ORDER BY
                p."SU_LBL_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        public."SU_LBL_Subject_Label" x
    WHERE
        x."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
    AND
        x."SU_LBL_ChangedAt" = (
            SELECT
                min(f."SU_LBL_ChangedAt")
            FROM
                public."SU_LBL_Subject_Label" f
            WHERE
                f."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
            AND
                f."SU_LBL_ChangedAt" > NEW."SU_LBL_ChangedAt"
        )
    AND
        x."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LBL_Subject_Label" ON public."SU_LBL_Subject_Label";
CREATE TRIGGER "it_SU_LBL_Subject_Label"
BEFORE INSERT ON public."SU_LBL_Subject_Label"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LBL_Subject_Label"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag before INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TAG_Subject_Tag"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag" x
        WHERE
            x."SU_TAG_ChangedAt" = NEW."SU_TAG_ChangedAt"
        AND
            x."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            x."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag" x
        WHERE
            x."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            x."SU_TAG_ChangedAt" = NEW."SU_TAG_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TAG_Subject_Tag for: %', concat_ws(', ', NEW."SU_TAG_SU_ID", NEW."SU_TAG_ChangedAt");
    END IF;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_TAG_Subject_Tag"
            FROM
                public."SU_TAG_Subject_Tag" p
            WHERE
                p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
            AND
                p."SU_TAG_ChangedAt" < NEW."SU_TAG_ChangedAt"
            ORDER BY
                p."SU_TAG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        public."SU_TAG_Subject_Tag" x
    WHERE
        x."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
    AND
        x."SU_TAG_ChangedAt" = (
            SELECT
                min(f."SU_TAG_ChangedAt")
            FROM
                public."SU_TAG_Subject_Tag" f
            WHERE
                f."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
            AND
                f."SU_TAG_ChangedAt" > NEW."SU_TAG_ChangedAt"
        )
    AND
        x."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TAG_Subject_Tag" ON public."SU_TAG_Subject_Tag";
CREATE TRIGGER "it_SU_TAG_Subject_Tag"
BEFORE INSERT ON public."SU_TAG_Subject_Tag"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TAG_Subject_Tag"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level before INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LVL_Subject_Level"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level" x
        WHERE
            x."SU_LVL_ChangedAt" = NEW."SU_LVL_ChangedAt"
        AND
            x."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            x."SU_LVL_GRD_ID" = NEW."SU_LVL_GRD_ID"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level" x
        WHERE
            x."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            x."SU_LVL_ChangedAt" = NEW."SU_LVL_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LVL_Subject_Level for: %', concat_ws(', ', NEW."SU_LVL_SU_ID", NEW."SU_LVL_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LVL_Subject_Level" ON public."SU_LVL_Subject_Level";
CREATE TRIGGER "it_SU_LVL_Subject_Level"
BEFORE INSERT ON public."SU_LVL_Subject_Level"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LVL_Subject_Level"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text before INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TXT_Subject_Text"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text" x
        WHERE
            x."SU_TXT_ChangedAt" = NEW."SU_TXT_ChangedAt"
        AND
            x."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            md5(x."SU_TXT_Subject_Text"::text) = md5(NEW."SU_TXT_Subject_Text"::text)
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text" x
        WHERE
            x."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            x."SU_TXT_ChangedAt" = NEW."SU_TXT_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TXT_Subject_Text for: %', concat_ws(', ', NEW."SU_TXT_SU_ID", NEW."SU_TXT_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TXT_Subject_Text" ON public."SU_TXT_Subject_Text";
CREATE TRIGGER "it_SU_TXT_Subject_Text"
BEFORE INSERT ON public."SU_TXT_Subject_Text"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TXT_Subject_Text"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment before INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ASR_Subject_Assessment"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment" x
        WHERE
            x."SU_ASR_ChangedAt" = NEW."SU_ASR_ChangedAt"
        AND
            x."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            x."SU_ASR_Subject_Assessment" = NEW."SU_ASR_Subject_Assessment"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment" x
        WHERE
            x."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            x."SU_ASR_ChangedAt" = NEW."SU_ASR_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ASR_Subject_Assessment for: %', concat_ws(', ', NEW."SU_ASR_SU_ID", NEW."SU_ASR_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ASR_Subject_Assessment" ON public."SU_ASR_Subject_Assessment";
CREATE TRIGGER "it_SU_ASR_Subject_Assessment"
BEFORE INSERT ON public."SU_ASR_Subject_Assessment"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ASR_Subject_Assessment"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable before INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ERS_Subject_Erasable"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable" x
        WHERE
            x."SU_ERS_ChangedAt" = NEW."SU_ERS_ChangedAt"
        AND
            x."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            x."SU_ERS_Subject_Erasable" = NEW."SU_ERS_Subject_Erasable"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value at a time that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable" x
        WHERE
            x."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            x."SU_ERS_ChangedAt" = NEW."SU_ERS_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ERS_Subject_Erasable for: %', concat_ws(', ', NEW."SU_ERS_SU_ID", NEW."SU_ERS_ChangedAt");
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ERS_Subject_Erasable" ON public."SU_ERS_Subject_Erasable";
CREATE TRIGGER "it_SU_ERS_Subject_Erasable"
BEFORE INSERT ON public."SU_ERS_Subject_Erasable"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ERS_Subject_Erasable"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name before INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_NAM_Object_Name"()
RETURNS trigger
AS
$$
BEGIN
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name" x
        WHERE
            x."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
        AND
            x."OB_NAM_Object_Name" = NEW."OB_NAM_Object_Name"
    ) THEN
        RETURN NULL;
    END IF;
    -- another value for an entity that already has a value is a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name" x
        WHERE
            x."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_NAM_Object_Name for: %', NEW."OB_NAM_OB_ID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_NAM_Object_Name" ON public."OB_NAM_Object_Name";
CREATE TRIGGER "it_OB_NAM_Object_Name"
BEFORE INSERT ON public."OB_NAM_Object_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_NAM_Object_Name"();
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attribute tables see to that).
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
    _GRD smallint;
    _LVL smallint;
BEGIN
    _id := NEW."SU_ID";
    IF _id IS NULL THEN
        INSERT INTO public."SU_Subject" (
            "Metadata_SU"
        )
        VALUES (
            NEW."Metadata_SU"
        )
        RETURNING "SU_ID" INTO _id;
    END IF;
    IF NEW."SU_NAM_Subject_Name" IS NOT NULL THEN
        INSERT INTO public."SU_NAM_Subject_Name" (
            "Metadata_SU_NAM",
            "SU_NAM_SU_ID",
            "SU_NAM_Subject_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", NEW."Metadata_SU"),
            coalesce(NEW."SU_NAM_SU_ID", _id),
            NEW."SU_NAM_Subject_Name"
        );
    END IF;
    IF NEW."SU_COD_Subject_Code" IS NOT NULL THEN
        INSERT INTO public."SU_COD_Subject_Code" (
            "Metadata_SU_COD",
            "SU_COD_SU_ID",
            "SU_COD_Subject_Code"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", NEW."Metadata_SU"),
            coalesce(NEW."SU_COD_SU_ID", _id),
            NEW."SU_COD_Subject_Code"
        );
    END IF;
    _GRD := NEW."SU_GRD_GRD_ID";
    IF _GRD IS NULL AND NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."SU_GRD_GRD_Grade"
        LIMIT 1;
    END IF;
    IF _GRD IS NOT NULL THEN
        INSERT INTO public."SU_GRD_Subject_Grade" (
            "Metadata_SU_GRD",
            "SU_GRD_SU_ID",
            "SU_GRD_GRD_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", NEW."Metadata_SU"),
            coalesce(NEW."SU_GRD_SU_ID", _id),
            _GRD
        );
    END IF;
    IF NEW."SU_NOT_Subject_Note" IS NOT NULL THEN
        INSERT INTO public."SU_NOT_Subject_Note" (
            "Metadata_SU_NOT",
            "SU_NOT_SU_ID",
            "SU_NOT_Subject_Note"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", NEW."Metadata_SU"),
            coalesce(NEW."SU_NOT_SU_ID", _id),
            NEW."SU_NOT_Subject_Note"
        );
    END IF;
    IF NEW."SU_TTL_Subject_Title" IS NOT NULL THEN
        INSERT INTO public."SU_TTL_Subject_Title" (
            "Metadata_SU_TTL",
            "SU_TTL_SU_ID",
            "SU_TTL_ChangedAt",
            "SU_TTL_Subject_Title"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", NEW."Metadata_SU"),
            coalesce(NEW."SU_TTL_SU_ID", _id),
            coalesce(NEW."SU_TTL_ChangedAt", _now),
            NEW."SU_TTL_Subject_Title"
        );
    END IF;
    IF NEW."SU_STA_Subject_State" IS NOT NULL THEN
        INSERT INTO public."SU_STA_Subject_State" (
            "Metadata_SU_STA",
            "SU_STA_SU_ID",
            "SU_STA_ChangedAt",
            "SU_STA_Subject_State"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", NEW."Metadata_SU"),
            coalesce(NEW."SU_STA_SU_ID", _id),
            coalesce(NEW."SU_STA_ChangedAt", _now),
            NEW."SU_STA_Subject_State"
        );
    END IF;
    IF NEW."SU_LBL_Subject_Label" IS NOT NULL THEN
        INSERT INTO public."SU_LBL_Subject_Label" (
            "Metadata_SU_LBL",
            "SU_LBL_SU_ID",
            "SU_LBL_ChangedAt",
            "SU_LBL_Subject_Label"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LBL_SU_ID", _id),
            coalesce(NEW."SU_LBL_ChangedAt", _now),
            NEW."SU_LBL_Subject_Label"
        );
    END IF;
    IF NEW."SU_TAG_Subject_Tag" IS NOT NULL THEN
        INSERT INTO public."SU_TAG_Subject_Tag" (
            "Metadata_SU_TAG",
            "SU_TAG_SU_ID",
            "SU_TAG_ChangedAt",
            "SU_TAG_Subject_Tag"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", NEW."Metadata_SU"),
            coalesce(NEW."SU_TAG_SU_ID", _id),
            coalesce(NEW."SU_TAG_ChangedAt", _now),
            NEW."SU_TAG_Subject_Tag"
        );
    END IF;
    _LVL := NEW."SU_LVL_GRD_ID";
    IF _LVL IS NULL AND NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
        SELECT
            k."GRD_ID"
        INTO
            _LVL
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."SU_LVL_GRD_Grade"
        LIMIT 1;
    END IF;
    IF _LVL IS NOT NULL THEN
        INSERT INTO public."SU_LVL_Subject_Level" (
            "Metadata_SU_LVL",
            "SU_LVL_SU_ID",
            "SU_LVL_ChangedAt",
            "SU_LVL_GRD_ID"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LVL_SU_ID", _id),
            coalesce(NEW."SU_LVL_ChangedAt", _now),
            _LVL
        );
    END IF;
    IF NEW."SU_TXT_Subject_Text" IS NOT NULL THEN
        INSERT INTO public."SU_TXT_Subject_Text" (
            "Metadata_SU_TXT",
            "SU_TXT_SU_ID",
            "SU_TXT_ChangedAt",
            "SU_TXT_Subject_Text"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", NEW."Metadata_SU"),
            coalesce(NEW."SU_TXT_SU_ID", _id),
            coalesce(NEW."SU_TXT_ChangedAt", _now),
            NEW."SU_TXT_Subject_Text"
        );
    END IF;
    IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL THEN
        INSERT INTO public."SU_ASR_Subject_Assessment" (
            "Metadata_SU_ASR",
            "SU_ASR_SU_ID",
            "SU_ASR_ChangedAt",
            "SU_ASR_Subject_Assessment"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", NEW."Metadata_SU"),
            coalesce(NEW."SU_ASR_SU_ID", _id),
            coalesce(NEW."SU_ASR_ChangedAt", _now),
            NEW."SU_ASR_Subject_Assessment"
        );
    END IF;
    IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL THEN
        INSERT INTO public."SU_ERS_Subject_Erasable" (
            "Metadata_SU_ERS",
            "SU_ERS_SU_ID",
            "SU_ERS_ChangedAt",
            "SU_ERS_Subject_Erasable"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", NEW."Metadata_SU"),
            coalesce(NEW."SU_ERS_SU_ID", _id),
            coalesce(NEW."SU_ERS_ChangedAt", _now),
            NEW."SU_ERS_Subject_Erasable"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "it_lSU_Subject"
INSTEAD OF INSERT ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_Subject"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _GRD smallint;
    _LVL smallint;
BEGIN
    IF NEW."SU_ID" IS DISTINCT FROM OLD."SU_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_SU_ID" IS DISTINCT FROM OLD."SU_NAM_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NAM_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_Subject_Name" IS DISTINCT FROM OLD."SU_NAM_Subject_Name"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_NAM_Subject_Name" IS NOT NULL AND (
            OLD."SU_NAM_Subject_Name" IS NULL OR
            OLD."SU_NAM_Subject_Name" <> NEW."SU_NAM_Subject_Name"
        ) THEN
            INSERT INTO public."SU_NAM_Subject_Name" (
                "Metadata_SU_NAM",
                "SU_NAM_SU_ID",
                "SU_NAM_Subject_Name"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_NAM" IS NOT DISTINCT FROM OLD."Metadata_SU_NAM"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_NAM"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_NAM_SU_ID", NEW."SU_ID"),
                NEW."SU_NAM_Subject_Name"
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_SU_NAM" IS TRUE
    AND OLD."SU_NAM_Subject_Name" IS NOT NULL
    AND NEW."SU_NAM_Subject_Name" IS NULL
    THEN
        IF to_regclass('public."SU_NAM_Subject_Name_Deleted"') IS NULL THEN
            CREATE TABLE public."SU_NAM_Subject_Name_Deleted" (
                LIKE public."SU_NAM_Subject_Name",
                "SU_NAM_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."SU_NAM_Subject_Name"
            WHERE "SU_NAM_SU_ID" = OLD."SU_ID"
            RETURNING *
        )
        INSERT INTO public."SU_NAM_Subject_Name_Deleted"
        SELECT
            d.*,
            _now
        FROM
            d;
    END IF;
    IF NEW."SU_COD_SU_ID" IS DISTINCT FROM OLD."SU_COD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_COD_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_COD_Subject_Code" IS DISTINCT FROM OLD."SU_COD_Subject_Code"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_COD_Subject_Code" IS NOT NULL AND (
            OLD."SU_COD_Subject_Code" IS NULL OR
            OLD."SU_COD_Subject_Code" <> NEW."SU_COD_Subject_Code"
        ) THEN
            INSERT INTO public."SU_COD_Subject_Code" (
                "Metadata_SU_COD",
                "SU_COD_SU_ID",
                "SU_COD_Subject_Code"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_COD" IS NOT DISTINCT FROM OLD."Metadata_SU_COD"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_COD"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_COD_SU_ID", NEW."SU_ID"),
                NEW."SU_COD_Subject_Code"
            );
        END IF;
    END IF;
    IF NEW."SU_GRD_SU_ID" IS DISTINCT FROM OLD."SU_GRD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_GRD_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_GRD_GRD_ID" IS DISTINCT FROM OLD."SU_GRD_GRD_ID"
    OR NEW."SU_GRD_GRD_Grade" IS DISTINCT FROM OLD."SU_GRD_GRD_Grade"
    THEN
        _GRD := NEW."SU_GRD_GRD_ID";
        IF _GRD IS NOT DISTINCT FROM OLD."SU_GRD_GRD_ID" AND NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."SU_GRD_GRD_Grade"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _GRD IS NOT NULL AND (
            OLD."SU_GRD_GRD_ID" IS NULL OR
            OLD."SU_GRD_GRD_ID" <> _GRD
        ) THEN
            INSERT INTO public."SU_GRD_Subject_Grade" (
                "Metadata_SU_GRD",
                "SU_GRD_SU_ID",
                "SU_GRD_GRD_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_GRD" IS NOT DISTINCT FROM OLD."Metadata_SU_GRD"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_GRD"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_GRD_SU_ID", NEW."SU_ID"),
                _GRD
            );
        END IF;
    END IF;
    IF NEW."SU_NOT_SU_ID" IS DISTINCT FROM OLD."SU_NOT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NOT_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NOT_Subject_Note" IS DISTINCT FROM OLD."SU_NOT_Subject_Note"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_NOT_Subject_Note" IS NOT NULL AND (
            OLD."SU_NOT_Subject_Note" IS NULL OR
            md5(OLD."SU_NOT_Subject_Note"::text) <> md5(NEW."SU_NOT_Subject_Note"::text)
        ) THEN
            INSERT INTO public."SU_NOT_Subject_Note" (
                "Metadata_SU_NOT",
                "SU_NOT_SU_ID",
                "SU_NOT_Subject_Note"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_NOT" IS NOT DISTINCT FROM OLD."Metadata_SU_NOT"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_NOT"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_NOT_SU_ID", NEW."SU_ID"),
                NEW."SU_NOT_Subject_Note"
            );
        END IF;
    END IF;
    IF NEW."SU_TTL_SU_ID" IS DISTINCT FROM OLD."SU_TTL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TTL_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_TTL_Subject_Title" IS DISTINCT FROM OLD."SU_TTL_Subject_Title"
    OR NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_TTL_Subject_Title" IS NOT NULL AND (
            NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" OR
            OLD."SU_TTL_Subject_Title" IS NULL OR
            OLD."SU_TTL_Subject_Title" <> NEW."SU_TTL_Subject_Title"
        ) THEN
            INSERT INTO public."SU_TTL_Subject_Title" (
                "Metadata_SU_TTL",
                "SU_TTL_SU_ID",
                "SU_TTL_ChangedAt",
                "SU_TTL_Subject_Title"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TTL" IS NOT DISTINCT FROM OLD."Metadata_SU_TTL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TTL"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_TTL_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" THEN NEW."SU_TTL_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_TTL_Subject_Title"
            );
        END IF;
    END IF;
    IF NEW."SU_STA_SU_ID" IS DISTINCT FROM OLD."SU_STA_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_STA_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_STA_Subject_State" IS DISTINCT FROM OLD."SU_STA_Subject_State"
    OR NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_STA_Subject_State" IS NOT NULL AND (
            NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" OR
            OLD."SU_STA_Subject_State" IS NULL OR
            OLD."SU_STA_Subject_State" <> NEW."SU_STA_Subject_State"
        ) THEN
            INSERT INTO public."SU_STA_Subject_State" (
                "Metadata_SU_STA",
                "SU_STA_SU_ID",
                "SU_STA_ChangedAt",
                "SU_STA_Subject_State"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_STA" IS NOT DISTINCT FROM OLD."Metadata_SU_STA"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_STA"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_STA_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" THEN NEW."SU_STA_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_STA_Subject_State"
            );
        END IF;
    END IF;
    IF NEW."SU_LBL_SU_ID" IS DISTINCT FROM OLD."SU_LBL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LBL_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_LBL_Subject_Label" IS DISTINCT FROM OLD."SU_LBL_Subject_Label"
    OR NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_LBL_Subject_Label" IS NOT NULL AND (
            NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" OR
            OLD."SU_LBL_Subject_Label" IS NULL OR
            OLD."SU_LBL_Subject_Label" <> NEW."SU_LBL_Subject_Label"
        ) THEN
            INSERT INTO public."SU_LBL_Subject_Label" (
                "Metadata_SU_LBL",
                "SU_LBL_SU_ID",
                "SU_LBL_ChangedAt",
                "SU_LBL_Subject_Label"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_LBL" IS NOT DISTINCT FROM OLD."Metadata_SU_LBL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_LBL"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_LBL_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" THEN NEW."SU_LBL_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_LBL_Subject_Label"
            );
        END IF;
    END IF;
    IF NEW."SU_TAG_SU_ID" IS DISTINCT FROM OLD."SU_TAG_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TAG_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_TAG_Subject_Tag" IS DISTINCT FROM OLD."SU_TAG_Subject_Tag"
    OR NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_TAG_Subject_Tag" IS NOT NULL AND (
            NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" OR
            OLD."SU_TAG_Subject_Tag" IS NULL OR
            OLD."SU_TAG_Subject_Tag" <> NEW."SU_TAG_Subject_Tag"
        ) THEN
            INSERT INTO public."SU_TAG_Subject_Tag" (
                "Metadata_SU_TAG",
                "SU_TAG_SU_ID",
                "SU_TAG_ChangedAt",
                "SU_TAG_Subject_Tag"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TAG" IS NOT DISTINCT FROM OLD."Metadata_SU_TAG"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TAG"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_TAG_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" THEN NEW."SU_TAG_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_TAG_Subject_Tag"
            );
        END IF;
    END IF;
    IF NEW."SU_LVL_SU_ID" IS DISTINCT FROM OLD."SU_LVL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LVL_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_LVL_GRD_ID" IS DISTINCT FROM OLD."SU_LVL_GRD_ID"
    OR NEW."SU_LVL_GRD_Grade" IS DISTINCT FROM OLD."SU_LVL_GRD_Grade"
    OR NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt"
    THEN
        _LVL := NEW."SU_LVL_GRD_ID";
        IF _LVL IS NOT DISTINCT FROM OLD."SU_LVL_GRD_ID" AND NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _LVL
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."SU_LVL_GRD_Grade"
            LIMIT 1;
        END IF;
        -- a value that is left as it is states nothing
        IF _LVL IS NOT NULL AND (
            NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" OR
            OLD."SU_LVL_GRD_ID" IS NULL OR
            OLD."SU_LVL_GRD_ID" <> _LVL
        ) THEN
            INSERT INTO public."SU_LVL_Subject_Level" (
                "Metadata_SU_LVL",
                "SU_LVL_SU_ID",
                "SU_LVL_ChangedAt",
                "SU_LVL_GRD_ID"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_LVL" IS NOT DISTINCT FROM OLD."Metadata_SU_LVL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_LVL"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_LVL_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" THEN NEW."SU_LVL_ChangedAt"
                    ELSE _now
                END,
                _LVL
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_SU_LVL" IS TRUE
    AND OLD."SU_LVL_GRD_ID" IS NOT NULL
    AND (NEW."SU_LVL_GRD_ID" IS NULL OR NEW."SU_LVL_GRD_Grade" IS NULL)
    THEN
        IF to_regclass('public."SU_LVL_Subject_Level_Deleted"') IS NULL THEN
            CREATE TABLE public."SU_LVL_Subject_Level_Deleted" (
                LIKE public."SU_LVL_Subject_Level",
                "SU_LVL_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."SU_LVL_Subject_Level"
            WHERE "SU_LVL_SU_ID" = OLD."SU_ID"
            RETURNING *
        )
        INSERT INTO public."SU_LVL_Subject_Level_Deleted"
        SELECT
            d.*,
            (CASE WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" THEN NEW."SU_LVL_ChangedAt" ELSE _now END)::timestamp
        FROM
            d;
    END IF;
    IF NEW."SU_TXT_SU_ID" IS DISTINCT FROM OLD."SU_TXT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TXT_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_TXT_Subject_Text" IS DISTINCT FROM OLD."SU_TXT_Subject_Text"
    OR NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_TXT_Subject_Text" IS NOT NULL AND (
            NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" OR
            OLD."SU_TXT_Subject_Text" IS NULL OR
            md5(OLD."SU_TXT_Subject_Text"::text) <> md5(NEW."SU_TXT_Subject_Text"::text)
        ) THEN
            INSERT INTO public."SU_TXT_Subject_Text" (
                "Metadata_SU_TXT",
                "SU_TXT_SU_ID",
                "SU_TXT_ChangedAt",
                "SU_TXT_Subject_Text"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TXT" IS NOT DISTINCT FROM OLD."Metadata_SU_TXT"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TXT"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_TXT_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" THEN NEW."SU_TXT_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_TXT_Subject_Text"
            );
        END IF;
    END IF;
    IF NEW."SU_ASR_SU_ID" IS DISTINCT FROM OLD."SU_ASR_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ASR_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_ASR_Subject_Assessment" IS DISTINCT FROM OLD."SU_ASR_Subject_Assessment"
    OR NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL AND (
            NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" OR
            OLD."SU_ASR_Subject_Assessment" IS NULL OR
            OLD."SU_ASR_Subject_Assessment" <> NEW."SU_ASR_Subject_Assessment"
        ) THEN
            INSERT INTO public."SU_ASR_Subject_Assessment" (
                "Metadata_SU_ASR",
                "SU_ASR_SU_ID",
                "SU_ASR_ChangedAt",
                "SU_ASR_Subject_Assessment"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_ASR" IS NOT DISTINCT FROM OLD."Metadata_SU_ASR"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_ASR"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_ASR_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" THEN NEW."SU_ASR_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_ASR_Subject_Assessment"
            );
        END IF;
    END IF;
    IF NEW."SU_ERS_SU_ID" IS DISTINCT FROM OLD."SU_ERS_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ERS_SU_ID is not updatable.';
    END IF;
    IF NEW."SU_ERS_Subject_Erasable" IS DISTINCT FROM OLD."SU_ERS_Subject_Erasable"
    OR NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL AND (
            NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" OR
            OLD."SU_ERS_Subject_Erasable" IS NULL OR
            OLD."SU_ERS_Subject_Erasable" <> NEW."SU_ERS_Subject_Erasable"
        ) THEN
            INSERT INTO public."SU_ERS_Subject_Erasable" (
                "Metadata_SU_ERS",
                "SU_ERS_SU_ID",
                "SU_ERS_ChangedAt",
                "SU_ERS_Subject_Erasable"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_ERS" IS NOT DISTINCT FROM OLD."Metadata_SU_ERS"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_ERS"
                    END, NEW."Metadata_SU"),
                coalesce(NEW."SU_ERS_SU_ID", NEW."SU_ID"),
                CASE
                    WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" THEN NEW."SU_ERS_ChangedAt"
                    ELSE _now
                END,
                NEW."SU_ERS_Subject_Erasable"
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_SU_ERS" IS TRUE
    AND OLD."SU_ERS_Subject_Erasable" IS NOT NULL
    AND NEW."SU_ERS_Subject_Erasable" IS NULL
    THEN
        IF to_regclass('public."SU_ERS_Subject_Erasable_Deleted"') IS NULL THEN
            CREATE TABLE public."SU_ERS_Subject_Erasable_Deleted" (
                LIKE public."SU_ERS_Subject_Erasable",
                "SU_ERS_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."SU_ERS_Subject_Erasable"
            WHERE "SU_ERS_SU_ID" = OLD."SU_ID"
            RETURNING *
        )
        INSERT INTO public."SU_ERS_Subject_Erasable_Deleted"
        SELECT
            d.*,
            (CASE WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" THEN NEW."SU_ERS_ChangedAt" ELSE _now END)::timestamp
        FROM
            d;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "ut_lSU_Subject"
INSTEAD OF UPDATE ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_Subject"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_Subject"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_NAM_Subject_Name" x
    WHERE
        x."SU_NAM_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_COD_Subject_Code" x
    WHERE
        x."SU_COD_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_GRD_Subject_Grade" x
    WHERE
        x."SU_GRD_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_NOT_Subject_Note" x
    WHERE
        x."SU_NOT_SU_ID" = OLD."SU_ID"
    ;
    DELETE FROM
        public."SU_TTL_Subject_Title" x
    WHERE
        x."SU_TTL_SU_ID" = OLD."SU_ID"
    AND
        x."SU_TTL_ChangedAt" = OLD."SU_TTL_ChangedAt"
    ;
    DELETE FROM
        public."SU_STA_Subject_State" x
    WHERE
        x."SU_STA_SU_ID" = OLD."SU_ID"
    AND
        x."SU_STA_ChangedAt" = OLD."SU_STA_ChangedAt"
    ;
    DELETE FROM
        public."SU_LBL_Subject_Label" x
    WHERE
        x."SU_LBL_SU_ID" = OLD."SU_ID"
    AND
        x."SU_LBL_ChangedAt" = OLD."SU_LBL_ChangedAt"
    ;
    DELETE FROM
        public."SU_TAG_Subject_Tag" x
    WHERE
        x."SU_TAG_SU_ID" = OLD."SU_ID"
    AND
        x."SU_TAG_ChangedAt" = OLD."SU_TAG_ChangedAt"
    ;
    DELETE FROM
        public."SU_LVL_Subject_Level" x
    WHERE
        x."SU_LVL_SU_ID" = OLD."SU_ID"
    AND
        x."SU_LVL_ChangedAt" = OLD."SU_LVL_ChangedAt"
    ;
    DELETE FROM
        public."SU_TXT_Subject_Text" x
    WHERE
        x."SU_TXT_SU_ID" = OLD."SU_ID"
    AND
        x."SU_TXT_ChangedAt" = OLD."SU_TXT_ChangedAt"
    ;
    DELETE FROM
        public."SU_ASR_Subject_Assessment" x
    WHERE
        x."SU_ASR_SU_ID" = OLD."SU_ID"
    AND
        x."SU_ASR_ChangedAt" = OLD."SU_ASR_ChangedAt"
    ;
    DELETE FROM
        public."SU_ERS_Subject_Erasable" x
    WHERE
        x."SU_ERS_SU_ID" = OLD."SU_ID"
    AND
        x."SU_ERS_ChangedAt" = OLD."SU_ERS_ChangedAt"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."SU_Subject" a
    WHERE
        a."SU_ID" = OLD."SU_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name" x
        WHERE
            x."SU_NAM_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code" x
        WHERE
            x."SU_COD_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade" x
        WHERE
            x."SU_GRD_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note" x
        WHERE
            x."SU_NOT_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title" x
        WHERE
            x."SU_TTL_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State" x
        WHERE
            x."SU_STA_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label" x
        WHERE
            x."SU_LBL_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag" x
        WHERE
            x."SU_TAG_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level" x
        WHERE
            x."SU_LVL_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text" x
        WHERE
            x."SU_TXT_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment" x
        WHERE
            x."SU_ASR_SU_ID" = a."SU_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable" x
        WHERE
            x."SU_ERS_SU_ID" = a."SU_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "dt_lSU_Subject"
INSTEAD OF DELETE ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_Subject"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."OB_ID";
    IF _id IS NULL THEN
        INSERT INTO public."OB_Object" (
            "Metadata_OB"
        )
        VALUES (
            NEW."Metadata_OB"
        )
        RETURNING "OB_ID" INTO _id;
    END IF;
    IF NEW."OB_NAM_Object_Name" IS NOT NULL THEN
        INSERT INTO public."OB_NAM_Object_Name" (
            "Metadata_OB_NAM",
            "OB_NAM_OB_ID",
            "OB_NAM_Object_Name"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", NEW."Metadata_OB"),
            coalesce(NEW."OB_NAM_OB_ID", _id),
            NEW."OB_NAM_Object_Name"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "it_lOB_Object"
INSTEAD OF INSERT ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_Object"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    IF NEW."OB_ID" IS DISTINCT FROM OLD."OB_ID" THEN
        RAISE EXCEPTION 'The identity column OB_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_OB_ID" IS DISTINCT FROM OLD."OB_NAM_OB_ID" THEN
        RAISE EXCEPTION 'The foreign key column OB_NAM_OB_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_Object_Name" IS DISTINCT FROM OLD."OB_NAM_Object_Name"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."OB_NAM_Object_Name" IS NOT NULL AND (
            OLD."OB_NAM_Object_Name" IS NULL OR
            OLD."OB_NAM_Object_Name" <> NEW."OB_NAM_Object_Name"
        ) THEN
            INSERT INTO public."OB_NAM_Object_Name" (
                "Metadata_OB_NAM",
                "OB_NAM_OB_ID",
                "OB_NAM_Object_Name"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_OB" IS DISTINCT FROM OLD."Metadata_OB"
                         AND NEW."Metadata_OB_NAM" IS NOT DISTINCT FROM OLD."Metadata_OB_NAM"
                        THEN NEW."Metadata_OB"
                        ELSE NEW."Metadata_OB_NAM"
                    END, NEW."Metadata_OB"),
                coalesce(NEW."OB_NAM_OB_ID", NEW."OB_ID"),
                NEW."OB_NAM_Object_Name"
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "ut_lOB_Object"
INSTEAD OF UPDATE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_Object"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_Object"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."OB_NAM_Object_Name" x
    WHERE
        x."OB_NAM_OB_ID" = OLD."OB_ID"
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        public."OB_Object" a
    WHERE
        a."OB_ID" = OLD."OB_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name" x
        WHERE
            x."OB_NAM_OB_ID" = a."OB_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "dt_lOB_Object"
INSTEAD OF DELETE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_Object"();
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attribute tables see to that).
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."EV_ID";
    IF _id IS NULL THEN
        INSERT INTO public."EV_Event" (
            "SU_ID_for",
            "Metadata_EV"
        )
        VALUES (
            NEW."SU_ID_for",
            NEW."Metadata_EV"
        )
        RETURNING "EV_ID" INTO _id;
    END IF;
    IF NEW."EV_QTY_Event_Quantity" IS NOT NULL THEN
        INSERT INTO public."EV_QTY_Event_Quantity" (
            "Metadata_EV_QTY",
            "EV_QTY_EV_ID",
            "EV_QTY_Event_Quantity"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", NEW."Metadata_EV"),
            coalesce(NEW."EV_QTY_EV_ID", _id),
            NEW."EV_QTY_Event_Quantity"
        );
    END IF;
    IF NEW."EV_PLC_Event_Place" IS NOT NULL THEN
        INSERT INTO public."EV_PLC_Event_Place" (
            "Metadata_EV_PLC",
            "EV_PLC_EV_ID",
            "EV_PLC_ChangedAt",
            "EV_PLC_Event_Place"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", NEW."Metadata_EV"),
            coalesce(NEW."EV_PLC_EV_ID", _id),
            coalesce(NEW."EV_PLC_ChangedAt", _now),
            NEW."EV_PLC_Event_Place"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "it_lEV_Event"
INSTEAD OF INSERT ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."it_lEV_Event"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    IF NEW."EV_ID" IS DISTINCT FROM OLD."EV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_ID is not updatable.';
    END IF;
    IF NEW."SU_ID_for" IS DISTINCT FROM OLD."SU_ID_for" THEN
        RAISE EXCEPTION 'The role column SU_ID_for is not updatable.';
    END IF;
    IF NEW."EV_QTY_EV_ID" IS DISTINCT FROM OLD."EV_QTY_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_QTY_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_QTY_Event_Quantity" IS DISTINCT FROM OLD."EV_QTY_Event_Quantity"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_QTY_Event_Quantity" IS NOT NULL AND (
            OLD."EV_QTY_Event_Quantity" IS NULL OR
            OLD."EV_QTY_Event_Quantity" <> NEW."EV_QTY_Event_Quantity"
        ) THEN
            INSERT INTO public."EV_QTY_Event_Quantity" (
                "Metadata_EV_QTY",
                "EV_QTY_EV_ID",
                "EV_QTY_Event_Quantity"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_QTY" IS NOT DISTINCT FROM OLD."Metadata_EV_QTY"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_QTY"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_QTY_EV_ID", NEW."EV_ID"),
                NEW."EV_QTY_Event_Quantity"
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_EV_QTY" IS TRUE
    AND OLD."EV_QTY_Event_Quantity" IS NOT NULL
    AND NEW."EV_QTY_Event_Quantity" IS NULL
    THEN
        IF to_regclass('public."EV_QTY_Event_Quantity_Deleted"') IS NULL THEN
            CREATE TABLE public."EV_QTY_Event_Quantity_Deleted" (
                LIKE public."EV_QTY_Event_Quantity",
                "EV_QTY_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."EV_QTY_Event_Quantity"
            WHERE "EV_QTY_EV_ID" = OLD."EV_ID"
            RETURNING *
        )
        INSERT INTO public."EV_QTY_Event_Quantity_Deleted"
        SELECT
            d.*,
            _now
        FROM
            d;
    END IF;
    IF NEW."EV_PLC_EV_ID" IS DISTINCT FROM OLD."EV_PLC_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_PLC_EV_ID is not updatable.';
    END IF;
    IF NEW."EV_PLC_Event_Place" IS DISTINCT FROM OLD."EV_PLC_Event_Place"
    OR NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt"
    THEN
        -- a value that is left as it is states nothing
        IF NEW."EV_PLC_Event_Place" IS NOT NULL AND (
            NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" OR
            OLD."EV_PLC_Event_Place" IS NULL OR
            OLD."EV_PLC_Event_Place" <> NEW."EV_PLC_Event_Place"
        ) THEN
            INSERT INTO public."EV_PLC_Event_Place" (
                "Metadata_EV_PLC",
                "EV_PLC_EV_ID",
                "EV_PLC_ChangedAt",
                "EV_PLC_Event_Place"
            )
            VALUES (
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_PLC" IS NOT DISTINCT FROM OLD."Metadata_EV_PLC"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_PLC"
                    END, NEW."Metadata_EV"),
                coalesce(NEW."EV_PLC_EV_ID", NEW."EV_ID"),
                CASE
                    WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" THEN NEW."EV_PLC_ChangedAt"
                    ELSE _now
                END,
                NEW."EV_PLC_Event_Place"
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF NEW."Deletable_EV_PLC" IS TRUE
    AND OLD."EV_PLC_Event_Place" IS NOT NULL
    AND NEW."EV_PLC_Event_Place" IS NULL
    THEN
        IF to_regclass('public."EV_PLC_Event_Place_Deleted"') IS NULL THEN
            CREATE TABLE public."EV_PLC_Event_Place_Deleted" (
                LIKE public."EV_PLC_Event_Place",
                "EV_PLC_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."EV_PLC_Event_Place"
            WHERE "EV_PLC_EV_ID" = OLD."EV_ID"
            RETURNING *
        )
        INSERT INTO public."EV_PLC_Event_Place_Deleted"
        SELECT
            d.*,
            (CASE WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" THEN NEW."EV_PLC_ChangedAt" ELSE _now END)::timestamp
        FROM
            d;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "ut_lEV_Event"
INSTEAD OF UPDATE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."ut_lEV_Event"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lEV_Event"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."EV_QTY_Event_Quantity" x
    WHERE
        x."EV_QTY_EV_ID" = OLD."EV_ID"
    ;
    DELETE FROM
        public."EV_PLC_Event_Place" x
    WHERE
        x."EV_PLC_EV_ID" = OLD."EV_ID"
    AND
        x."EV_PLC_ChangedAt" = OLD."EV_PLC_ChangedAt"
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        public."EV_Event" a
    WHERE
        a."EV_ID" = OLD."EV_ID"
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity" x
        WHERE
            x."EV_QTY_EV_ID" = a."EV_ID"
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place" x
        WHERE
            x."EV_PLC_EV_ID" = a."EV_ID"
    )
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."dt_lEV_Event"();
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers make a tie and its latest view behave like a table that is loaded with plain statements.
-- The tie table has a trigger for insert, which stores a row only when it is not there already, refuses a contradiction
-- and, for an idempotent tie, leaves out what only states again what the row before it says. The latest view has
-- three 'instead of' triggers: insert, update, and delete. They propagate such operations to the tie table in a consistent
-- way. Default values are used for some columns if not provided by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_holder_OB_item_GRD_grade before INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_SU_holder_OB_item_GRD_grade" := coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0);
    NEW."SU_holder_OB_item_GRD_grade_ChangedAt" := coalesce(NEW."SU_holder_OB_item_GRD_grade_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade" x
        WHERE
            x."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            x."OB_ID_item" = NEW."OB_ID_item"
        AND
            x."GRD_ID_grade" = NEW."GRD_ID_grade"
        AND
            x."SU_holder_OB_item_GRD_grade_ChangedAt" = NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade" x
        WHERE
            x."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            x."OB_ID_item" = NEW."OB_ID_item"
        AND
            x."SU_holder_OB_item_GRD_grade_ChangedAt" = NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_holder_OB_item_GRD_grade for: %', concat_ws(', ',
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_holder_OB_item_GRD_grade" ON public."SU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_SU_holder_OB_item_GRD_grade"
BEFORE INSERT ON public."SU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_holder_OB_item_GRD_grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."SU_holder_OB_item_GRD_grade" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "SU_ID_holder",
        "OB_ID_item",
        "GRD_ID_grade"
    )
    SELECT
        NEW."Metadata_SU_holder_OB_item_GRD_grade",
        NEW."SU_holder_OB_item_GRD_grade_ChangedAt",
        NEW."SU_ID_holder",
        NEW."OB_ID_item",
        coalesce(NEW."GRD_ID_grade", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."grade_GRD_Grade"
            LIMIT 1
        ))
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_lSU_holder_OB_item_GRD_grade"
INSTEAD OF INSERT ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _GRD_grade smallint;
BEGIN
    IF NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder" THEN
        RAISE EXCEPTION 'The identity column SU_ID_holder is not updatable.';
    END IF;
    IF NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item" THEN
        RAISE EXCEPTION 'The identity column OB_ID_item is not updatable.';
    END IF;
    _GRD_grade := NEW."GRD_ID_grade";
    IF NEW."grade_GRD_Grade" IS DISTINCT FROM OLD."grade_GRD_Grade" THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD_grade
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."grade_GRD_Grade"
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        _GRD_grade IS NOT NULL
    AND
        (
            NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" OR
            NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder"
        OR
            NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item"
        OR
            _GRD_grade IS DISTINCT FROM OLD."GRD_ID_grade"
        )
    THEN
        INSERT INTO public."SU_holder_OB_item_GRD_grade" (
            "Metadata_SU_holder_OB_item_GRD_grade",
            "SU_holder_OB_item_GRD_grade_ChangedAt",
            "SU_ID_holder",
            "OB_ID_item",
            "GRD_ID_grade"
        )
        VALUES (
            NEW."Metadata_SU_holder_OB_item_GRD_grade",
            CASE
                WHEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
                ELSE _now
            END,
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            _GRD_grade
        );
    END IF;
    -- a null in every value of a deletable tie moves what the identifiers have to the deletion table
    IF NEW."Deletable_SU_holder_OB_item_GRD_grade" IS TRUE
    AND (NEW."GRD_ID_grade" IS NULL OR NEW."grade_GRD_Grade" IS NULL)
    THEN
        IF to_regclass('public."SU_holder_OB_item_GRD_grade_Deleted"') IS NULL THEN
            CREATE TABLE public."SU_holder_OB_item_GRD_grade_Deleted" (
                LIKE public."SU_holder_OB_item_GRD_grade",
                "SU_holder_OB_item_GRD_grade_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."SU_holder_OB_item_GRD_grade"
            WHERE
                "SU_ID_holder" = OLD."SU_ID_holder"
            AND
                "OB_ID_item" = OLD."OB_ID_item"
            RETURNING *
        )
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Deleted"
        SELECT
            d.*,
            (CASE WHEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt" ELSE _now END)::timestamp
        FROM
            d;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "ut_lSU_holder_OB_item_GRD_grade"
INSTEAD OF UPDATE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_holder_OB_item_GRD_grade" x
    WHERE
        x."SU_holder_OB_item_GRD_grade_ChangedAt" = OLD."SU_holder_OB_item_GRD_grade_ChangedAt"
    AND
        x."SU_ID_holder" = OLD."SU_ID_holder"
    AND
        x."OB_ID_item" = OLD."OB_ID_item"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "dt_lSU_holder_OB_item_GRD_grade"
INSTEAD OF DELETE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_keeper_OB_thing_GRD_rank before INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_SU_keeper_OB_thing_GRD_rank" := coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0);
    NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank" x
        WHERE
            x."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            x."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            x."GRD_ID_rank" = NEW."GRD_ID_rank"
        AND
            x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank" x
        WHERE
            x."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            x."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_keeper_OB_thing_GRD_rank for: %', concat_ws(', ',
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
        );
    END IF;
    -- what has the same values as the row before it, or as the row after it, is a restatement
    -- (an idempotent tie does not store it, and removes the row after it that the new row makes a restatement of)
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_ID_keeper",
                p."OB_ID_thing",
                p."GRD_ID_rank"
            FROM
                public."SU_keeper_OB_thing_GRD_rank" p
            WHERE
                p."SU_ID_keeper" = NEW."SU_ID_keeper"
            AND
                p."OB_ID_thing" = NEW."OB_ID_thing"
            AND
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" < NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
            ORDER BY
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            pre."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            pre."GRD_ID_rank" = NEW."GRD_ID_rank"
    ) THEN
        RETURN NULL;
    END IF;
    DELETE FROM
        public."SU_keeper_OB_thing_GRD_rank" x
    WHERE
        x."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        x."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = (
            SELECT
                min(f."SU_keeper_OB_thing_GRD_rank_ChangedAt")
            FROM
                public."SU_keeper_OB_thing_GRD_rank" f
            WHERE
                f."SU_ID_keeper" = NEW."SU_ID_keeper"
            AND
                f."OB_ID_thing" = NEW."OB_ID_thing"
            AND
                f."SU_keeper_OB_thing_GRD_rank_ChangedAt" > NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
        )
    AND
        x."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        x."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        x."GRD_ID_rank" = NEW."GRD_ID_rank"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_keeper_OB_thing_GRD_rank" ON public."SU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_SU_keeper_OB_thing_GRD_rank"
BEFORE INSERT ON public."SU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "SU_ID_keeper",
        "OB_ID_thing",
        "GRD_ID_rank"
    )
    SELECT
        NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
        NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt",
        NEW."SU_ID_keeper",
        NEW."OB_ID_thing",
        coalesce(NEW."GRD_ID_rank", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."rank_GRD_Grade"
            LIMIT 1
        ))
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF INSERT ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _GRD_rank smallint;
BEGIN
    IF NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper" THEN
        RAISE EXCEPTION 'The identity column SU_ID_keeper is not updatable.';
    END IF;
    IF NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing" THEN
        RAISE EXCEPTION 'The identity column OB_ID_thing is not updatable.';
    END IF;
    _GRD_rank := NEW."GRD_ID_rank";
    IF NEW."rank_GRD_Grade" IS DISTINCT FROM OLD."rank_GRD_Grade" THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD_rank
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."rank_GRD_Grade"
        LIMIT 1;
    END IF;
    -- values that are left as they are state nothing
    IF
        _GRD_rank IS NOT NULL
    AND
        (
            NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" OR
            NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper"
        OR
            NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing"
        OR
            _GRD_rank IS DISTINCT FROM OLD."GRD_ID_rank"
        )
    THEN
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ChangedAt",
            "SU_ID_keeper",
            "OB_ID_thing",
            "GRD_ID_rank"
        )
        VALUES (
            NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
            CASE
                WHEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" THEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
                ELSE _now
            END,
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            _GRD_rank
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "ut_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF UPDATE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_keeper_OB_thing_GRD_rank" x
    WHERE
        x."SU_keeper_OB_thing_GRD_rank_ChangedAt" = OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt"
    AND
        x."SU_ID_keeper" = OLD."SU_ID_keeper"
    AND
        x."OB_ID_thing" = OLD."OB_ID_thing"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "dt_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF DELETE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_part_SU_owner before INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_OB_part_SU_owner" := coalesce(NEW."Metadata_OB_part_SU_owner", 0);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner" x
        WHERE
            x."OB_ID_part" = NEW."OB_ID_part"
        AND
            x."SU_ID_owner" = NEW."SU_ID_owner"
        AND
            true
    ) THEN
        RETURN NULL;
    END IF;
    -- other values for identifiers that already have values (at that time) are a contradiction
    IF EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner" x
        WHERE
            x."OB_ID_part" = NEW."OB_ID_part"
        AND
            true
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_part_SU_owner for: %', concat_ws(', ',
            NEW."OB_ID_part",
            ''
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_part_SU_owner" ON public."OB_part_SU_owner";
CREATE TRIGGER "it_OB_part_SU_owner"
BEFORE INSERT ON public."OB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_part_SU_owner"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."OB_part_SU_owner" (
        "Metadata_OB_part_SU_owner",
        "OB_ID_part",
        "SU_ID_owner"
    )
    SELECT
        NEW."Metadata_OB_part_SU_owner",
        NEW."OB_ID_part",
        NEW."SU_ID_owner"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "it_lOB_part_SU_owner"
INSTEAD OF INSERT ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_part_SU_owner"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    IF NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part" THEN
        RAISE EXCEPTION 'The identity column OB_ID_part is not updatable.';
    END IF;
    -- values that are left as they are state nothing
    IF
        NEW."SU_ID_owner" IS NOT NULL
    AND
        (
            NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part"
        OR
            NEW."SU_ID_owner" IS DISTINCT FROM OLD."SU_ID_owner"
        )
    THEN
        INSERT INTO public."OB_part_SU_owner" (
            "Metadata_OB_part_SU_owner",
            "OB_ID_part",
            "SU_ID_owner"
        )
        VALUES (
            NEW."Metadata_OB_part_SU_owner",
            NEW."OB_ID_part",
            NEW."SU_ID_owner"
        );
    END IF;
    -- a null in every value of a deletable tie moves what the identifiers have to the deletion table
    IF NEW."Deletable_OB_part_SU_owner" IS TRUE
    AND NEW."SU_ID_owner" IS NULL
    THEN
        IF to_regclass('public."OB_part_SU_owner_Deleted"') IS NULL THEN
            CREATE TABLE public."OB_part_SU_owner_Deleted" (
                LIKE public."OB_part_SU_owner",
                "OB_part_SU_owner_Deleted" timestamp
            );
        END IF;
        WITH d AS (
            DELETE FROM public."OB_part_SU_owner"
            WHERE
                "OB_ID_part" = OLD."OB_ID_part"
            RETURNING *
        )
        INSERT INTO public."OB_part_SU_owner_Deleted"
        SELECT
            d.*,
            _now
        FROM
            d;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "ut_lOB_part_SU_owner"
INSTEAD OF UPDATE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_part_SU_owner"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."OB_part_SU_owner" x
    WHERE
        x."OB_ID_part" = OLD."OB_ID_part"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "dt_lOB_part_SU_owner"
INSTEAD OF DELETE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_part_SU_owner"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_partner_SU_with before INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    NEW."Metadata_SU_partner_SU_with" := coalesce(NEW."Metadata_SU_partner_SU_with", 0);
    NEW."SU_partner_SU_with_ChangedAt" := coalesce(NEW."SU_partner_SU_with_ChangedAt", _now);
    -- the identical is not stored again
    IF EXISTS (
        SELECT
            1
        FROM
            public."SU_partner_SU_with" x
        WHERE
            x."SU_ID_partner" = NEW."SU_ID_partner"
        AND
            x."SU_ID_with" = NEW."SU_ID_with"
        AND
            x."SU_partner_SU_with_ChangedAt" = NEW."SU_partner_SU_with_ChangedAt"
    ) THEN
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_partner_SU_with" ON public."SU_partner_SU_with";
CREATE TRIGGER "it_SU_partner_SU_with"
BEFORE INSERT ON public."SU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_partner_SU_with"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
BEGIN
    INSERT INTO public."SU_partner_SU_with" (
        "Metadata_SU_partner_SU_with",
        "SU_partner_SU_with_ChangedAt",
        "SU_ID_partner",
        "SU_ID_with"
    )
    SELECT
        NEW."Metadata_SU_partner_SU_with",
        NEW."SU_partner_SU_with_ChangedAt",
        NEW."SU_ID_partner",
        NEW."SU_ID_with"
    ;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "it_lSU_partner_SU_with"
INSTEAD OF INSERT ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_partner_SU_with"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- values that are left as they are state nothing
    IF
        NEW."SU_ID_partner" IS NOT NULL
    AND
        NEW."SU_ID_with" IS NOT NULL
    AND
        (
            NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" OR
            NEW."SU_ID_partner" IS DISTINCT FROM OLD."SU_ID_partner"
        OR
            NEW."SU_ID_with" IS DISTINCT FROM OLD."SU_ID_with"
        )
    THEN
        INSERT INTO public."SU_partner_SU_with" (
            "Metadata_SU_partner_SU_with",
            "SU_partner_SU_with_ChangedAt",
            "SU_ID_partner",
            "SU_ID_with"
        )
        VALUES (
            NEW."Metadata_SU_partner_SU_with",
            CASE
                WHEN NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" THEN NEW."SU_partner_SU_with_ChangedAt"
                ELSE _now
            END,
            NEW."SU_ID_partner",
            NEW."SU_ID_with"
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "ut_lSU_partner_SU_with"
INSTEAD OF UPDATE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_partner_SU_with"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
BEGIN
    DELETE FROM
        public."SU_partner_SU_with" x
    WHERE
        x."SU_partner_SU_with_ChangedAt" = OLD."SU_partner_SU_with_ChangedAt"
    AND
        x."SU_ID_partner" = OLD."SU_ID_partner"
    AND
        x."SU_ID_with" = OLD."SU_ID_with"
    ;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "dt_lSU_partner_SU_with"
INSTEAD OF DELETE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_partner_SU_with"();
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA public IS 'A model for testing the triggers of the latest views: an attribute for each combination of the settings that the triggers read (restatable, idempotent, assertive, deletable, checksum, knotted, static or historized), ties with and without identifiers, and a nexus with an attribute. The scripts in sqlserver-tests/ run against its output.';
COMMENT ON TABLE public."GRD_Grade" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN public."GRD_Grade"."GRD_Grade" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN public."EV_QTY_Event_Quantity"."EV_QTY_Event_Quantity" IS 'Static.';
COMMENT ON COLUMN public."EV_PLC_Event_Place"."EV_PLC_Event_Place" IS 'Historized and not restatable, as an attribute of an anchor may be.';
COMMENT ON COLUMN public."SU_NAM_Subject_Name"."SU_NAM_Subject_Name" IS 'Static.';
COMMENT ON COLUMN public."SU_COD_Subject_Code"."SU_COD_Subject_Code" IS 'Static and idempotent.';
COMMENT ON COLUMN public."SU_GRD_Subject_Grade"."SU_GRD_GRD_ID" IS 'Static and knotted.';
COMMENT ON COLUMN public."SU_NOT_Subject_Note"."SU_NOT_Subject_Note" IS 'Static, with a checksum.';
COMMENT ON COLUMN public."SU_TTL_Subject_Title"."SU_TTL_Subject_Title" IS 'Historized, restatable.';
COMMENT ON COLUMN public."SU_STA_Subject_State"."SU_STA_Subject_State" IS 'Historized, not restatable: a restatement is an error.';
COMMENT ON COLUMN public."SU_LBL_Subject_Label"."SU_LBL_Subject_Label" IS 'Historized, not restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN public."SU_TAG_Subject_Tag"."SU_TAG_Subject_Tag" IS 'Historized, restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN public."SU_LVL_Subject_Level"."SU_LVL_GRD_ID" IS 'Historized and knotted.';
COMMENT ON COLUMN public."SU_TXT_Subject_Text"."SU_TXT_Subject_Text" IS 'Historized, with a checksum.';
COMMENT ON COLUMN public."SU_ASR_Subject_Assessment"."SU_ASR_Subject_Assessment" IS 'Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).';
COMMENT ON COLUMN public."SU_ERS_Subject_Erasable"."SU_ERS_Subject_Erasable" IS 'Historized and deletable (uni-temporal).';
COMMENT ON COLUMN public."OB_NAM_Object_Name"."OB_NAM_Object_Name" IS 'Static.';
COMMENT ON TABLE public."SU_Subject" IS 'The subject of the tests.';
COMMENT ON TABLE public."OB_Object" IS 'Something the subject has or keeps.';
COMMENT ON TABLE public."EV_Event" IS 'An event, with attributes of its own, a static one and a historized one.';
COMMENT ON COLUMN public."EV_Event"."SU_ID_for" IS 'The subject the event is for.';
COMMENT ON TABLE public."SU_holder_OB_item_GRD_grade" IS 'Historized, with identifiers and a knotted value role, restatable.';
COMMENT ON COLUMN public."SU_holder_OB_item_GRD_grade"."SU_ID_holder" IS 'The subject of the tests.';
COMMENT ON COLUMN public."SU_holder_OB_item_GRD_grade"."OB_ID_item" IS 'Something the subject has or keeps.';
COMMENT ON COLUMN public."SU_holder_OB_item_GRD_grade"."GRD_ID_grade" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE public."SU_keeper_OB_thing_GRD_rank" IS 'Historized, with identifiers and a knotted value role, idempotent and not assertive.';
COMMENT ON COLUMN public."SU_keeper_OB_thing_GRD_rank"."SU_ID_keeper" IS 'The subject of the tests.';
COMMENT ON COLUMN public."SU_keeper_OB_thing_GRD_rank"."OB_ID_thing" IS 'Something the subject has or keeps.';
COMMENT ON COLUMN public."SU_keeper_OB_thing_GRD_rank"."GRD_ID_rank" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE public."OB_part_SU_owner" IS 'Static, with an identifier and a value role: each object has one owner.';
COMMENT ON COLUMN public."OB_part_SU_owner"."OB_ID_part" IS 'Something the subject has or keeps.';
COMMENT ON COLUMN public."OB_part_SU_owner"."SU_ID_owner" IS 'The subject of the tests.';
COMMENT ON TABLE public."SU_partner_SU_with" IS 'Historized, without identifiers.';
COMMENT ON COLUMN public."SU_partner_SU_with"."SU_ID_partner" IS 'The subject of the tests.';
COMMENT ON COLUMN public."SU_partner_SU_with"."SU_ID_with" IS 'The subject of the tests.';
