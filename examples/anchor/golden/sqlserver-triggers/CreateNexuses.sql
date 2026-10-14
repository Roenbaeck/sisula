-- NEXUSES -----------------------------------------------------------------------------------------------------------
--
-- Nexuses (event-like constructs) store identities of composite event instances and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Nexus table -------------------------------------------------------------------------------------------------------
-- EV_Event table (with 1 attributes and 1 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.EV_Event', 'U') IS NULL
CREATE TABLE [dbo].[EV_Event] (
    EV_ID int IDENTITY(1,1) not null,
    SU_ID_for int not null, 
    constraint EV_Event_fkSU_for foreign key (
        SU_ID_for
    ) references [dbo].[SU_Subject](SU_ID), 
    Metadata_EV int not null, 
    constraint pkEV_Event primary key (
        EV_ID asc
    )
);
GO
