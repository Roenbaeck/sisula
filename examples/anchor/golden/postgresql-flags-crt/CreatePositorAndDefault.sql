-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw."_Positor" (
    "Positor" smallint not null,
    constraint "pk_Positor" primary key (
        "Positor"
    )
);
INSERT INTO dw."_Positor" (
    "Positor"
)
VALUES (
    0
)
ON CONFLICT DO NOTHING;
