-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GRD_Grade table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE GRD_Grade (
            GRD_ID number(5) not null,
            GRD_Grade nvarchar2(42) not null,
            Metadata_GRD number(10) not null,
            constraint pkGRD_Grade primary key (
                GRD_ID
            ),
            constraint uqGRD_Grade unique (
                GRD_Grade
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
