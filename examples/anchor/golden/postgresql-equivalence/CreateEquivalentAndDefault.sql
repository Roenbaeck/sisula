-- EQUIVALENTS METADATA -----------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available equivalents. Since at least one equivalent
-- must be available the table is set up with a default equivalent with identity 0.
--
-- Equivalent table ---------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."_EQ" (
    "EQ" smallint not null,
    constraint "pk_EQ" primary key (
        "EQ" 
    )
);
INSERT INTO public."_EQ" (
    "EQ"
)
VALUES (
    0
)
ON CONFLICT DO NOTHING;
