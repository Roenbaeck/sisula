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
    ) references knots."ETY_Händelsetyp"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Händelse" primary key (
        "EV_ID"
    )
);
