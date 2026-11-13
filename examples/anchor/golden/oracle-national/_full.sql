-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- In Oracle a schema is a user, which a script does not create. The schemas that the model puts its tables, views,
-- functions and procedures in must exist before this script is run, and the user that runs it needs the privileges to
-- create those objects in them (CREATE ANY TABLE, CREATE ANY VIEW, ... or the same privileges on each schema).
--
-- The schemas of this model are
--
--   dw
--   knots
--   anchors
--   nexuses
--   attributes
--   ties
--
-- A model whose schema is public, or that has none, creates everything in the schema that the script is run in.
--
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
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Händelse table (with 6 attributes and 3 roles)
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
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- An attribute that may be deleted (deletability) also has a deletion table, which holds what was deleted and when.
-- Oracle cannot make a table in a trigger without ending the transaction, so these are made here, not when needed.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Händelse_Datum (
            EV_DAT_EV_ID number(12,0) not null,
            EV_DAT_Händelse_Datum timestamp not null,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Händelse_Datum foreign key (
                EV_DAT_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_DAT_Händelse_Datum primary key (
                EV_DAT_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Händelse_Publik (
            EV_AUD_EV_ID number(12,0) not null,
            EV_AUD_Händelse_Publik number(10) not null,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Händelse_Publik foreign key (
                EV_AUD_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_AUD_Händelse_Publik primary key (
                EV_AUD_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Händelse_Intäkt (
            EV_REV_EV_ID number(12,0) not null,
            EV_REV_Händelse_Intäkt number(19,4) not null,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Händelse_Intäkt foreign key (
                EV_REV_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_REV_Händelse_Intäkt primary key (
                EV_REV_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Händelse_Status (
            EV_STA_EV_ID number(12,0) not null,
            EV_STA_Händelse_Status nvarchar2(20) not null,
            EV_STA_ChangedAt timestamp not null,
            Metadata_EV_STA number(10) not null,
            constraint fkEV_STA_Händelse_Status foreign key (
                EV_STA_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_STA_Händelse_Status primary key (
                EV_STA_EV_ID,
                EV_STA_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Händelse_Utnyttjande (
            EV_UTL_EV_ID number(12,0) not null,
            EV_UTL_UTL_ID number(3) not null,
            Metadata_EV_UTL number(10) not null,
            constraint fk_A_EV_UTL_Händelse_Utnyttjande foreign key (
                EV_UTL_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint fk_K_EV_UTL_Händelse_Utnyttjande foreign key (
                EV_UTL_UTL_ID
            ) references knots.UTL_Utnyttjande(UTL_ID),
            constraint pkEV_UTL_Händelse_Utnyttjande primary key (
                EV_UTL_EV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Händelse_Level (
            EV_LVL_EV_ID number(12,0) not null,
            EV_LVL_PLV_ID number(3) not null,
            EV_LVL_ChangedAt date not null,
            Metadata_EV_LVL number(10) not null,
            constraint fk_A_EV_LVL_Händelse_Level foreign key (
                EV_LVL_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint fk_K_EV_LVL_Händelse_Level foreign key (
                EV_LVL_PLV_ID
            ) references knots.PLV_Yrkesnivå(PLV_ID),
            constraint pkEV_LVL_Händelse_Level primary key (
                EV_LVL_EV_ID,
                EV_LVL_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Scen_Namn (
            ST_NAM_ST_ID number(10) not null,
            ST_NAM_Scen_Namn nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Scen_Namn foreign key (
                ST_NAM_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint pkST_NAM_Scen_Namn primary key (
                ST_NAM_ST_ID,
                ST_NAM_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Scen_Plats (
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Scen_Plats varchar2(100) not null,
            ST_LOC_Checksum raw(16) generated always as (standard_hash(ST_LOC_Scen_Plats, 'MD5')) virtual,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Scen_Plats foreign key (
                ST_LOC_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint pkST_LOC_Scen_Plats primary key (
                ST_LOC_ST_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Scen_Medel (
            ST_AVG_ST_ID number(10) not null,
            ST_AVG_UTL_ID number(3) not null,
            ST_AVG_ChangedAt timestamp not null,
            Metadata_ST_AVG number(10) not null,
            constraint fk_A_ST_AVG_Scen_Medel foreign key (
                ST_AVG_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint fk_K_ST_AVG_Scen_Medel foreign key (
                ST_AVG_UTL_ID
            ) references knots.UTL_Utnyttjande(UTL_ID),
            constraint pkST_AVG_Scen_Medel primary key (
                ST_AVG_ST_ID,
                ST_AVG_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Scen_Minimum (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(3) not null,
            Metadata_ST_MIN number(10) not null,
            constraint fk_A_ST_MIN_Scen_Minimum foreign key (
                ST_MIN_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint fk_K_ST_MIN_Scen_Minimum foreign key (
                ST_MIN_UTL_ID
            ) references knots.UTL_Utnyttjande(UTL_ID),
            constraint pkST_MIN_Scen_Minimum primary key (
                ST_MIN_ST_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Deletion table -----------------------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Deleted table (what was deleted from ST_MIN_Scen_Minimum, and when)
-- It has the columns of the attribute table, without keys and without the checksum, and the time of the deletion.
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Scen_Minimum_Deleted (
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(3) not null,
            Metadata_ST_MIN number(10) not null,
            ST_MIN_Deleted timestamp(9) not null
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Skådespelare_Namn (
            AC_NAM_AC_ID number(5) not null,
            AC_NAM_Skådespelare_Namn nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Skådespelare_Namn foreign key (
                AC_NAM_AC_ID
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint pkAC_NAM_Skådespelare_Namn primary key (
                AC_NAM_AC_ID,
                AC_NAM_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Skådespelare_Kön (
            AC_GEN_AC_ID number(5) not null,
            AC_GEN_GEN_ID number(3) not null,
            Metadata_AC_GEN number(10) not null,
            constraint fk_A_AC_GEN_Skådespelare_Kön foreign key (
                AC_GEN_AC_ID
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint fk_K_AC_GEN_Skådespelare_Kön foreign key (
                AC_GEN_GEN_ID
            ) references knots.GEN_Kön(GEN_ID),
            constraint pkAC_GEN_Skådespelare_Kön primary key (
                AC_GEN_AC_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Skådespelare_Yrkesnivå (
            AC_PLV_AC_ID number(5) not null,
            AC_PLV_PLV_ID number(3) not null,
            AC_PLV_ChangedAt timestamp not null,
            Metadata_AC_PLV number(10) not null,
            constraint fk_A_AC_PLV_Skådespelare_Yrkesnivå foreign key (
                AC_PLV_AC_ID
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint fk_K_AC_PLV_Skådespelare_Yrkesnivå foreign key (
                AC_PLV_PLV_ID
            ) references knots.PLV_Yrkesnivå(PLV_ID),
            constraint pkAC_PLV_Skådespelare_Yrkesnivå primary key (
                AC_PLV_AC_ID,
                AC_PLV_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Föreställning_Namn (
            PR_NAM_PR_ID number(19) not null,
            PR_NAM_Föreställning_Namn nvarchar2(42) not null,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Föreställning_Namn foreign key (
                PR_NAM_PR_ID
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkPR_NAM_Föreställning_Namn primary key (
                PR_NAM_PR_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Föreställning_Längd (
            PR_LEN_PR_ID number(19) not null,
            PR_LEN_Föreställning_Längd timestamp not null,
            PR_LEN_ChangedAt date not null,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Föreställning_Längd foreign key (
                PR_LEN_PR_ID
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkPR_LEN_Föreställning_Längd primary key (
                PR_LEN_PR_ID,
                PR_LEN_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- A tie that may be deleted (deletability) also has a deletion table, which holds what was deleted and when.
-- Oracle cannot make a table in a trigger without ending the transaction, so these are made here, not when needed.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently (
            AC_ID_partner number(5) not null, 
            AC_ID_with number(5) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
            constraint AC_partner_AC_with_ONG_currently_fkAC_partner foreign key (
                AC_ID_partner
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkAC_with foreign key (
                AC_ID_with
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_fkONG_currently foreign key (
                ONG_ID_currently
            ) references knots.ONG_Pågående(ONG_ID),
            constraint AC_partner_AC_with_ONG_currently_uqAC_partner unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint AC_partner_AC_with_ONG_currently_uqAC_with unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint pkAC_partner_AC_with_ONG_currently primary key (
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently,
                AC_partner_AC_with_ONG_currently_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_subset_PN_of (
            AC_ID_subset number(5) not null, 
            PN_ID_of number(19) not null, 
            Metadata_AC_subset_PN_of number(10) not null,
            constraint AC_subset_PN_of_fkAC_subset foreign key (
                AC_ID_subset
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_subset_PN_of_fkPN_of foreign key (
                PN_ID_of
            ) references anchors.PN_Person(PN_ID),
            constraint AC_subset_PN_of_uqAC_subset unique (
                AC_ID_subset
            ),
            constraint AC_subset_PN_of_uqPN_of unique (
                PN_ID_of
            ),
            constraint pkAC_subset_PN_of primary key (
                AC_ID_subset,
                PN_ID_of
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_rollsattes (
            EV_ID_in number(12,0) not null, 
            AC_ID_rollsattes number(5) not null, 
            Metadata_EV_in_AC_rollsattes number(10) not null,
            constraint EV_in_AC_rollsattes_fkEV_in foreign key (
                EV_ID_in
            ) references nexuses.EV_Händelse(EV_ID),
            constraint EV_in_AC_rollsattes_fkAC_rollsattes foreign key (
                AC_ID_rollsattes
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint pkEV_in_AC_rollsattes primary key (
                EV_ID_in,
                AC_ID_rollsattes
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_deltar_PR_in_RAT_fick (
            AC_ID_deltar number(5) not null, 
            PR_ID_in number(19) not null, 
            RAT_ID_fick number(3) not null,
            AC_deltar_PR_in_RAT_fick_ChangedAt timestamp not null,
            Metadata_AC_deltar_PR_in_RAT_fick number(10) not null,
            constraint AC_deltar_PR_in_RAT_fick_fkAC_deltar foreign key (
                AC_ID_deltar
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_deltar_PR_in_RAT_fick_fkPR_in foreign key (
                PR_ID_in
            ) references anchors.PR_Föreställning(PR_ID),
            constraint AC_deltar_PR_in_RAT_fick_fkRAT_fick foreign key (
                RAT_ID_fick
            ) references knots.RAT_Betyg(RAT_ID),
            constraint pkAC_deltar_PR_in_RAT_fick primary key (
                AC_ID_deltar,
                PR_ID_in,
                AC_deltar_PR_in_RAT_fick_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_spelas (
            ST_ID_at number(10) not null, 
            PR_ID_spelas number(19) not null, 
            ST_at_PR_spelas_ChangedAt timestamp not null,
            Metadata_ST_at_PR_spelas number(10) not null,
            constraint ST_at_PR_spelas_fkST_at foreign key (
                ST_ID_at
            ) references anchors.ST_Scen(ST_ID),
            constraint ST_at_PR_spelas_fkPR_spelas foreign key (
                PR_ID_spelas
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkST_at_PR_spelas primary key (
                ST_ID_at,
                PR_ID_spelas,
                ST_at_PR_spelas_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_förälder_AC_barn_PAT_har (
            AC_ID_förälder number(5) not null, 
            AC_ID_barn number(5) not null, 
            PAT_ID_har number(3) not null,
            Metadata_AC_förälder_AC_barn_PAT_har number(10) not null,
            constraint AC_förälder_AC_barn_PAT_har_fkAC_förälder foreign key (
                AC_ID_förälder
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_förälder_AC_barn_PAT_har_fkAC_barn foreign key (
                AC_ID_barn
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_förälder_AC_barn_PAT_har_fkPAT_har foreign key (
                PAT_ID_har
            ) references knots.PAT_Föräldratyp(PAT_ID),
            constraint pkAC_förälder_AC_barn_PAT_har primary key (
                AC_ID_förälder,
                AC_ID_barn,
                PAT_ID_har
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_innehåll_ST_plats_EV_of (
            PR_ID_innehåll number(19) not null, 
            ST_ID_plats number(10) not null, 
            EV_ID_of number(12,0) not null, 
            PR_innehåll_ST_plats_EV_of_ChangedAt timestamp not null,
            Metadata_PR_innehåll_ST_plats_EV_of number(10) not null,
            constraint PR_innehåll_ST_plats_EV_of_fkPR_innehåll foreign key (
                PR_ID_innehåll
            ) references anchors.PR_Föreställning(PR_ID),
            constraint PR_innehåll_ST_plats_EV_of_fkST_plats foreign key (
                ST_ID_plats
            ) references anchors.ST_Scen(ST_ID),
            constraint PR_innehåll_ST_plats_EV_of_fkEV_of foreign key (
                EV_ID_of
            ) references nexuses.EV_Händelse(EV_ID),
            constraint PR_innehåll_ST_plats_EV_of_uqPR_innehåll unique (
                PR_ID_innehåll,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            ),
            constraint PR_innehåll_ST_plats_EV_of_uqST_plats unique (
                ST_ID_plats,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            ),
            constraint pkPR_innehåll_ST_plats_EV_of primary key (
                PR_ID_innehåll,
                ST_ID_plats,
                EV_ID_of,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These SQL table macros rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(TIMESTAMP '2020-01-01 00:00:00').
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_STA_Händelse_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Händelse_Status (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_EV_ID,
            EV_STA_Händelse_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Händelse_Status
        WHERE
            EV_STA_ChangedAt <= changingTimepoint
    ]';
END rEV_STA_Händelse_Status;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Händelse_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Händelse_Level (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Händelse_Level
        WHERE
            EV_LVL_ChangedAt <= changingTimepoint
    ]';
END rEV_LVL_Händelse_Level;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Scen_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Scen_Namn (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Scen_Namn,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Scen_Namn
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Scen_Namn;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Scen_Medel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Scen_Medel (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Scen_Medel
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Scen_Medel;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Skådespelare_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Skådespelare_Namn (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Skådespelare_Namn,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Skådespelare_Namn
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Skådespelare_Namn;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Skådespelare_Yrkesnivå rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Skådespelare_Yrkesnivå (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Skådespelare_Yrkesnivå;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Föreställning_Längd rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Föreställning_Längd (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Föreställning_Längd,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Föreställning_Längd
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Föreställning_Längd;
/
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Scen (
    ST_ID,
    Metadata_ST,
    ST_NAM_ST_ID,
    Metadata_ST_NAM,
    ST_NAM_ChangedAt,
    ST_NAM_Scen_Namn,
    ST_LOC_ST_ID,
    Metadata_ST_LOC,
    ST_LOC_Checksum,
    ST_LOC_Scen_Plats,
    ST_AVG_ST_ID,
    Metadata_ST_AVG,
    ST_AVG_ChangedAt,
    ST_AVG_UTL_Utnyttjande,
    ST_AVG_Metadata_UTL,
    ST_AVG_UTL_ID,
    ST_MIN_ST_ID,
    Metadata_ST_MIN,
    Deletable_ST_MIN,
    ST_MIN_UTL_Utnyttjande,
    ST_MIN_Metadata_UTL,
    ST_MIN_UTL_ID
)
AS
SELECT
    "ST".ST_ID,
    "ST".Metadata_ST,
    "NAM".ST_NAM_ST_ID,
    "NAM".Metadata_ST_NAM,
    "NAM".ST_NAM_ChangedAt,
    "NAM".ST_NAM_Scen_Namn,
    "LOC".ST_LOC_ST_ID,
    "LOC".Metadata_ST_LOC,
    "LOC".ST_LOC_Checksum,
    "LOC".ST_LOC_Scen_Plats,
    "AVG".ST_AVG_ST_ID,
    "AVG".Metadata_ST_AVG,
    "AVG".ST_AVG_ChangedAt,
    "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
    "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
    "AVG".ST_AVG_UTL_ID,
    "MIN".ST_MIN_ST_ID,
    "MIN".Metadata_ST_MIN,
    CAST(NULL AS number(1)),
    "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
    "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
    "MIN".ST_MIN_UTL_ID
FROM
    anchors.ST_Scen "ST"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.ST_NAM_Scen_Namn a
        WHERE
            a.ST_NAM_ChangedAt = (
                SELECT
                    MAX(sub.ST_NAM_ChangedAt)
                FROM
                    attributes.ST_NAM_Scen_Namn sub
                WHERE
                    sub.ST_NAM_ST_ID = a.ST_NAM_ST_ID
            )
    ) "NAM"
ON
    "NAM".ST_NAM_ST_ID = "ST".ST_ID
LEFT JOIN
    attributes.ST_LOC_Scen_Plats "LOC"
ON
    "LOC".ST_LOC_ST_ID = "ST".ST_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.ST_AVG_Scen_Medel a
        WHERE
            a.ST_AVG_ChangedAt = (
                SELECT
                    MAX(sub.ST_AVG_ChangedAt)
                FROM
                    attributes.ST_AVG_Scen_Medel sub
                WHERE
                    sub.ST_AVG_ST_ID = a.ST_AVG_ST_ID
            )
    ) "AVG"
ON
    "AVG".ST_AVG_ST_ID = "ST".ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande "kAVG"
ON
    "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
LEFT JOIN
    attributes.ST_MIN_Scen_Minimum "MIN"
ON
    "MIN".ST_MIN_ST_ID = "ST".ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande "kMIN"
ON
    "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Scen (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Scen "ST"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.ST_NAM_Scen_Namn a
                WHERE
                    a.ST_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.ST_NAM_ChangedAt)
                        FROM
                            attributes.ST_NAM_Scen_Namn sub
                        WHERE
                            sub.ST_NAM_ST_ID = a.ST_NAM_ST_ID
                        AND
                            sub.ST_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        LEFT JOIN
            attributes.ST_LOC_Scen_Plats "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.ST_AVG_Scen_Medel a
                WHERE
                    a.ST_AVG_ChangedAt = (
                        SELECT
                            MAX(sub.ST_AVG_ChangedAt)
                        FROM
                            attributes.ST_AVG_Scen_Medel sub
                        WHERE
                            sub.ST_AVG_ST_ID = a.ST_AVG_ST_ID
                        AND
                            sub.ST_AVG_ChangedAt <= changingTimepoint
                    )
            ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN
            attributes.ST_MIN_Scen_Minimum "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END pST_Scen;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nST_Scen
AS
SELECT
    *
FROM
    anchors.pST_Scen(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dST_Scen (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ChangedAt,
            "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM (
            SELECT DISTINCT
                h.ST_NAM_ST_ID AS ST_ID,
                CAST(h.ST_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.ST_NAM_Scen_Namn h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.ST_AVG_ST_ID AS ST_ID,
                CAST(h.ST_AVG_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'AVG' AS mnemonic
            FROM
                attributes.ST_AVG_Scen_Medel h
            WHERE
                (selection IS NULL OR selection LIKE '%AVG%')
            AND
                h.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            anchors.ST_Scen "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_NAM_ChangedAt) OVER (
                    PARTITION BY h.ST_NAM_ST_ID
                    ORDER BY h.ST_NAM_ChangedAt
                ) AS untilTime
            FROM
                attributes.ST_NAM_Scen_Namn h
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.ST_LOC_Scen_Plats "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.ST_AVG_ChangedAt) OVER (
                    PARTITION BY h.ST_AVG_ST_ID
                    ORDER BY h.ST_AVG_ChangedAt
                ) AS untilTime
            FROM
                attributes.ST_AVG_Scen_Medel h
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "AVG".untilTime IS NULL
        OR
            "AVG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.UTL_Utnyttjande "kAVG"
        ON
            "kAVG".UTL_ID = "AVG".ST_AVG_UTL_ID
        LEFT JOIN
            attributes.ST_MIN_Scen_Minimum "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Scen;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Skådespelare (
    AC_ID,
    Metadata_AC,
    AC_NAM_AC_ID,
    Metadata_AC_NAM,
    AC_NAM_ChangedAt,
    AC_NAM_Skådespelare_Namn,
    AC_GEN_AC_ID,
    Metadata_AC_GEN,
    AC_GEN_GEN_Checksum,
    AC_GEN_GEN_Kön,
    AC_GEN_Metadata_GEN,
    AC_GEN_GEN_ID,
    AC_PLV_AC_ID,
    Metadata_AC_PLV,
    AC_PLV_ChangedAt,
    AC_PLV_PLV_Checksum,
    AC_PLV_PLV_Yrkesnivå,
    AC_PLV_Metadata_PLV,
    AC_PLV_PLV_ID
)
AS
SELECT
    "AC".AC_ID,
    "AC".Metadata_AC,
    "NAM".AC_NAM_AC_ID,
    "NAM".Metadata_AC_NAM,
    "NAM".AC_NAM_ChangedAt,
    "NAM".AC_NAM_Skådespelare_Namn,
    "GEN".AC_GEN_AC_ID,
    "GEN".Metadata_AC_GEN,
    "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
    "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
    "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
    "GEN".AC_GEN_GEN_ID,
    "PLV".AC_PLV_AC_ID,
    "PLV".Metadata_AC_PLV,
    "PLV".AC_PLV_ChangedAt,
    "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
    "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
    "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
    "PLV".AC_PLV_PLV_ID
FROM
    anchors.AC_Skådespelare "AC"
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.AC_NAM_Skådespelare_Namn a
        WHERE
            a.AC_NAM_ChangedAt = (
                SELECT
                    MAX(sub.AC_NAM_ChangedAt)
                FROM
                    attributes.AC_NAM_Skådespelare_Namn sub
                WHERE
                    sub.AC_NAM_AC_ID = a.AC_NAM_AC_ID
            )
    ) "NAM"
ON
    "NAM".AC_NAM_AC_ID = "AC".AC_ID
LEFT JOIN
    attributes.AC_GEN_Skådespelare_Kön "GEN"
ON
    "GEN".AC_GEN_AC_ID = "AC".AC_ID
LEFT JOIN
    knots.GEN_Kön "kGEN"
ON
    "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå a
        WHERE
            a.AC_PLV_ChangedAt = (
                SELECT
                    MAX(sub.AC_PLV_ChangedAt)
                FROM
                    attributes.AC_PLV_Skådespelare_Yrkesnivå sub
                WHERE
                    sub.AC_PLV_AC_ID = a.AC_PLV_AC_ID
            )
    ) "PLV"
ON
    "PLV".AC_PLV_AC_ID = "AC".AC_ID
LEFT JOIN
    knots.PLV_Yrkesnivå "kPLV"
ON
    "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Skådespelare (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Skådespelare "AC"
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.AC_NAM_Skådespelare_Namn a
                WHERE
                    a.AC_NAM_ChangedAt = (
                        SELECT
                            MAX(sub.AC_NAM_ChangedAt)
                        FROM
                            attributes.AC_NAM_Skådespelare_Namn sub
                        WHERE
                            sub.AC_NAM_AC_ID = a.AC_NAM_AC_ID
                        AND
                            sub.AC_NAM_ChangedAt <= changingTimepoint
                    )
            ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        LEFT JOIN
            attributes.AC_GEN_Skådespelare_Kön "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.GEN_Kön "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.AC_PLV_Skådespelare_Yrkesnivå a
                WHERE
                    a.AC_PLV_ChangedAt = (
                        SELECT
                            MAX(sub.AC_PLV_ChangedAt)
                        FROM
                            attributes.AC_PLV_Skådespelare_Yrkesnivå sub
                        WHERE
                            sub.AC_PLV_AC_ID = a.AC_PLV_AC_ID
                        AND
                            sub.AC_PLV_ChangedAt <= changingTimepoint
                    )
            ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.PLV_Yrkesnivå "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END pAC_Skådespelare;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nAC_Skådespelare
AS
SELECT
    *
FROM
    anchors.pAC_Skådespelare(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dAC_Skådespelare (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ChangedAt,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM (
            SELECT DISTINCT
                h.AC_NAM_AC_ID AS AC_ID,
                CAST(h.AC_NAM_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'NAM' AS mnemonic
            FROM
                attributes.AC_NAM_Skådespelare_Namn h
            WHERE
                (selection IS NULL OR selection LIKE '%NAM%')
            AND
                h.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.AC_PLV_AC_ID AS AC_ID,
                CAST(h.AC_PLV_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'PLV' AS mnemonic
            FROM
                attributes.AC_PLV_Skådespelare_Yrkesnivå h
            WHERE
                (selection IS NULL OR selection LIKE '%PLV%')
            AND
                h.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            anchors.AC_Skådespelare "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_NAM_ChangedAt) OVER (
                    PARTITION BY h.AC_NAM_AC_ID
                    ORDER BY h.AC_NAM_ChangedAt
                ) AS untilTime
            FROM
                attributes.AC_NAM_Skådespelare_Namn h
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.AC_GEN_Skådespelare_Kön "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        LEFT JOIN
            knots.GEN_Kön "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.AC_PLV_ChangedAt) OVER (
                    PARTITION BY h.AC_PLV_AC_ID
                    ORDER BY h.AC_PLV_ChangedAt
                ) AS untilTime
            FROM
                attributes.AC_PLV_Skådespelare_Yrkesnivå h
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "PLV".untilTime IS NULL
        OR
            "PLV".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.PLV_Yrkesnivå "kPLV"
        ON
            "kPLV".PLV_ID = "PLV".AC_PLV_PLV_ID
    ]';
END dAC_Skådespelare;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Föreställning (
    PR_ID,
    Metadata_PR,
    PR_NAM_PR_ID,
    Metadata_PR_NAM,
    PR_NAM_Föreställning_Namn,
    PR_LEN_PR_ID,
    Metadata_PR_LEN,
    PR_LEN_ChangedAt,
    PR_LEN_Föreställning_Längd
)
AS
SELECT
    "PR".PR_ID,
    "PR".Metadata_PR,
    "NAM".PR_NAM_PR_ID,
    "NAM".Metadata_PR_NAM,
    "NAM".PR_NAM_Föreställning_Namn,
    "LEN".PR_LEN_PR_ID,
    "LEN".Metadata_PR_LEN,
    "LEN".PR_LEN_ChangedAt,
    "LEN".PR_LEN_Föreställning_Längd
FROM
    anchors.PR_Föreställning "PR"
LEFT JOIN
    attributes.PR_NAM_Föreställning_Namn "NAM"
ON
    "NAM".PR_NAM_PR_ID = "PR".PR_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.PR_LEN_Föreställning_Längd a
        WHERE
            a.PR_LEN_ChangedAt = (
                SELECT
                    MAX(sub.PR_LEN_ChangedAt)
                FROM
                    attributes.PR_LEN_Föreställning_Längd sub
                WHERE
                    sub.PR_LEN_PR_ID = a.PR_LEN_PR_ID
            )
    ) "LEN"
ON
    "LEN".PR_LEN_PR_ID = "PR".PR_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Föreställning (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Föreställning_Längd
        FROM
            anchors.PR_Föreställning "PR"
        LEFT JOIN
            attributes.PR_NAM_Föreställning_Namn "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.PR_LEN_Föreställning_Längd a
                WHERE
                    a.PR_LEN_ChangedAt = (
                        SELECT
                            MAX(sub.PR_LEN_ChangedAt)
                        FROM
                            attributes.PR_LEN_Föreställning_Längd sub
                        WHERE
                            sub.PR_LEN_PR_ID = a.PR_LEN_PR_ID
                        AND
                            sub.PR_LEN_ChangedAt <= changingTimepoint
                    )
            ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
    ]';
END pPR_Föreställning;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nPR_Föreställning
AS
SELECT
    *
FROM
    anchors.pPR_Föreställning(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dPR_Föreställning (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_Föreställning_Längd
        FROM (
            SELECT DISTINCT
                h.PR_LEN_PR_ID AS PR_ID,
                CAST(h.PR_LEN_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LEN' AS mnemonic
            FROM
                attributes.PR_LEN_Föreställning_Längd h
            WHERE
                (selection IS NULL OR selection LIKE '%LEN%')
            AND
                h.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            anchors.PR_Föreställning "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN
            attributes.PR_NAM_Föreställning_Namn "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.PR_LEN_ChangedAt) OVER (
                    PARTITION BY h.PR_LEN_PR_ID
                    ORDER BY h.PR_LEN_ChangedAt
                ) AS untilTime
            FROM
                attributes.PR_LEN_Föreställning_Längd h
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LEN".untilTime IS NULL
        OR
            "LEN".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
    ]';
END dPR_Föreställning;
/
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- nexus perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Händelse (
    EV_ID,
    Metadata_EV,
    ST_ID_hölls,
    PR_ID_spelades,
    of_ETY_Checksum,
    of_ETY_Händelsetyp,
    of_Metadata_ETY,
    ETY_ID_of,
    EV_DAT_EV_ID,
    Metadata_EV_DAT,
    EV_DAT_Händelse_Datum,
    EV_AUD_EV_ID,
    Metadata_EV_AUD,
    EV_AUD_Händelse_Publik,
    EV_REV_EV_ID,
    Metadata_EV_REV,
    EV_REV_Händelse_Intäkt,
    EV_STA_EV_ID,
    Metadata_EV_STA,
    EV_STA_ChangedAt,
    EV_STA_Händelse_Status,
    EV_UTL_EV_ID,
    Metadata_EV_UTL,
    EV_UTL_UTL_Utnyttjande,
    EV_UTL_Metadata_UTL,
    EV_UTL_UTL_ID,
    EV_LVL_EV_ID,
    Metadata_EV_LVL,
    EV_LVL_ChangedAt,
    EV_LVL_PLV_Checksum,
    EV_LVL_PLV_Yrkesnivå,
    EV_LVL_Metadata_PLV,
    EV_LVL_PLV_ID
)
AS
SELECT
    "EV".EV_ID,
    "EV".Metadata_EV,
    "EV".ST_ID_hölls,
    "EV".PR_ID_spelades,
    "ETY_of".ETY_Checksum AS of_ETY_Checksum,
    "ETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
    "ETY_of".Metadata_ETY AS of_Metadata_ETY,
    "EV".ETY_ID_of,
    "DAT".EV_DAT_EV_ID,
    "DAT".Metadata_EV_DAT,
    "DAT".EV_DAT_Händelse_Datum,
    "AUD".EV_AUD_EV_ID,
    "AUD".Metadata_EV_AUD,
    "AUD".EV_AUD_Händelse_Publik,
    "REV".EV_REV_EV_ID,
    "REV".Metadata_EV_REV,
    "REV".EV_REV_Händelse_Intäkt,
    "STA".EV_STA_EV_ID,
    "STA".Metadata_EV_STA,
    "STA".EV_STA_ChangedAt,
    "STA".EV_STA_Händelse_Status,
    "UTL".EV_UTL_EV_ID,
    "UTL".Metadata_EV_UTL,
    "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
    "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
    "UTL".EV_UTL_UTL_ID,
    "LVL".EV_LVL_EV_ID,
    "LVL".Metadata_EV_LVL,
    "LVL".EV_LVL_ChangedAt,
    "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
    "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
    "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
    "LVL".EV_LVL_PLV_ID
FROM
    nexuses.EV_Händelse "EV"
LEFT JOIN
    knots.ETY_Händelsetyp "ETY_of"
ON
    "ETY_of".ETY_ID = "EV".ETY_ID_of
LEFT JOIN
    attributes.EV_DAT_Händelse_Datum "DAT"
ON
    "DAT".EV_DAT_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_AUD_Händelse_Publik "AUD"
ON
    "AUD".EV_AUD_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_REV_Händelse_Intäkt "REV"
ON
    "REV".EV_REV_EV_ID = "EV".EV_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_STA_Händelse_Status a
        WHERE
            a.EV_STA_ChangedAt = (
                SELECT
                    MAX(sub.EV_STA_ChangedAt)
                FROM
                    attributes.EV_STA_Händelse_Status sub
                WHERE
                    sub.EV_STA_EV_ID = a.EV_STA_EV_ID
            )
    ) "STA"
ON
    "STA".EV_STA_EV_ID = "EV".EV_ID
LEFT JOIN
    attributes.EV_UTL_Händelse_Utnyttjande "UTL"
ON
    "UTL".EV_UTL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.UTL_Utnyttjande "kUTL"
ON
    "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            attributes.EV_LVL_Händelse_Level a
        WHERE
            a.EV_LVL_ChangedAt = (
                SELECT
                    MAX(sub.EV_LVL_ChangedAt)
                FROM
                    attributes.EV_LVL_Händelse_Level sub
                WHERE
                    sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
            )
    ) "LVL"
ON
    "LVL".EV_LVL_EV_ID = "EV".EV_ID
LEFT JOIN
    knots.PLV_Yrkesnivå "kLVL"
ON
    "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Händelse (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_hölls,
            "EV".PR_ID_spelades,
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Händelse "EV"
        LEFT JOIN
            knots.ETY_Händelsetyp "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Händelse_Datum "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Händelse_Publik "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Händelse_Intäkt "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_STA_Händelse_Status a
                WHERE
                    a.EV_STA_ChangedAt = (
                        SELECT
                            MAX(sub.EV_STA_ChangedAt)
                        FROM
                            attributes.EV_STA_Händelse_Status sub
                        WHERE
                            sub.EV_STA_EV_ID = a.EV_STA_EV_ID
                        AND
                            sub.EV_STA_ChangedAt <= changingTimepoint
                    )
            ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_UTL_Händelse_Utnyttjande "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    attributes.EV_LVL_Händelse_Level a
                WHERE
                    a.EV_LVL_ChangedAt = (
                        SELECT
                            MAX(sub.EV_LVL_ChangedAt)
                        FROM
                            attributes.EV_LVL_Händelse_Level sub
                        WHERE
                            sub.EV_LVL_EV_ID = a.EV_LVL_EV_ID
                        AND
                            sub.EV_LVL_ChangedAt <= changingTimepoint
                    )
            ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.PLV_Yrkesnivå "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END pEV_Händelse;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.nEV_Händelse
AS
SELECT
    *
FROM
    nexuses.pEV_Händelse(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.dEV_Händelse (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_hölls,
            "EV".PR_ID_spelades,
            "ETY_of".ETY_Checksum AS of_ETY_Checksum,
            "ETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "ETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ChangedAt,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM (
            SELECT DISTINCT
                h.EV_STA_EV_ID AS EV_ID,
                CAST(h.EV_STA_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'STA' AS mnemonic
            FROM
                attributes.EV_STA_Händelse_Status h
            WHERE
                (selection IS NULL OR selection LIKE '%STA%')
            AND
                h.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.EV_LVL_EV_ID AS EV_ID,
                CAST(h.EV_LVL_ChangedAt AS timestamp(9)) AS inspectedTimepoint,
                'LVL' AS mnemonic
            FROM
                attributes.EV_LVL_Händelse_Level h
            WHERE
                (selection IS NULL OR selection LIKE '%LVL%')
            AND
                h.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            nexuses.EV_Händelse "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_Händelsetyp "ETY_of"
        ON
            "ETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN
            attributes.EV_DAT_Händelse_Datum "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_AUD_Händelse_Publik "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        LEFT JOIN
            attributes.EV_REV_Händelse_Intäkt "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_STA_ChangedAt) OVER (
                    PARTITION BY h.EV_STA_EV_ID
                    ORDER BY h.EV_STA_ChangedAt
                ) AS untilTime
            FROM
                attributes.EV_STA_Händelse_Status h
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            attributes.EV_UTL_Händelse_Utnyttjande "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        LEFT JOIN
            knots.UTL_Utnyttjande "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.EV_LVL_ChangedAt) OVER (
                    PARTITION BY h.EV_LVL_EV_ID
                    ORDER BY h.EV_LVL_ChangedAt
                ) AS untilTime
            FROM
                attributes.EV_LVL_Händelse_Level h
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS date)
        AND (
            "LVL".untilTime IS NULL
        OR
            "LVL".untilTime > CAST(timepoints.inspectedTimepoint AS date)
        )
        LEFT JOIN
            knots.PLV_Yrkesnivå "kLVL"
        ON
            "kLVL".PLV_ID = "LVL".EV_LVL_PLV_ID
    ]';
END dEV_Händelse;
/
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_part_EV_in(TIMESTAMP '2020-01-01 00:00:00').
--
-- A historized tie shows, for each identifier (for each anchor, in a tie without identifiers), the rows that have the latest
-- changing time: that is worked out with an analytic MAX in an inline view, whose column holds the latest time.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner,
    AC_ID_with,
    currently_ONG_Pågående,
    currently_Metadata_ONG,
    ONG_ID_currently
)
AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    "ONG_currently".ONG_Pågående AS currently_ONG_Pågående,
    "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
        FROM
            ties.AC_partner_AC_with_ONG_currently t
    ) tie
LEFT JOIN
    knots.ONG_Pågående "ONG_currently"
ON
    "ONG_currently".ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
AND
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_partner_AC_with_ONG_currently,
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
                FROM
                    ties.AC_partner_AC_with_ONG_currently t
                WHERE
                    t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            knots.ONG_Pågående "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
        AND
            tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
    ]';
END pAC_partner_AC_with_ONG_currently;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_partner_AC_with_ONG_currently,
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            ties.AC_partner_AC_with_ONG_currently tie
        LEFT JOIN
            knots.ONG_Pågående "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of (
    Metadata_AC_subset_PN_of,
    AC_ID_subset,
    PN_ID_of
)
AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_subset_PN_of,
            tie.AC_ID_subset,
            tie.PN_ID_of
        FROM
            ties.AC_subset_PN_of tie
    ]';
END pAC_subset_PN_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes (
    Metadata_EV_in_AC_rollsattes,
    EV_ID_in,
    AC_ID_rollsattes
)
AS
SELECT
    tie.Metadata_EV_in_AC_rollsattes,
    tie.EV_ID_in,
    tie.AC_ID_rollsattes
FROM
    ties.EV_in_AC_rollsattes tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_EV_in_AC_rollsattes,
            tie.EV_ID_in,
            tie.AC_ID_rollsattes
        FROM
            ties.EV_in_AC_rollsattes tie
    ]';
END pEV_in_AC_rollsattes;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes
AS
SELECT
    *
FROM
    ties.pEV_in_AC_rollsattes(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick (
    Metadata_AC_deltar_PR_in_RAT_fick,
    AC_deltar_PR_in_RAT_fick_ChangedAt,
    AC_ID_deltar,
    PR_ID_in,
    fick_RAT_Checksum,
    fick_RAT_Betyg,
    fick_Metadata_RAT,
    RAT_ID_fick
)
AS
SELECT
    tie.Metadata_AC_deltar_PR_in_RAT_fick,
    tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
    tie.AC_ID_deltar,
    tie.PR_ID_in,
    "RAT_fick".RAT_Checksum AS fick_RAT_Checksum,
    "RAT_fick".RAT_Betyg AS fick_RAT_Betyg,
    "RAT_fick".Metadata_RAT AS fick_Metadata_RAT,
    tie.RAT_ID_fick
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_deltar_PR_in_RAT_fick_ChangedAt) OVER (
                PARTITION BY
                    t.AC_ID_deltar,
                    t.PR_ID_in
            ) AS latestTime
        FROM
            ties.AC_deltar_PR_in_RAT_fick t
    ) tie
LEFT JOIN
    knots.RAT_Betyg "RAT_fick"
ON
    "RAT_fick".RAT_ID = tie.RAT_ID_fick
WHERE
    tie.AC_deltar_PR_in_RAT_fick_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_deltar_PR_in_RAT_fick,
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
            tie.AC_ID_deltar,
            tie.PR_ID_in,
            "RAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "RAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "RAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            tie.RAT_ID_fick
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_deltar_PR_in_RAT_fick_ChangedAt) OVER (
                        PARTITION BY
                            t.AC_ID_deltar,
                            t.PR_ID_in
                    ) AS latestTime
                FROM
                    ties.AC_deltar_PR_in_RAT_fick t
                WHERE
                    t.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            knots.RAT_Betyg "RAT_fick"
        ON
            "RAT_fick".RAT_ID = tie.RAT_ID_fick
        WHERE
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt = tie.latestTime
    ]';
END pAC_deltar_PR_in_RAT_fick;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_deltar_PR_in_RAT_fick
AS
SELECT
    *
FROM
    ties.pAC_deltar_PR_in_RAT_fick(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_deltar_PR_in_RAT_fick (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_deltar_PR_in_RAT_fick,
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
            tie.AC_ID_deltar,
            tie.PR_ID_in,
            "RAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "RAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "RAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            tie.RAT_ID_fick
        FROM
            ties.AC_deltar_PR_in_RAT_fick tie
        LEFT JOIN
            knots.RAT_Betyg "RAT_fick"
        ON
            "RAT_fick".RAT_ID = tie.RAT_ID_fick
        WHERE
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_deltar_PR_in_RAT_fick;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas (
    Metadata_ST_at_PR_spelas,
    ST_at_PR_spelas_ChangedAt,
    ST_ID_at,
    PR_ID_spelas
)
AS
SELECT
    tie.Metadata_ST_at_PR_spelas,
    tie.ST_at_PR_spelas_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_spelas
FROM
    (
        SELECT
            t.*,
            MAX(t.ST_at_PR_spelas_ChangedAt) OVER (
                PARTITION BY
                    t.ST_ID_at,
                    t.PR_ID_spelas
            ) AS latestTime
        FROM
            ties.ST_at_PR_spelas t
    ) tie
WHERE
    tie.ST_at_PR_spelas_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_spelas,
            tie.ST_at_PR_spelas_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_spelas
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.ST_at_PR_spelas_ChangedAt) OVER (
                        PARTITION BY
                            t.ST_ID_at,
                            t.PR_ID_spelas
                    ) AS latestTime
                FROM
                    ties.ST_at_PR_spelas t
                WHERE
                    t.ST_at_PR_spelas_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.ST_at_PR_spelas_ChangedAt = tie.latestTime
    ]';
END pST_at_PR_spelas;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_spelas
AS
SELECT
    *
FROM
    ties.pST_at_PR_spelas(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_spelas (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_spelas,
            tie.ST_at_PR_spelas_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_spelas
        FROM
            ties.ST_at_PR_spelas tie
        WHERE
            tie.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_spelas;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har (
    Metadata_AC_förälder_AC_barn_PAT_har,
    AC_ID_förälder,
    AC_ID_barn,
    har_PAT_Föräldratyp,
    har_Metadata_PAT,
    PAT_ID_har
)
AS
SELECT
    tie.Metadata_AC_förälder_AC_barn_PAT_har,
    tie.AC_ID_förälder,
    tie.AC_ID_barn,
    "PAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
    "PAT_har".Metadata_PAT AS har_Metadata_PAT,
    tie.PAT_ID_har
FROM
    ties.AC_förälder_AC_barn_PAT_har tie
LEFT JOIN
    knots.PAT_Föräldratyp "PAT_har"
ON
    "PAT_har".PAT_ID = tie.PAT_ID_har
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_förälder_AC_barn_PAT_har,
            tie.AC_ID_förälder,
            tie.AC_ID_barn,
            "PAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "PAT_har".Metadata_PAT AS har_Metadata_PAT,
            tie.PAT_ID_har
        FROM
            ties.AC_förälder_AC_barn_PAT_har tie
        LEFT JOIN
            knots.PAT_Föräldratyp "PAT_har"
        ON
            "PAT_har".PAT_ID = tie.PAT_ID_har
    ]';
END pAC_förälder_AC_barn_PAT_har;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har
AS
SELECT
    *
FROM
    ties.pAC_förälder_AC_barn_PAT_har(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of (
    Metadata_PR_innehåll_ST_plats_EV_of,
    PR_innehåll_ST_plats_EV_of_ChangedAt,
    PR_ID_innehåll,
    ST_ID_plats,
    EV_ID_of
)
AS
SELECT
    tie.Metadata_PR_innehåll_ST_plats_EV_of,
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
    tie.PR_ID_innehåll,
    tie.ST_ID_plats,
    tie.EV_ID_of
FROM
    (
        SELECT
            t.*,
            MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.PR_ID_innehåll) AS latestPR_ID_innehåll,
            MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.ST_ID_plats) AS latestST_ID_plats
        FROM
            ties.PR_innehåll_ST_plats_EV_of t
    ) tie
WHERE
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestPR_ID_innehåll
AND
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestST_ID_plats
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_PR_innehåll_ST_plats_EV_of,
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
            tie.PR_ID_innehåll,
            tie.ST_ID_plats,
            tie.EV_ID_of
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.PR_ID_innehåll) AS latestPR_ID_innehåll,
                    MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.ST_ID_plats) AS latestST_ID_plats
                FROM
                    ties.PR_innehåll_ST_plats_EV_of t
                WHERE
                    t.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestPR_ID_innehåll
        AND
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestST_ID_plats
    ]';
END pPR_innehåll_ST_plats_EV_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_innehåll_ST_plats_EV_of
AS
SELECT
    *
FROM
    ties.pPR_innehåll_ST_plats_EV_of(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_innehåll_ST_plats_EV_of (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_PR_innehåll_ST_plats_EV_of,
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
            tie.PR_ID_innehåll,
            tie.ST_ID_plats,
            tie.EV_ID_of
        FROM
            ties.PR_innehåll_ST_plats_EV_of tie
        WHERE
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dPR_innehåll_ST_plats_EV_of;
/
-- ATTRIBUTE INSERT PROCEDURES ----------------------------------------------------------------------------------------
--
-- The procedures here state one value of an attribute, in the way that the model says: a row that is already there is
-- not stored again, another value at a time that has a value is a contradiction, and a value that is the same as the
-- one before it (a restatement) is skipped by an idempotent attribute and refused by one that may not be restated.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- These are procedures and not triggers on the attribute tables, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. The triggers on the latest views call them, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_changing => SYSTIMESTAMP, p_value => 'Ann', p_metadata => 1); END;
--
-- A row put straight into an attribute table by an INSERT is not looked at.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Händelse_Datum states a value of EV_DAT_Händelse_Datum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Händelse_Datum (
    p_owner IN attributes.EV_DAT_Händelse_Datum.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum%TYPE,
    p_metadata IN attributes.EV_DAT_Händelse_Datum.Metadata_EV_DAT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum%TYPE,
        b IN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_DAT_Händelse_Datum
        FROM
            attributes.EV_DAT_Händelse_Datum x
        WHERE
            x.EV_DAT_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_DAT_Händelse_Datum, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Händelse_Datum for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_DAT_Händelse_Datum (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_Händelse_Datum
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_DAT_Händelse_Datum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Händelse_Publik states a value of EV_AUD_Händelse_Publik
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Händelse_Publik (
    p_owner IN attributes.EV_AUD_Händelse_Publik.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik%TYPE,
    p_metadata IN attributes.EV_AUD_Händelse_Publik.Metadata_EV_AUD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik%TYPE,
        b IN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_AUD_Händelse_Publik
        FROM
            attributes.EV_AUD_Händelse_Publik x
        WHERE
            x.EV_AUD_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_AUD_Händelse_Publik, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Händelse_Publik for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_AUD_Händelse_Publik (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Händelse_Publik
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_AUD_Händelse_Publik;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Händelse_Intäkt states a value of EV_REV_Händelse_Intäkt
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Händelse_Intäkt (
    p_owner IN attributes.EV_REV_Händelse_Intäkt.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt%TYPE,
    p_metadata IN attributes.EV_REV_Händelse_Intäkt.Metadata_EV_REV%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt%TYPE,
        b IN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_REV_Händelse_Intäkt
        FROM
            attributes.EV_REV_Händelse_Intäkt x
        WHERE
            x.EV_REV_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_REV_Händelse_Intäkt, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Händelse_Intäkt for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_REV_Händelse_Intäkt (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_Händelse_Intäkt
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_REV_Händelse_Intäkt;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Händelse_Status states a value of EV_STA_Händelse_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Händelse_Status (
    p_owner IN attributes.EV_STA_Händelse_Status.EV_STA_EV_ID%TYPE,
    p_changing IN attributes.EV_STA_Händelse_Status.EV_STA_ChangedAt%TYPE,
    p_value IN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status%TYPE,
    p_metadata IN attributes.EV_STA_Händelse_Status.Metadata_EV_STA%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status%TYPE,
        b IN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_STA_Händelse_Status
        FROM
            attributes.EV_STA_Händelse_Status x
        WHERE
            x.EV_STA_EV_ID = p_owner
        AND
            x.EV_STA_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_STA_Händelse_Status, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Händelse_Status for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.EV_STA_Händelse_Status (
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Händelse_Status
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_STA_Händelse_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Händelse_Utnyttjande states a value of EV_UTL_Händelse_Utnyttjande
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Händelse_Utnyttjande (
    p_owner IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_UTL_ID%TYPE,
    p_metadata IN attributes.EV_UTL_Händelse_Utnyttjande.Metadata_EV_UTL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_UTL_ID%TYPE,
        b IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_UTL_UTL_ID
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande x
        WHERE
            x.EV_UTL_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_UTL_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Händelse_Utnyttjande for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande (
        Metadata_EV_UTL,
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_UTL_Händelse_Utnyttjande;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Händelse_Level states a value of EV_LVL_Händelse_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Händelse_Level (
    p_owner IN attributes.EV_LVL_Händelse_Level.EV_LVL_EV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Händelse_Level.EV_LVL_ChangedAt%TYPE,
    p_value IN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID%TYPE,
    p_metadata IN attributes.EV_LVL_Händelse_Level.Metadata_EV_LVL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID%TYPE,
        b IN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_LVL_PLV_ID
        FROM
            attributes.EV_LVL_Händelse_Level x
        WHERE
            x.EV_LVL_EV_ID = p_owner
        AND
            x.EV_LVL_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_LVL_PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Händelse_Level for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.EV_LVL_Händelse_Level (
        Metadata_EV_LVL,
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_LVL_Händelse_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Scen_Namn states a value of ST_NAM_Scen_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Scen_Namn (
    p_owner IN attributes.ST_NAM_Scen_Namn.ST_NAM_ST_ID%TYPE,
    p_changing IN attributes.ST_NAM_Scen_Namn.ST_NAM_ChangedAt%TYPE,
    p_value IN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn%TYPE,
    p_metadata IN attributes.ST_NAM_Scen_Namn.Metadata_ST_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn%TYPE,
        b IN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_NAM_Scen_Namn
        FROM
            attributes.ST_NAM_Scen_Namn x
        WHERE
            x.ST_NAM_ST_ID = p_owner
        AND
            x.ST_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_NAM_Scen_Namn, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Scen_Namn for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.ST_NAM_Scen_Namn (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Scen_Namn
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_NAM_Scen_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Scen_Plats states a value of ST_LOC_Scen_Plats
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Scen_Plats (
    p_owner IN attributes.ST_LOC_Scen_Plats.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats%TYPE,
    p_metadata IN attributes.ST_LOC_Scen_Plats.Metadata_ST_LOC%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats%TYPE,
        b IN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats%TYPE
    ) RETURN BOOLEAN
    IS
        v_same NUMBER;
    BEGIN
        SELECT CASE WHEN STANDARD_HASH(a, 'MD5') = STANDARD_HASH(b, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
        RETURN v_same = 1;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.ST_LOC_Scen_Plats
        FROM
            attributes.ST_LOC_Scen_Plats x
        WHERE
            x.ST_LOC_ST_ID = p_owner
    ) LOOP
        IF same(r.ST_LOC_Scen_Plats, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Scen_Plats for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.ST_LOC_Scen_Plats (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Scen_Plats
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_ST_LOC_Scen_Plats;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Scen_Medel states a value of ST_AVG_Scen_Medel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Scen_Medel (
    p_owner IN attributes.ST_AVG_Scen_Medel.ST_AVG_ST_ID%TYPE,
    p_changing IN attributes.ST_AVG_Scen_Medel.ST_AVG_ChangedAt%TYPE,
    p_value IN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID%TYPE,
    p_metadata IN attributes.ST_AVG_Scen_Medel.Metadata_ST_AVG%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID%TYPE,
        b IN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel x
        WHERE
            x.ST_AVG_ST_ID = p_owner
        AND
            x.ST_AVG_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Scen_Medel for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < p_changing
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.ST_AVG_ChangedAt,
            f.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > p_changing
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            DELETE FROM
                attributes.ST_AVG_Scen_Medel
            WHERE
                ST_AVG_ST_ID = p_owner
            AND
                ST_AVG_ChangedAt = r.ST_AVG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO attributes.ST_AVG_Scen_Medel (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_AVG_Scen_Medel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Scen_Minimum states a value of ST_MIN_Scen_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Scen_Minimum (
    p_owner IN attributes.ST_MIN_Scen_Minimum.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID%TYPE,
    p_metadata IN attributes.ST_MIN_Scen_Minimum.Metadata_ST_MIN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID%TYPE,
        b IN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.ST_MIN_UTL_ID
        FROM
            attributes.ST_MIN_Scen_Minimum x
        WHERE
            x.ST_MIN_ST_ID = p_owner
    ) LOOP
        IF same(r.ST_MIN_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Scen_Minimum for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.ST_MIN_Scen_Minimum (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_ST_MIN_Scen_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Skådespelare_Namn states a value of AC_NAM_Skådespelare_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Skådespelare_Namn (
    p_owner IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_AC_ID%TYPE,
    p_changing IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_ChangedAt%TYPE,
    p_value IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn%TYPE,
    p_metadata IN attributes.AC_NAM_Skådespelare_Namn.Metadata_AC_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn%TYPE,
        b IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn x
        WHERE
            x.AC_NAM_AC_ID = p_owner
        AND
            x.AC_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_NAM_Skådespelare_Namn, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < p_changing
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Skådespelare_Namn, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > p_changing
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Skådespelare_Namn, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO attributes.AC_NAM_Skådespelare_Namn (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Skådespelare_Namn
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_NAM_Skådespelare_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Skådespelare_Kön states a value of AC_GEN_Skådespelare_Kön
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Skådespelare_Kön (
    p_owner IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID%TYPE,
    p_metadata IN attributes.AC_GEN_Skådespelare_Kön.Metadata_AC_GEN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID%TYPE,
        b IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.AC_GEN_GEN_ID
        FROM
            attributes.AC_GEN_Skådespelare_Kön x
        WHERE
            x.AC_GEN_AC_ID = p_owner
    ) LOOP
        IF same(r.AC_GEN_GEN_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Skådespelare_Kön for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.AC_GEN_Skådespelare_Kön (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_AC_GEN_Skådespelare_Kön;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Skådespelare_Yrkesnivå states a value of AC_PLV_Skådespelare_Yrkesnivå
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Skådespelare_Yrkesnivå (
    p_owner IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_AC_ID%TYPE,
    p_changing IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_ChangedAt%TYPE,
    p_value IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID%TYPE,
    p_metadata IN attributes.AC_PLV_Skådespelare_Yrkesnivå.Metadata_AC_PLV%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID%TYPE,
        b IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_PLV_PLV_ID
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå x
        WHERE
            x.AC_PLV_AC_ID = p_owner
        AND
            x.AC_PLV_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_PLV_PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_PLV_Skådespelare_Yrkesnivå;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Föreställning_Namn states a value of PR_NAM_Föreställning_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Föreställning_Namn (
    p_owner IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn%TYPE,
    p_metadata IN attributes.PR_NAM_Föreställning_Namn.Metadata_PR_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn%TYPE,
        b IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.PR_NAM_Föreställning_Namn
        FROM
            attributes.PR_NAM_Föreställning_Namn x
        WHERE
            x.PR_NAM_PR_ID = p_owner
    ) LOOP
        IF same(r.PR_NAM_Föreställning_Namn, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Föreställning_Namn for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.PR_NAM_Föreställning_Namn (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Föreställning_Namn
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_PR_NAM_Föreställning_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Föreställning_Längd states a value of PR_LEN_Föreställning_Längd
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Föreställning_Längd (
    p_owner IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_PR_ID%TYPE,
    p_changing IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_ChangedAt%TYPE,
    p_value IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd%TYPE,
    p_metadata IN attributes.PR_LEN_Föreställning_Längd.Metadata_PR_LEN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd%TYPE,
        b IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd x
        WHERE
            x.PR_LEN_PR_ID = p_owner
        AND
            x.PR_LEN_ChangedAt = p_changing
    ) LOOP
        IF same(r.PR_LEN_Föreställning_Längd, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Föreställning_Längd for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < p_changing
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Föreställning_Längd, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.PR_LEN_ChangedAt,
            f.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > p_changing
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Föreställning_Längd, p_value) THEN
            DELETE FROM
                attributes.PR_LEN_Föreställning_Längd
            WHERE
                PR_LEN_PR_ID = p_owner
            AND
                PR_LEN_ChangedAt = r.PR_LEN_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO attributes.PR_LEN_Föreställning_Längd (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Föreställning_Längd
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_PR_LEN_Föreställning_Längd;
/
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates (the insert procedures of the
-- attributes, ip_<attribute>, see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Scen instead of INSERT trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lST_Scen
INSTEAD OF INSERT ON anchors.lST_Scen
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.ST_Scen (
            Metadata_ST
        )
        VALUES (
            :NEW.Metadata_ST
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Scen_Namn IS NOT NULL THEN
        attributes.ip_ST_NAM_Scen_Namn(
            p_owner => COALESCE(:NEW.ST_NAM_ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_value => :NEW.ST_NAM_Scen_Namn,
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Scen_Plats IS NOT NULL THEN
        attributes.ip_ST_LOC_Scen_Plats(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Scen_Plats,
            p_metadata => COALESCE(:NEW.Metadata_ST_LOC, :NEW.Metadata_ST)
        );
    END IF;
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF v_AVG IS NULL AND :NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utnyttjande k
            WHERE
                k.UTL_Utnyttjande = :NEW.ST_AVG_UTL_Utnyttjande
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        attributes.ip_ST_AVG_Scen_Medel(
            p_owner => COALESCE(:NEW.ST_AVG_ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_value => v_AVG,
            p_metadata => COALESCE(:NEW.Metadata_ST_AVG, :NEW.Metadata_ST)
        );
    END IF;
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF v_MIN IS NULL AND :NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utnyttjande k
            WHERE
                k.UTL_Utnyttjande = :NEW.ST_MIN_UTL_Utnyttjande
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        attributes.ip_ST_MIN_Scen_Minimum(
            p_owner => COALESCE(:NEW.ST_MIN_ST_ID, v_id),
            p_value => v_MIN,
            p_metadata => COALESCE(:NEW.Metadata_ST_MIN, :NEW.Metadata_ST)
        );
    END IF;
END it_lST_Scen;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Scen instead of UPDATE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lST_Scen
INSTEAD OF UPDATE ON anchors.lST_Scen
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_ST_ID <> :OLD.ST_NAM_ST_ID
        OR (:NEW.ST_NAM_ST_ID IS NULL AND :OLD.ST_NAM_ST_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ST_ID IS NOT NULL AND :OLD.ST_NAM_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_NAM_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_Scen_Namn <> :OLD.ST_NAM_Scen_Namn
        OR (:NEW.ST_NAM_Scen_Namn IS NULL AND :OLD.ST_NAM_Scen_Namn IS NOT NULL)
        OR (:NEW.ST_NAM_Scen_Namn IS NOT NULL AND :OLD.ST_NAM_Scen_Namn IS NULL))
    OR (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_NAM_Scen_Namn IS NOT NULL THEN
            attributes.ip_ST_NAM_Scen_Namn(
                p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
                        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
                    THEN :NEW.ST_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.ST_NAM_Scen_Namn,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_NAM = :OLD.Metadata_ST_NAM
                            OR (:NEW.Metadata_ST_NAM IS NULL AND :OLD.Metadata_ST_NAM IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_NAM
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_LOC_ST_ID <> :OLD.ST_LOC_ST_ID
        OR (:NEW.ST_LOC_ST_ID IS NULL AND :OLD.ST_LOC_ST_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ST_ID IS NOT NULL AND :OLD.ST_LOC_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_LOC_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_LOC_Scen_Plats <> :OLD.ST_LOC_Scen_Plats
        OR (:NEW.ST_LOC_Scen_Plats IS NULL AND :OLD.ST_LOC_Scen_Plats IS NOT NULL)
        OR (:NEW.ST_LOC_Scen_Plats IS NOT NULL AND :OLD.ST_LOC_Scen_Plats IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_LOC_Scen_Plats IS NOT NULL THEN
            attributes.ip_ST_LOC_Scen_Plats(
                p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                p_value => :NEW.ST_LOC_Scen_Plats,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_LOC = :OLD.Metadata_ST_LOC
                            OR (:NEW.Metadata_ST_LOC IS NULL AND :OLD.Metadata_ST_LOC IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_LOC
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_AVG_ST_ID <> :OLD.ST_AVG_ST_ID
        OR (:NEW.ST_AVG_ST_ID IS NULL AND :OLD.ST_AVG_ST_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ST_ID IS NOT NULL AND :OLD.ST_AVG_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_AVG_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_AVG_UTL_ID <> :OLD.ST_AVG_UTL_ID
        OR (:NEW.ST_AVG_UTL_ID IS NULL AND :OLD.ST_AVG_UTL_ID IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_ID IS NOT NULL AND :OLD.ST_AVG_UTL_ID IS NULL))
    OR (:NEW.ST_AVG_UTL_Utnyttjande <> :OLD.ST_AVG_UTL_Utnyttjande
        OR (:NEW.ST_AVG_UTL_Utnyttjande IS NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NULL))
    OR (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_AVG := :NEW.ST_AVG_UTL_ID;
        IF (v_AVG = :OLD.ST_AVG_UTL_ID OR (v_AVG IS NULL AND :OLD.ST_AVG_UTL_ID IS NULL))
        AND :NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utnyttjande k
                WHERE
                    k.UTL_Utnyttjande = :NEW.ST_AVG_UTL_Utnyttjande
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_AVG := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_AVG IS NOT NULL AND (
            (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) OR
            :OLD.ST_AVG_UTL_ID IS NULL OR
            :OLD.ST_AVG_UTL_ID <> v_AVG
        ) THEN
            attributes.ip_ST_AVG_Scen_Medel(
                p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
                    THEN :NEW.ST_AVG_ChangedAt
                    ELSE v_now
                END,
                p_value => v_AVG,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_AVG = :OLD.Metadata_ST_AVG
                            OR (:NEW.Metadata_ST_AVG IS NULL AND :OLD.Metadata_ST_AVG IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_AVG
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    IF (:NEW.ST_MIN_ST_ID <> :OLD.ST_MIN_ST_ID
        OR (:NEW.ST_MIN_ST_ID IS NULL AND :OLD.ST_MIN_ST_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ST_ID IS NOT NULL AND :OLD.ST_MIN_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_MIN_ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_MIN_UTL_ID <> :OLD.ST_MIN_UTL_ID
        OR (:NEW.ST_MIN_UTL_ID IS NULL AND :OLD.ST_MIN_UTL_ID IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_ID IS NOT NULL AND :OLD.ST_MIN_UTL_ID IS NULL))
    OR (:NEW.ST_MIN_UTL_Utnyttjande <> :OLD.ST_MIN_UTL_Utnyttjande
        OR (:NEW.ST_MIN_UTL_Utnyttjande IS NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_MIN := :NEW.ST_MIN_UTL_ID;
        IF (v_MIN = :OLD.ST_MIN_UTL_ID OR (v_MIN IS NULL AND :OLD.ST_MIN_UTL_ID IS NULL))
        AND :NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utnyttjande k
                WHERE
                    k.UTL_Utnyttjande = :NEW.ST_MIN_UTL_Utnyttjande
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_MIN IS NOT NULL AND (
            :OLD.ST_MIN_UTL_ID IS NULL OR
            :OLD.ST_MIN_UTL_ID <> v_MIN
        ) THEN
            attributes.ip_ST_MIN_Scen_Minimum(
                p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                p_value => v_MIN,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
                            OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
                            OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL))
                        AND (:NEW.Metadata_ST_MIN = :OLD.Metadata_ST_MIN
                            OR (:NEW.Metadata_ST_MIN IS NULL AND :OLD.Metadata_ST_MIN IS NULL))
                        THEN :NEW.Metadata_ST
                        ELSE :NEW.Metadata_ST_MIN
                    END, :NEW.Metadata_ST)
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_ST_MIN = 1
    AND :OLD.ST_MIN_UTL_ID IS NOT NULL
    AND (:NEW.ST_MIN_UTL_ID IS NULL OR :NEW.ST_MIN_UTL_Utnyttjande IS NULL)
    THEN
        INSERT INTO attributes.ST_MIN_Scen_Minimum_Deleted (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            Metadata_ST_MIN,
            ST_MIN_Deleted
        )
        SELECT
            x.ST_MIN_ST_ID,
            x.ST_MIN_UTL_ID,
            x.Metadata_ST_MIN,
            v_now
        FROM
            attributes.ST_MIN_Scen_Minimum x
        WHERE
            x.ST_MIN_ST_ID = :OLD.ST_ID;
        DELETE FROM
            attributes.ST_MIN_Scen_Minimum
        WHERE
            ST_MIN_ST_ID = :OLD.ST_ID;
    END IF;
END ut_lST_Scen;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Scen instead of DELETE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lST_Scen
INSTEAD OF DELETE ON anchors.lST_Scen
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.ST_NAM_Scen_Namn x
    WHERE
        x.ST_NAM_ST_ID = :OLD.ST_ID
    AND
        x.ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    DELETE FROM
        attributes.ST_LOC_Scen_Plats x
    WHERE
        x.ST_LOC_ST_ID = :OLD.ST_ID
    ;
    DELETE FROM
        attributes.ST_AVG_Scen_Medel x
    WHERE
        x.ST_AVG_ST_ID = :OLD.ST_ID
    AND
        x.ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    DELETE FROM
        attributes.ST_MIN_Scen_Minimum x
    WHERE
        x.ST_MIN_ST_ID = :OLD.ST_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.ST_Scen a
    WHERE
        a.ST_ID = :OLD.ST_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_NAM_Scen_Namn x
        WHERE
            x.ST_NAM_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_LOC_Scen_Plats x
        WHERE
            x.ST_LOC_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_AVG_Scen_Medel x
        WHERE
            x.ST_AVG_ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.ST_MIN_Scen_Minimum x
        WHERE
            x.ST_MIN_ST_ID = a.ST_ID
    )
    ;
END dt_lST_Scen;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Skådespelare instead of INSERT trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lAC_Skådespelare
INSTEAD OF INSERT ON anchors.lAC_Skådespelare
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(5);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.AC_Skådespelare (
            Metadata_AC
        )
        VALUES (
            :NEW.Metadata_AC
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Skådespelare_Namn IS NOT NULL THEN
        attributes.ip_AC_NAM_Skådespelare_Namn(
            p_owner => COALESCE(:NEW.AC_NAM_AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_value => :NEW.AC_NAM_Skådespelare_Namn,
            p_metadata => COALESCE(:NEW.Metadata_AC_NAM, :NEW.Metadata_AC)
        );
    END IF;
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF v_GEN IS NULL AND :NEW.AC_GEN_GEN_Kön IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                knots.GEN_Kön k
            WHERE
                k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Kön, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        attributes.ip_AC_GEN_Skådespelare_Kön(
            p_owner => COALESCE(:NEW.AC_GEN_AC_ID, v_id),
            p_value => v_GEN,
            p_metadata => COALESCE(:NEW.Metadata_AC_GEN, :NEW.Metadata_AC)
        );
    END IF;
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF v_PLV IS NULL AND :NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_Yrkesnivå k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_Yrkesnivå, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        attributes.ip_AC_PLV_Skådespelare_Yrkesnivå(
            p_owner => COALESCE(:NEW.AC_PLV_AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_value => v_PLV,
            p_metadata => COALESCE(:NEW.Metadata_AC_PLV, :NEW.Metadata_AC)
        );
    END IF;
END it_lAC_Skådespelare;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Skådespelare instead of UPDATE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lAC_Skådespelare
INSTEAD OF UPDATE ON anchors.lAC_Skådespelare
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_AC_ID <> :OLD.AC_NAM_AC_ID
        OR (:NEW.AC_NAM_AC_ID IS NULL AND :OLD.AC_NAM_AC_ID IS NOT NULL)
        OR (:NEW.AC_NAM_AC_ID IS NOT NULL AND :OLD.AC_NAM_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_NAM_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_Skådespelare_Namn <> :OLD.AC_NAM_Skådespelare_Namn
        OR (:NEW.AC_NAM_Skådespelare_Namn IS NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NOT NULL)
        OR (:NEW.AC_NAM_Skådespelare_Namn IS NOT NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NULL))
    OR (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.AC_NAM_Skådespelare_Namn IS NOT NULL THEN
            attributes.ip_AC_NAM_Skådespelare_Namn(
                p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
                        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
                    THEN :NEW.AC_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.AC_NAM_Skådespelare_Namn,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_NAM = :OLD.Metadata_AC_NAM
                            OR (:NEW.Metadata_AC_NAM IS NULL AND :OLD.Metadata_AC_NAM IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_NAM
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
    IF (:NEW.AC_GEN_AC_ID <> :OLD.AC_GEN_AC_ID
        OR (:NEW.AC_GEN_AC_ID IS NULL AND :OLD.AC_GEN_AC_ID IS NOT NULL)
        OR (:NEW.AC_GEN_AC_ID IS NOT NULL AND :OLD.AC_GEN_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_GEN_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_GEN_GEN_ID <> :OLD.AC_GEN_GEN_ID
        OR (:NEW.AC_GEN_GEN_ID IS NULL AND :OLD.AC_GEN_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_ID IS NOT NULL AND :OLD.AC_GEN_GEN_ID IS NULL))
    OR (:NEW.AC_GEN_GEN_Kön <> :OLD.AC_GEN_GEN_Kön
        OR (:NEW.AC_GEN_GEN_Kön IS NULL AND :OLD.AC_GEN_GEN_Kön IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_Kön IS NOT NULL AND :OLD.AC_GEN_GEN_Kön IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GEN := :NEW.AC_GEN_GEN_ID;
        IF (v_GEN = :OLD.AC_GEN_GEN_ID OR (v_GEN IS NULL AND :OLD.AC_GEN_GEN_ID IS NULL))
        AND :NEW.AC_GEN_GEN_Kön IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    knots.GEN_Kön k
                WHERE
                    k.GEN_Checksum = STANDARD_HASH(:NEW.AC_GEN_GEN_Kön, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_GEN IS NOT NULL AND (
            :OLD.AC_GEN_GEN_ID IS NULL OR
            :OLD.AC_GEN_GEN_ID <> v_GEN
        ) THEN
            attributes.ip_AC_GEN_Skådespelare_Kön(
                p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                p_value => v_GEN,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_GEN = :OLD.Metadata_AC_GEN
                            OR (:NEW.Metadata_AC_GEN IS NULL AND :OLD.Metadata_AC_GEN IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_GEN
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
    IF (:NEW.AC_PLV_AC_ID <> :OLD.AC_PLV_AC_ID
        OR (:NEW.AC_PLV_AC_ID IS NULL AND :OLD.AC_PLV_AC_ID IS NOT NULL)
        OR (:NEW.AC_PLV_AC_ID IS NOT NULL AND :OLD.AC_PLV_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_PLV_AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_PLV_PLV_ID <> :OLD.AC_PLV_PLV_ID
        OR (:NEW.AC_PLV_PLV_ID IS NULL AND :OLD.AC_PLV_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ID IS NOT NULL AND :OLD.AC_PLV_PLV_ID IS NULL))
    OR (:NEW.AC_PLV_PLV_Yrkesnivå <> :OLD.AC_PLV_PLV_Yrkesnivå
        OR (:NEW.AC_PLV_PLV_Yrkesnivå IS NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NULL))
    OR (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_PLV := :NEW.AC_PLV_PLV_ID;
        IF (v_PLV = :OLD.AC_PLV_PLV_ID OR (v_PLV IS NULL AND :OLD.AC_PLV_PLV_ID IS NULL))
        AND :NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_Yrkesnivå k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.AC_PLV_PLV_Yrkesnivå, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_PLV := kv.PLV_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_PLV IS NOT NULL AND (
            (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) OR
            :OLD.AC_PLV_PLV_ID IS NULL OR
            :OLD.AC_PLV_PLV_ID <> v_PLV
        ) THEN
            attributes.ip_AC_PLV_Skådespelare_Yrkesnivå(
                p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
                    THEN :NEW.AC_PLV_ChangedAt
                    ELSE v_now
                END,
                p_value => v_PLV,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
                            OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
                            OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL))
                        AND (:NEW.Metadata_AC_PLV = :OLD.Metadata_AC_PLV
                            OR (:NEW.Metadata_AC_PLV IS NULL AND :OLD.Metadata_AC_PLV IS NULL))
                        THEN :NEW.Metadata_AC
                        ELSE :NEW.Metadata_AC_PLV
                    END, :NEW.Metadata_AC)
            );
        END IF;
    END IF;
END ut_lAC_Skådespelare;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Skådespelare instead of DELETE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lAC_Skådespelare
INSTEAD OF DELETE ON anchors.lAC_Skådespelare
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.AC_NAM_Skådespelare_Namn x
    WHERE
        x.AC_NAM_AC_ID = :OLD.AC_ID
    AND
        x.AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    DELETE FROM
        attributes.AC_GEN_Skådespelare_Kön x
    WHERE
        x.AC_GEN_AC_ID = :OLD.AC_ID
    ;
    DELETE FROM
        attributes.AC_PLV_Skådespelare_Yrkesnivå x
    WHERE
        x.AC_PLV_AC_ID = :OLD.AC_ID
    AND
        x.AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.AC_Skådespelare a
    WHERE
        a.AC_ID = :OLD.AC_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_NAM_Skådespelare_Namn x
        WHERE
            x.AC_NAM_AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_GEN_Skådespelare_Kön x
        WHERE
            x.AC_GEN_AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå x
        WHERE
            x.AC_PLV_AC_ID = a.AC_ID
    )
    ;
END dt_lAC_Skådespelare;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Föreställning instead of INSERT trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.it_lPR_Föreställning
INSTEAD OF INSERT ON anchors.lPR_Föreställning
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(19);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO anchors.PR_Föreställning (
            Metadata_PR
        )
        VALUES (
            :NEW.Metadata_PR
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Föreställning_Namn IS NOT NULL THEN
        attributes.ip_PR_NAM_Föreställning_Namn(
            p_owner => COALESCE(:NEW.PR_NAM_PR_ID, v_id),
            p_value => :NEW.PR_NAM_Föreställning_Namn,
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Föreställning_Längd IS NOT NULL THEN
        attributes.ip_PR_LEN_Föreställning_Längd(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_value => :NEW.PR_LEN_Föreställning_Längd,
            p_metadata => COALESCE(:NEW.Metadata_PR_LEN, :NEW.Metadata_PR)
        );
    END IF;
END it_lPR_Föreställning;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Föreställning instead of UPDATE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.ut_lPR_Föreställning
INSTEAD OF UPDATE ON anchors.lPR_Föreställning
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_PR_ID <> :OLD.PR_NAM_PR_ID
        OR (:NEW.PR_NAM_PR_ID IS NULL AND :OLD.PR_NAM_PR_ID IS NOT NULL)
        OR (:NEW.PR_NAM_PR_ID IS NOT NULL AND :OLD.PR_NAM_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_NAM_PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_Föreställning_Namn <> :OLD.PR_NAM_Föreställning_Namn
        OR (:NEW.PR_NAM_Föreställning_Namn IS NULL AND :OLD.PR_NAM_Föreställning_Namn IS NOT NULL)
        OR (:NEW.PR_NAM_Föreställning_Namn IS NOT NULL AND :OLD.PR_NAM_Föreställning_Namn IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_NAM_Föreställning_Namn IS NOT NULL THEN
            attributes.ip_PR_NAM_Föreställning_Namn(
                p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                p_value => :NEW.PR_NAM_Föreställning_Namn,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
                            OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
                            OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL))
                        AND (:NEW.Metadata_PR_NAM = :OLD.Metadata_PR_NAM
                            OR (:NEW.Metadata_PR_NAM IS NULL AND :OLD.Metadata_PR_NAM IS NULL))
                        THEN :NEW.Metadata_PR
                        ELSE :NEW.Metadata_PR_NAM
                    END, :NEW.Metadata_PR)
            );
        END IF;
    END IF;
    IF (:NEW.PR_LEN_PR_ID <> :OLD.PR_LEN_PR_ID
        OR (:NEW.PR_LEN_PR_ID IS NULL AND :OLD.PR_LEN_PR_ID IS NOT NULL)
        OR (:NEW.PR_LEN_PR_ID IS NOT NULL AND :OLD.PR_LEN_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_LEN_PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_LEN_Föreställning_Längd <> :OLD.PR_LEN_Föreställning_Längd
        OR (:NEW.PR_LEN_Föreställning_Längd IS NULL AND :OLD.PR_LEN_Föreställning_Längd IS NOT NULL)
        OR (:NEW.PR_LEN_Föreställning_Längd IS NOT NULL AND :OLD.PR_LEN_Föreställning_Längd IS NULL))
    OR (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_LEN_Föreställning_Längd IS NOT NULL THEN
            attributes.ip_PR_LEN_Föreställning_Längd(
                p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                p_changing => CASE
                    WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
                        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
                    THEN :NEW.PR_LEN_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.PR_LEN_Föreställning_Längd,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
                            OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
                            OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL))
                        AND (:NEW.Metadata_PR_LEN = :OLD.Metadata_PR_LEN
                            OR (:NEW.Metadata_PR_LEN IS NULL AND :OLD.Metadata_PR_LEN IS NULL))
                        THEN :NEW.Metadata_PR
                        ELSE :NEW.Metadata_PR_LEN
                    END, :NEW.Metadata_PR)
            );
        END IF;
    END IF;
END ut_lPR_Föreställning;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Föreställning instead of DELETE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lPR_Föreställning
INSTEAD OF DELETE ON anchors.lPR_Föreställning
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.PR_NAM_Föreställning_Namn x
    WHERE
        x.PR_NAM_PR_ID = :OLD.PR_ID
    ;
    DELETE FROM
        attributes.PR_LEN_Föreställning_Längd x
    WHERE
        x.PR_LEN_PR_ID = :OLD.PR_ID
    AND
        x.PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        anchors.PR_Föreställning a
    WHERE
        a.PR_ID = :OLD.PR_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.PR_NAM_Föreställning_Namn x
        WHERE
            x.PR_NAM_PR_ID = a.PR_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.PR_LEN_Föreställning_Längd x
        WHERE
            x.PR_LEN_PR_ID = a.PR_ID
    )
    ;
END dt_lPR_Föreställning;
/
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates (the insert procedures of the
-- attributes, ip_<attribute>, see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_Händelse instead of INSERT trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.it_lEV_Händelse
INSTEAD OF INSERT ON nexuses.lEV_Händelse
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(12,0);
    v_ETY_of number(3);
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        -- the identity of the knot value of the role, given as it is or looked up from the value
        v_ETY_of := :NEW.ETY_ID_of;
        IF v_ETY_of IS NULL AND :NEW.of_ETY_Händelsetyp IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ETY_ID
                FROM
                    knots.ETY_Händelsetyp k
                WHERE
                    k.ETY_Checksum = STANDARD_HASH(:NEW.of_ETY_Händelsetyp, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ETY_of := kv.ETY_ID;
            END LOOP;
        END IF;
        INSERT INTO nexuses.EV_Händelse (
            ST_ID_hölls,
            PR_ID_spelades,
            ETY_ID_of,
            Metadata_EV
        )
        VALUES (
            :NEW.ST_ID_hölls,
            :NEW.PR_ID_spelades,
            v_ETY_of,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Händelse_Datum IS NOT NULL THEN
        attributes.ip_EV_DAT_Händelse_Datum(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Händelse_Datum,
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Händelse_Publik IS NOT NULL THEN
        attributes.ip_EV_AUD_Händelse_Publik(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Händelse_Publik,
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Händelse_Intäkt IS NOT NULL THEN
        attributes.ip_EV_REV_Händelse_Intäkt(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Händelse_Intäkt,
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_STA_Händelse_Status IS NOT NULL THEN
        attributes.ip_EV_STA_Händelse_Status(
            p_owner => COALESCE(:NEW.EV_STA_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_STA_ChangedAt, v_now),
            p_value => :NEW.EV_STA_Händelse_Status,
            p_metadata => COALESCE(:NEW.Metadata_EV_STA, :NEW.Metadata_EV)
        );
    END IF;
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF v_UTL IS NULL AND :NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                knots.UTL_Utnyttjande k
            WHERE
                k.UTL_Utnyttjande = :NEW.EV_UTL_UTL_Utnyttjande
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_UTL := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_UTL IS NOT NULL THEN
        attributes.ip_EV_UTL_Händelse_Utnyttjande(
            p_owner => COALESCE(:NEW.EV_UTL_EV_ID, v_id),
            p_value => v_UTL,
            p_metadata => COALESCE(:NEW.Metadata_EV_UTL, :NEW.Metadata_EV)
        );
    END IF;
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF v_LVL IS NULL AND :NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                knots.PLV_Yrkesnivå k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_Yrkesnivå, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_LVL := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_LVL IS NOT NULL THEN
        attributes.ip_EV_LVL_Händelse_Level(
            p_owner => COALESCE(:NEW.EV_LVL_EV_ID, v_id),
            p_changing => COALESCE(:NEW.EV_LVL_ChangedAt, v_now),
            p_value => v_LVL,
            p_metadata => COALESCE(:NEW.Metadata_EV_LVL, :NEW.Metadata_EV)
        );
    END IF;
END it_lEV_Händelse;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Händelse instead of UPDATE trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.ut_lEV_Händelse
INSTEAD OF UPDATE ON nexuses.lEV_Händelse
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.ST_ID_hölls <> :OLD.ST_ID_hölls
        OR (:NEW.ST_ID_hölls IS NULL AND :OLD.ST_ID_hölls IS NOT NULL)
        OR (:NEW.ST_ID_hölls IS NOT NULL AND :OLD.ST_ID_hölls IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ST_ID_hölls is not updatable.');
    END IF;
    IF (:NEW.PR_ID_spelades <> :OLD.PR_ID_spelades
        OR (:NEW.PR_ID_spelades IS NULL AND :OLD.PR_ID_spelades IS NOT NULL)
        OR (:NEW.PR_ID_spelades IS NOT NULL AND :OLD.PR_ID_spelades IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column PR_ID_spelades is not updatable.');
    END IF;
    IF (:NEW.ETY_ID_of <> :OLD.ETY_ID_of
        OR (:NEW.ETY_ID_of IS NULL AND :OLD.ETY_ID_of IS NOT NULL)
        OR (:NEW.ETY_ID_of IS NOT NULL AND :OLD.ETY_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column ETY_ID_of is not updatable.');
    END IF;
    IF (:NEW.of_ETY_Händelsetyp <> :OLD.of_ETY_Händelsetyp
        OR (:NEW.of_ETY_Händelsetyp IS NULL AND :OLD.of_ETY_Händelsetyp IS NOT NULL)
        OR (:NEW.of_ETY_Händelsetyp IS NOT NULL AND :OLD.of_ETY_Händelsetyp IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column of_ETY_Händelsetyp is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_EV_ID <> :OLD.EV_DAT_EV_ID
        OR (:NEW.EV_DAT_EV_ID IS NULL AND :OLD.EV_DAT_EV_ID IS NOT NULL)
        OR (:NEW.EV_DAT_EV_ID IS NOT NULL AND :OLD.EV_DAT_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_DAT_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_Händelse_Datum <> :OLD.EV_DAT_Händelse_Datum
        OR (:NEW.EV_DAT_Händelse_Datum IS NULL AND :OLD.EV_DAT_Händelse_Datum IS NOT NULL)
        OR (:NEW.EV_DAT_Händelse_Datum IS NOT NULL AND :OLD.EV_DAT_Händelse_Datum IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_DAT_Händelse_Datum IS NOT NULL THEN
            attributes.ip_EV_DAT_Händelse_Datum(
                p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_DAT_Händelse_Datum,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_DAT = :OLD.Metadata_EV_DAT
                            OR (:NEW.Metadata_EV_DAT IS NULL AND :OLD.Metadata_EV_DAT IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_DAT
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_AUD_EV_ID <> :OLD.EV_AUD_EV_ID
        OR (:NEW.EV_AUD_EV_ID IS NULL AND :OLD.EV_AUD_EV_ID IS NOT NULL)
        OR (:NEW.EV_AUD_EV_ID IS NOT NULL AND :OLD.EV_AUD_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_AUD_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_AUD_Händelse_Publik <> :OLD.EV_AUD_Händelse_Publik
        OR (:NEW.EV_AUD_Händelse_Publik IS NULL AND :OLD.EV_AUD_Händelse_Publik IS NOT NULL)
        OR (:NEW.EV_AUD_Händelse_Publik IS NOT NULL AND :OLD.EV_AUD_Händelse_Publik IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_AUD_Händelse_Publik IS NOT NULL THEN
            attributes.ip_EV_AUD_Händelse_Publik(
                p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_AUD_Händelse_Publik,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_AUD = :OLD.Metadata_EV_AUD
                            OR (:NEW.Metadata_EV_AUD IS NULL AND :OLD.Metadata_EV_AUD IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_AUD
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_REV_EV_ID <> :OLD.EV_REV_EV_ID
        OR (:NEW.EV_REV_EV_ID IS NULL AND :OLD.EV_REV_EV_ID IS NOT NULL)
        OR (:NEW.EV_REV_EV_ID IS NOT NULL AND :OLD.EV_REV_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_REV_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_REV_Händelse_Intäkt <> :OLD.EV_REV_Händelse_Intäkt
        OR (:NEW.EV_REV_Händelse_Intäkt IS NULL AND :OLD.EV_REV_Händelse_Intäkt IS NOT NULL)
        OR (:NEW.EV_REV_Händelse_Intäkt IS NOT NULL AND :OLD.EV_REV_Händelse_Intäkt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_REV_Händelse_Intäkt IS NOT NULL THEN
            attributes.ip_EV_REV_Händelse_Intäkt(
                p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                p_value => :NEW.EV_REV_Händelse_Intäkt,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_REV = :OLD.Metadata_EV_REV
                            OR (:NEW.Metadata_EV_REV IS NULL AND :OLD.Metadata_EV_REV IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_REV
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_STA_EV_ID <> :OLD.EV_STA_EV_ID
        OR (:NEW.EV_STA_EV_ID IS NULL AND :OLD.EV_STA_EV_ID IS NOT NULL)
        OR (:NEW.EV_STA_EV_ID IS NOT NULL AND :OLD.EV_STA_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_STA_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_STA_Händelse_Status <> :OLD.EV_STA_Händelse_Status
        OR (:NEW.EV_STA_Händelse_Status IS NULL AND :OLD.EV_STA_Händelse_Status IS NOT NULL)
        OR (:NEW.EV_STA_Händelse_Status IS NOT NULL AND :OLD.EV_STA_Händelse_Status IS NULL))
    OR (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.EV_STA_Händelse_Status IS NOT NULL THEN
            attributes.ip_EV_STA_Händelse_Status(
                p_owner => COALESCE(:NEW.EV_STA_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
                        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL))
                    THEN :NEW.EV_STA_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.EV_STA_Händelse_Status,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_STA = :OLD.Metadata_EV_STA
                            OR (:NEW.Metadata_EV_STA IS NULL AND :OLD.Metadata_EV_STA IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_STA
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_UTL_EV_ID <> :OLD.EV_UTL_EV_ID
        OR (:NEW.EV_UTL_EV_ID IS NULL AND :OLD.EV_UTL_EV_ID IS NOT NULL)
        OR (:NEW.EV_UTL_EV_ID IS NOT NULL AND :OLD.EV_UTL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_UTL_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_UTL_UTL_ID <> :OLD.EV_UTL_UTL_ID
        OR (:NEW.EV_UTL_UTL_ID IS NULL AND :OLD.EV_UTL_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_ID IS NOT NULL AND :OLD.EV_UTL_UTL_ID IS NULL))
    OR (:NEW.EV_UTL_UTL_Utnyttjande <> :OLD.EV_UTL_UTL_Utnyttjande
        OR (:NEW.EV_UTL_UTL_Utnyttjande IS NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_UTL := :NEW.EV_UTL_UTL_ID;
        IF (v_UTL = :OLD.EV_UTL_UTL_ID OR (v_UTL IS NULL AND :OLD.EV_UTL_UTL_ID IS NULL))
        AND :NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    knots.UTL_Utnyttjande k
                WHERE
                    k.UTL_Utnyttjande = :NEW.EV_UTL_UTL_Utnyttjande
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_UTL := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_UTL IS NOT NULL AND (
            :OLD.EV_UTL_UTL_ID IS NULL OR
            :OLD.EV_UTL_UTL_ID <> v_UTL
        ) THEN
            attributes.ip_EV_UTL_Händelse_Utnyttjande(
                p_owner => COALESCE(:NEW.EV_UTL_EV_ID, :NEW.EV_ID),
                p_value => v_UTL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_UTL = :OLD.Metadata_EV_UTL
                            OR (:NEW.Metadata_EV_UTL IS NULL AND :OLD.Metadata_EV_UTL IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_UTL
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
    IF (:NEW.EV_LVL_EV_ID <> :OLD.EV_LVL_EV_ID
        OR (:NEW.EV_LVL_EV_ID IS NULL AND :OLD.EV_LVL_EV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_EV_ID IS NOT NULL AND :OLD.EV_LVL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_LVL_EV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_LVL_PLV_ID <> :OLD.EV_LVL_PLV_ID
        OR (:NEW.EV_LVL_PLV_ID IS NULL AND :OLD.EV_LVL_PLV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ID IS NOT NULL AND :OLD.EV_LVL_PLV_ID IS NULL))
    OR (:NEW.EV_LVL_PLV_Yrkesnivå <> :OLD.EV_LVL_PLV_Yrkesnivå
        OR (:NEW.EV_LVL_PLV_Yrkesnivå IS NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NULL))
    OR (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_LVL := :NEW.EV_LVL_PLV_ID;
        IF (v_LVL = :OLD.EV_LVL_PLV_ID OR (v_LVL IS NULL AND :OLD.EV_LVL_PLV_ID IS NULL))
        AND :NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    knots.PLV_Yrkesnivå k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.EV_LVL_PLV_Yrkesnivå, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_LVL := kv.PLV_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_LVL IS NOT NULL AND (
            (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
                OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
                OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL)) OR
            :OLD.EV_LVL_PLV_ID IS NULL OR
            :OLD.EV_LVL_PLV_ID <> v_LVL
        ) THEN
            attributes.ip_EV_LVL_Händelse_Level(
                p_owner => COALESCE(:NEW.EV_LVL_EV_ID, :NEW.EV_ID),
                p_changing => CASE
                    WHEN (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
                        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
                        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL))
                    THEN :NEW.EV_LVL_ChangedAt
                    ELSE v_now
                END,
                p_value => v_LVL,
                p_metadata => COALESCE(
                    CASE
                        WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
                            OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
                            OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL))
                        AND (:NEW.Metadata_EV_LVL = :OLD.Metadata_EV_LVL
                            OR (:NEW.Metadata_EV_LVL IS NULL AND :OLD.Metadata_EV_LVL IS NULL))
                        THEN :NEW.Metadata_EV
                        ELSE :NEW.Metadata_EV_LVL
                    END, :NEW.Metadata_EV)
            );
        END IF;
    END IF;
END ut_lEV_Händelse;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Händelse instead of DELETE trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER nexuses.dt_lEV_Händelse
INSTEAD OF DELETE ON nexuses.lEV_Händelse
FOR EACH ROW
BEGIN
    DELETE FROM
        attributes.EV_DAT_Händelse_Datum x
    WHERE
        x.EV_DAT_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_AUD_Händelse_Publik x
    WHERE
        x.EV_AUD_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_REV_Händelse_Intäkt x
    WHERE
        x.EV_REV_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_STA_Händelse_Status x
    WHERE
        x.EV_STA_EV_ID = :OLD.EV_ID
    AND
        x.EV_STA_ChangedAt = :OLD.EV_STA_ChangedAt
    ;
    DELETE FROM
        attributes.EV_UTL_Händelse_Utnyttjande x
    WHERE
        x.EV_UTL_EV_ID = :OLD.EV_ID
    ;
    DELETE FROM
        attributes.EV_LVL_Händelse_Level x
    WHERE
        x.EV_LVL_EV_ID = :OLD.EV_ID
    AND
        x.EV_LVL_ChangedAt = :OLD.EV_LVL_ChangedAt
    ;
    -- a nexus that has no attribute rows left is removed
    DELETE FROM
        nexuses.EV_Händelse a
    WHERE
        a.EV_ID = :OLD.EV_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_DAT_Händelse_Datum x
        WHERE
            x.EV_DAT_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_AUD_Händelse_Publik x
        WHERE
            x.EV_AUD_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_REV_Händelse_Intäkt x
        WHERE
            x.EV_REV_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_STA_Händelse_Status x
        WHERE
            x.EV_STA_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande x
        WHERE
            x.EV_UTL_EV_ID = a.EV_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            attributes.EV_LVL_Händelse_Level x
        WHERE
            x.EV_LVL_EV_ID = a.EV_ID
    )
    ;
END dt_lEV_Händelse;
/
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- A tie and its latest view behave like a table that is loaded with plain statements. The rules for a row of a tie (it is
-- stored only when it is not there already, a contradiction is refused and, for an idempotent tie, what only states again
-- what the row before it says is left out) are in an insert procedure for each tie, ip_<tie>. The latest view has
-- three 'instead of' triggers: insert, update, and delete. They propagate such operations to the tie table in a consistent
-- way, the insert and update triggers by calling the insert procedure. Default values are used for some columns if not
-- provided by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures and not in a trigger on the tie table, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. A load can call the procedure itself:
--
--     BEGIN ip_AC_parent_AC_child(p_AC_parent => 1, p_AC_child => 2); END;
--
-- A row put straight into a tie table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a row of AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN ties.AC_partner_AC_with_ONG_currently.AC_ID_partner%TYPE,
    p_AC_with IN ties.AC_partner_AC_with_ONG_currently.AC_ID_with%TYPE,
    p_ONG_currently IN ties.AC_partner_AC_with_ONG_currently.ONG_ID_currently%TYPE,
    p_changing IN ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE,
    p_metadata IN ties.AC_partner_AC_with_ONG_currently.Metadata_AC_partner_AC_with_ONG_currently%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_metadata ties.AC_partner_AC_with_ONG_currently.Metadata_AC_partner_AC_with_ONG_currently%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_partner_AC_with_ONG_currently x
        WHERE
            x.AC_ID_partner = p_AC_partner
        AND
            x.AC_ID_with = p_AC_with
        AND
            x.ONG_ID_currently = p_ONG_currently
        AND
            x.AC_partner_AC_with_ONG_currently_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_partner_AC_with_ONG_currently (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    VALUES (
        v_metadata,
        v_changing,
        p_AC_partner,
        p_AC_with,
        p_ONG_currently
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.currently_ONG_Pågående IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                knots.ONG_Pågående k
            WHERE
                k.ONG_Pågående = :NEW.currently_ONG_Pågående
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_lAC_partner_AC_with_ONG_currently;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_partner_AC_with_ONG_currently
INSTEAD OF UPDATE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_ONG_currently number(3);
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.currently_ONG_Pågående <> :OLD.currently_ONG_Pågående
        OR (:NEW.currently_ONG_Pågående IS NULL AND :OLD.currently_ONG_Pågående IS NOT NULL)
        OR (:NEW.currently_ONG_Pågående IS NOT NULL AND :OLD.currently_ONG_Pågående IS NULL)) THEN
        v_ONG_currently := NULL;
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                knots.ONG_Pågående k
            WHERE
                k.ONG_Pågående = :NEW.currently_ONG_Pågående
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    -- values that are left as they are state nothing
    IF
        :NEW.AC_ID_partner IS NOT NULL
    AND
        :NEW.AC_ID_with IS NOT NULL
    AND
        v_ONG_currently IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_partner <> :OLD.AC_ID_partner
                OR (:NEW.AC_ID_partner IS NULL AND :OLD.AC_ID_partner IS NOT NULL)
                OR (:NEW.AC_ID_partner IS NOT NULL AND :OLD.AC_ID_partner IS NULL))
        OR
            (:NEW.AC_ID_with <> :OLD.AC_ID_with
                OR (:NEW.AC_ID_with IS NULL AND :OLD.AC_ID_with IS NOT NULL)
                OR (:NEW.AC_ID_with IS NOT NULL AND :OLD.AC_ID_with IS NULL))
        OR
            (v_ONG_currently <> :OLD.ONG_ID_currently
                OR (v_ONG_currently IS NULL AND :OLD.ONG_ID_currently IS NOT NULL)
                OR (v_ONG_currently IS NOT NULL AND :OLD.ONG_ID_currently IS NULL))
        )
    THEN
        ties.ip_AC_partner_AC_with_ONG_currently(
            p_AC_partner => :NEW.AC_ID_partner,
            p_AC_with => :NEW.AC_ID_with,
            p_ONG_currently => v_ONG_currently,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
        );
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_partner_AC_with_ONG_currently x
    WHERE
        x.AC_partner_AC_with_ONG_currently_ChangedAt = :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
    AND
        x.AC_ID_partner = :OLD.AC_ID_partner
    AND
        x.AC_ID_with = :OLD.AC_ID_with
    AND
        x.ONG_ID_currently = :OLD.ONG_ID_currently
    ;
END dt_lAC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a row of AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_subset_PN_of (
    p_AC_subset IN ties.AC_subset_PN_of.AC_ID_subset%TYPE,
    p_PN_of IN ties.AC_subset_PN_of.PN_ID_of%TYPE,
    p_metadata IN ties.AC_subset_PN_of.Metadata_AC_subset_PN_of%TYPE
)
IS
    v_metadata ties.AC_subset_PN_of.Metadata_AC_subset_PN_of%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_subset_PN_of x
        WHERE
            x.AC_ID_subset = p_AC_subset
        AND
            x.PN_ID_of = p_PN_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_subset_PN_of (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of
    )
    VALUES (
        v_metadata,
        p_AC_subset,
        p_PN_of
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_subset_PN_of
INSTEAD OF INSERT ON ties.lAC_subset_PN_of
FOR EACH ROW
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_lAC_subset_PN_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_subset_PN_of
INSTEAD OF UPDATE ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- values that are left as they are state nothing
    IF
        :NEW.AC_ID_subset IS NOT NULL
    AND
        :NEW.PN_ID_of IS NOT NULL
    AND
        (
            (:NEW.AC_ID_subset <> :OLD.AC_ID_subset
                OR (:NEW.AC_ID_subset IS NULL AND :OLD.AC_ID_subset IS NOT NULL)
                OR (:NEW.AC_ID_subset IS NOT NULL AND :OLD.AC_ID_subset IS NULL))
        OR
            (:NEW.PN_ID_of <> :OLD.PN_ID_of
                OR (:NEW.PN_ID_of IS NULL AND :OLD.PN_ID_of IS NOT NULL)
                OR (:NEW.PN_ID_of IS NOT NULL AND :OLD.PN_ID_of IS NULL))
        )
    THEN
        ties.ip_AC_subset_PN_of(
            p_AC_subset => :NEW.AC_ID_subset,
            p_PN_of => :NEW.PN_ID_of,
            p_metadata => :NEW.Metadata_AC_subset_PN_of
        );
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_subset_PN_of
INSTEAD OF DELETE ON ties.lAC_subset_PN_of
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_subset_PN_of x
    WHERE
        x.AC_ID_subset = :OLD.AC_ID_subset
    AND
        x.PN_ID_of = :OLD.PN_ID_of
    ;
END dt_lAC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_rollsattes states a row of EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_rollsattes (
    p_EV_in IN ties.EV_in_AC_rollsattes.EV_ID_in%TYPE,
    p_AC_rollsattes IN ties.EV_in_AC_rollsattes.AC_ID_rollsattes%TYPE,
    p_metadata IN ties.EV_in_AC_rollsattes.Metadata_EV_in_AC_rollsattes%TYPE
)
IS
    v_metadata ties.EV_in_AC_rollsattes.Metadata_EV_in_AC_rollsattes%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.EV_in_AC_rollsattes x
        WHERE
            x.EV_ID_in = p_EV_in
        AND
            x.AC_ID_rollsattes = p_AC_rollsattes
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.EV_in_AC_rollsattes (
        Metadata_EV_in_AC_rollsattes,
        EV_ID_in,
        AC_ID_rollsattes
    )
    VALUES (
        v_metadata,
        p_EV_in,
        p_AC_rollsattes
    );
END ip_EV_in_AC_rollsattes;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_rollsattes
INSTEAD OF INSERT ON ties.lEV_in_AC_rollsattes
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_rollsattes => :NEW.AC_ID_rollsattes,
        p_metadata => :NEW.Metadata_EV_in_AC_rollsattes
    );
END it_lEV_in_AC_rollsattes;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_rollsattes instead of DELETE trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lEV_in_AC_rollsattes
INSTEAD OF DELETE ON ties.lEV_in_AC_rollsattes
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.EV_in_AC_rollsattes x
    WHERE
        x.EV_ID_in = :OLD.EV_ID_in
    AND
        x.AC_ID_rollsattes = :OLD.AC_ID_rollsattes
    ;
END dt_lEV_in_AC_rollsattes;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_deltar_PR_in_RAT_fick states a row of AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_deltar_PR_in_RAT_fick (
    p_AC_deltar IN ties.AC_deltar_PR_in_RAT_fick.AC_ID_deltar%TYPE,
    p_PR_in IN ties.AC_deltar_PR_in_RAT_fick.PR_ID_in%TYPE,
    p_RAT_fick IN ties.AC_deltar_PR_in_RAT_fick.RAT_ID_fick%TYPE,
    p_changing IN ties.AC_deltar_PR_in_RAT_fick.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE,
    p_metadata IN ties.AC_deltar_PR_in_RAT_fick.Metadata_AC_deltar_PR_in_RAT_fick%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.AC_deltar_PR_in_RAT_fick.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE;
    v_metadata ties.AC_deltar_PR_in_RAT_fick.Metadata_AC_deltar_PR_in_RAT_fick%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_deltar_PR_in_RAT_fick x
        WHERE
            x.AC_ID_deltar = p_AC_deltar
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.RAT_ID_fick = p_RAT_fick
        AND
            x.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_deltar_PR_in_RAT_fick x
        WHERE
            x.AC_ID_deltar = p_AC_deltar
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_deltar_PR_in_RAT_fick for: '
            || p_AC_deltar
            || ', '
            || p_PR_in
            || ', '
            || v_changing
        );
    END LOOP;
    INSERT INTO ties.AC_deltar_PR_in_RAT_fick (
        Metadata_AC_deltar_PR_in_RAT_fick,
        AC_deltar_PR_in_RAT_fick_ChangedAt,
        AC_ID_deltar,
        PR_ID_in,
        RAT_ID_fick
    )
    VALUES (
        v_metadata,
        v_changing,
        p_AC_deltar,
        p_PR_in,
        p_RAT_fick
    );
END ip_AC_deltar_PR_in_RAT_fick;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_deltar_PR_in_RAT_fick
INSTEAD OF INSERT ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_RAT_fick number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_fick := :NEW.RAT_ID_fick;
    IF v_RAT_fick IS NULL AND :NEW.fick_RAT_Betyg IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                knots.RAT_Betyg k
            WHERE
                k.RAT_Checksum = STANDARD_HASH(:NEW.fick_RAT_Betyg, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_fick := kv.RAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_deltar_PR_in_RAT_fick(
        p_AC_deltar => :NEW.AC_ID_deltar,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_fick => v_RAT_fick,
        p_changing => :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt,
        p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
    );
END it_lAC_deltar_PR_in_RAT_fick;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_deltar_PR_in_RAT_fick instead of UPDATE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_deltar_PR_in_RAT_fick
INSTEAD OF UPDATE ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing ties.AC_deltar_PR_in_RAT_fick.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE;
    v_RAT_fick number(3);
BEGIN
    IF (:NEW.AC_ID_deltar <> :OLD.AC_ID_deltar
        OR (:NEW.AC_ID_deltar IS NULL AND :OLD.AC_ID_deltar IS NOT NULL)
        OR (:NEW.AC_ID_deltar IS NOT NULL AND :OLD.AC_ID_deltar IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID_deltar is not updatable.');
    END IF;
    IF (:NEW.PR_ID_in <> :OLD.PR_ID_in
        OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
        OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID_in is not updatable.');
    END IF;
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt <> :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL)
        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_fick := :NEW.RAT_ID_fick;
    IF (:NEW.fick_RAT_Betyg <> :OLD.fick_RAT_Betyg
        OR (:NEW.fick_RAT_Betyg IS NULL AND :OLD.fick_RAT_Betyg IS NOT NULL)
        OR (:NEW.fick_RAT_Betyg IS NOT NULL AND :OLD.fick_RAT_Betyg IS NULL)) THEN
        v_RAT_fick := NULL;
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                knots.RAT_Betyg k
            WHERE
                k.RAT_Checksum = STANDARD_HASH(:NEW.fick_RAT_Betyg, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_fick := kv.RAT_ID;
        END LOOP;
    END IF;
    -- values that are left as they are state nothing
    IF
        v_RAT_fick IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_deltar <> :OLD.AC_ID_deltar
                OR (:NEW.AC_ID_deltar IS NULL AND :OLD.AC_ID_deltar IS NOT NULL)
                OR (:NEW.AC_ID_deltar IS NOT NULL AND :OLD.AC_ID_deltar IS NULL))
        OR
            (:NEW.PR_ID_in <> :OLD.PR_ID_in
                OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
                OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL))
        OR
            (v_RAT_fick <> :OLD.RAT_ID_fick
                OR (v_RAT_fick IS NULL AND :OLD.RAT_ID_fick IS NOT NULL)
                OR (v_RAT_fick IS NOT NULL AND :OLD.RAT_ID_fick IS NULL))
        )
    THEN
        ties.ip_AC_deltar_PR_in_RAT_fick(
            p_AC_deltar => :NEW.AC_ID_deltar,
            p_PR_in => :NEW.PR_ID_in,
            p_RAT_fick => v_RAT_fick,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
        );
    END IF;
END ut_lAC_deltar_PR_in_RAT_fick;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_deltar_PR_in_RAT_fick
INSTEAD OF DELETE ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_deltar_PR_in_RAT_fick x
    WHERE
        x.AC_deltar_PR_in_RAT_fick_ChangedAt = :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
    AND
        x.AC_ID_deltar = :OLD.AC_ID_deltar
    AND
        x.PR_ID_in = :OLD.PR_ID_in
    ;
END dt_lAC_deltar_PR_in_RAT_fick;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_spelas states a row of ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_spelas (
    p_ST_at IN ties.ST_at_PR_spelas.ST_ID_at%TYPE,
    p_PR_spelas IN ties.ST_at_PR_spelas.PR_ID_spelas%TYPE,
    p_changing IN ties.ST_at_PR_spelas.ST_at_PR_spelas_ChangedAt%TYPE,
    p_metadata IN ties.ST_at_PR_spelas.Metadata_ST_at_PR_spelas%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.ST_at_PR_spelas.ST_at_PR_spelas_ChangedAt%TYPE;
    v_metadata ties.ST_at_PR_spelas.Metadata_ST_at_PR_spelas%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.ST_at_PR_spelas x
        WHERE
            x.ST_ID_at = p_ST_at
        AND
            x.PR_ID_spelas = p_PR_spelas
        AND
            x.ST_at_PR_spelas_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.ST_at_PR_spelas (
        Metadata_ST_at_PR_spelas,
        ST_at_PR_spelas_ChangedAt,
        ST_ID_at,
        PR_ID_spelas
    )
    VALUES (
        v_metadata,
        v_changing,
        p_ST_at,
        p_PR_spelas
    );
END ip_ST_at_PR_spelas;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_spelas
INSTEAD OF INSERT ON ties.lST_at_PR_spelas
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_spelas => :NEW.PR_ID_spelas,
        p_changing => :NEW.ST_at_PR_spelas_ChangedAt,
        p_metadata => :NEW.Metadata_ST_at_PR_spelas
    );
END it_lST_at_PR_spelas;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_spelas instead of DELETE trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lST_at_PR_spelas
INSTEAD OF DELETE ON ties.lST_at_PR_spelas
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.ST_at_PR_spelas x
    WHERE
        x.ST_at_PR_spelas_ChangedAt = :OLD.ST_at_PR_spelas_ChangedAt
    AND
        x.ST_ID_at = :OLD.ST_ID_at
    AND
        x.PR_ID_spelas = :OLD.PR_ID_spelas
    ;
END dt_lST_at_PR_spelas;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_förälder_AC_barn_PAT_har states a row of AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_förälder_AC_barn_PAT_har (
    p_AC_förälder IN ties.AC_förälder_AC_barn_PAT_har.AC_ID_förälder%TYPE,
    p_AC_barn IN ties.AC_förälder_AC_barn_PAT_har.AC_ID_barn%TYPE,
    p_PAT_har IN ties.AC_förälder_AC_barn_PAT_har.PAT_ID_har%TYPE,
    p_metadata IN ties.AC_förälder_AC_barn_PAT_har.Metadata_AC_förälder_AC_barn_PAT_har%TYPE
)
IS
    v_metadata ties.AC_förälder_AC_barn_PAT_har.Metadata_AC_förälder_AC_barn_PAT_har%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_förälder_AC_barn_PAT_har x
        WHERE
            x.AC_ID_förälder = p_AC_förälder
        AND
            x.AC_ID_barn = p_AC_barn
        AND
            x.PAT_ID_har = p_PAT_har
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_förälder_AC_barn_PAT_har (
        Metadata_AC_förälder_AC_barn_PAT_har,
        AC_ID_förälder,
        AC_ID_barn,
        PAT_ID_har
    )
    VALUES (
        v_metadata,
        p_AC_förälder,
        p_AC_barn,
        p_PAT_har
    );
END ip_AC_förälder_AC_barn_PAT_har;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_förälder_AC_barn_PAT_har
INSTEAD OF INSERT ON ties.lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
DECLARE
    v_PAT_har number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_PAT_har := :NEW.PAT_ID_har;
    IF v_PAT_har IS NULL AND :NEW.har_PAT_Föräldratyp IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                knots.PAT_Föräldratyp k
            WHERE
                k.PAT_Föräldratyp = :NEW.har_PAT_Föräldratyp
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_har := kv.PAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_förälder_AC_barn_PAT_har(
        p_AC_förälder => :NEW.AC_ID_förälder,
        p_AC_barn => :NEW.AC_ID_barn,
        p_PAT_har => v_PAT_har,
        p_metadata => :NEW.Metadata_AC_förälder_AC_barn_PAT_har
    );
END it_lAC_förälder_AC_barn_PAT_har;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_förälder_AC_barn_PAT_har instead of DELETE trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_förälder_AC_barn_PAT_har
INSTEAD OF DELETE ON ties.lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_förälder_AC_barn_PAT_har x
    WHERE
        x.AC_ID_förälder = :OLD.AC_ID_förälder
    AND
        x.AC_ID_barn = :OLD.AC_ID_barn
    AND
        x.PAT_ID_har = :OLD.PAT_ID_har
    ;
END dt_lAC_förälder_AC_barn_PAT_har;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_innehåll_ST_plats_EV_of states a row of PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_innehåll_ST_plats_EV_of (
    p_PR_innehåll IN ties.PR_innehåll_ST_plats_EV_of.PR_ID_innehåll%TYPE,
    p_ST_plats IN ties.PR_innehåll_ST_plats_EV_of.ST_ID_plats%TYPE,
    p_EV_of IN ties.PR_innehåll_ST_plats_EV_of.EV_ID_of%TYPE,
    p_changing IN ties.PR_innehåll_ST_plats_EV_of.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE,
    p_metadata IN ties.PR_innehåll_ST_plats_EV_of.Metadata_PR_innehåll_ST_plats_EV_of%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.PR_innehåll_ST_plats_EV_of.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE;
    v_metadata ties.PR_innehåll_ST_plats_EV_of.Metadata_PR_innehåll_ST_plats_EV_of%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.PR_innehåll_ST_plats_EV_of x
        WHERE
            x.PR_ID_innehåll = p_PR_innehåll
        AND
            x.ST_ID_plats = p_ST_plats
        AND
            x.EV_ID_of = p_EV_of
        AND
            x.PR_innehåll_ST_plats_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.PR_innehåll_ST_plats_EV_of (
        Metadata_PR_innehåll_ST_plats_EV_of,
        PR_innehåll_ST_plats_EV_of_ChangedAt,
        PR_ID_innehåll,
        ST_ID_plats,
        EV_ID_of
    )
    VALUES (
        v_metadata,
        v_changing,
        p_PR_innehåll,
        p_ST_plats,
        p_EV_of
    );
END ip_PR_innehåll_ST_plats_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_innehåll_ST_plats_EV_of
INSTEAD OF INSERT ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :NEW.PR_ID_innehåll,
        p_ST_plats => :NEW.ST_ID_plats,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt,
        p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
    );
END it_lPR_innehåll_ST_plats_EV_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_innehåll_ST_plats_EV_of instead of UPDATE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lPR_innehåll_ST_plats_EV_of
INSTEAD OF UPDATE ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing ties.PR_innehåll_ST_plats_EV_of.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE;
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt <> :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL)
        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt ELSE v_now END;
    -- values that are left as they are state nothing
    IF
        :NEW.PR_ID_innehåll IS NOT NULL
    AND
        :NEW.ST_ID_plats IS NOT NULL
    AND
        :NEW.EV_ID_of IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.PR_ID_innehåll <> :OLD.PR_ID_innehåll
                OR (:NEW.PR_ID_innehåll IS NULL AND :OLD.PR_ID_innehåll IS NOT NULL)
                OR (:NEW.PR_ID_innehåll IS NOT NULL AND :OLD.PR_ID_innehåll IS NULL))
        OR
            (:NEW.ST_ID_plats <> :OLD.ST_ID_plats
                OR (:NEW.ST_ID_plats IS NULL AND :OLD.ST_ID_plats IS NOT NULL)
                OR (:NEW.ST_ID_plats IS NOT NULL AND :OLD.ST_ID_plats IS NULL))
        OR
            (:NEW.EV_ID_of <> :OLD.EV_ID_of
                OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
                OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL))
        )
    THEN
        ties.ip_PR_innehåll_ST_plats_EV_of(
            p_PR_innehåll => :NEW.PR_ID_innehåll,
            p_ST_plats => :NEW.ST_ID_plats,
            p_EV_of => :NEW.EV_ID_of,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
        );
    END IF;
END ut_lPR_innehåll_ST_plats_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_innehåll_ST_plats_EV_of
INSTEAD OF DELETE ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.PR_innehåll_ST_plats_EV_of x
    WHERE
        x.PR_innehåll_ST_plats_EV_of_ChangedAt = :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
    AND
        x.PR_ID_innehåll = :OLD.PR_ID_innehåll
    AND
        x.ST_ID_plats = :OLD.ST_ID_plats
    AND
        x.EV_ID_of = :OLD.EV_ID_of
    ;
END dt_lPR_innehåll_ST_plats_EV_of;
/
-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          the checksum, a hash of the value, which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change (a SQL table macro)
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; a violation is a row with the construct, what is wrong, the key as JSON
--
-- Oracle does not enforce that a key is unique (the primary keys are the identities), so a lookup through a key
-- view can find more than one identity when ic_key_ is not empty.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Scen_1st (
    ST_ID,
    ST_LOC_Scen_Plats,
    ST_LOC_Checksum
)
AS
SELECT
    "ST".ST_ID,
    "ST".ST_LOC_Scen_Plats,
    "ST".ST_LOC_Checksum
FROM
    anchors.lST_Scen "ST"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_ST_Scen_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Scen_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'ST_LOC_Checksum' VALUE ST_LOC_Checksum
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Scen_1st
WHERE
    ST_LOC_Checksum IS NOT NULL
GROUP BY
    ST_LOC_Checksum
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Scen_1st',
    'more than one natural key',
    JSON_OBJECT(
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Scen_1st
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Scen_2nd (
    ST_ID,
    ST_NAM_Scen_Namn
)
AS
SELECT
    "ST".ST_ID,
    "ST".ST_NAM_Scen_Namn
FROM
    anchors.lST_Scen "ST"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pkey_ST_Scen_2nd (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "ST".ST_ID,
            "ST".ST_NAM_Scen_Namn AS ST_NAM_Scen_Namn
        FROM
            anchors.pST_Scen(changingTimepoint) "ST"
    ]';
END pkey_ST_Scen_2nd;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_ST_Scen_2nd (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Scen_2nd',
    'duplicate natural key',
    JSON_OBJECT(
        'ST_NAM_Scen_Namn' VALUE ST_NAM_Scen_Namn
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Scen_2nd
WHERE
    ST_NAM_Scen_Namn IS NOT NULL
GROUP BY
    ST_NAM_Scen_Namn
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Scen_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Scen_2nd
GROUP BY
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_AC_Skådespelare_1st (
    AC_ID,
    AC_NAM_Skådespelare_Namn
)
AS
SELECT
    "AC".AC_ID,
    "AC".AC_NAM_Skådespelare_Namn
FROM
    anchors.lAC_Skådespelare "AC"
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare at a changing time
--
-- A SQL table macro (Oracle Database 19.7 or later): it returns the text of a query, in which changingTimepoint stands
-- for the value given. It calls the point-in-time perspectives, which are macros too.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pkey_AC_Skådespelare_1st (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "AC".AC_ID,
            "AC".AC_NAM_Skådespelare_Namn AS AC_NAM_Skådespelare_Namn
        FROM
            anchors.pAC_Skådespelare(changingTimepoint) "AC"
    ]';
END pkey_AC_Skådespelare_1st;
/
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_AC_Skådespelare_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Skådespelare_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'AC_NAM_Skådespelare_Namn' VALUE AC_NAM_Skådespelare_Namn
    ),
    COUNT(DISTINCT AC_ID)
FROM
    anchors.key_AC_Skådespelare_1st
WHERE
    AC_NAM_Skådespelare_Namn IS NOT NULL
GROUP BY
    AC_NAM_Skådespelare_Namn
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Skådespelare_1st',
    'more than one natural key',
    JSON_OBJECT(
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    anchors.key_AC_Skådespelare_1st
GROUP BY
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_PR_Föreställning_1st (
    PR_ID,
    PR_NAM_Föreställning_Namn
)
AS
SELECT
    "PR".PR_ID,
    "PR".PR_NAM_Föreställning_Namn
FROM
    anchors.lPR_Föreställning "PR"
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.ic_key_PR_Föreställning_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Föreställning_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'PR_NAM_Föreställning_Namn' VALUE PR_NAM_Föreställning_Namn
    ),
    COUNT(DISTINCT PR_ID)
FROM
    anchors.key_PR_Föreställning_1st
WHERE
    PR_NAM_Föreställning_Namn IS NOT NULL
GROUP BY
    PR_NAM_Föreställning_Namn
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Föreställning_1st',
    'more than one natural key',
    JSON_OBJECT(
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    anchors.key_PR_Föreställning_1st
GROUP BY
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.key_EV_Händelse_1st (
    EV_ID,
    EV_DAT_Händelse_Datum,
    hölls_ST_LOC_Scen_Plats,
    hölls_ST_LOC_Checksum,
    spelades_PR_NAM_Föreställning_Namn
)
AS
SELECT
    "EV".EV_ID,
    "EV".EV_DAT_Händelse_Datum,
    "s2".ST_LOC_Scen_Plats,
    "s2".ST_LOC_Checksum,
    "s4".PR_NAM_Föreställning_Namn
FROM
    nexuses.lEV_Händelse "EV"
LEFT JOIN
    anchors.lST_Scen "s2"
ON
    "s2".ST_ID = "EV".ST_ID_hölls
LEFT JOIN
    anchors.lPR_Föreställning "s4"
ON
    "s4".PR_ID = "EV".PR_ID_spelades
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.ic_key_EV_Händelse_1st (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Händelse_1st',
    'duplicate natural key',
    JSON_OBJECT(
        'EV_DAT_Händelse_Datum' VALUE EV_DAT_Händelse_Datum,
        'hölls_ST_LOC_Checksum' VALUE hölls_ST_LOC_Checksum,
        'spelades_PR_NAM_Föreställning_Namn' VALUE spelades_PR_NAM_Föreställning_Namn
    ),
    COUNT(DISTINCT EV_ID)
FROM
    nexuses.key_EV_Händelse_1st
WHERE
    EV_DAT_Händelse_Datum IS NOT NULL
AND
    hölls_ST_LOC_Checksum IS NOT NULL
AND
    spelades_PR_NAM_Föreställning_Namn IS NOT NULL
GROUP BY
    EV_DAT_Händelse_Datum,
    hölls_ST_LOC_Checksum,
    spelades_PR_NAM_Föreställning_Namn
HAVING
    COUNT(DISTINCT EV_ID) > 1
UNION ALL
SELECT
    'key_EV_Händelse_1st',
    'more than one natural key',
    JSON_OBJECT(
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    nexuses.key_EV_Händelse_1st
GROUP BY
    EV_ID
HAVING
    COUNT(*) > 1;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the tables and the columns holding values and references, making
-- them available to catalogs and semantic layers. A comment in Oracle is replaced by running the statement again.
-- Oracle has no comment on a schema, so the description of the model itself is not added.
--
COMMENT ON TABLE knots.PAT_Föräldratyp IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN knots.PAT_Föräldratyp.PAT_Föräldratyp IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots.GEN_Kön IS 'Gender of an actor.';
COMMENT ON COLUMN knots.GEN_Kön.GEN_Kön IS 'Gender of an actor.';
COMMENT ON TABLE knots.PLV_Yrkesnivå IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN knots.PLV_Yrkesnivå.PLV_Yrkesnivå IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots.UTL_Utnyttjande IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots.UTL_Utnyttjande.UTL_Utnyttjande IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots.ONG_Pågående IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots.ONG_Pågående.ONG_Pågående IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots.RAT_Betyg IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN knots.RAT_Betyg.RAT_Betyg IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn IS 'Name or title of the program.';
COMMENT ON COLUMN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors.ST_Scen IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors.AC_Skådespelare IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses.EV_Händelse IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses.EV_Händelse.ST_ID_hölls IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses.EV_Händelse.PR_ID_spelades IS 'The program that was played at the event.';
COMMENT ON TABLE ties.AC_partner_AC_with_ONG_currently IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties.AC_subset_PN_of.AC_ID_subset IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties.AC_subset_PN_of.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE ties.EV_in_AC_rollsattes IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties.EV_in_AC_rollsattes.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties.EV_in_AC_rollsattes.AC_ID_rollsattes IS 'An actor cast in the event.';
COMMENT ON TABLE ties.AC_deltar_PR_in_RAT_fick IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties.AC_deltar_PR_in_RAT_fick.AC_ID_deltar IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties.AC_deltar_PR_in_RAT_fick.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties.AC_deltar_PR_in_RAT_fick.RAT_ID_fick IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties.ST_at_PR_spelas IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties.ST_at_PR_spelas.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties.ST_at_PR_spelas.PR_ID_spelas IS 'The program playing at the stage.';
COMMENT ON TABLE ties.AC_förälder_AC_barn_PAT_har IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties.AC_förälder_AC_barn_PAT_har.AC_ID_förälder IS 'The actor who is the parent.';
COMMENT ON COLUMN ties.AC_förälder_AC_barn_PAT_har.AC_ID_barn IS 'The actor who is the child.';
COMMENT ON COLUMN ties.AC_förälder_AC_barn_PAT_har.PAT_ID_har IS 'The type of parental relationship.';
COMMENT ON TABLE ties.PR_innehåll_ST_plats_EV_of IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties.PR_innehåll_ST_plats_EV_of.PR_ID_innehåll IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties.PR_innehåll_ST_plats_EV_of.ST_ID_plats IS 'The stage where the event was located.';
COMMENT ON COLUMN ties.PR_innehåll_ST_plats_EV_of.EV_ID_of IS 'The event.';
