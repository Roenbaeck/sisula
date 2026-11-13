-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- BigQuery has no sequences: the load gives an identity to every new event.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.`EV_Event` (
    `EV_ID` numeric(12,0) not null,
    `ST_ID_wasHeldAt` int64 not null, 
    `PR_ID_wasPlayed` int64 not null, 
    `ETY_ID_of` int64 not null,
    `Metadata_EV` int64 not null, 
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkST_wasHeldAt` FOREIGN KEY (`ST_ID_wasHeldAt`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkPR_wasPlayed` FOREIGN KEY (`PR_ID_wasPlayed`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkETY_of` FOREIGN KEY (`ETY_ID_of`) REFERENCES
        knots.`ETY_EventType`(`ETY_ID`) NOT ENFORCED
)
CLUSTER BY `EV_ID`;
