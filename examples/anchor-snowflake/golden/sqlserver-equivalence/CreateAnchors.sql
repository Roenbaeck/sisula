-- ANCHORS -----------------------------------------------------------------------------------------------------------
--
-- Anchors store the identities of entities and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PN_Person', 'U') IS NULL
CREATE TABLE [dbo].[PN_Person] (
    PN_ID int IDENTITY(1,1) not null,
    Metadata_PN int not null, 
    constraint pkPN_Person primary key (
        PN_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage', 'U') IS NULL
CREATE TABLE [dbo].[ST_Stage] (
    ST_ID int IDENTITY(1,1) not null,
    Metadata_ST int not null, 
    constraint pkST_Stage primary key (
        ST_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor', 'U') IS NULL
CREATE TABLE [dbo].[AC_Actor] (
    AC_ID int IDENTITY(1,1) not null,
    Metadata_AC int not null, 
    constraint pkAC_Actor primary key (
        AC_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program', 'U') IS NULL
CREATE TABLE [dbo].[PR_Program] (
    PR_ID int IDENTITY(1,1) not null,
    Metadata_PR int not null, 
    constraint pkPR_Program primary key (
        PR_ID asc
    )
);
GO
