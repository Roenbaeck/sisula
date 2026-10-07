-- ANCHORS -----------------------------------------------------------------------------------------------------------
--
-- Anchors store the identities of entities and are immutable.
-- (Attribute tables moved to CreateAttributes.js.)
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.PN_Person', 'U') IS NULL
CREATE TABLE [anchors].[PN_Person] (
    PN_ID bigint IDENTITY(1,1) not null,
    Metadata_PN bigint not null, 
    constraint pkPN_Person primary key (
        PN_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.ST_Stage', 'U') IS NULL
CREATE TABLE [anchors].[ST_Stage] (
    ST_ID int not null,
    Metadata_ST bigint not null, 
    constraint pkST_Stage primary key (
        ST_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.AC_Actor', 'U') IS NULL
CREATE TABLE [anchors].[AC_Actor] (
    AC_ID smallint IDENTITY(1,1) not null,
    Metadata_AC bigint not null, 
    constraint pkAC_Actor primary key (
        AC_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('anchors.PR_Program', 'U') IS NULL
CREATE TABLE [anchors].[PR_Program] (
    PR_ID bigint not null,
    Metadata_PR bigint not null, 
    constraint pkPR_Program primary key (
        PR_ID asc
    )
);
GO
