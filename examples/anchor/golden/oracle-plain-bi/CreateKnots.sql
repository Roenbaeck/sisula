-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PAT_ParentalType (
            PAT_ID number(3) not null,
            PAT_ParentalType nvarchar2(42) not null,
            constraint pkPAT_ParentalType primary key (
                PAT_ID
            ),
            constraint uqPAT_ParentalType unique (
                PAT_ParentalType
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE GEN_Gender (
            GEN_ID number(3) not null,
            GEN_Gender nvarchar2(42) not null,
            constraint pkGEN_Gender primary key (
                GEN_ID
            ),
            constraint uqGEN_Gender unique (
                GEN_Gender
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE PLV_ProfessionalLevel (
            PLV_ID number(3) not null,
            PLV_ProfessionalLevel nclob not null,
            PLV_Checksum raw(16) generated always as (standard_hash(PLV_ProfessionalLevel, 'MD5')) virtual,
            constraint pkPLV_ProfessionalLevel primary key (
                PLV_ID
            ),
            constraint uqPLV_ProfessionalLevel unique (
                PLV_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE UTL_Utilization (
            UTL_ID number(3) not null,
            UTL_Utilization number(3) not null,
            constraint pkUTL_Utilization primary key (
                UTL_ID
            ),
            constraint uqUTL_Utilization unique (
                UTL_Utilization
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ONG_Ongoing (
            ONG_ID number(3) not null,
            ONG_Ongoing nvarchar2(3) not null,
            constraint pkONG_Ongoing primary key (
                ONG_ID
            ),
            constraint uqONG_Ongoing unique (
                ONG_Ongoing
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE RAT_Rating (
            RAT_ID number(3) not null,
            RAT_Rating nvarchar2(42) not null,
            constraint pkRAT_Rating primary key (
                RAT_ID
            ),
            constraint uqRAT_Rating unique (
                RAT_Rating
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ETY_EventType (
            ETY_ID number(3) not null,
            ETY_EventType nvarchar2(42) not null,
            constraint pkETY_EventType primary key (
                ETY_ID
            ),
            constraint uqETY_EventType unique (
                ETY_EventType
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
