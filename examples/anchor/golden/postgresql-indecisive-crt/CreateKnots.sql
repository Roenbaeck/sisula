-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GRD_Grade table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GRD_Grade" (
    "GRD_ID" smallint not null,
    "GRD_Grade" varchar(42) not null,
    "Metadata_GRD" integer not null,
    constraint "pkGRD_Grade" primary key (
        "GRD_ID" 
    ),
    constraint "uqGRD_Grade" unique (
        "GRD_Grade"
    )
);
