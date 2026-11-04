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
    )
) ORDER BY "Positor" UNSEGMENTED ALL NODES;
INSERT INTO public."_Positor" (
    "Positor"
)
SELECT
    0
WHERE NOT EXISTS (
    SELECT
        1
    FROM
        public."_Positor"
    WHERE
        "Positor" = 0
);
