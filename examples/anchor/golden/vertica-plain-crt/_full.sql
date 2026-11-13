-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS public;
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."_Positor" (
    "Positor" tinyint not null,
    constraint "pk_Positor" primary key (
        "Positor"
    )
) ORDER BY "Positor" UNSEGMENTED ALL NODES;
INSERT INTO public."_Positor" (
    "Positor"
)
SELECT
    0
WHERE NOT EXISTS (
    SELECT
        1
    FROM
        public."_Positor"
    WHERE
        "Positor" = 0
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PAT_ParentalType" (
    "PAT_ID" tinyint not null,
    "PAT_ParentalType" varchar(42) not null,
    constraint "pkPAT_ParentalType" primary key (
        "PAT_ID" 
    ),
    constraint "uqPAT_ParentalType" unique (
        "PAT_ParentalType"
    )
) ORDER BY "PAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GEN_Gender" (
    "GEN_ID" tinyint not null,
    "GEN_Gender" varchar(42) not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID" 
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Gender"
    )
) ORDER BY "GEN_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PLV_ProfessionalLevel" (
    "PLV_ID" tinyint not null,
    "PLV_ProfessionalLevel" long varchar(32000000) not null,
    "PLV_Checksum" int default hash("PLV_ProfessionalLevel"),
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID" 
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
) ORDER BY "PLV_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."UTL_Utilization" (
    "UTL_ID" tinyint not null,
    "UTL_Utilization" tinyint not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID" 
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
) ORDER BY "UTL_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ONG_Ongoing" (
    "ONG_ID" tinyint not null,
    "ONG_Ongoing" varchar(3) not null,
    constraint "pkONG_Ongoing" primary key (
        "ONG_ID" 
    ),
    constraint "uqONG_Ongoing" unique (
        "ONG_Ongoing"
    )
) ORDER BY "ONG_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."RAT_Rating" (
    "RAT_ID" tinyint not null,
    "RAT_Rating" varchar(42) not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID" 
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Rating"
    )
) ORDER BY "RAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ETY_EventType" (
    "ETY_ID" tinyint not null,
    "ETY_EventType" varchar(42) not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID" 
    ),
    constraint "uqETY_EventType" unique (
        "ETY_EventType"
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
CREATE SEQUENCE IF NOT EXISTS public."PN_Person_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."PN_Person" (
    "PN_ID" integer default nextval('public."PN_Person_ID_SEQ"') not null, 
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
) ORDER BY "PN_ID" SEGMENTED BY MODULARHASH("PN_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_Stage_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."ST_Stage" (
    "ST_ID" integer default nextval('public."ST_Stage_ID_SEQ"') not null, 
    constraint "pkST_Stage" primary key (
        "ST_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_Actor_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_Actor" (
    "AC_ID" integer default nextval('public."AC_Actor_ID_SEQ"') not null, 
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    )
) ORDER BY "AC_ID" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_Program_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."PR_Program" (
    "PR_ID" integer default nextval('public."PR_Program_ID_SEQ"') not null, 
    constraint "pkPR_Program" primary key (
        "PR_ID"
    )
) ORDER BY "PR_ID" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_Event_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."EV_Event" (
    "EV_ID" integer default nextval('public."EV_Event_ID_SEQ"') not null, 
    "ST_ID_wasHeldAt" integer not null, 
    "PR_ID_wasPlayed" integer not null, 
    "ETY_ID_of" tinyint not null,
    constraint "EV_Event_fkST_wasHeldAt" foreign key (
        "ST_ID_wasHeldAt"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "EV_Event_fkPR_wasPlayed" foreign key (
        "PR_ID_wasPlayed"
    ) references public."PR_Program"("PR_ID"), 
    constraint "EV_Event_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references public."ETY_EventType"("ETY_ID"),
    "EV_Dummy" boolean null,
    constraint "pkEV_Event" primary key (
        "EV_ID"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_DAT_Event_Date_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date_Posit" (
    "EV_DAT_ID" integer default nextval('public."EV_DAT_Event_Date_Posit_ID_SEQ"') not null, 
    "EV_ID" integer not null,
    "EV_DAT_Event_Date" timestamp not null,
    constraint "fkEV_DAT_Event_Date_Posit" foreign key (
        "EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date_Posit" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Event_Date_Posit" unique (
        "EV_ID",
        "EV_DAT_Event_Date"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date_Annex" (
    "EV_DAT_ID" integer not null,
    "EV_DAT_PositedAt" timestamp not null,
    "EV_DAT_Positor" tinyint not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "EV_DAT_Assertion" char(1) default (
        case
            when "EV_DAT_Reliability" > 0 then '+'
            when "EV_DAT_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkEV_DAT_Event_Date_Annex" foreign key (
        "EV_DAT_ID"
    ) references public."EV_DAT_Event_Date_Posit"("EV_DAT_ID"),
    constraint "pkEV_DAT_Event_Date_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_Positor",
        "EV_DAT_PositedAt"
    )
) ORDER BY "EV_DAT_ID", "EV_DAT_Positor", "EV_DAT_PositedAt" SEGMENTED BY MODULARHASH("EV_DAT_ID") ALL NODES;
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_AUD_Event_Audience_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience_Posit" (
    "EV_AUD_ID" integer default nextval('public."EV_AUD_Event_Audience_Posit_ID_SEQ"') not null, 
    "EV_ID" integer not null,
    "EV_AUD_Event_Audience" integer not null,
    constraint "fkEV_AUD_Event_Audience_Posit" foreign key (
        "EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience_Posit" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Event_Audience_Posit" unique (
        "EV_ID",
        "EV_AUD_Event_Audience"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience_Annex" (
    "EV_AUD_ID" integer not null,
    "EV_AUD_PositedAt" timestamp not null,
    "EV_AUD_Positor" tinyint not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "EV_AUD_Assertion" char(1) default (
        case
            when "EV_AUD_Reliability" > 0 then '+'
            when "EV_AUD_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkEV_AUD_Event_Audience_Annex" foreign key (
        "EV_AUD_ID"
    ) references public."EV_AUD_Event_Audience_Posit"("EV_AUD_ID"),
    constraint "pkEV_AUD_Event_Audience_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_Positor",
        "EV_AUD_PositedAt"
    )
) ORDER BY "EV_AUD_ID", "EV_AUD_Positor", "EV_AUD_PositedAt" SEGMENTED BY MODULARHASH("EV_AUD_ID") ALL NODES;
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_REV_Event_Revenue_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue_Posit" (
    "EV_REV_ID" integer default nextval('public."EV_REV_Event_Revenue_Posit_ID_SEQ"') not null, 
    "EV_ID" integer not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    constraint "fkEV_REV_Event_Revenue_Posit" foreign key (
        "EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue_Posit" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Event_Revenue_Posit" unique (
        "EV_ID",
        "EV_REV_Event_Revenue"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue_Annex" (
    "EV_REV_ID" integer not null,
    "EV_REV_PositedAt" timestamp not null,
    "EV_REV_Positor" tinyint not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "EV_REV_Assertion" char(1) default (
        case
            when "EV_REV_Reliability" > 0 then '+'
            when "EV_REV_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkEV_REV_Event_Revenue_Annex" foreign key (
        "EV_REV_ID"
    ) references public."EV_REV_Event_Revenue_Posit"("EV_REV_ID"),
    constraint "pkEV_REV_Event_Revenue_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_Positor",
        "EV_REV_PositedAt"
    )
) ORDER BY "EV_REV_ID", "EV_REV_Positor", "EV_REV_PositedAt" SEGMENTED BY MODULARHASH("EV_REV_ID") ALL NODES;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_NAM_Stage_Name_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name_Posit" (
    "ST_NAM_ID" integer default nextval('public."ST_NAM_Stage_Name_Posit_ID_SEQ"') not null, 
    "ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Stage_Name_Posit" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name_Posit" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Stage_Name_Posit" unique (
        "ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Stage_Name"
    )
) ORDER BY "ST_ID", "ST_NAM_ChangedAt" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name_Annex" (
    "ST_NAM_ID" integer not null,
    "ST_NAM_PositedAt" timestamp not null,
    "ST_NAM_Positor" tinyint not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "ST_NAM_Assertion" char(1) default (
        case
            when "ST_NAM_Reliability" > 0 then '+'
            when "ST_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkST_NAM_Stage_Name_Annex" foreign key (
        "ST_NAM_ID"
    ) references public."ST_NAM_Stage_Name_Posit"("ST_NAM_ID"),
    constraint "pkST_NAM_Stage_Name_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_Positor",
        "ST_NAM_PositedAt"
    )
) ORDER BY "ST_NAM_ID", "ST_NAM_Positor", "ST_NAM_PositedAt" SEGMENTED BY MODULARHASH("ST_NAM_ID") ALL NODES;
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_LOC_Stage_Location_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location_Posit" (
    "ST_LOC_ID" integer default nextval('public."ST_LOC_Stage_Location_Posit_ID_SEQ"') not null, 
    "ST_ID" integer not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" int default hash("ST_LOC_Stage_Location"),
    constraint "fkST_LOC_Stage_Location_Posit" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location_Posit" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Stage_Location_Posit" unique (
        "ST_ID",
        "ST_LOC_Checksum" 
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location_Annex" (
    "ST_LOC_ID" integer not null,
    "ST_LOC_PositedAt" timestamp not null,
    "ST_LOC_Positor" tinyint not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "ST_LOC_Assertion" char(1) default (
        case
            when "ST_LOC_Reliability" > 0 then '+'
            when "ST_LOC_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkST_LOC_Stage_Location_Annex" foreign key (
        "ST_LOC_ID"
    ) references public."ST_LOC_Stage_Location_Posit"("ST_LOC_ID"),
    constraint "pkST_LOC_Stage_Location_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_Positor",
        "ST_LOC_PositedAt"
    )
) ORDER BY "ST_LOC_ID", "ST_LOC_Positor", "ST_LOC_PositedAt" SEGMENTED BY MODULARHASH("ST_LOC_ID") ALL NODES;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_AVG_Stage_Average_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average_Posit" (
    "ST_AVG_ID" integer default nextval('public."ST_AVG_Stage_Average_Posit_ID_SEQ"') not null, 
    "ST_ID" integer not null,
    "UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average_Posit" foreign key (
        "UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average_Posit" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Stage_Average_Posit" unique (
        "ST_ID",
        "ST_AVG_ChangedAt",
        "UTL_ID"
    )
) ORDER BY "ST_ID", "ST_AVG_ChangedAt" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average_Annex" (
    "ST_AVG_ID" integer not null,
    "ST_AVG_PositedAt" timestamp not null,
    "ST_AVG_Positor" tinyint not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "ST_AVG_Assertion" char(1) default (
        case
            when "ST_AVG_Reliability" > 0 then '+'
            when "ST_AVG_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkST_AVG_Stage_Average_Annex" foreign key (
        "ST_AVG_ID"
    ) references public."ST_AVG_Stage_Average_Posit"("ST_AVG_ID"),
    constraint "pkST_AVG_Stage_Average_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_Positor",
        "ST_AVG_PositedAt"
    )
) ORDER BY "ST_AVG_ID", "ST_AVG_Positor", "ST_AVG_PositedAt" SEGMENTED BY MODULARHASH("ST_AVG_ID") ALL NODES;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Posit" (
    "ST_MIN_ID" integer default nextval('public."ST_MIN_Stage_Minimum_Posit_ID_SEQ"') not null, 
    "ST_ID" integer not null,
    "UTL_ID" tinyint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum_Posit" foreign key (
        "UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Stage_Minimum_Posit" unique (
        "ST_ID",
        "UTL_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Annex" (
    "ST_MIN_ID" integer not null,
    "ST_MIN_PositedAt" timestamp not null,
    "ST_MIN_Positor" tinyint not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "ST_MIN_Assertion" char(1) default (
        case
            when "ST_MIN_Reliability" > 0 then '+'
            when "ST_MIN_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkST_MIN_Stage_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references public."ST_MIN_Stage_Minimum_Posit"("ST_MIN_ID"),
    constraint "pkST_MIN_Stage_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_Positor",
        "ST_MIN_PositedAt"
    )
) ORDER BY "ST_MIN_ID", "ST_MIN_Positor", "ST_MIN_PositedAt" SEGMENTED BY MODULARHASH("ST_MIN_ID") ALL NODES;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_NAM_Actor_Name_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name_Posit" (
    "AC_NAM_ID" integer default nextval('public."AC_NAM_Actor_Name_Posit_ID_SEQ"') not null, 
    "AC_ID" integer not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Actor_Name_Posit" foreign key (
        "AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name_Posit" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Actor_Name_Posit" unique (
        "AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name"
    )
) ORDER BY "AC_ID", "AC_NAM_ChangedAt" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name_Annex" (
    "AC_NAM_ID" integer not null,
    "AC_NAM_PositedAt" timestamp not null,
    "AC_NAM_Positor" tinyint not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "AC_NAM_Assertion" char(1) default (
        case
            when "AC_NAM_Reliability" > 0 then '+'
            when "AC_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_NAM_Actor_Name_Annex" foreign key (
        "AC_NAM_ID"
    ) references public."AC_NAM_Actor_Name_Posit"("AC_NAM_ID"),
    constraint "pkAC_NAM_Actor_Name_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_Positor",
        "AC_NAM_PositedAt"
    )
) ORDER BY "AC_NAM_ID", "AC_NAM_Positor", "AC_NAM_PositedAt" SEGMENTED BY MODULARHASH("AC_NAM_ID") ALL NODES;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_GEN_Actor_Gender_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender_Posit" (
    "AC_GEN_ID" integer default nextval('public."AC_GEN_Actor_Gender_Posit_ID_SEQ"') not null, 
    "AC_ID" integer not null,
    "GEN_ID" tinyint not null,
    constraint "fk_A_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender_Posit" foreign key (
        "GEN_ID"
    ) references public."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Posit" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Actor_Gender_Posit" unique (
        "AC_ID",
        "GEN_ID"
    )
) ORDER BY "AC_ID" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender_Annex" (
    "AC_GEN_ID" integer not null,
    "AC_GEN_PositedAt" timestamp not null,
    "AC_GEN_Positor" tinyint not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "AC_GEN_Assertion" char(1) default (
        case
            when "AC_GEN_Reliability" > 0 then '+'
            when "AC_GEN_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_GEN_Actor_Gender_Annex" foreign key (
        "AC_GEN_ID"
    ) references public."AC_GEN_Actor_Gender_Posit"("AC_GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_Positor",
        "AC_GEN_PositedAt"
    )
) ORDER BY "AC_GEN_ID", "AC_GEN_Positor", "AC_GEN_PositedAt" SEGMENTED BY MODULARHASH("AC_GEN_ID") ALL NODES;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Posit" (
    "AC_PLV_ID" integer default nextval('public."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ"') not null, 
    "AC_ID" integer not null,
    "PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "PLV_ID"
    ) references public."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Posit" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Actor_ProfessionalLevel_Posit" unique (
        "AC_ID",
        "AC_PLV_ChangedAt",
        "PLV_ID"
    )
) ORDER BY "AC_ID", "AC_PLV_ChangedAt" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Annex" (
    "AC_PLV_ID" integer not null,
    "AC_PLV_PositedAt" timestamp not null,
    "AC_PLV_Positor" tinyint not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "AC_PLV_Assertion" char(1) default (
        case
            when "AC_PLV_Reliability" > 0 then '+'
            when "AC_PLV_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_PLV_Actor_ProfessionalLevel_Annex" foreign key (
        "AC_PLV_ID"
    ) references public."AC_PLV_Actor_ProfessionalLevel_Posit"("AC_PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_Positor",
        "AC_PLV_PositedAt"
    )
) ORDER BY "AC_PLV_ID", "AC_PLV_Positor", "AC_PLV_PositedAt" SEGMENTED BY MODULARHASH("AC_PLV_ID") ALL NODES;
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_NAM_Program_Name_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name_Posit" (
    "PR_NAM_ID" integer default nextval('public."PR_NAM_Program_Name_Posit_ID_SEQ"') not null, 
    "PR_ID" integer not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name_Posit" foreign key (
        "PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name_Posit" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Program_Name_Posit" unique (
        "PR_ID",
        "PR_NAM_Program_Name"
    )
) ORDER BY "PR_ID" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name_Annex" (
    "PR_NAM_ID" integer not null,
    "PR_NAM_PositedAt" timestamp not null,
    "PR_NAM_Positor" tinyint not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "PR_NAM_Assertion" char(1) default (
        case
            when "PR_NAM_Reliability" > 0 then '+'
            when "PR_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkPR_NAM_Program_Name_Annex" foreign key (
        "PR_NAM_ID"
    ) references public."PR_NAM_Program_Name_Posit"("PR_NAM_ID"),
    constraint "pkPR_NAM_Program_Name_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_Positor",
        "PR_NAM_PositedAt"
    )
) ORDER BY "PR_NAM_ID", "PR_NAM_Positor", "PR_NAM_PositedAt" SEGMENTED BY MODULARHASH("PR_NAM_ID") ALL NODES;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_LEN_Program_Length_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length_Posit" (
    "PR_LEN_ID" integer default nextval('public."PR_LEN_Program_Length_Posit_ID_SEQ"') not null, 
    "PR_ID" integer not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length_Posit" foreign key (
        "PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length_Posit" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Program_Length_Posit" unique (
        "PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Program_Length"
    )
) ORDER BY "PR_ID", "PR_LEN_ChangedAt" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length_Annex" (
    "PR_LEN_ID" integer not null,
    "PR_LEN_PositedAt" timestamp not null,
    "PR_LEN_Positor" tinyint not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "PR_LEN_Assertion" char(1) default (
        case
            when "PR_LEN_Reliability" > 0 then '+'
            when "PR_LEN_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkPR_LEN_Program_Length_Annex" foreign key (
        "PR_LEN_ID"
    ) references public."PR_LEN_Program_Length_Posit"("PR_LEN_ID"),
    constraint "pkPR_LEN_Program_Length_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_Positor",
        "PR_LEN_PositedAt"
    )
) ORDER BY "PR_LEN_ID", "PR_LEN_Positor", "PR_LEN_PositedAt" SEGMENTED BY MODULARHASH("PR_LEN_ID") ALL NODES;
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."EV_DAT_Event_Date" AS
SELECT
    p."EV_DAT_ID",
    p."EV_ID",
    p."EV_DAT_Event_Date",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion"
