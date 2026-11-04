-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw."_Who" (
    "Who" smallint not null,
    constraint "pk_Who" primary key (
        "Who"
    )
);
INSERT INTO dw."_Who" (
    "Who"
)
VALUES (
    0
)
ON CONFLICT DO NOTHING;
