-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- The table is called Who_ (PostgreSQL has an underscore first, which an unquoted Oracle name cannot start with).
--
-- Positor table ------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE dw.Who_ (
            Who number(5) not null,
            constraint pk_Who primary key (
                Who
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
INSERT INTO dw.Who_ (
    Who
)
SELECT
    0
FROM
    dual
WHERE NOT EXISTS (
    SELECT
        1
    FROM
        dw.Who_ p
    WHERE
        p.Who = 0
);
