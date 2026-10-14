-- NEXUSES -----------------------------------------------------------------------------------------------------------
--
-- Nexuses (event-like constructs) store identities of composite event instances and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Nexus table -------------------------------------------------------------------------------------------------------
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('nexuses.EV_Event', 'U') IS NULL
CREATE TABLE [nexuses].[EV_Event] (
    EV_ID numeric(12,0) not null,
    ST_ID_wasHeldAt int not null, 
    PR_ID_wasPlayed bigint not null, 
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references [anchors].[ST_Stage](ST_ID), 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references [anchors].[PR_Program](PR_ID), 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references [knots].[ETY_EventType](ETY_ID),
    Metadata_EV bigint not null, 
    constraint pkEV_Event primary key (
        EV_ID asc
    )
);
GO
