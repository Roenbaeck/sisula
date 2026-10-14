-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."_Positor" (
    "Positor" tinyint not null,
    constraint "pk_Positor" primary key (
        "Positor"
    ) RELY
);
MERGE INTO public."_Positor" p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p."Positor"
)
WHEN NOT MATCHED THEN
INSERT (
    "Positor"
)
VALUES (
    d._defaultPositor
);