FROM
    public."EV_DAT_Event_Date_Posit" p
JOIN
    public."EV_DAT_Event_Date_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW public."EV_AUD_Event_Audience" AS
SELECT
    p."EV_AUD_ID",
    p."EV_ID",
    p."EV_AUD_Event_Audience",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion"
FROM
    public."EV_AUD_Event_Audience_Posit" p
JOIN
    public."EV_AUD_Event_Audience_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW public."EV_REV_Event_Revenue" AS
SELECT
    p."EV_REV_ID",
    p."EV_ID",
    p."EV_REV_Event_Revenue",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion"
FROM
    public."EV_REV_Event_Revenue_Posit" p
JOIN
    public."EV_REV_Event_Revenue_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW public."ST_NAM_Stage_Name" AS
SELECT
    p."ST_NAM_ID",
    p."ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion"
FROM
    public."ST_NAM_Stage_Name_Posit" p
JOIN
    public."ST_NAM_Stage_Name_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW public."ST_LOC_Stage_Location" AS
SELECT
    p."ST_LOC_ID",
    p."ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion"
FROM
    public."ST_LOC_Stage_Location_Posit" p
JOIN
    public."ST_LOC_Stage_Location_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW public."ST_AVG_Stage_Average" AS
SELECT
    p."ST_AVG_ID",
    p."ST_ID",
    p."UTL_ID",
    p."ST_AVG_ChangedAt",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Positor",
    a."ST_AVG_Reliability",
    a."ST_AVG_Assertion"
