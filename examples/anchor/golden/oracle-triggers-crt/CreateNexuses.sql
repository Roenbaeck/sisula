-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 2 attributes and 1 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE EV_Event_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE EV_Event (
            EV_ID number(10) default EV_Event_ID_SEQ.nextval not null, 
            SU_ID_for number(10) not null, 
            Metadata_EV number(10) not null, 
            constraint EV_Event_fkSU_for foreign key (
                SU_ID_for
            ) references SU_Subject(SU_ID),
            constraint pkEV_Event primary key (
                EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
