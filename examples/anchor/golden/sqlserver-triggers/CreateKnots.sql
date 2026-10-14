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
IF Object_ID('dbo.GRD_Grade', 'U') IS NULL
CREATE TABLE [dbo].[GRD_Grade] (
    GRD_ID tinyint not null,
    GRD_Grade nvarchar(42) not null,
    Metadata_GRD int not null,
    constraint pkGRD_Grade primary key (
        GRD_ID asc
    ),
    constraint uqGRD_Grade unique (
        GRD_Grade
    )
);
GO
