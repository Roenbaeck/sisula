-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- BigQuery has no sequences: the load gives an identity to every new event.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Händelse table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.`EV_Händelse` (
    `EV_ID` numeric(12,0) not null,
    `ST_ID_hölls` int64 not null, 
    `PR_ID_spelades` int64 not null, 
    `ETY_ID_of` int64 not null,
    `Metadata_EV` int64 not null, 
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_Händelse_fkST_hölls` FOREIGN KEY (`ST_ID_hölls`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Händelse_fkPR_spelades` FOREIGN KEY (`PR_ID_spelades`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Händelse_fkETY_of` FOREIGN KEY (`ETY_ID_of`) REFERENCES
        knots.`ETY_Händelsetyp`(`ETY_ID`) NOT ENFORCED
)
CLUSTER BY `EV_ID`;
