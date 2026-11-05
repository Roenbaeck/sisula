-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
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