FROM
    public."ST_AVG_Stage_Average_Posit" p
JOIN
    public."ST_AVG_Stage_Average_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW public."ST_MIN_Stage_Minimum" AS
SELECT
    p."ST_MIN_ID",
    p."ST_ID",
    p."UTL_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Positor",
    a."ST_MIN_Reliability",
    a."ST_MIN_Assertion"
FROM
    public."ST_MIN_Stage_Minimum_Posit" p
JOIN
    public."ST_MIN_Stage_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW public."AC_NAM_Actor_Name" AS
SELECT
    p."AC_NAM_ID",
    p."AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion"
FROM
    public."AC_NAM_Actor_Name_Posit" p
JOIN
    public."AC_NAM_Actor_Name_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW public."AC_GEN_Actor_Gender" AS
SELECT
    p."AC_GEN_ID",
    p."AC_ID",
    p."GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Positor",
    a."AC_GEN_Reliability",
    a."AC_GEN_Assertion"
FROM
    public."AC_GEN_Actor_Gender_Posit" p
JOIN
    public."AC_GEN_Actor_Gender_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW public."AC_PLV_Actor_ProfessionalLevel" AS
SELECT
    p."AC_PLV_ID",
    p."AC_ID",
    p."PLV_ID",
    p."AC_PLV_ChangedAt",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Positor",
    a."AC_PLV_Reliability",
    a."AC_PLV_Assertion"
FROM
    public."AC_PLV_Actor_ProfessionalLevel_Posit" p
JOIN
    public."AC_PLV_Actor_ProfessionalLevel_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW public."PR_NAM_Program_Name" AS
SELECT
    p."PR_NAM_ID",
    p."PR_ID",
    p."PR_NAM_Program_Name",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion"
FROM
    public."PR_NAM_Program_Name_Posit" p
JOIN
    public."PR_NAM_Program_Name_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW public."PR_LEN_Program_Length" AS
SELECT
    p."PR_LEN_ID",
    p."PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion"
FROM
    public."PR_LEN_Program_Length_Posit" p
JOIN
    public."PR_LEN_Program_Length_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
;
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of an attribute with the latest row of their annex for each positor: what is known now about each
-- posit, which each positor asserts, retracts or denies. Vertica has no function that returns a table, so it is a view and shows
-- what is known now (the rewinders of the other databases can be asked about an earlier time, or about a positor); the
-- perspectives that Vertica has are over it.
--
CREATE OR REPLACE VIEW public."rEV_DAT_Event_Date" AS
SELECT
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion",
    p."EV_ID",
    p."EV_DAT_Event_Date"
