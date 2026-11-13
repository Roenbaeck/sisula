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
-- PAT_Föräldratyp table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.PAT_Föräldratyp (
            PAT_ID number(3) not null,
            PAT_Föräldratyp nvarchar2(42) not null,
            Metadata_PAT number(10) not null,
            constraint pkPAT_Föräldratyp primary key (
                PAT_ID
            ),
            constraint uqPAT_Föräldratyp unique (
                PAT_Föräldratyp
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.GEN_Kön (
            GEN_ID number(3) not null,
            GEN_Kön nvarchar2(42) not null,
            GEN_Checksum raw(16) generated always as (standard_hash(GEN_Kön, 'MD5')) virtual,
            Metadata_GEN number(10) not null,
            constraint pkGEN_Kön primary key (
                GEN_ID
            ),
            constraint uqGEN_Kön unique (
                GEN_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.PLV_Yrkesnivå (
            PLV_ID number(3) not null,
            PLV_Yrkesnivå nclob not null,
            PLV_Checksum raw(16) generated always as (standard_hash(PLV_Yrkesnivå, 'MD5')) virtual,
            Metadata_PLV number(10) not null,
            constraint pkPLV_Yrkesnivå primary key (
                PLV_ID
            ),
            constraint uqPLV_Yrkesnivå unique (
                PLV_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.UTL_Utnyttjande (
            UTL_ID number(3) not null,
            UTL_Utnyttjande number(3) not null,
            Metadata_UTL number(10) not null,
            constraint pkUTL_Utnyttjande primary key (
                UTL_ID
            ),
            constraint uqUTL_Utnyttjande unique (
                UTL_Utnyttjande
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.ONG_Pågående (
            ONG_ID number(3) not null,
            ONG_Pågående nvarchar2(3) not null,
            Metadata_ONG number(10) not null,
            constraint pkONG_Pågående primary key (
                ONG_ID
            ),
            constraint uqONG_Pågående unique (
                ONG_Pågående
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE knots.RAT_Betyg_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.RAT_Betyg (
            RAT_ID number(3) default knots.RAT_Betyg_ID_SEQ.nextval not null, 
            RAT_Betyg nvarchar2(42) not null,
            RAT_Checksum raw(16) generated always as (standard_hash(RAT_Betyg, 'MD5')) virtual,
            Metadata_RAT number(10) not null,
            constraint pkRAT_Betyg primary key (
                RAT_ID
            ),
            constraint uqRAT_Betyg unique (
                RAT_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE knots.ETY_Händelsetyp (
            ETY_ID number(3) not null,
            ETY_Händelsetyp nvarchar2(42) not null,
            ETY_Checksum raw(16) generated always as (standard_hash(ETY_Händelsetyp, 'MD5')) virtual,
            Metadata_ETY number(10) not null,
            constraint pkETY_Händelsetyp primary key (
                ETY_ID
            ),
            constraint uqETY_Händelsetyp unique (
                ETY_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
