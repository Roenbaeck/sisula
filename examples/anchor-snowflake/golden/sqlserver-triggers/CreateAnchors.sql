-- ANCHORS -----------------------------------------------------------------------------------------------------------
--
-- Anchors store the identities of entities and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- SU_Subject table (with 12 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_Subject', 'U') IS NULL
CREATE TABLE [dbo].[SU_Subject] (
    SU_ID int IDENTITY(1,1) not null,
    Metadata_SU int not null, 
    constraint pkSU_Subject primary key (
        SU_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- OB_Object table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_Object', 'U') IS NULL
CREATE TABLE [dbo].[OB_Object] (
    OB_ID int IDENTITY(1,1) not null,
    Metadata_OB int not null, 
    constraint pkOB_Object primary key (
        OB_ID asc
    )
);
GO