FROM
    public."EV_DAT_Event_Date_Posit" p
JOIN
    public."EV_DAT_Event_Date_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_DAT_ID", a."EV_DAT_Positor"
    ORDER BY a."EV_DAT_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rEV_AUD_Event_Audience" AS
SELECT
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion",
    p."EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    public."EV_AUD_Event_Audience_Posit" p
JOIN
    public."EV_AUD_Event_Audience_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_AUD_ID", a."EV_AUD_Positor"
    ORDER BY a."EV_AUD_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rEV_REV_Event_Revenue" AS
SELECT
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion",
    p."EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    public."EV_REV_Event_Revenue_Posit" p
JOIN
    public."EV_REV_Event_Revenue_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_REV_ID", a."EV_REV_Positor"
    ORDER BY a."EV_REV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rST_NAM_Stage_Name" AS
SELECT
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion",
    p."ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    public."ST_NAM_Stage_Name_Posit" p
JOIN
    public."ST_NAM_Stage_Name_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_NAM_ID", a."ST_NAM_Positor"
    ORDER BY a."ST_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rST_LOC_Stage_Location" AS
SELECT
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion",
    p."ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    public."ST_LOC_Stage_Location_Posit" p
JOIN
    public."ST_LOC_Stage_Location_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_LOC_ID", a."ST_LOC_Positor"
    ORDER BY a."ST_LOC_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rST_AVG_Stage_Average" AS
SELECT
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Positor",
    a."ST_AVG_Reliability",
    a."ST_AVG_Assertion",
    p."ST_ID",
    p."UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    public."ST_AVG_Stage_Average_Posit" p
JOIN
    public."ST_AVG_Stage_Average_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_AVG_ID", a."ST_AVG_Positor"
    ORDER BY a."ST_AVG_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rST_MIN_Stage_Minimum" AS
SELECT
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Positor",
    a."ST_MIN_Reliability",
    a."ST_MIN_Assertion",
    p."ST_ID",
    p."UTL_ID"
FROM
    public."ST_MIN_Stage_Minimum_Posit" p
JOIN
    public."ST_MIN_Stage_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_MIN_ID", a."ST_MIN_Positor"
    ORDER BY a."ST_MIN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_NAM_Actor_Name" AS
SELECT
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion",
    p."AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    public."AC_NAM_Actor_Name_Posit" p
JOIN
    public."AC_NAM_Actor_Name_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_NAM_ID", a."AC_NAM_Positor"
    ORDER BY a."AC_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_GEN_Actor_Gender" AS
SELECT
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Positor",
    a."AC_GEN_Reliability",
    a."AC_GEN_Assertion",
    p."AC_ID",
    p."GEN_ID"
FROM
    public."AC_GEN_Actor_Gender_Posit" p
JOIN
    public."AC_GEN_Actor_Gender_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_GEN_ID", a."AC_GEN_Positor"
    ORDER BY a."AC_GEN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_PLV_Actor_ProfessionalLevel" AS
SELECT
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Positor",
    a."AC_PLV_Reliability",
    a."AC_PLV_Assertion",
    p."AC_ID",
    p."PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    public."AC_PLV_Actor_ProfessionalLevel_Posit" p
JOIN
    public."AC_PLV_Actor_ProfessionalLevel_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_PLV_ID", a."AC_PLV_Positor"
    ORDER BY a."AC_PLV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rPR_NAM_Program_Name" AS
SELECT
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion",
    p."PR_ID",
    p."PR_NAM_Program_Name"
FROM
    public."PR_NAM_Program_Name_Posit" p
JOIN
    public."PR_NAM_Program_Name_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_NAM_ID", a."PR_NAM_Positor"
    ORDER BY a."PR_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rPR_LEN_Program_Length" AS
SELECT
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion",
    p."PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    public."PR_LEN_Program_Length_Posit" p
