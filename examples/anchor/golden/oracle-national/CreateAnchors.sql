-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE anchors.PN_Person_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.PN_Person (
            PN_ID number(19) default anchors.PN_Person_ID_SEQ.nextval not null, 
            Metadata_PN number(10) not null, 
            constraint pkPN_Person primary key (
                PN_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.ST_Scen (
            ST_ID number(10) not null,
            Metadata_ST number(10) not null, 
            constraint pkST_Scen primary key (
                ST_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE anchors.AC_Skådespelare_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.AC_Skådespelare (
            AC_ID number(5) default anchors.AC_Skådespelare_ID_SEQ.nextval not null, 
            Metadata_AC number(10) not null, 
            constraint pkAC_Skådespelare primary key (
                AC_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE anchors.PR_Föreställning (
            PR_ID number(19) not null,
            Metadata_PR number(10) not null, 
            constraint pkPR_Föreställning primary key (
                PR_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
