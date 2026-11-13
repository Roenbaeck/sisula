-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw.`_Who` (
    `Who` int64 not null,
    PRIMARY KEY (
        `Who`
    ) NOT ENFORCED
);
MERGE INTO dw.`_Who` p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p.`Who`
)
WHEN NOT MATCHED THEN
INSERT (
    `Who`
)
VALUES (
    d._defaultPositor
);