JOIN
    public."PR_LEN_Program_Length_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_LEN_ID", a."PR_LEN_Positor"
    ORDER BY a."PR_LEN_PositedAt" DESC
)
;
-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the now
-- perspectives take none, and are views over the rewinders of the attributes (views that show the latest annex row of every posit
-- for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW public."lST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "AVG"."UTL_Utilization",
    "AVG"."UTL_ID",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "MIN"."UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_NAM_Assertion" <> '?' THEN r."ST_NAM_ChangedAt" END) OVER (
                PARTITION BY r."ST_NAM_Positor", r."ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_NAM_Stage_Name" r
    ) x
    WHERE
        x."ST_NAM_Assertion" = '+'
    AND
        x."ST_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_NAM_Positor", x."ST_ID"
        ORDER BY
            x."ST_NAM_ChangedAt" DESC,
            x."ST_NAM_PositedAt" DESC,
            x."ST_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_LOC_Stage_Location" r
    ) x
    WHERE
        x."ST_LOC_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_LOC_Positor", x."ST_ID"
        ORDER BY
            x."ST_LOC_PositedAt" DESC,
            x."ST_LOC_Reliability" DESC
    )
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_AVG_Assertion" <> '?' THEN r."ST_AVG_ChangedAt" END) OVER (
                PARTITION BY r."ST_AVG_Positor", r."ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_AVG_Stage_Average" r
    ) x
    WHERE
        x."ST_AVG_Assertion" = '+'
    AND
        x."ST_AVG_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_AVG_Positor", x."ST_ID"
        ORDER BY
            x."ST_AVG_ChangedAt" DESC,
            x."ST_AVG_PositedAt" DESC,
            x."ST_AVG_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."UTL_ID"
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_MIN_Stage_Minimum" r
    ) x
    WHERE
        x."ST_MIN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_MIN_Positor", x."ST_ID"
        ORDER BY
            x."ST_MIN_PositedAt" DESC,
            x."ST_MIN_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."UTL_ID"
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "AVG"."UTL_Utilization",
    "AVG"."UTL_ID",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "MIN"."UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_NAM_Assertion" <> '?' THEN r."ST_NAM_ChangedAt" END) OVER (
                PARTITION BY r."ST_NAM_Positor", r."ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_NAM_Stage_Name" r
        WHERE
            r."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."ST_NAM_Assertion" = '+'
    AND
        x."ST_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_NAM_Positor", x."ST_ID"
        ORDER BY
            x."ST_NAM_ChangedAt" DESC,
            x."ST_NAM_PositedAt" DESC,
            x."ST_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_LOC_Stage_Location" r
    ) x
    WHERE
        x."ST_LOC_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_LOC_Positor", x."ST_ID"
        ORDER BY
            x."ST_LOC_PositedAt" DESC,
            x."ST_LOC_Reliability" DESC
    )
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_AVG_Assertion" <> '?' THEN r."ST_AVG_ChangedAt" END) OVER (
                PARTITION BY r."ST_AVG_Positor", r."ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_AVG_Stage_Average" r
        WHERE
            r."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."ST_AVG_Assertion" = '+'
    AND
        x."ST_AVG_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_AVG_Positor", x."ST_ID"
        ORDER BY
            x."ST_AVG_ChangedAt" DESC,
            x."ST_AVG_PositedAt" DESC,
            x."ST_AVG_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."UTL_ID"
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_MIN_Stage_Minimum" r
    ) x
    WHERE
        x."ST_MIN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_MIN_Positor", x."ST_ID"
        ORDER BY
            x."ST_MIN_PositedAt" DESC,
            x."ST_MIN_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."UTL_ID"
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "GEN"."GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "PLV"."PLV_Checksum",
    "PLV"."PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_NAM_Assertion" <> '?' THEN r."AC_NAM_ChangedAt" END) OVER (
                PARTITION BY r."AC_NAM_Positor", r."AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_NAM_Actor_Name" r
    ) x
    WHERE
        x."AC_NAM_Assertion" = '+'
    AND
        x."AC_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_NAM_Positor", x."AC_ID"
        ORDER BY
            x."AC_NAM_ChangedAt" DESC,
            x."AC_NAM_PositedAt" DESC,
            x."AC_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."GEN_Gender" AS "GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_GEN_Actor_Gender" r
    ) x
    WHERE
        x."AC_GEN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."AC_GEN_Positor", x."AC_ID"
        ORDER BY
            x."AC_GEN_PositedAt" DESC,
            x."AC_GEN_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."GEN_Gender" k
    ON
        k."GEN_ID" = y."GEN_ID"
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "PLV_Checksum",
        k."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_PLV_Assertion" <> '?' THEN r."AC_PLV_ChangedAt" END) OVER (
                PARTITION BY r."AC_PLV_Positor", r."AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel" r
    ) x
    WHERE
        x."AC_PLV_Assertion" = '+'
    AND
        x."AC_PLV_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_PLV_Positor", x."AC_ID"
        ORDER BY
            x."AC_PLV_ChangedAt" DESC,
            x."AC_PLV_PositedAt" DESC,
            x."AC_PLV_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."PLV_ID"
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."nAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "GEN"."GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "PLV"."PLV_Checksum",
    "PLV"."PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_NAM_Assertion" <> '?' THEN r."AC_NAM_ChangedAt" END) OVER (
                PARTITION BY r."AC_NAM_Positor", r."AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_NAM_Actor_Name" r
        WHERE
            r."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."AC_NAM_Assertion" = '+'
    AND
        x."AC_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_NAM_Positor", x."AC_ID"
        ORDER BY
            x."AC_NAM_ChangedAt" DESC,
            x."AC_NAM_PositedAt" DESC,
            x."AC_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."GEN_Gender" AS "GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_GEN_Actor_Gender" r
    ) x
    WHERE
        x."AC_GEN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."AC_GEN_Positor", x."AC_ID"
        ORDER BY
            x."AC_GEN_PositedAt" DESC,
            x."AC_GEN_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."GEN_Gender" k
    ON
        k."GEN_ID" = y."GEN_ID"
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "PLV_Checksum",
        k."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_PLV_Assertion" <> '?' THEN r."AC_PLV_ChangedAt" END) OVER (
                PARTITION BY r."AC_PLV_Positor", r."AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel" r
        WHERE
            r."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."AC_PLV_Assertion" = '+'
    AND
        x."AC_PLV_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_PLV_Positor", x."AC_ID"
        ORDER BY
            x."AC_PLV_ChangedAt" DESC,
            x."AC_PLV_PositedAt" DESC,
            x."AC_PLV_Reliability" DESC
    )
    ) y
    LEFT JOIN
        public."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."PLV_ID"
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."lPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_NAM_Program_Name" r
    ) x
    WHERE
        x."PR_NAM_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."PR_NAM_Positor", x."PR_ID"
        ORDER BY
            x."PR_NAM_PositedAt" DESC,
            x."PR_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_LEN_Assertion" <> '?' THEN r."PR_LEN_ChangedAt" END) OVER (
                PARTITION BY r."PR_LEN_Positor", r."PR_ID"
            ) AS "inEffect"
        FROM
            public."rPR_LEN_Program_Length" r
    ) x
    WHERE
        x."PR_LEN_Assertion" = '+'
    AND
        x."PR_LEN_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."PR_LEN_Positor", x."PR_ID"
        ORDER BY
            x."PR_LEN_ChangedAt" DESC,
            x."PR_LEN_PositedAt" DESC,
            x."PR_LEN_Reliability" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_NAM_Program_Name" r
    ) x
    WHERE
        x."PR_NAM_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."PR_NAM_Positor", x."PR_ID"
        ORDER BY
            x."PR_NAM_PositedAt" DESC,
            x."PR_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_LEN_Assertion" <> '?' THEN r."PR_LEN_ChangedAt" END) OVER (
                PARTITION BY r."PR_LEN_Positor", r."PR_ID"
            ) AS "inEffect"
        FROM
            public."rPR_LEN_Program_Length" r
        WHERE
            r."PR_LEN_ChangedAt" <= current_timestamp::date
    ) x
    WHERE
        x."PR_LEN_Assertion" = '+'
    AND
        x."PR_LEN_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."PR_LEN_Positor", x."PR_ID"
        ORDER BY
            x."PR_LEN_ChangedAt" DESC,
            x."PR_LEN_PositedAt" DESC,
            x."PR_LEN_Reliability" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = p."Positor"
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the now
-- perspectives take none, and are views over the rewinders of the attributes (views that show the latest annex row of every posit
-- for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV"."EV_ID",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_EventType" AS "ETY_EventType",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
CROSS JOIN
    public."_Positor" p
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_DAT_Event_Date" r
    ) x
    WHERE
        x."EV_DAT_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_DAT_Positor", x."EV_ID"
        ORDER BY
            x."EV_DAT_PositedAt" DESC,
            x."EV_DAT_Reliability" DESC
    )
) "DAT"
ON
    "DAT"."EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_AUD_Event_Audience" r
    ) x
    WHERE
        x."EV_AUD_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_AUD_Positor", x."EV_ID"
        ORDER BY
            x."EV_AUD_PositedAt" DESC,
            x."EV_AUD_Reliability" DESC
    )
) "AUD"
ON
    "AUD"."EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_REV_Event_Revenue" r
    ) x
    WHERE
        x."EV_REV_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_REV_Positor", x."EV_ID"
        ORDER BY
            x."EV_REV_PositedAt" DESC,
            x."EV_REV_Reliability" DESC
    )
) "REV"
ON
    "REV"."EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV"."EV_ID",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_EventType" AS "ETY_EventType",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
