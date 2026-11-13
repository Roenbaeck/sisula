-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- The table is called Positor_ (PostgreSQL has an underscore first, which an unquoted Oracle name cannot start with).
--
-- Positor table ------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE dw.Positor_ (
            Positor number(3) not null,
            constraint pk_Positor primary key (
                Positor
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
INSERT INTO dw.Positor_ (
    Positor
)
SELECT
    0
FROM
    dual
WHERE NOT EXISTS (
    SELECT
        1
    FROM
        dw.Positor_ p
    WHERE
        p.Positor = 0
);
