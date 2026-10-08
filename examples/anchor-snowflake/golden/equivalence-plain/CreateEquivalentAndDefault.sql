-- EQUIVALENTS METADATA -----------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available equivalents. Since at least one equivalent
-- must be available the table is set up with a default equivalent with identity 0.
--
-- Equivalent table ---------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."_EQ" (
    "EQ" tinyint not null,
    constraint "pk_EQ" primary key (
        "EQ" 
    ) RELY
);
MERGE INTO public."_EQ" e
USING ( SELECT 0 AS _defaultEquivalent ) d
ON (
    d._defaultEquivalent = e."EQ"
)
WHEN NOT MATCHED THEN
INSERT (
    "EQ"
)
VALUES (
    d._defaultEquivalent
);