CROSS JOIN
    public."_Positor" p
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_DAT_Event_Date" r
    ) x
    WHERE
        x."EV_DAT_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_DAT_Positor", x."EV_ID"
        ORDER BY
            x."EV_DAT_PositedAt" DESC,
            x."EV_DAT_Reliability" DESC
    )
) "DAT"
ON
    "DAT"."EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_AUD_Event_Audience" r
    ) x
    WHERE
        x."EV_AUD_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_AUD_Positor", x."EV_ID"
        ORDER BY
            x."EV_AUD_PositedAt" DESC,
            x."EV_AUD_Reliability" DESC
    )
) "AUD"
ON
    "AUD"."EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_REV_Event_Revenue" r
    ) x
    WHERE
        x."EV_REV_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."EV_REV_Positor", x."EV_ID"
        ORDER BY
            x."EV_REV_PositedAt" DESC,
            x."EV_REV_Reliability" DESC
    )
) "REV"
ON
    "REV"."EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Positor" = p."Positor"
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE SEQUENCE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently_Posit" (
    "AC_partner_AC_with_ONG_currently_ID" integer default nextval('public."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ"') not null, 
    "AC_ID_partner" integer not null, 
    "AC_ID_with" integer not null, 
    "ONG_ID_currently" tinyint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references public."ONG_Ongoing"("ONG_ID"),
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "pkAC_partner_AC_with_ONG_currently_Posit" primary key (
        "AC_partner_AC_with_ONG_currently_ID"
    ),
    constraint "uqAC_partner_AC_with_ONG_currently" unique (
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently"
    )
) ORDER BY "AC_partner_AC_with_ONG_currently_ID" SEGMENTED BY MODULARHASH("AC_partner_AC_with_ONG_currently_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently_Annex" (
    "AC_partner_AC_with_ONG_currently_ID" integer not null,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp not null,
    "AC_partner_AC_with_ONG_currently_Positor" tinyint not null,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2) not null,
    "AC_partner_AC_with_ONG_currently_Assertion" char(1) default (
        case
            when "AC_partner_AC_with_ONG_currently_Reliability" > 0 then '+'
            when "AC_partner_AC_with_ONG_currently_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_partner_AC_with_ONG_currently_Annex" foreign key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) references public."AC_partner_AC_with_ONG_currently_Posit"("AC_partner_AC_with_ONG_currently_ID"),
    constraint "pkAC_partner_AC_with_ONG_currently_Annex" primary key (
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_Positor",
        "AC_partner_AC_with_ONG_currently_PositedAt"
    )
) ORDER BY "AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_Positor", "AC_partner_AC_with_ONG_currently_PositedAt" SEGMENTED BY MODULARHASH("AC_partner_AC_with_ONG_currently_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS public."AC_subset_PN_of_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_subset_PN_of_Posit" (
    "AC_subset_PN_of_ID" integer default nextval('public."AC_subset_PN_of_Posit_ID_SEQ"') not null, 
    "AC_ID_subset" integer not null, 
    "PN_ID_of" integer not null, 
    constraint "AC_subset_PN_of_Posit_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_subset_PN_of_Posit_fkPN_of" foreign key (
        "PN_ID_of"
    ) references public."PN_Person"("PN_ID"), 
    constraint "AC_subset_PN_of_Posit_uqAC_subset" unique (
        "AC_ID_subset"
    ),
    constraint "AC_subset_PN_of_Posit_uqPN_of" unique (
        "PN_ID_of"
    ),
    constraint "pkAC_subset_PN_of_Posit" primary key (
        "AC_subset_PN_of_ID"
    ),
    constraint "uqAC_subset_PN_of" unique (
        "AC_ID_subset",
        "PN_ID_of"
    )
) ORDER BY "AC_subset_PN_of_ID" SEGMENTED BY MODULARHASH("AC_subset_PN_of_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."AC_subset_PN_of_Annex" (
    "AC_subset_PN_of_ID" integer not null,
    "AC_subset_PN_of_PositedAt" timestamp not null,
    "AC_subset_PN_of_Positor" tinyint not null,
    "AC_subset_PN_of_Reliability" decimal(5,2) not null,
    "AC_subset_PN_of_Assertion" char(1) default (
        case
            when "AC_subset_PN_of_Reliability" > 0 then '+'
            when "AC_subset_PN_of_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_subset_PN_of_Annex" foreign key (
        "AC_subset_PN_of_ID"
    ) references public."AC_subset_PN_of_Posit"("AC_subset_PN_of_ID"),
    constraint "pkAC_subset_PN_of_Annex" primary key (
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_Positor",
        "AC_subset_PN_of_PositedAt"
    )
) ORDER BY "AC_subset_PN_of_ID", "AC_subset_PN_of_Positor", "AC_subset_PN_of_PositedAt" SEGMENTED BY MODULARHASH("AC_subset_PN_of_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS public."EV_in_AC_wasCast_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."EV_in_AC_wasCast_Posit" (
    "EV_in_AC_wasCast_ID" integer default nextval('public."EV_in_AC_wasCast_Posit_ID_SEQ"') not null, 
    "EV_ID_in" integer not null, 
    "AC_ID_wasCast" integer not null, 
    constraint "EV_in_AC_wasCast_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references public."EV_Event"("EV_ID"), 
    constraint "EV_in_AC_wasCast_Posit_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "pkEV_in_AC_wasCast_Posit" primary key (
        "EV_in_AC_wasCast_ID"
    ),
    constraint "uqEV_in_AC_wasCast" unique (
        "EV_ID_in",
        "AC_ID_wasCast"
    )
) ORDER BY "EV_in_AC_wasCast_ID" SEGMENTED BY MODULARHASH("EV_in_AC_wasCast_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."EV_in_AC_wasCast_Annex" (
    "EV_in_AC_wasCast_ID" integer not null,
    "EV_in_AC_wasCast_PositedAt" timestamp not null,
    "EV_in_AC_wasCast_Positor" tinyint not null,
    "EV_in_AC_wasCast_Reliability" decimal(5,2) not null,
    "EV_in_AC_wasCast_Assertion" char(1) default (
        case
            when "EV_in_AC_wasCast_Reliability" > 0 then '+'
            when "EV_in_AC_wasCast_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkEV_in_AC_wasCast_Annex" foreign key (
        "EV_in_AC_wasCast_ID"
    ) references public."EV_in_AC_wasCast_Posit"("EV_in_AC_wasCast_ID"),
    constraint "pkEV_in_AC_wasCast_Annex" primary key (
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_Positor",
        "EV_in_AC_wasCast_PositedAt"
    )
) ORDER BY "EV_in_AC_wasCast_ID", "EV_in_AC_wasCast_Positor", "EV_in_AC_wasCast_PositedAt" SEGMENTED BY MODULARHASH("EV_in_AC_wasCast_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS public."AC_part_PR_in_RAT_got_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_part_PR_in_RAT_got_Posit" (
    "AC_part_PR_in_RAT_got_ID" integer default nextval('public."AC_part_PR_in_RAT_got_Posit_ID_SEQ"') not null, 
    "AC_ID_part" integer not null, 
    "PR_ID_in" integer not null, 
    "RAT_ID_got" tinyint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp not null,
    constraint "AC_part_PR_in_RAT_got_Posit_fkAC_part" foreign key (
        "AC_ID_part"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_part_PR_in_RAT_got_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references public."PR_Program"("PR_ID"), 
    constraint "AC_part_PR_in_RAT_got_Posit_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references public."RAT_Rating"("RAT_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Posit" primary key (
        "AC_part_PR_in_RAT_got_ID"
    ),
    constraint "uqAC_part_PR_in_RAT_got" unique (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "RAT_ID_got"
    )
) ORDER BY "AC_part_PR_in_RAT_got_ID" SEGMENTED BY MODULARHASH("AC_part_PR_in_RAT_got_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."AC_part_PR_in_RAT_got_Annex" (
    "AC_part_PR_in_RAT_got_ID" integer not null,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp not null,
    "AC_part_PR_in_RAT_got_Positor" tinyint not null,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2) not null,
    "AC_part_PR_in_RAT_got_Assertion" char(1) default (
        case
            when "AC_part_PR_in_RAT_got_Reliability" > 0 then '+'
            when "AC_part_PR_in_RAT_got_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_part_PR_in_RAT_got_Annex" foreign key (
        "AC_part_PR_in_RAT_got_ID"
    ) references public."AC_part_PR_in_RAT_got_Posit"("AC_part_PR_in_RAT_got_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Annex" primary key (
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_Positor",
        "AC_part_PR_in_RAT_got_PositedAt"
    )
) ORDER BY "AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_Positor", "AC_part_PR_in_RAT_got_PositedAt" SEGMENTED BY MODULARHASH("AC_part_PR_in_RAT_got_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS public."ST_at_PR_isPlaying_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."ST_at_PR_isPlaying_Posit" (
    "ST_at_PR_isPlaying_ID" integer default nextval('public."ST_at_PR_isPlaying_Posit_ID_SEQ"') not null, 
    "ST_ID_at" integer not null, 
    "PR_ID_isPlaying" integer not null, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp not null,
    constraint "ST_at_PR_isPlaying_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "ST_at_PR_isPlaying_Posit_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references public."PR_Program"("PR_ID"), 
    constraint "pkST_at_PR_isPlaying_Posit" primary key (
        "ST_at_PR_isPlaying_ID"
    ),
    constraint "uqST_at_PR_isPlaying" unique (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    )
) ORDER BY "ST_at_PR_isPlaying_ID" SEGMENTED BY MODULARHASH("ST_at_PR_isPlaying_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."ST_at_PR_isPlaying_Annex" (
    "ST_at_PR_isPlaying_ID" integer not null,
    "ST_at_PR_isPlaying_PositedAt" timestamp not null,
    "ST_at_PR_isPlaying_Positor" tinyint not null,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2) not null,
    "ST_at_PR_isPlaying_Assertion" char(1) default (
        case
            when "ST_at_PR_isPlaying_Reliability" > 0 then '+'
            when "ST_at_PR_isPlaying_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkST_at_PR_isPlaying_Annex" foreign key (
        "ST_at_PR_isPlaying_ID"
    ) references public."ST_at_PR_isPlaying_Posit"("ST_at_PR_isPlaying_ID"),
    constraint "pkST_at_PR_isPlaying_Annex" primary key (
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_Positor",
        "ST_at_PR_isPlaying_PositedAt"
    )
) ORDER BY "ST_at_PR_isPlaying_ID", "ST_at_PR_isPlaying_Positor", "ST_at_PR_isPlaying_PositedAt" SEGMENTED BY MODULARHASH("ST_at_PR_isPlaying_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS public."AC_parent_AC_child_PAT_having_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."AC_parent_AC_child_PAT_having_Posit" (
    "AC_parent_AC_child_PAT_having_ID" integer default nextval('public."AC_parent_AC_child_PAT_having_Posit_ID_SEQ"') not null, 
    "AC_ID_parent" integer not null, 
    "AC_ID_child" integer not null, 
    "PAT_ID_having" tinyint not null,
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_child" foreign key (
        "AC_ID_child"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references public."PAT_ParentalType"("PAT_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Posit" primary key (
        "AC_parent_AC_child_PAT_having_ID"
    ),
    constraint "uqAC_parent_AC_child_PAT_having" unique (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
) ORDER BY "AC_parent_AC_child_PAT_having_ID" SEGMENTED BY MODULARHASH("AC_parent_AC_child_PAT_having_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."AC_parent_AC_child_PAT_having_Annex" (
    "AC_parent_AC_child_PAT_having_ID" integer not null,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp not null,
    "AC_parent_AC_child_PAT_having_Positor" tinyint not null,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2) not null,
    "AC_parent_AC_child_PAT_having_Assertion" char(1) default (
        case
            when "AC_parent_AC_child_PAT_having_Reliability" > 0 then '+'
            when "AC_parent_AC_child_PAT_having_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkAC_parent_AC_child_PAT_having_Annex" foreign key (
        "AC_parent_AC_child_PAT_having_ID"
    ) references public."AC_parent_AC_child_PAT_having_Posit"("AC_parent_AC_child_PAT_having_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Annex" primary key (
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_Positor",
        "AC_parent_AC_child_PAT_having_PositedAt"
    )
) ORDER BY "AC_parent_AC_child_PAT_having_ID", "AC_parent_AC_child_PAT_having_Positor", "AC_parent_AC_child_PAT_having_PositedAt" SEGMENTED BY MODULARHASH("AC_parent_AC_child_PAT_having_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS public."PR_content_ST_location_EV_of_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS public."PR_content_ST_location_EV_of_Posit" (
    "PR_content_ST_location_EV_of_ID" integer default nextval('public."PR_content_ST_location_EV_of_Posit_ID_SEQ"') not null, 
    "PR_ID_content" integer not null, 
    "ST_ID_location" integer not null, 
    "EV_ID_of" integer not null, 
    constraint "PR_content_ST_location_EV_of_Posit_fkPR_content" foreign key (
        "PR_ID_content"
    ) references public."PR_Program"("PR_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_fkST_location" foreign key (
        "ST_ID_location"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references public."EV_Event"("EV_ID"), 
    constraint "pkPR_content_ST_location_EV_of_Posit" primary key (
        "PR_content_ST_location_EV_of_ID"
    ),
    constraint "uqPR_content_ST_location_EV_of" unique (
        "EV_ID_of",
        "PR_ID_content",
        "ST_ID_location"
    )
) ORDER BY "PR_content_ST_location_EV_of_ID" SEGMENTED BY MODULARHASH("PR_content_ST_location_EV_of_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS public."PR_content_ST_location_EV_of_Annex" (
    "PR_content_ST_location_EV_of_ID" integer not null,
    "PR_content_ST_location_EV_of_PositedAt" timestamp not null,
    "PR_content_ST_location_EV_of_Positor" tinyint not null,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2) not null,
    "PR_content_ST_location_EV_of_Assertion" char(1) default (
        case
            when "PR_content_ST_location_EV_of_Reliability" > 0 then '+'
            when "PR_content_ST_location_EV_of_Reliability" = 0 then '?'
            else '-'
        end
    ),
    constraint "fkPR_content_ST_location_EV_of_Annex" foreign key (
        "PR_content_ST_location_EV_of_ID"
    ) references public."PR_content_ST_location_EV_of_Posit"("PR_content_ST_location_EV_of_ID"),
    constraint "pkPR_content_ST_location_EV_of_Annex" primary key (
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_Positor",
        "PR_content_ST_location_EV_of_PositedAt"
    )
) ORDER BY "PR_content_ST_location_EV_of_ID", "PR_content_ST_location_EV_of_Positor", "PR_content_ST_location_EV_of_PositedAt" SEGMENTED BY MODULARHASH("PR_content_ST_location_EV_of_ID") ALL NODES;
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."AC_partner_AC_with_ONG_currently" AS
SELECT
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    public."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
;
CREATE OR REPLACE VIEW public."AC_subset_PN_of" AS
SELECT
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
;
CREATE OR REPLACE VIEW public."EV_in_AC_wasCast" AS
SELECT
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."EV_in_AC_wasCast_Annex" a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
;
CREATE OR REPLACE VIEW public."AC_part_PR_in_RAT_got" AS
SELECT
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."AC_part_PR_in_RAT_got_Posit" p
JOIN
    public."AC_part_PR_in_RAT_got_Annex" a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
;
CREATE OR REPLACE VIEW public."ST_at_PR_isPlaying" AS
SELECT
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."ST_at_PR_isPlaying_Posit" p
JOIN
    public."ST_at_PR_isPlaying_Annex" a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
;
CREATE OR REPLACE VIEW public."AC_parent_AC_child_PAT_having" AS
SELECT
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."AC_parent_AC_child_PAT_having_Annex" a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
;
CREATE OR REPLACE VIEW public."PR_content_ST_location_EV_of" AS
SELECT
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."PR_content_ST_location_EV_of_Annex" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
;
-- TIE REWINDERS ------------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of a tie with the latest row of their annex for each positor: what is known now about each posit,
-- which each positor asserts, retracts or denies. Vertica has no function that returns a table, so it is a view and shows what
-- is known now (the rewinders of the other databases can be asked about an earlier time, or about a positor); the perspectives
-- that Vertica has are over it.
--
CREATE OR REPLACE VIEW public."rAC_partner_AC_with_ONG_currently" AS
SELECT
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    public."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor"
    ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_subset_PN_of" AS
SELECT
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor"
    ORDER BY a."AC_subset_PN_of_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rEV_in_AC_wasCast" AS
SELECT
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."EV_in_AC_wasCast_Annex" a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor"
    ORDER BY a."EV_in_AC_wasCast_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_part_PR_in_RAT_got" AS
SELECT
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."AC_part_PR_in_RAT_got_Posit" p
JOIN
    public."AC_part_PR_in_RAT_got_Annex" a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor"
    ORDER BY a."AC_part_PR_in_RAT_got_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rST_at_PR_isPlaying" AS
SELECT
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."ST_at_PR_isPlaying_Posit" p
JOIN
    public."ST_at_PR_isPlaying_Annex" a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor"
    ORDER BY a."ST_at_PR_isPlaying_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rAC_parent_AC_child_PAT_having" AS
SELECT
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."AC_parent_AC_child_PAT_having_Annex" a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor"
    ORDER BY a."AC_parent_AC_child_PAT_having_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW public."rPR_content_ST_location_EV_of" AS
SELECT
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."PR_content_ST_location_EV_of_Annex" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor"
    ORDER BY a."PR_content_ST_location_EV_of_PositedAt" DESC
)
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the
-- now perspectives take none, and are views over the rewinder of the tie (a view that shows the latest annex row of every
-- posit for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."AC_partner_AC_with_ONG_currently_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "ONG_Ongoing",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_partner_AC_with_ONG_currently_Assertion" <> '?' THEN r."AC_partner_AC_with_ONG_currently_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            public."rAC_partner_AC_with_ONG_currently" r
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = '+'
    AND
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW public."nAC_partner_AC_with_ONG_currently" AS
SELECT
    t."AC_partner_AC_with_ONG_currently_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "ONG_Ongoing",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_partner_AC_with_ONG_currently_Assertion" <> '?' THEN r."AC_partner_AC_with_ONG_currently_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            public."rAC_partner_AC_with_ONG_currently" r
        WHERE
            r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = '+'
    AND
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW public."lAC_subset_PN_of" AS
SELECT
    t."AC_subset_PN_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_subset_PN_of" r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = '+'
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" AS
SELECT
    t."AC_subset_PN_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_subset_PN_of" r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = '+'
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" AS
SELECT
    t."EV_in_AC_wasCast_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Positor",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Reliability" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_in_AC_wasCast" r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" AS
SELECT
    t."EV_in_AC_wasCast_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Positor",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Reliability" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_in_AC_wasCast" r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" AS
SELECT
    t."AC_part_PR_in_RAT_got_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Positor",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Reliability" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_part_PR_in_RAT_got_Assertion" <> '?' THEN r."AC_part_PR_in_RAT_got_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            public."rAC_part_PR_in_RAT_got" r
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Assertion" = '+'
    AND
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nAC_part_PR_in_RAT_got" AS
SELECT
    t."AC_part_PR_in_RAT_got_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Positor",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Reliability" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_part_PR_in_RAT_got_Assertion" <> '?' THEN r."AC_part_PR_in_RAT_got_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            public."rAC_part_PR_in_RAT_got" r
        WHERE
            r."AC_part_PR_in_RAT_got_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Assertion" = '+'
    AND
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lST_at_PR_isPlaying" AS
SELECT
    t."ST_at_PR_isPlaying_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Positor",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Reliability" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_isPlaying_Assertion" <> '?' THEN r."ST_at_PR_isPlaying_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            public."rST_at_PR_isPlaying" r
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Assertion" = '+'
    AND
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" AS
SELECT
    t."ST_at_PR_isPlaying_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Positor",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Reliability" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_isPlaying_Assertion" <> '?' THEN r."ST_at_PR_isPlaying_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            public."rST_at_PR_isPlaying" r
        WHERE
            r."ST_at_PR_isPlaying_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Assertion" = '+'
    AND
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" AS
SELECT
    t."AC_parent_AC_child_PAT_having_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "PAT_ParentalType",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Positor",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Reliability" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_parent_AC_child_PAT_having" r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Assertion" = '+'
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" AS
SELECT
    t."AC_parent_AC_child_PAT_having_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "PAT_ParentalType",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Positor",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Reliability" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_parent_AC_child_PAT_having" r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Assertion" = '+'
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" AS
SELECT
    t."PR_content_ST_location_EV_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."PR_content_ST_location_EV_of_Positor",
                s."EV_ID_of"
            ORDER BY
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Reliability" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_content_ST_location_EV_of" r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" AS
SELECT
    t."PR_content_ST_location_EV_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."PR_content_ST_location_EV_of_Positor",
                s."EV_ID_of"
            ORDER BY
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Reliability" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_content_ST_location_EV_of" r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Assertion" = '+'
) t
WHERE
    t."latest" = 1
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
COMMENT ON COLUMN public."EV_DAT_Event_Date_Posit"."EV_DAT_Event_Date" IS 'Date and time when the event took place.';
COMMENT ON COLUMN public."EV_AUD_Event_Audience_Posit"."EV_AUD_Event_Audience" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public."EV_REV_Event_Revenue_Posit"."EV_REV_Event_Revenue" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public."ST_NAM_Stage_Name_Posit"."ST_NAM_Stage_Name" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public."ST_LOC_Stage_Location_Posit"."ST_LOC_Stage_Location" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public."ST_AVG_Stage_Average_Posit"."UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public."ST_MIN_Stage_Minimum_Posit"."UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public."AC_NAM_Actor_Name_Posit"."AC_NAM_Actor_Name" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public."AC_GEN_Actor_Gender_Posit"."GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN public."AC_PLV_Actor_ProfessionalLevel_Posit"."PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN public."PR_NAM_Program_Name_Posit"."PR_NAM_Program_Name" IS 'Name or title of the program.';
COMMENT ON COLUMN public."PR_LEN_Program_Length_Posit"."PR_LEN_Program_Length" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE public."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE public."ST_Stage" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE public."AC_Actor" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE public."PR_Program" IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE public."EV_Event" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN public."EV_Event"."ST_ID_wasHeldAt" IS 'The stage at which the event was held.';
COMMENT ON COLUMN public."EV_Event"."PR_ID_wasPlayed" IS 'The program that was played at the event.';
COMMENT ON COLUMN public."EV_Event"."ETY_ID_of" IS 'The type of the event.';
COMMENT ON TABLE public."AC_partner_AC_with_ONG_currently_Posit" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently_Posit"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE public."AC_subset_PN_of_Posit" IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN public."AC_subset_PN_of_Posit"."AC_ID_subset" IS 'The actor.';
COMMENT ON COLUMN public."AC_subset_PN_of_Posit"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE public."EV_in_AC_wasCast_Posit" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN public."EV_in_AC_wasCast_Posit"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN public."EV_in_AC_wasCast_Posit"."AC_ID_wasCast" IS 'An actor cast in the event.';
COMMENT ON TABLE public."AC_part_PR_in_RAT_got_Posit" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got_Posit"."AC_ID_part" IS 'The actor having a part in the program.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got_Posit"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got_Posit"."RAT_ID_got" IS 'The rating the actor got for the part.';
COMMENT ON TABLE public."ST_at_PR_isPlaying_Posit" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN public."ST_at_PR_isPlaying_Posit"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN public."ST_at_PR_isPlaying_Posit"."PR_ID_isPlaying" IS 'The program playing at the stage.';
COMMENT ON TABLE public."AC_parent_AC_child_PAT_having_Posit" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having_Posit"."AC_ID_parent" IS 'The actor who is the parent.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having_Posit"."AC_ID_child" IS 'The actor who is the child.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having_Posit"."PAT_ID_having" IS 'The type of parental relationship.';
COMMENT ON TABLE public."PR_content_ST_location_EV_of_Posit" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of_Posit"."PR_ID_content" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of_Posit"."ST_ID_location" IS 'The stage where the event was located.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of_Posit"."EV_ID_of" IS 'The event.';
