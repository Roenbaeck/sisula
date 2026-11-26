-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses store immutable identities for event-like entities.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE nexuses.EV_Händelse (
            EV_ID number(12,0) not null,
            ST_ID_hölls number(10) not null, 
            PR_ID_spelades number(19) not null, 
            ETY_ID_of number(3) not null,
            Metadata_EV number(10) not null, 
            constraint EV_Händelse_fkST_hölls foreign key (
                ST_ID_hölls
            ) references anchors.ST_Scen(ST_ID),
            constraint EV_Händelse_fkPR_spelades foreign key (
                PR_ID_spelades
            ) references anchors.PR_Föreställning(PR_ID),
            constraint EV_Händelse_fkETY_of foreign key (
                ETY_ID_of
            ) references knots.ETY_Händelsetyp(ETY_ID),
            constraint pkEV_Händelse primary key (
                EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
