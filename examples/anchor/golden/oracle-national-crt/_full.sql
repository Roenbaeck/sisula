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
-- An attribute has a posit table, which holds the values, and an annex table, which holds who positioned each
-- of them (positor), when (positing time), and how reliable it is (reliability, from which the assertion follows).
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_DAT_Händelse_Datum_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Händelse_Datum_Posit (
            EV_DAT_ID number(10) default attributes.EV_DAT_Händelse_Datum_Posit_ID_SEQ.nextval not null, 
            EV_DAT_EV_ID number(12,0) not null,
            EV_DAT_Händelse_Datum timestamp not null,
            constraint fkEV_DAT_Händelse_Datum_Posit foreign key (
                EV_DAT_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_DAT_Händelse_Datum_Posit primary key (
                EV_DAT_ID
            ),
            constraint uqEV_DAT_Händelse_Datum_Posit unique (
                EV_DAT_EV_ID,
                EV_DAT_Händelse_Datum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Annex table (of EV_DAT_Händelse_Datum_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Händelse_Datum_Annex (
            EV_DAT_ID number(10) not null,
            EV_DAT_PositedAt timestamp not null,
            EV_DAT_Positor number(3) not null,
            EV_DAT_Reliability number(5,2) not null,
            EV_DAT_Assertion char(1) generated always as (
                case
                    when EV_DAT_Reliability > 0 then '+'
                    when EV_DAT_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Händelse_Datum_Annex foreign key (
                EV_DAT_ID
            ) references attributes.EV_DAT_Händelse_Datum_Posit(EV_DAT_ID),
            constraint pkEV_DAT_Händelse_Datum_Annex primary key (
                EV_DAT_ID,
                EV_DAT_Positor,
                EV_DAT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_AUD_Händelse_Publik_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Händelse_Publik_Posit (
            EV_AUD_ID number(10) default attributes.EV_AUD_Händelse_Publik_Posit_ID_SEQ.nextval not null, 
            EV_AUD_EV_ID number(12,0) not null,
            EV_AUD_Händelse_Publik number(10) not null,
            constraint fkEV_AUD_Händelse_Publik_Posit foreign key (
                EV_AUD_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_AUD_Händelse_Publik_Posit primary key (
                EV_AUD_ID
            ),
            constraint uqEV_AUD_Händelse_Publik_Posit unique (
                EV_AUD_EV_ID,
                EV_AUD_Händelse_Publik
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Annex table (of EV_AUD_Händelse_Publik_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Händelse_Publik_Annex (
            EV_AUD_ID number(10) not null,
            EV_AUD_PositedAt timestamp not null,
            EV_AUD_Positor number(3) not null,
            EV_AUD_Reliability number(5,2) not null,
            EV_AUD_Assertion char(1) generated always as (
                case
                    when EV_AUD_Reliability > 0 then '+'
                    when EV_AUD_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Händelse_Publik_Annex foreign key (
                EV_AUD_ID
            ) references attributes.EV_AUD_Händelse_Publik_Posit(EV_AUD_ID),
            constraint pkEV_AUD_Händelse_Publik_Annex primary key (
                EV_AUD_ID,
                EV_AUD_Positor,
                EV_AUD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_REV_Händelse_Intäkt_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Händelse_Intäkt_Posit (
            EV_REV_ID number(10) default attributes.EV_REV_Händelse_Intäkt_Posit_ID_SEQ.nextval not null, 
            EV_REV_EV_ID number(12,0) not null,
            EV_REV_Händelse_Intäkt number(19,4) not null,
            constraint fkEV_REV_Händelse_Intäkt_Posit foreign key (
                EV_REV_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_REV_Händelse_Intäkt_Posit primary key (
                EV_REV_ID
            ),
            constraint uqEV_REV_Händelse_Intäkt_Posit unique (
                EV_REV_EV_ID,
                EV_REV_Händelse_Intäkt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Annex table (of EV_REV_Händelse_Intäkt_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Händelse_Intäkt_Annex (
            EV_REV_ID number(10) not null,
            EV_REV_PositedAt timestamp not null,
            EV_REV_Positor number(3) not null,
            EV_REV_Reliability number(5,2) not null,
            EV_REV_Assertion char(1) generated always as (
                case
                    when EV_REV_Reliability > 0 then '+'
                    when EV_REV_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Händelse_Intäkt_Annex foreign key (
                EV_REV_ID
            ) references attributes.EV_REV_Händelse_Intäkt_Posit(EV_REV_ID),
            constraint pkEV_REV_Händelse_Intäkt_Annex primary key (
                EV_REV_ID,
                EV_REV_Positor,
                EV_REV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_STA_Händelse_Status_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Händelse_Status_Posit (
            EV_STA_ID number(10) default attributes.EV_STA_Händelse_Status_Posit_ID_SEQ.nextval not null, 
            EV_STA_EV_ID number(12,0) not null,
            EV_STA_Händelse_Status nvarchar2(20) not null,
            EV_STA_ChangedAt timestamp not null,
            constraint fkEV_STA_Händelse_Status_Posit foreign key (
                EV_STA_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint pkEV_STA_Händelse_Status_Posit primary key (
                EV_STA_ID
            ),
            constraint uqEV_STA_Händelse_Status_Posit unique (
                EV_STA_EV_ID,
                EV_STA_ChangedAt,
                EV_STA_Händelse_Status
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Annex table (of EV_STA_Händelse_Status_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Händelse_Status_Annex (
            EV_STA_ID number(10) not null,
            EV_STA_PositedAt timestamp not null,
            EV_STA_Positor number(3) not null,
            EV_STA_Reliability number(5,2) not null,
            EV_STA_Assertion char(1) generated always as (
                case
                    when EV_STA_Reliability > 0 then '+'
                    when EV_STA_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_STA number(10) not null,
            constraint fkEV_STA_Händelse_Status_Annex foreign key (
                EV_STA_ID
            ) references attributes.EV_STA_Händelse_Status_Posit(EV_STA_ID),
            constraint pkEV_STA_Händelse_Status_Annex primary key (
                EV_STA_ID,
                EV_STA_Positor,
                EV_STA_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Händelse_Utnyttjande_Posit (
            EV_UTL_ID number(10) default attributes.EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ.nextval not null, 
            EV_UTL_EV_ID number(12,0) not null,
            EV_UTL_UTL_ID number(3) not null,
            constraint fk_A_EV_UTL_Händelse_Utnyttjande_Posit foreign key (
                EV_UTL_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint fk_K_EV_UTL_Händelse_Utnyttjande_Posit foreign key (
                EV_UTL_UTL_ID
            ) references knots.UTL_Utnyttjande(UTL_ID),
            constraint pkEV_UTL_Händelse_Utnyttjande_Posit primary key (
                EV_UTL_ID
            ),
            constraint uqEV_UTL_Händelse_Utnyttjande_Posit unique (
                EV_UTL_EV_ID,
                EV_UTL_UTL_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Annex table (of EV_UTL_Händelse_Utnyttjande_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Händelse_Utnyttjande_Annex (
            EV_UTL_ID number(10) not null,
            EV_UTL_PositedAt timestamp not null,
            EV_UTL_Positor number(3) not null,
            EV_UTL_Reliability number(5,2) not null,
            EV_UTL_Assertion char(1) generated always as (
                case
                    when EV_UTL_Reliability > 0 then '+'
                    when EV_UTL_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_UTL number(10) not null,
            constraint fkEV_UTL_Händelse_Utnyttjande_Annex foreign key (
                EV_UTL_ID
            ) references attributes.EV_UTL_Händelse_Utnyttjande_Posit(EV_UTL_ID),
            constraint pkEV_UTL_Händelse_Utnyttjande_Annex primary key (
                EV_UTL_ID,
                EV_UTL_Positor,
                EV_UTL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.EV_LVL_Händelse_Level_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Händelse_Level_Posit (
            EV_LVL_ID number(10) default attributes.EV_LVL_Händelse_Level_Posit_ID_SEQ.nextval not null, 
            EV_LVL_EV_ID number(12,0) not null,
            EV_LVL_PLV_ID number(3) not null,
            EV_LVL_ChangedAt date not null,
            constraint fk_A_EV_LVL_Händelse_Level_Posit foreign key (
                EV_LVL_EV_ID
            ) references nexuses.EV_Händelse(EV_ID),
            constraint fk_K_EV_LVL_Händelse_Level_Posit foreign key (
                EV_LVL_PLV_ID
            ) references knots.PLV_Yrkesnivå(PLV_ID),
            constraint pkEV_LVL_Händelse_Level_Posit primary key (
                EV_LVL_ID
            ),
            constraint uqEV_LVL_Händelse_Level_Posit unique (
                EV_LVL_EV_ID,
                EV_LVL_ChangedAt,
                EV_LVL_PLV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Annex table (of EV_LVL_Händelse_Level_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Händelse_Level_Annex (
            EV_LVL_ID number(10) not null,
            EV_LVL_PositedAt timestamp not null,
            EV_LVL_Positor number(3) not null,
            EV_LVL_Reliability number(5,2) not null,
            EV_LVL_Assertion char(1) generated always as (
                case
                    when EV_LVL_Reliability > 0 then '+'
                    when EV_LVL_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_LVL number(10) not null,
            constraint fkEV_LVL_Händelse_Level_Annex foreign key (
                EV_LVL_ID
            ) references attributes.EV_LVL_Händelse_Level_Posit(EV_LVL_ID),
            constraint pkEV_LVL_Händelse_Level_Annex primary key (
                EV_LVL_ID,
                EV_LVL_Positor,
                EV_LVL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_NAM_Scen_Namn_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Scen_Namn_Posit (
            ST_NAM_ID number(10) default attributes.ST_NAM_Scen_Namn_Posit_ID_SEQ.nextval not null, 
            ST_NAM_ST_ID number(10) not null,
            ST_NAM_Scen_Namn nvarchar2(42) not null,
            ST_NAM_ChangedAt timestamp not null,
            constraint fkST_NAM_Scen_Namn_Posit foreign key (
                ST_NAM_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint pkST_NAM_Scen_Namn_Posit primary key (
                ST_NAM_ID
            ),
            constraint uqST_NAM_Scen_Namn_Posit unique (
                ST_NAM_ST_ID,
                ST_NAM_ChangedAt,
                ST_NAM_Scen_Namn
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Annex table (of ST_NAM_Scen_Namn_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Scen_Namn_Annex (
            ST_NAM_ID number(10) not null,
            ST_NAM_PositedAt timestamp not null,
            ST_NAM_Positor number(3) not null,
            ST_NAM_Reliability number(5,2) not null,
            ST_NAM_Assertion char(1) generated always as (
                case
                    when ST_NAM_Reliability > 0 then '+'
                    when ST_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Scen_Namn_Annex foreign key (
                ST_NAM_ID
            ) references attributes.ST_NAM_Scen_Namn_Posit(ST_NAM_ID),
            constraint pkST_NAM_Scen_Namn_Annex primary key (
                ST_NAM_ID,
                ST_NAM_Positor,
                ST_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_LOC_Scen_Plats_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Scen_Plats_Posit (
            ST_LOC_ID number(10) default attributes.ST_LOC_Scen_Plats_Posit_ID_SEQ.nextval not null, 
            ST_LOC_ST_ID number(10) not null,
            ST_LOC_Scen_Plats varchar2(100) not null,
            ST_LOC_Checksum raw(16) generated always as (standard_hash(ST_LOC_Scen_Plats, 'MD5')) virtual,
            constraint fkST_LOC_Scen_Plats_Posit foreign key (
                ST_LOC_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint pkST_LOC_Scen_Plats_Posit primary key (
                ST_LOC_ID
            ),
            constraint uqST_LOC_Scen_Plats_Posit unique (
                ST_LOC_ST_ID,
                ST_LOC_Checksum
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Annex table (of ST_LOC_Scen_Plats_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Scen_Plats_Annex (
            ST_LOC_ID number(10) not null,
            ST_LOC_PositedAt timestamp not null,
            ST_LOC_Positor number(3) not null,
            ST_LOC_Reliability number(5,2) not null,
            ST_LOC_Assertion char(1) generated always as (
                case
                    when ST_LOC_Reliability > 0 then '+'
                    when ST_LOC_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Scen_Plats_Annex foreign key (
                ST_LOC_ID
            ) references attributes.ST_LOC_Scen_Plats_Posit(ST_LOC_ID),
            constraint pkST_LOC_Scen_Plats_Annex primary key (
                ST_LOC_ID,
                ST_LOC_Positor,
                ST_LOC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_AVG_Scen_Medel_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Scen_Medel_Posit (
            ST_AVG_ID number(10) default attributes.ST_AVG_Scen_Medel_Posit_ID_SEQ.nextval not null, 
            ST_AVG_ST_ID number(10) not null,
            ST_AVG_UTL_ID number(3) not null,
            ST_AVG_ChangedAt timestamp not null,
            constraint fk_A_ST_AVG_Scen_Medel_Posit foreign key (
                ST_AVG_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint fk_K_ST_AVG_Scen_Medel_Posit foreign key (
                ST_AVG_UTL_ID
            ) references knots.UTL_Utnyttjande(UTL_ID),
            constraint pkST_AVG_Scen_Medel_Posit primary key (
                ST_AVG_ID
            ),
            constraint uqST_AVG_Scen_Medel_Posit unique (
                ST_AVG_ST_ID,
                ST_AVG_ChangedAt,
                ST_AVG_UTL_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Annex table (of ST_AVG_Scen_Medel_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Scen_Medel_Annex (
            ST_AVG_ID number(10) not null,
            ST_AVG_PositedAt timestamp not null,
            ST_AVG_Positor number(3) not null,
            ST_AVG_Reliability number(5,2) not null,
            ST_AVG_Assertion char(1) generated always as (
                case
                    when ST_AVG_Reliability > 0 then '+'
                    when ST_AVG_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_AVG number(10) not null,
            constraint fkST_AVG_Scen_Medel_Annex foreign key (
                ST_AVG_ID
            ) references attributes.ST_AVG_Scen_Medel_Posit(ST_AVG_ID),
            constraint pkST_AVG_Scen_Medel_Annex primary key (
                ST_AVG_ID,
                ST_AVG_Positor,
                ST_AVG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.ST_MIN_Scen_Minimum_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Scen_Minimum_Posit (
            ST_MIN_ID number(10) default attributes.ST_MIN_Scen_Minimum_Posit_ID_SEQ.nextval not null, 
            ST_MIN_ST_ID number(10) not null,
            ST_MIN_UTL_ID number(3) not null,
            constraint fk_A_ST_MIN_Scen_Minimum_Posit foreign key (
                ST_MIN_ST_ID
            ) references anchors.ST_Scen(ST_ID),
            constraint fk_K_ST_MIN_Scen_Minimum_Posit foreign key (
                ST_MIN_UTL_ID
            ) references knots.UTL_Utnyttjande(UTL_ID),
            constraint pkST_MIN_Scen_Minimum_Posit primary key (
                ST_MIN_ID
            ),
            constraint uqST_MIN_Scen_Minimum_Posit unique (
                ST_MIN_ST_ID,
                ST_MIN_UTL_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Annex table (of ST_MIN_Scen_Minimum_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Scen_Minimum_Annex (
            ST_MIN_ID number(10) not null,
            ST_MIN_PositedAt timestamp not null,
            ST_MIN_Positor number(3) not null,
            ST_MIN_Reliability number(5,2) not null,
            ST_MIN_Assertion char(1) generated always as (
                case
                    when ST_MIN_Reliability > 0 then '+'
                    when ST_MIN_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_MIN number(10) not null,
            constraint fkST_MIN_Scen_Minimum_Annex foreign key (
                ST_MIN_ID
            ) references attributes.ST_MIN_Scen_Minimum_Posit(ST_MIN_ID),
            constraint pkST_MIN_Scen_Minimum_Annex primary key (
                ST_MIN_ID,
                ST_MIN_Positor,
                ST_MIN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.AC_NAM_Skådespelare_Namn_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Skådespelare_Namn_Posit (
            AC_NAM_ID number(10) default attributes.AC_NAM_Skådespelare_Namn_Posit_ID_SEQ.nextval not null, 
            AC_NAM_AC_ID number(5) not null,
            AC_NAM_Skådespelare_Namn nvarchar2(42) not null,
            AC_NAM_ChangedAt timestamp not null,
            constraint fkAC_NAM_Skådespelare_Namn_Posit foreign key (
                AC_NAM_AC_ID
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint pkAC_NAM_Skådespelare_Namn_Posit primary key (
                AC_NAM_ID
            ),
            constraint uqAC_NAM_Skådespelare_Namn_Posit unique (
                AC_NAM_AC_ID,
                AC_NAM_ChangedAt,
                AC_NAM_Skådespelare_Namn
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Annex table (of AC_NAM_Skådespelare_Namn_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Skådespelare_Namn_Annex (
            AC_NAM_ID number(10) not null,
            AC_NAM_PositedAt timestamp not null,
            AC_NAM_Positor number(3) not null,
            AC_NAM_Reliability number(5,2) not null,
            AC_NAM_Assertion char(1) generated always as (
                case
                    when AC_NAM_Reliability > 0 then '+'
                    when AC_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Skådespelare_Namn_Annex foreign key (
                AC_NAM_ID
            ) references attributes.AC_NAM_Skådespelare_Namn_Posit(AC_NAM_ID),
            constraint pkAC_NAM_Skådespelare_Namn_Annex primary key (
                AC_NAM_ID,
                AC_NAM_Positor,
                AC_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.AC_GEN_Skådespelare_Kön_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Skådespelare_Kön_Posit (
            AC_GEN_ID number(10) default attributes.AC_GEN_Skådespelare_Kön_Posit_ID_SEQ.nextval not null, 
            AC_GEN_AC_ID number(5) not null,
            AC_GEN_GEN_ID number(3) not null,
            constraint fk_A_AC_GEN_Skådespelare_Kön_Posit foreign key (
                AC_GEN_AC_ID
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint fk_K_AC_GEN_Skådespelare_Kön_Posit foreign key (
                AC_GEN_GEN_ID
            ) references knots.GEN_Kön(GEN_ID),
            constraint pkAC_GEN_Skådespelare_Kön_Posit primary key (
                AC_GEN_ID
            ),
            constraint uqAC_GEN_Skådespelare_Kön_Posit unique (
                AC_GEN_AC_ID,
                AC_GEN_GEN_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Annex table (of AC_GEN_Skådespelare_Kön_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Skådespelare_Kön_Annex (
            AC_GEN_ID number(10) not null,
            AC_GEN_PositedAt timestamp not null,
            AC_GEN_Positor number(3) not null,
            AC_GEN_Reliability number(5,2) not null,
            AC_GEN_Assertion char(1) generated always as (
                case
                    when AC_GEN_Reliability > 0 then '+'
                    when AC_GEN_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_GEN number(10) not null,
            constraint fkAC_GEN_Skådespelare_Kön_Annex foreign key (
                AC_GEN_ID
            ) references attributes.AC_GEN_Skådespelare_Kön_Posit(AC_GEN_ID),
            constraint pkAC_GEN_Skådespelare_Kön_Annex primary key (
                AC_GEN_ID,
                AC_GEN_Positor,
                AC_GEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit (
            AC_PLV_ID number(10) default attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ.nextval not null, 
            AC_PLV_AC_ID number(5) not null,
            AC_PLV_PLV_ID number(3) not null,
            AC_PLV_ChangedAt timestamp not null,
            constraint fk_A_AC_PLV_Skådespelare_Yrkesnivå_Posit foreign key (
                AC_PLV_AC_ID
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint fk_K_AC_PLV_Skådespelare_Yrkesnivå_Posit foreign key (
                AC_PLV_PLV_ID
            ) references knots.PLV_Yrkesnivå(PLV_ID),
            constraint pkAC_PLV_Skådespelare_Yrkesnivå_Posit primary key (
                AC_PLV_ID
            ),
            constraint uqAC_PLV_Skådespelare_Yrkesnivå_Posit unique (
                AC_PLV_AC_ID,
                AC_PLV_ChangedAt,
                AC_PLV_PLV_ID
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Annex table (of AC_PLV_Skådespelare_Yrkesnivå_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
            AC_PLV_ID number(10) not null,
            AC_PLV_PositedAt timestamp not null,
            AC_PLV_Positor number(3) not null,
            AC_PLV_Reliability number(5,2) not null,
            AC_PLV_Assertion char(1) generated always as (
                case
                    when AC_PLV_Reliability > 0 then '+'
                    when AC_PLV_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_PLV number(10) not null,
            constraint fkAC_PLV_Skådespelare_Yrkesnivå_Annex foreign key (
                AC_PLV_ID
            ) references attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit(AC_PLV_ID),
            constraint pkAC_PLV_Skådespelare_Yrkesnivå_Annex primary key (
                AC_PLV_ID,
                AC_PLV_Positor,
                AC_PLV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.PR_NAM_Föreställning_Namn_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Föreställning_Namn_Posit (
            PR_NAM_ID number(10) default attributes.PR_NAM_Föreställning_Namn_Posit_ID_SEQ.nextval not null, 
            PR_NAM_PR_ID number(19) not null,
            PR_NAM_Föreställning_Namn nvarchar2(42) not null,
            constraint fkPR_NAM_Föreställning_Namn_Posit foreign key (
                PR_NAM_PR_ID
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkPR_NAM_Föreställning_Namn_Posit primary key (
                PR_NAM_ID
            ),
            constraint uqPR_NAM_Föreställning_Namn_Posit unique (
                PR_NAM_PR_ID,
                PR_NAM_Föreställning_Namn
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Annex table (of PR_NAM_Föreställning_Namn_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Föreställning_Namn_Annex (
            PR_NAM_ID number(10) not null,
            PR_NAM_PositedAt timestamp not null,
            PR_NAM_Positor number(3) not null,
            PR_NAM_Reliability number(5,2) not null,
            PR_NAM_Assertion char(1) generated always as (
                case
                    when PR_NAM_Reliability > 0 then '+'
                    when PR_NAM_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Föreställning_Namn_Annex foreign key (
                PR_NAM_ID
            ) references attributes.PR_NAM_Föreställning_Namn_Posit(PR_NAM_ID),
            constraint pkPR_NAM_Föreställning_Namn_Annex primary key (
                PR_NAM_ID,
                PR_NAM_Positor,
                PR_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE attributes.PR_LEN_Föreställning_Längd_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Föreställning_Längd_Posit (
            PR_LEN_ID number(10) default attributes.PR_LEN_Föreställning_Längd_Posit_ID_SEQ.nextval not null, 
            PR_LEN_PR_ID number(19) not null,
            PR_LEN_Föreställning_Längd timestamp not null,
            PR_LEN_ChangedAt date not null,
            constraint fkPR_LEN_Föreställning_Längd_Posit foreign key (
                PR_LEN_PR_ID
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkPR_LEN_Föreställning_Längd_Posit primary key (
                PR_LEN_ID
            ),
            constraint uqPR_LEN_Föreställning_Längd_Posit unique (
                PR_LEN_PR_ID,
                PR_LEN_ChangedAt,
                PR_LEN_Föreställning_Längd
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Annex table (of PR_LEN_Föreställning_Längd_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Föreställning_Längd_Annex (
            PR_LEN_ID number(10) not null,
            PR_LEN_PositedAt timestamp not null,
            PR_LEN_Positor number(3) not null,
            PR_LEN_Reliability number(5,2) not null,
            PR_LEN_Assertion char(1) generated always as (
                case
                    when PR_LEN_Reliability > 0 then '+'
                    when PR_LEN_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Föreställning_Längd_Annex foreign key (
                PR_LEN_ID
            ) references attributes.PR_LEN_Föreställning_Längd_Posit(PR_LEN_ID),
            constraint pkPR_LEN_Föreställning_Längd_Annex primary key (
                PR_LEN_ID,
                PR_LEN_Positor,
                PR_LEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes.EV_DAT_Händelse_Datum AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Händelse_Datum,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion
FROM
    attributes.EV_DAT_Händelse_Datum_Posit p
JOIN
    attributes.EV_DAT_Händelse_Datum_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
;
CREATE OR REPLACE VIEW attributes.EV_AUD_Händelse_Publik AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Händelse_Publik,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion
FROM
    attributes.EV_AUD_Händelse_Publik_Posit p
JOIN
    attributes.EV_AUD_Händelse_Publik_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
;
CREATE OR REPLACE VIEW attributes.EV_REV_Händelse_Intäkt AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    p.EV_REV_EV_ID,
    p.EV_REV_Händelse_Intäkt,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion
FROM
    attributes.EV_REV_Händelse_Intäkt_Posit p
JOIN
    attributes.EV_REV_Händelse_Intäkt_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
;
CREATE OR REPLACE VIEW attributes.EV_STA_Händelse_Status AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    p.EV_STA_EV_ID,
    p.EV_STA_Händelse_Status,
    p.EV_STA_ChangedAt,
    a.EV_STA_PositedAt,
    a.EV_STA_Positor,
    a.EV_STA_Reliability,
    a.EV_STA_Assertion
FROM
    attributes.EV_STA_Händelse_Status_Posit p
JOIN
    attributes.EV_STA_Händelse_Status_Annex a
ON
    a.EV_STA_ID = p.EV_STA_ID
;
CREATE OR REPLACE VIEW attributes.EV_UTL_Händelse_Utnyttjande AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Positor,
    a.EV_UTL_Reliability,
    a.EV_UTL_Assertion
FROM
    attributes.EV_UTL_Händelse_Utnyttjande_Posit p
JOIN
    attributes.EV_UTL_Händelse_Utnyttjande_Annex a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
;
CREATE OR REPLACE VIEW attributes.EV_LVL_Händelse_Level AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID,
    p.EV_LVL_ChangedAt,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Positor,
    a.EV_LVL_Reliability,
    a.EV_LVL_Assertion
FROM
    attributes.EV_LVL_Händelse_Level_Posit p
JOIN
    attributes.EV_LVL_Händelse_Level_Annex a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
;
CREATE OR REPLACE VIEW attributes.ST_NAM_Scen_Namn AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Scen_Namn,
    p.ST_NAM_ChangedAt,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion
FROM
    attributes.ST_NAM_Scen_Namn_Posit p
JOIN
    attributes.ST_NAM_Scen_Namn_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
;
CREATE OR REPLACE VIEW attributes.ST_LOC_Scen_Plats AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Scen_Plats,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion
FROM
    attributes.ST_LOC_Scen_Plats_Posit p
JOIN
    attributes.ST_LOC_Scen_Plats_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
;
CREATE OR REPLACE VIEW attributes.ST_AVG_Scen_Medel AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID,
    p.ST_AVG_ChangedAt,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion
FROM
    attributes.ST_AVG_Scen_Medel_Posit p
JOIN
    attributes.ST_AVG_Scen_Medel_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
;
CREATE OR REPLACE VIEW attributes.ST_MIN_Scen_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion
FROM
    attributes.ST_MIN_Scen_Minimum_Posit p
JOIN
    attributes.ST_MIN_Scen_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
;
CREATE OR REPLACE VIEW attributes.AC_NAM_Skådespelare_Namn AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Skådespelare_Namn,
    p.AC_NAM_ChangedAt,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion
FROM
    attributes.AC_NAM_Skådespelare_Namn_Posit p
JOIN
    attributes.AC_NAM_Skådespelare_Namn_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
;
CREATE OR REPLACE VIEW attributes.AC_GEN_Skådespelare_Kön AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion
FROM
    attributes.AC_GEN_Skådespelare_Kön_Posit p
JOIN
    attributes.AC_GEN_Skådespelare_Kön_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
;
CREATE OR REPLACE VIEW attributes.AC_PLV_Skådespelare_Yrkesnivå AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID,
    p.AC_PLV_ChangedAt,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion
FROM
    attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
JOIN
    attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
;
CREATE OR REPLACE VIEW attributes.PR_NAM_Föreställning_Namn AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Föreställning_Namn,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion
FROM
    attributes.PR_NAM_Föreställning_Namn_Posit p
JOIN
    attributes.PR_NAM_Föreställning_Namn_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
;
CREATE OR REPLACE VIEW attributes.PR_LEN_Föreställning_Längd AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Föreställning_Längd,
    p.PR_LEN_ChangedAt,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion
FROM
    attributes.PR_LEN_Föreställning_Längd_Posit p
JOIN
    attributes.PR_LEN_Föreställning_Längd_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These SQL table macros rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the
-- union of the two will produce all rows in a posit table.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(CAST(NULL AS number), TIMESTAMP '2020-01-01 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The assembled rewinder and forwarder pick, for each posit and positor, the annex row that was last posited
-- at or before the positing time (the macros do not call each other, they do what the others do in their own query).
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Händelse_Datum_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Positor,
            EV_DAT_Reliability,
            EV_DAT_Assertion
        FROM
            attributes.EV_DAT_Händelse_Datum_Annex
        WHERE
            EV_DAT_PositedAt <= positingTimepoint
    ]';
END rEV_DAT_Händelse_Datum_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Händelse_Datum (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Positor,
            EV_DAT_Reliability,
            EV_DAT_Assertion,
            EV_DAT_EV_ID,
            EV_DAT_Händelse_Datum
        FROM (
            SELECT
                a.Metadata_EV_DAT,
                p.EV_DAT_ID,
                a.EV_DAT_PositedAt,
                a.EV_DAT_Positor,
                a.EV_DAT_Reliability,
                a.EV_DAT_Assertion,
                p.EV_DAT_EV_ID,
                p.EV_DAT_Händelse_Datum,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_DAT_ID,
                        a.EV_DAT_Positor
                    ORDER BY
                        a.EV_DAT_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_DAT_Händelse_Datum_Posit p
            JOIN
                attributes.EV_DAT_Händelse_Datum_Annex a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            AND
                a.EV_DAT_Positor = COALESCE(positor, a.EV_DAT_Positor)
            WHERE
                a.EV_DAT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_DAT_Händelse_Datum;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Händelse_Publik_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Positor,
            EV_AUD_Reliability,
            EV_AUD_Assertion
        FROM
            attributes.EV_AUD_Händelse_Publik_Annex
        WHERE
            EV_AUD_PositedAt <= positingTimepoint
    ]';
END rEV_AUD_Händelse_Publik_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Händelse_Publik (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Positor,
            EV_AUD_Reliability,
            EV_AUD_Assertion,
            EV_AUD_EV_ID,
            EV_AUD_Händelse_Publik
        FROM (
            SELECT
                a.Metadata_EV_AUD,
                p.EV_AUD_ID,
                a.EV_AUD_PositedAt,
                a.EV_AUD_Positor,
                a.EV_AUD_Reliability,
                a.EV_AUD_Assertion,
                p.EV_AUD_EV_ID,
                p.EV_AUD_Händelse_Publik,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_AUD_ID,
                        a.EV_AUD_Positor
                    ORDER BY
                        a.EV_AUD_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_AUD_Händelse_Publik_Posit p
            JOIN
                attributes.EV_AUD_Händelse_Publik_Annex a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            AND
                a.EV_AUD_Positor = COALESCE(positor, a.EV_AUD_Positor)
            WHERE
                a.EV_AUD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_AUD_Händelse_Publik;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Händelse_Intäkt_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Positor,
            EV_REV_Reliability,
            EV_REV_Assertion
        FROM
            attributes.EV_REV_Händelse_Intäkt_Annex
        WHERE
            EV_REV_PositedAt <= positingTimepoint
    ]';
END rEV_REV_Händelse_Intäkt_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Händelse_Intäkt (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Positor,
            EV_REV_Reliability,
            EV_REV_Assertion,
            EV_REV_EV_ID,
            EV_REV_Händelse_Intäkt
        FROM (
            SELECT
                a.Metadata_EV_REV,
                p.EV_REV_ID,
                a.EV_REV_PositedAt,
                a.EV_REV_Positor,
                a.EV_REV_Reliability,
                a.EV_REV_Assertion,
                p.EV_REV_EV_ID,
                p.EV_REV_Händelse_Intäkt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_REV_ID,
                        a.EV_REV_Positor
                    ORDER BY
                        a.EV_REV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_REV_Händelse_Intäkt_Posit p
            JOIN
                attributes.EV_REV_Händelse_Intäkt_Annex a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            AND
                a.EV_REV_Positor = COALESCE(positor, a.EV_REV_Positor)
            WHERE
                a.EV_REV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_REV_Händelse_Intäkt;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Händelse_Status_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_STA_ID,
            EV_STA_EV_ID,
            EV_STA_Händelse_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Händelse_Status_Posit
        WHERE
            EV_STA_ChangedAt <= changingTimepoint
    ]';
END rEV_STA_Händelse_Status_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Händelse_Status_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_STA_ID,
            EV_STA_EV_ID,
            EV_STA_Händelse_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Händelse_Status_Posit
        WHERE
            EV_STA_ChangedAt > changingTimepoint
    ]';
END fEV_STA_Händelse_Status_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Händelse_Status_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Positor,
            EV_STA_Reliability,
            EV_STA_Assertion
        FROM
            attributes.EV_STA_Händelse_Status_Annex
        WHERE
            EV_STA_PositedAt <= positingTimepoint
    ]';
END rEV_STA_Händelse_Status_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Händelse_Status (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Positor,
            EV_STA_Reliability,
            EV_STA_Assertion,
            EV_STA_EV_ID,
            EV_STA_Händelse_Status,
            EV_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_STA,
                p.EV_STA_ID,
                a.EV_STA_PositedAt,
                a.EV_STA_Positor,
                a.EV_STA_Reliability,
                a.EV_STA_Assertion,
                p.EV_STA_EV_ID,
                p.EV_STA_Händelse_Status,
                p.EV_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_STA_ID,
                        a.EV_STA_Positor
                    ORDER BY
                        a.EV_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_STA_Händelse_Status_Posit p
            JOIN
                attributes.EV_STA_Händelse_Status_Annex a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Positor = COALESCE(positor, a.EV_STA_Positor)
            WHERE
                p.EV_STA_ChangedAt <= changingTimepoint
            AND
                a.EV_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_STA_Händelse_Status;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Händelse_Status (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Positor,
            EV_STA_Reliability,
            EV_STA_Assertion,
            EV_STA_EV_ID,
            EV_STA_Händelse_Status,
            EV_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_STA,
                p.EV_STA_ID,
                a.EV_STA_PositedAt,
                a.EV_STA_Positor,
                a.EV_STA_Reliability,
                a.EV_STA_Assertion,
                p.EV_STA_EV_ID,
                p.EV_STA_Händelse_Status,
                p.EV_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_STA_ID,
                        a.EV_STA_Positor
                    ORDER BY
                        a.EV_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_STA_Händelse_Status_Posit p
            JOIN
                attributes.EV_STA_Händelse_Status_Annex a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Positor = COALESCE(positor, a.EV_STA_Positor)
            WHERE
                p.EV_STA_ChangedAt > changingTimepoint
            AND
                a.EV_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_STA_Händelse_Status;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Händelse_Utnyttjande_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Positor,
            EV_UTL_Reliability,
            EV_UTL_Assertion
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Annex
        WHERE
            EV_UTL_PositedAt <= positingTimepoint
    ]';
END rEV_UTL_Händelse_Utnyttjande_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Händelse_Utnyttjande (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Positor,
            EV_UTL_Reliability,
            EV_UTL_Assertion,
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        FROM (
            SELECT
                a.Metadata_EV_UTL,
                p.EV_UTL_ID,
                a.EV_UTL_PositedAt,
                a.EV_UTL_Positor,
                a.EV_UTL_Reliability,
                a.EV_UTL_Assertion,
                p.EV_UTL_EV_ID,
                p.EV_UTL_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_UTL_ID,
                        a.EV_UTL_Positor
                    ORDER BY
                        a.EV_UTL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_UTL_Händelse_Utnyttjande_Posit p
            JOIN
                attributes.EV_UTL_Händelse_Utnyttjande_Annex a
            ON
                a.EV_UTL_ID = p.EV_UTL_ID
            AND
                a.EV_UTL_Positor = COALESCE(positor, a.EV_UTL_Positor)
            WHERE
                a.EV_UTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_UTL_Händelse_Utnyttjande;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Händelse_Level_Posit (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_LVL_ID,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Händelse_Level_Posit
        WHERE
            EV_LVL_ChangedAt <= changingTimepoint
    ]';
END rEV_LVL_Händelse_Level_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Händelse_Level_Posit (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_LVL_ID,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Händelse_Level_Posit
        WHERE
            EV_LVL_ChangedAt > changingTimepoint
    ]';
END fEV_LVL_Händelse_Level_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Händelse_Level_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Positor,
            EV_LVL_Reliability,
            EV_LVL_Assertion
        FROM
            attributes.EV_LVL_Händelse_Level_Annex
        WHERE
            EV_LVL_PositedAt <= positingTimepoint
    ]';
END rEV_LVL_Händelse_Level_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Händelse_Level (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Positor,
            EV_LVL_Reliability,
            EV_LVL_Assertion,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_LVL,
                p.EV_LVL_ID,
                a.EV_LVL_PositedAt,
                a.EV_LVL_Positor,
                a.EV_LVL_Reliability,
                a.EV_LVL_Assertion,
                p.EV_LVL_EV_ID,
                p.EV_LVL_PLV_ID,
                p.EV_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_LVL_ID,
                        a.EV_LVL_Positor
                    ORDER BY
                        a.EV_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_LVL_Händelse_Level_Posit p
            JOIN
                attributes.EV_LVL_Händelse_Level_Annex a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Positor = COALESCE(positor, a.EV_LVL_Positor)
            WHERE
                p.EV_LVL_ChangedAt <= changingTimepoint
            AND
                a.EV_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_LVL_Händelse_Level;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Händelse_Level (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Positor,
            EV_LVL_Reliability,
            EV_LVL_Assertion,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_LVL,
                p.EV_LVL_ID,
                a.EV_LVL_PositedAt,
                a.EV_LVL_Positor,
                a.EV_LVL_Reliability,
                a.EV_LVL_Assertion,
                p.EV_LVL_EV_ID,
                p.EV_LVL_PLV_ID,
                p.EV_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_LVL_ID,
                        a.EV_LVL_Positor
                    ORDER BY
                        a.EV_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_LVL_Händelse_Level_Posit p
            JOIN
                attributes.EV_LVL_Händelse_Level_Annex a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Positor = COALESCE(positor, a.EV_LVL_Positor)
            WHERE
                p.EV_LVL_ChangedAt > changingTimepoint
            AND
                a.EV_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_LVL_Händelse_Level;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Scen_Namn_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_ST_ID,
            ST_NAM_Scen_Namn,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Scen_Namn_Posit
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Scen_Namn_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Scen_Namn_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_ST_ID,
            ST_NAM_Scen_Namn,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Scen_Namn_Posit
        WHERE
            ST_NAM_ChangedAt > changingTimepoint
    ]';
END fST_NAM_Scen_Namn_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Scen_Namn_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability,
            ST_NAM_Assertion
        FROM
            attributes.ST_NAM_Scen_Namn_Annex
        WHERE
            ST_NAM_PositedAt <= positingTimepoint
    ]';
END rST_NAM_Scen_Namn_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Scen_Namn (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability,
            ST_NAM_Assertion,
            ST_NAM_ST_ID,
            ST_NAM_Scen_Namn,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Positor,
                a.ST_NAM_Reliability,
                a.ST_NAM_Assertion,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Scen_Namn,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Positor
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_NAM_Scen_Namn_Posit p
            JOIN
                attributes.ST_NAM_Scen_Namn_Annex a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Positor = COALESCE(positor, a.ST_NAM_Positor)
            WHERE
                p.ST_NAM_ChangedAt <= changingTimepoint
            AND
                a.ST_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_NAM_Scen_Namn;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Scen_Namn (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability,
            ST_NAM_Assertion,
            ST_NAM_ST_ID,
            ST_NAM_Scen_Namn,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Positor,
                a.ST_NAM_Reliability,
                a.ST_NAM_Assertion,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Scen_Namn,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Positor
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_NAM_Scen_Namn_Posit p
            JOIN
                attributes.ST_NAM_Scen_Namn_Annex a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Positor = COALESCE(positor, a.ST_NAM_Positor)
            WHERE
                p.ST_NAM_ChangedAt > changingTimepoint
            AND
                a.ST_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_NAM_Scen_Namn;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Scen_Plats_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Positor,
            ST_LOC_Reliability,
            ST_LOC_Assertion
        FROM
            attributes.ST_LOC_Scen_Plats_Annex
        WHERE
            ST_LOC_PositedAt <= positingTimepoint
    ]';
END rST_LOC_Scen_Plats_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Scen_Plats (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Positor,
            ST_LOC_Reliability,
            ST_LOC_Assertion,
            ST_LOC_ST_ID,
            ST_LOC_Checksum,
            ST_LOC_Scen_Plats
        FROM (
            SELECT
                a.Metadata_ST_LOC,
                p.ST_LOC_ID,
                a.ST_LOC_PositedAt,
                a.ST_LOC_Positor,
                a.ST_LOC_Reliability,
                a.ST_LOC_Assertion,
                p.ST_LOC_ST_ID,
                p.ST_LOC_Checksum,
                p.ST_LOC_Scen_Plats,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_LOC_ID,
                        a.ST_LOC_Positor
                    ORDER BY
                        a.ST_LOC_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_LOC_Scen_Plats_Posit p
            JOIN
                attributes.ST_LOC_Scen_Plats_Annex a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            AND
                a.ST_LOC_Positor = COALESCE(positor, a.ST_LOC_Positor)
            WHERE
                a.ST_LOC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_LOC_Scen_Plats;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Scen_Medel_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Scen_Medel_Posit
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Scen_Medel_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Scen_Medel_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Scen_Medel_Posit
        WHERE
            ST_AVG_ChangedAt > changingTimepoint
    ]';
END fST_AVG_Scen_Medel_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Scen_Medel_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability,
            ST_AVG_Assertion
        FROM
            attributes.ST_AVG_Scen_Medel_Annex
        WHERE
            ST_AVG_PositedAt <= positingTimepoint
    ]';
END rST_AVG_Scen_Medel_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Scen_Medel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability,
            ST_AVG_Assertion,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Positor,
                a.ST_AVG_Reliability,
                a.ST_AVG_Assertion,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Positor
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_AVG_Scen_Medel_Posit p
            JOIN
                attributes.ST_AVG_Scen_Medel_Annex a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Positor = COALESCE(positor, a.ST_AVG_Positor)
            WHERE
                p.ST_AVG_ChangedAt <= changingTimepoint
            AND
                a.ST_AVG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_AVG_Scen_Medel;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Scen_Medel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability,
            ST_AVG_Assertion,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Positor,
                a.ST_AVG_Reliability,
                a.ST_AVG_Assertion,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Positor
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_AVG_Scen_Medel_Posit p
            JOIN
                attributes.ST_AVG_Scen_Medel_Annex a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Positor = COALESCE(positor, a.ST_AVG_Positor)
            WHERE
                p.ST_AVG_ChangedAt > changingTimepoint
            AND
                a.ST_AVG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_AVG_Scen_Medel;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Scen_Minimum_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Positor,
            ST_MIN_Reliability,
            ST_MIN_Assertion
        FROM
            attributes.ST_MIN_Scen_Minimum_Annex
        WHERE
            ST_MIN_PositedAt <= positingTimepoint
    ]';
END rST_MIN_Scen_Minimum_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Scen_Minimum (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Positor,
            ST_MIN_Reliability,
            ST_MIN_Assertion,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        FROM (
            SELECT
                a.Metadata_ST_MIN,
                p.ST_MIN_ID,
                a.ST_MIN_PositedAt,
                a.ST_MIN_Positor,
                a.ST_MIN_Reliability,
                a.ST_MIN_Assertion,
                p.ST_MIN_ST_ID,
                p.ST_MIN_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_MIN_ID,
                        a.ST_MIN_Positor
                    ORDER BY
                        a.ST_MIN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_MIN_Scen_Minimum_Posit p
            JOIN
                attributes.ST_MIN_Scen_Minimum_Annex a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            AND
                a.ST_MIN_Positor = COALESCE(positor, a.ST_MIN_Positor)
            WHERE
                a.ST_MIN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_MIN_Scen_Minimum;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Skådespelare_Namn_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_AC_ID,
            AC_NAM_Skådespelare_Namn,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Skådespelare_Namn_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Skådespelare_Namn_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_AC_ID,
            AC_NAM_Skådespelare_Namn,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit
        WHERE
            AC_NAM_ChangedAt > changingTimepoint
    ]';
END fAC_NAM_Skådespelare_Namn_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Skådespelare_Namn_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability,
            AC_NAM_Assertion
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Annex
        WHERE
            AC_NAM_PositedAt <= positingTimepoint
    ]';
END rAC_NAM_Skådespelare_Namn_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Skådespelare_Namn (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability,
            AC_NAM_Assertion,
            AC_NAM_AC_ID,
            AC_NAM_Skådespelare_Namn,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Positor,
                a.AC_NAM_Reliability,
                a.AC_NAM_Assertion,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Skådespelare_Namn,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Positor
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_NAM_Skådespelare_Namn_Posit p
            JOIN
                attributes.AC_NAM_Skådespelare_Namn_Annex a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Positor = COALESCE(positor, a.AC_NAM_Positor)
            WHERE
                p.AC_NAM_ChangedAt <= changingTimepoint
            AND
                a.AC_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_NAM_Skådespelare_Namn;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Skådespelare_Namn (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability,
            AC_NAM_Assertion,
            AC_NAM_AC_ID,
            AC_NAM_Skådespelare_Namn,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Positor,
                a.AC_NAM_Reliability,
                a.AC_NAM_Assertion,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Skådespelare_Namn,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Positor
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_NAM_Skådespelare_Namn_Posit p
            JOIN
                attributes.AC_NAM_Skådespelare_Namn_Annex a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Positor = COALESCE(positor, a.AC_NAM_Positor)
            WHERE
                p.AC_NAM_ChangedAt > changingTimepoint
            AND
                a.AC_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_NAM_Skådespelare_Namn;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Skådespelare_Kön_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Positor,
            AC_GEN_Reliability,
            AC_GEN_Assertion
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Annex
        WHERE
            AC_GEN_PositedAt <= positingTimepoint
    ]';
END rAC_GEN_Skådespelare_Kön_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Skådespelare_Kön (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Positor,
            AC_GEN_Reliability,
            AC_GEN_Assertion,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        FROM (
            SELECT
                a.Metadata_AC_GEN,
                p.AC_GEN_ID,
                a.AC_GEN_PositedAt,
                a.AC_GEN_Positor,
                a.AC_GEN_Reliability,
                a.AC_GEN_Assertion,
                p.AC_GEN_AC_ID,
                p.AC_GEN_GEN_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_GEN_ID,
                        a.AC_GEN_Positor
                    ORDER BY
                        a.AC_GEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_GEN_Skådespelare_Kön_Posit p
            JOIN
                attributes.AC_GEN_Skådespelare_Kön_Annex a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            AND
                a.AC_GEN_Positor = COALESCE(positor, a.AC_GEN_Positor)
            WHERE
                a.AC_GEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_GEN_Skådespelare_Kön;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Skådespelare_Yrkesnivå_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Skådespelare_Yrkesnivå_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Skådespelare_Yrkesnivå_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit
        WHERE
            AC_PLV_ChangedAt > changingTimepoint
    ]';
END fAC_PLV_Skådespelare_Yrkesnivå_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Skådespelare_Yrkesnivå_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability,
            AC_PLV_Assertion
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex
        WHERE
            AC_PLV_PositedAt <= positingTimepoint
    ]';
END rAC_PLV_Skådespelare_Yrkesnivå_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Skådespelare_Yrkesnivå (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability,
            AC_PLV_Assertion,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Positor,
                a.AC_PLV_Reliability,
                a.AC_PLV_Assertion,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Positor
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
            JOIN
                attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Positor = COALESCE(positor, a.AC_PLV_Positor)
            WHERE
                p.AC_PLV_ChangedAt <= changingTimepoint
            AND
                a.AC_PLV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_PLV_Skådespelare_Yrkesnivå;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Skådespelare_Yrkesnivå (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability,
            AC_PLV_Assertion,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Positor,
                a.AC_PLV_Reliability,
                a.AC_PLV_Assertion,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Positor
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
            JOIN
                attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Positor = COALESCE(positor, a.AC_PLV_Positor)
            WHERE
                p.AC_PLV_ChangedAt > changingTimepoint
            AND
                a.AC_PLV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_PLV_Skådespelare_Yrkesnivå;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Föreställning_Namn_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Positor,
            PR_NAM_Reliability,
            PR_NAM_Assertion
        FROM
            attributes.PR_NAM_Föreställning_Namn_Annex
        WHERE
            PR_NAM_PositedAt <= positingTimepoint
    ]';
END rPR_NAM_Föreställning_Namn_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Föreställning_Namn (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Positor,
            PR_NAM_Reliability,
            PR_NAM_Assertion,
            PR_NAM_PR_ID,
            PR_NAM_Föreställning_Namn
        FROM (
            SELECT
                a.Metadata_PR_NAM,
                p.PR_NAM_ID,
                a.PR_NAM_PositedAt,
                a.PR_NAM_Positor,
                a.PR_NAM_Reliability,
                a.PR_NAM_Assertion,
                p.PR_NAM_PR_ID,
                p.PR_NAM_Föreställning_Namn,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_NAM_ID,
                        a.PR_NAM_Positor
                    ORDER BY
                        a.PR_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_NAM_Föreställning_Namn_Posit p
            JOIN
                attributes.PR_NAM_Föreställning_Namn_Annex a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            AND
                a.PR_NAM_Positor = COALESCE(positor, a.PR_NAM_Positor)
            WHERE
                a.PR_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_NAM_Föreställning_Namn;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Föreställning_Längd_Posit (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PR_ID,
            PR_LEN_Föreställning_Längd,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Föreställning_Längd_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Föreställning_Längd_Posit (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PR_ID,
            PR_LEN_Föreställning_Längd,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit
        WHERE
            PR_LEN_ChangedAt > changingTimepoint
    ]';
END fPR_LEN_Föreställning_Längd_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Föreställning_Längd_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability,
            PR_LEN_Assertion
        FROM
            attributes.PR_LEN_Föreställning_Längd_Annex
        WHERE
            PR_LEN_PositedAt <= positingTimepoint
    ]';
END rPR_LEN_Föreställning_Längd_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Föreställning_Längd (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability,
            PR_LEN_Assertion,
            PR_LEN_PR_ID,
            PR_LEN_Föreställning_Längd,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Positor,
                a.PR_LEN_Reliability,
                a.PR_LEN_Assertion,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Föreställning_Längd,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Positor
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_LEN_Föreställning_Längd_Posit p
            JOIN
                attributes.PR_LEN_Föreställning_Längd_Annex a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Positor = COALESCE(positor, a.PR_LEN_Positor)
            WHERE
                p.PR_LEN_ChangedAt <= changingTimepoint
            AND
                a.PR_LEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_LEN_Föreställning_Längd;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Föreställning_Längd (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability,
            PR_LEN_Assertion,
            PR_LEN_PR_ID,
            PR_LEN_Föreställning_Längd,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Positor,
                a.PR_LEN_Reliability,
                a.PR_LEN_Assertion,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Föreställning_Längd,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Positor
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_LEN_Föreställning_Längd_Posit p
            JOIN
                attributes.PR_LEN_Föreställning_Längd_Annex a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Positor = COALESCE(positor, a.PR_LEN_Positor)
            WHERE
                p.PR_LEN_ChangedAt > changingTimepoint
            AND
                a.PR_LEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_LEN_Föreställning_Längd;
/
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tST_Scen (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
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
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Positor,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Assertion,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Positor,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Assertion,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Positor,
            "AVG".ST_AVG_Reliability,
            "AVG".ST_AVG_Assertion,
            "AVG".ST_AVG_UTL_Utnyttjande,
            "AVG".ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Positor,
            "MIN".ST_MIN_Reliability,
            "MIN".ST_MIN_Assertion,
            "MIN".ST_MIN_UTL_Utnyttjande,
            "MIN".ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Scen "ST"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_NAM_Positor, x.ST_NAM_ST_ID
                        ORDER BY
                            x.ST_NAM_ChangedAt DESC,
                            x.ST_NAM_PositedAt DESC,
                            x.ST_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_NAM_Assertion <> '?' THEN r.ST_NAM_ChangedAt END) OVER (
                            PARTITION BY r.ST_NAM_Positor, r.ST_NAM_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Positor,
                            an.ST_NAM_Reliability,
                            an.ST_NAM_Assertion,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Scen_Namn,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Positor
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Scen_Namn_Posit po
                        JOIN
                            attributes.ST_NAM_Scen_Namn_Annex an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_NAM_Assertion = COALESCE(assertion, x.ST_NAM_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.ST_NAM_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_LOC_Positor, x.ST_LOC_ST_ID
                        ORDER BY
                            x.ST_LOC_PositedAt DESC,
                            x.ST_LOC_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Positor,
                            an.ST_LOC_Reliability,
                            an.ST_LOC_Assertion,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Scen_Plats,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID, an.ST_LOC_Positor
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_LOC_Scen_Plats_Posit po
                        JOIN
                            attributes.ST_LOC_Scen_Plats_Annex an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_LOC_Assertion = COALESCE(assertion, x.ST_LOC_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_AVG_Metadata_UTL,
                k.UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_AVG_Positor, x.ST_AVG_ST_ID
                        ORDER BY
                            x.ST_AVG_ChangedAt DESC,
                            x.ST_AVG_PositedAt DESC,
                            x.ST_AVG_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_AVG_Assertion <> '?' THEN r.ST_AVG_ChangedAt END) OVER (
                            PARTITION BY r.ST_AVG_Positor, r.ST_AVG_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Positor,
                            an.ST_AVG_Reliability,
                            an.ST_AVG_Assertion,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Positor
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Scen_Medel_Posit po
                        JOIN
                            attributes.ST_AVG_Scen_Medel_Annex an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_AVG_Assertion = COALESCE(assertion, x.ST_AVG_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.ST_AVG_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.UTL_Utnyttjande k
            ON
                k.UTL_ID = y.ST_AVG_UTL_ID
            WHERE
                y.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_MIN_Metadata_UTL,
                k.UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_MIN_Positor, x.ST_MIN_ST_ID
                        ORDER BY
                            x.ST_MIN_PositedAt DESC,
                            x.ST_MIN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Positor,
                            an.ST_MIN_Reliability,
                            an.ST_MIN_Assertion,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID, an.ST_MIN_Positor
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_MIN_Scen_Minimum_Posit po
                        JOIN
                            attributes.ST_MIN_Scen_Minimum_Annex an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_MIN_Assertion = COALESCE(assertion, x.ST_MIN_Assertion)
            ) y
            LEFT JOIN
                knots.UTL_Utnyttjande k
            ON
                k.UTL_ID = y.ST_MIN_UTL_ID
            WHERE
                y.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tST_Scen;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Scen (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Positor,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Assertion,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Positor,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Assertion,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Positor,
            "AVG".ST_AVG_Reliability,
            "AVG".ST_AVG_Assertion,
            "AVG".ST_AVG_UTL_Utnyttjande,
            "AVG".ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Positor,
            "MIN".ST_MIN_Reliability,
            "MIN".ST_MIN_Assertion,
            "MIN".ST_MIN_UTL_Utnyttjande,
            "MIN".ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            anchors.ST_Scen "ST"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_NAM_Positor, x.ST_NAM_ST_ID
                        ORDER BY
                            x.ST_NAM_ChangedAt DESC,
                            x.ST_NAM_PositedAt DESC,
                            x.ST_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_NAM_Assertion <> '?' THEN r.ST_NAM_ChangedAt END) OVER (
                            PARTITION BY r.ST_NAM_Positor, r.ST_NAM_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Positor,
                            an.ST_NAM_Reliability,
                            an.ST_NAM_Assertion,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Scen_Namn,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Positor
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Scen_Namn_Posit po
                        JOIN
                            attributes.ST_NAM_Scen_Namn_Annex an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                        WHERE
                            po.ST_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_NAM_Assertion = '+'
                AND
                    x.ST_NAM_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_LOC_Positor, x.ST_LOC_ST_ID
                        ORDER BY
                            x.ST_LOC_PositedAt DESC,
                            x.ST_LOC_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_LOC,
                            po.ST_LOC_ID,
                            an.ST_LOC_PositedAt,
                            an.ST_LOC_Positor,
                            an.ST_LOC_Reliability,
                            an.ST_LOC_Assertion,
                            po.ST_LOC_ST_ID,
                            po.ST_LOC_Checksum,
                            po.ST_LOC_Scen_Plats,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_LOC_ID, an.ST_LOC_Positor
                                ORDER BY an.ST_LOC_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_LOC_Scen_Plats_Posit po
                        JOIN
                            attributes.ST_LOC_Scen_Plats_Annex an
                        ON
                            an.ST_LOC_ID = po.ST_LOC_ID
                        WHERE
                            an.ST_LOC_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_LOC_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_AVG_Metadata_UTL,
                k.UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_AVG_Positor, x.ST_AVG_ST_ID
                        ORDER BY
                            x.ST_AVG_ChangedAt DESC,
                            x.ST_AVG_PositedAt DESC,
                            x.ST_AVG_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.ST_AVG_Assertion <> '?' THEN r.ST_AVG_ChangedAt END) OVER (
                            PARTITION BY r.ST_AVG_Positor, r.ST_AVG_ST_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Positor,
                            an.ST_AVG_Reliability,
                            an.ST_AVG_Assertion,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Positor
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Scen_Medel_Posit po
                        JOIN
                            attributes.ST_AVG_Scen_Medel_Annex an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                        WHERE
                            po.ST_AVG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.ST_AVG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_AVG_Assertion = '+'
                AND
                    x.ST_AVG_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.UTL_Utnyttjande k
            ON
                k.UTL_ID = y.ST_AVG_UTL_ID
            WHERE
                y.pickRank = 1
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS ST_MIN_Metadata_UTL,
                k.UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.ST_MIN_Positor, x.ST_MIN_ST_ID
                        ORDER BY
                            x.ST_MIN_PositedAt DESC,
                            x.ST_MIN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_ST_MIN,
                            po.ST_MIN_ID,
                            an.ST_MIN_PositedAt,
                            an.ST_MIN_Positor,
                            an.ST_MIN_Reliability,
                            an.ST_MIN_Assertion,
                            po.ST_MIN_ST_ID,
                            po.ST_MIN_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_MIN_ID, an.ST_MIN_Positor
                                ORDER BY an.ST_MIN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_MIN_Scen_Minimum_Posit po
                        JOIN
                            attributes.ST_MIN_Scen_Minimum_Annex an
                        ON
                            an.ST_MIN_ID = po.ST_MIN_ID
                        WHERE
                            an.ST_MIN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.ST_MIN_Assertion = '+'
            ) y
            LEFT JOIN
                knots.UTL_Utnyttjande k
            ON
                k.UTL_ID = y.ST_MIN_UTL_ID
            WHERE
                y.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Positor = positorTable.Positor
    ]';
END pST_Scen;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Scen
AS
SELECT
    *
FROM
    anchors.pST_Scen(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
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
            positorTable.Positor,
            timepoints.inspectedTimepoint,
            "ST".ST_ID,
            "ST".Metadata_ST,
            "NAM".ST_NAM_ST_ID,
            "NAM".Metadata_ST_NAM,
            "NAM".ST_NAM_ID,
            "NAM".ST_NAM_ChangedAt,
            "NAM".ST_NAM_PositedAt,
            "NAM".ST_NAM_Positor,
            "NAM".ST_NAM_Reliability,
            "NAM".ST_NAM_Assertion,
            "NAM".ST_NAM_Scen_Namn,
            "LOC".ST_LOC_ST_ID,
            "LOC".Metadata_ST_LOC,
            "LOC".ST_LOC_ID,
            "LOC".ST_LOC_PositedAt,
            "LOC".ST_LOC_Positor,
            "LOC".ST_LOC_Reliability,
            "LOC".ST_LOC_Assertion,
            "LOC".ST_LOC_Checksum,
            "LOC".ST_LOC_Scen_Plats,
            "AVG".ST_AVG_ST_ID,
            "AVG".Metadata_ST_AVG,
            "AVG".ST_AVG_ID,
            "AVG".ST_AVG_ChangedAt,
            "AVG".ST_AVG_PositedAt,
            "AVG".ST_AVG_Positor,
            "AVG".ST_AVG_Reliability,
            "AVG".ST_AVG_Assertion,
            "kAVG".UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
            "kAVG".Metadata_UTL AS ST_AVG_Metadata_UTL,
            "AVG".ST_AVG_UTL_ID,
            "MIN".ST_MIN_ST_ID,
            "MIN".Metadata_ST_MIN,
            "MIN".ST_MIN_ID,
            "MIN".ST_MIN_PositedAt,
            "MIN".ST_MIN_Positor,
            "MIN".ST_MIN_Reliability,
            "MIN".ST_MIN_Assertion,
            "kMIN".UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
            "kMIN".Metadata_UTL AS ST_MIN_Metadata_UTL,
            "MIN".ST_MIN_UTL_ID
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_NAM_Positor AS inspectedPositor,
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
                h.ST_AVG_Positor AS inspectedPositor,
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
        ON
            timepoints.inspectedPositor = positorTable.Positor
        JOIN
            anchors.ST_Scen "ST"
        ON
            "ST".ST_ID = timepoints.ST_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.ST_NAM_ChangedAt) OVER (
                    PARTITION BY y.ST_NAM_Positor, y.ST_NAM_ST_ID
                    ORDER BY y.ST_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_NAM_Positor, r.ST_NAM_ST_ID, r.ST_NAM_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_NAM_Assertion = '+' THEN 0 ELSE 1 END,
                                r.ST_NAM_PositedAt DESC,
                                r.ST_NAM_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_NAM,
                            po.ST_NAM_ID,
                            an.ST_NAM_PositedAt,
                            an.ST_NAM_Positor,
                            an.ST_NAM_Reliability,
                            an.ST_NAM_Assertion,
                            po.ST_NAM_ST_ID,
                            po.ST_NAM_Scen_Namn,
                            po.ST_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_NAM_ID, an.ST_NAM_Positor
                                ORDER BY an.ST_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_NAM_Scen_Namn_Posit po
                        JOIN
                            attributes.ST_NAM_Scen_Namn_Annex an
                        ON
                            an.ST_NAM_ID = po.ST_NAM_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_NAM_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "NAM"
        ON
            "NAM".ST_NAM_ST_ID = "ST".ST_ID
        AND
            "NAM".ST_NAM_Positor = timepoints.inspectedPositor
        AND
            "NAM".ST_NAM_Assertion = '+'
        AND
            "NAM".ST_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_LOC_Positor, r.ST_LOC_ST_ID
                        ORDER BY
                            r.ST_LOC_PositedAt DESC,
                            r.ST_LOC_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_LOC,
                        po.ST_LOC_ID,
                        an.ST_LOC_PositedAt,
                        an.ST_LOC_Positor,
                        an.ST_LOC_Reliability,
                        an.ST_LOC_Assertion,
                        po.ST_LOC_ST_ID,
                        po.ST_LOC_Checksum,
                        po.ST_LOC_Scen_Plats,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_LOC_ID, an.ST_LOC_Positor
                            ORDER BY an.ST_LOC_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.ST_LOC_Scen_Plats_Posit po
                    JOIN
                        attributes.ST_LOC_Scen_Plats_Annex an
                    ON
                        an.ST_LOC_ID = po.ST_LOC_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_LOC_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "LOC"
        ON
            "LOC".ST_LOC_ST_ID = "ST".ST_ID
        AND
            "LOC".ST_LOC_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.ST_AVG_ChangedAt) OVER (
                    PARTITION BY y.ST_AVG_Positor, y.ST_AVG_ST_ID
                    ORDER BY y.ST_AVG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.ST_AVG_Positor, r.ST_AVG_ST_ID, r.ST_AVG_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_AVG_Assertion = '+' THEN 0 ELSE 1 END,
                                r.ST_AVG_PositedAt DESC,
                                r.ST_AVG_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_AVG,
                            po.ST_AVG_ID,
                            an.ST_AVG_PositedAt,
                            an.ST_AVG_Positor,
                            an.ST_AVG_Reliability,
                            an.ST_AVG_Assertion,
                            po.ST_AVG_ST_ID,
                            po.ST_AVG_UTL_ID,
                            po.ST_AVG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_AVG_ID, an.ST_AVG_Positor
                                ORDER BY an.ST_AVG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.ST_AVG_Scen_Medel_Posit po
                        JOIN
                            attributes.ST_AVG_Scen_Medel_Annex an
                        ON
                            an.ST_AVG_ID = po.ST_AVG_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_AVG_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "AVG"
        ON
            "AVG".ST_AVG_ST_ID = "ST".ST_ID
        AND
            "AVG".ST_AVG_Positor = timepoints.inspectedPositor
        AND
            "AVG".ST_AVG_Assertion = '+'
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
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.ST_MIN_Positor, r.ST_MIN_ST_ID
                        ORDER BY
                            r.ST_MIN_PositedAt DESC,
                            r.ST_MIN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_ST_MIN,
                        po.ST_MIN_ID,
                        an.ST_MIN_PositedAt,
                        an.ST_MIN_Positor,
                        an.ST_MIN_Reliability,
                        an.ST_MIN_Assertion,
                        po.ST_MIN_ST_ID,
                        po.ST_MIN_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_MIN_ID, an.ST_MIN_Positor
                            ORDER BY an.ST_MIN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.ST_MIN_Scen_Minimum_Posit po
                    JOIN
                        attributes.ST_MIN_Scen_Minimum_Annex an
                    ON
                        an.ST_MIN_ID = po.ST_MIN_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.ST_MIN_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "MIN"
        ON
            "MIN".ST_MIN_ST_ID = "ST".ST_ID
        AND
            "MIN".ST_MIN_Positor = timepoints.inspectedPositor
        LEFT JOIN
            knots.UTL_Utnyttjande "kMIN"
        ON
            "kMIN".UTL_ID = "MIN".ST_MIN_UTL_ID
    ]';
END dST_Scen;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tAC_Skådespelare (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
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
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Positor,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Assertion,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Positor,
            "GEN".AC_GEN_Reliability,
            "GEN".AC_GEN_Assertion,
            "GEN".AC_GEN_GEN_Checksum,
            "GEN".AC_GEN_GEN_Kön,
            "GEN".AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Positor,
            "PLV".AC_PLV_Reliability,
            "PLV".AC_PLV_Assertion,
            "PLV".AC_PLV_PLV_Checksum,
            "PLV".AC_PLV_PLV_Yrkesnivå,
            "PLV".AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Skådespelare "AC"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_NAM_Positor, x.AC_NAM_AC_ID
                        ORDER BY
                            x.AC_NAM_ChangedAt DESC,
                            x.AC_NAM_PositedAt DESC,
                            x.AC_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_NAM_Assertion <> '?' THEN r.AC_NAM_ChangedAt END) OVER (
                            PARTITION BY r.AC_NAM_Positor, r.AC_NAM_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Positor,
                            an.AC_NAM_Reliability,
                            an.AC_NAM_Assertion,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Skådespelare_Namn,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Positor
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Skådespelare_Namn_Posit po
                        JOIN
                            attributes.AC_NAM_Skådespelare_Namn_Annex an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_NAM_Assertion = COALESCE(assertion, x.AC_NAM_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.AC_NAM_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.GEN_Checksum AS AC_GEN_GEN_Checksum,
                k.Metadata_GEN AS AC_GEN_Metadata_GEN,
                k.GEN_Kön AS AC_GEN_GEN_Kön
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_GEN_Positor, x.AC_GEN_AC_ID
                        ORDER BY
                            x.AC_GEN_PositedAt DESC,
                            x.AC_GEN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Positor,
                            an.AC_GEN_Reliability,
                            an.AC_GEN_Assertion,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID, an.AC_GEN_Positor
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_GEN_Skådespelare_Kön_Posit po
                        JOIN
                            attributes.AC_GEN_Skådespelare_Kön_Annex an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_GEN_Assertion = COALESCE(assertion, x.AC_GEN_Assertion)
            ) y
            LEFT JOIN
                knots.GEN_Kön k
            ON
                k.GEN_ID = y.AC_GEN_GEN_ID
            WHERE
                y.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS AC_PLV_PLV_Checksum,
                k.Metadata_PLV AS AC_PLV_Metadata_PLV,
                k.PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_PLV_Positor, x.AC_PLV_AC_ID
                        ORDER BY
                            x.AC_PLV_ChangedAt DESC,
                            x.AC_PLV_PositedAt DESC,
                            x.AC_PLV_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_PLV_Assertion <> '?' THEN r.AC_PLV_ChangedAt END) OVER (
                            PARTITION BY r.AC_PLV_Positor, r.AC_PLV_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Positor,
                            an.AC_PLV_Reliability,
                            an.AC_PLV_Assertion,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Positor
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit po
                        JOIN
                            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_PLV_Assertion = COALESCE(assertion, x.AC_PLV_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.AC_PLV_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.PLV_Yrkesnivå k
            ON
                k.PLV_ID = y.AC_PLV_PLV_ID
            WHERE
                y.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tAC_Skådespelare;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Skådespelare (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Positor,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Assertion,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Positor,
            "GEN".AC_GEN_Reliability,
            "GEN".AC_GEN_Assertion,
            "GEN".AC_GEN_GEN_Checksum,
            "GEN".AC_GEN_GEN_Kön,
            "GEN".AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Positor,
            "PLV".AC_PLV_Reliability,
            "PLV".AC_PLV_Assertion,
            "PLV".AC_PLV_PLV_Checksum,
            "PLV".AC_PLV_PLV_Yrkesnivå,
            "PLV".AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            anchors.AC_Skådespelare "AC"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_NAM_Positor, x.AC_NAM_AC_ID
                        ORDER BY
                            x.AC_NAM_ChangedAt DESC,
                            x.AC_NAM_PositedAt DESC,
                            x.AC_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_NAM_Assertion <> '?' THEN r.AC_NAM_ChangedAt END) OVER (
                            PARTITION BY r.AC_NAM_Positor, r.AC_NAM_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Positor,
                            an.AC_NAM_Reliability,
                            an.AC_NAM_Assertion,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Skådespelare_Namn,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Positor
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Skådespelare_Namn_Posit po
                        JOIN
                            attributes.AC_NAM_Skådespelare_Namn_Annex an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                        WHERE
                            po.AC_NAM_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_NAM_Assertion = '+'
                AND
                    x.AC_NAM_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.GEN_Checksum AS AC_GEN_GEN_Checksum,
                k.Metadata_GEN AS AC_GEN_Metadata_GEN,
                k.GEN_Kön AS AC_GEN_GEN_Kön
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_GEN_Positor, x.AC_GEN_AC_ID
                        ORDER BY
                            x.AC_GEN_PositedAt DESC,
                            x.AC_GEN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_AC_GEN,
                            po.AC_GEN_ID,
                            an.AC_GEN_PositedAt,
                            an.AC_GEN_Positor,
                            an.AC_GEN_Reliability,
                            an.AC_GEN_Assertion,
                            po.AC_GEN_AC_ID,
                            po.AC_GEN_GEN_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_GEN_ID, an.AC_GEN_Positor
                                ORDER BY an.AC_GEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_GEN_Skådespelare_Kön_Posit po
                        JOIN
                            attributes.AC_GEN_Skådespelare_Kön_Annex an
                        ON
                            an.AC_GEN_ID = po.AC_GEN_ID
                        WHERE
                            an.AC_GEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_GEN_Assertion = '+'
            ) y
            LEFT JOIN
                knots.GEN_Kön k
            ON
                k.GEN_ID = y.AC_GEN_GEN_ID
            WHERE
                y.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS AC_PLV_PLV_Checksum,
                k.Metadata_PLV AS AC_PLV_Metadata_PLV,
                k.PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.AC_PLV_Positor, x.AC_PLV_AC_ID
                        ORDER BY
                            x.AC_PLV_ChangedAt DESC,
                            x.AC_PLV_PositedAt DESC,
                            x.AC_PLV_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.AC_PLV_Assertion <> '?' THEN r.AC_PLV_ChangedAt END) OVER (
                            PARTITION BY r.AC_PLV_Positor, r.AC_PLV_AC_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Positor,
                            an.AC_PLV_Reliability,
                            an.AC_PLV_Assertion,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Positor
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit po
                        JOIN
                            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                        WHERE
                            po.AC_PLV_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.AC_PLV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.AC_PLV_Assertion = '+'
                AND
                    x.AC_PLV_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.PLV_Yrkesnivå k
            ON
                k.PLV_ID = y.AC_PLV_PLV_ID
            WHERE
                y.pickRank = 1
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Positor = positorTable.Positor
    ]';
END pAC_Skådespelare;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Skådespelare
AS
SELECT
    *
FROM
    anchors.pAC_Skådespelare(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
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
            positorTable.Positor,
            timepoints.inspectedTimepoint,
            "AC".AC_ID,
            "AC".Metadata_AC,
            "NAM".AC_NAM_AC_ID,
            "NAM".Metadata_AC_NAM,
            "NAM".AC_NAM_ID,
            "NAM".AC_NAM_ChangedAt,
            "NAM".AC_NAM_PositedAt,
            "NAM".AC_NAM_Positor,
            "NAM".AC_NAM_Reliability,
            "NAM".AC_NAM_Assertion,
            "NAM".AC_NAM_Skådespelare_Namn,
            "GEN".AC_GEN_AC_ID,
            "GEN".Metadata_AC_GEN,
            "GEN".AC_GEN_ID,
            "GEN".AC_GEN_PositedAt,
            "GEN".AC_GEN_Positor,
            "GEN".AC_GEN_Reliability,
            "GEN".AC_GEN_Assertion,
            "kGEN".GEN_Checksum AS AC_GEN_GEN_Checksum,
            "kGEN".GEN_Kön AS AC_GEN_GEN_Kön,
            "kGEN".Metadata_GEN AS AC_GEN_Metadata_GEN,
            "GEN".AC_GEN_GEN_ID,
            "PLV".AC_PLV_AC_ID,
            "PLV".Metadata_AC_PLV,
            "PLV".AC_PLV_ID,
            "PLV".AC_PLV_ChangedAt,
            "PLV".AC_PLV_PositedAt,
            "PLV".AC_PLV_Positor,
            "PLV".AC_PLV_Reliability,
            "PLV".AC_PLV_Assertion,
            "kPLV".PLV_Checksum AS AC_PLV_PLV_Checksum,
            "kPLV".PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
            "kPLV".Metadata_PLV AS AC_PLV_Metadata_PLV,
            "PLV".AC_PLV_PLV_ID
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_NAM_Positor AS inspectedPositor,
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
                h.AC_PLV_Positor AS inspectedPositor,
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
        ON
            timepoints.inspectedPositor = positorTable.Positor
        JOIN
            anchors.AC_Skådespelare "AC"
        ON
            "AC".AC_ID = timepoints.AC_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.AC_NAM_ChangedAt) OVER (
                    PARTITION BY y.AC_NAM_Positor, y.AC_NAM_AC_ID
                    ORDER BY y.AC_NAM_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_NAM_Positor, r.AC_NAM_AC_ID, r.AC_NAM_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_NAM_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_NAM_PositedAt DESC,
                                r.AC_NAM_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_NAM,
                            po.AC_NAM_ID,
                            an.AC_NAM_PositedAt,
                            an.AC_NAM_Positor,
                            an.AC_NAM_Reliability,
                            an.AC_NAM_Assertion,
                            po.AC_NAM_AC_ID,
                            po.AC_NAM_Skådespelare_Namn,
                            po.AC_NAM_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_NAM_ID, an.AC_NAM_Positor
                                ORDER BY an.AC_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_NAM_Skådespelare_Namn_Posit po
                        JOIN
                            attributes.AC_NAM_Skådespelare_Namn_Annex an
                        ON
                            an.AC_NAM_ID = po.AC_NAM_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_NAM_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "NAM"
        ON
            "NAM".AC_NAM_AC_ID = "AC".AC_ID
        AND
            "NAM".AC_NAM_Positor = timepoints.inspectedPositor
        AND
            "NAM".AC_NAM_Assertion = '+'
        AND
            "NAM".AC_NAM_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "NAM".untilTime IS NULL
        OR
            "NAM".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.AC_GEN_Positor, r.AC_GEN_AC_ID
                        ORDER BY
                            r.AC_GEN_PositedAt DESC,
                            r.AC_GEN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_AC_GEN,
                        po.AC_GEN_ID,
                        an.AC_GEN_PositedAt,
                        an.AC_GEN_Positor,
                        an.AC_GEN_Reliability,
                        an.AC_GEN_Assertion,
                        po.AC_GEN_AC_ID,
                        po.AC_GEN_GEN_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_GEN_ID, an.AC_GEN_Positor
                            ORDER BY an.AC_GEN_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.AC_GEN_Skådespelare_Kön_Posit po
                    JOIN
                        attributes.AC_GEN_Skådespelare_Kön_Annex an
                    ON
                        an.AC_GEN_ID = po.AC_GEN_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.AC_GEN_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "GEN"
        ON
            "GEN".AC_GEN_AC_ID = "AC".AC_ID
        AND
            "GEN".AC_GEN_Positor = timepoints.inspectedPositor
        LEFT JOIN
            knots.GEN_Kön "kGEN"
        ON
            "kGEN".GEN_ID = "GEN".AC_GEN_GEN_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.AC_PLV_ChangedAt) OVER (
                    PARTITION BY y.AC_PLV_Positor, y.AC_PLV_AC_ID
                    ORDER BY y.AC_PLV_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.AC_PLV_Positor, r.AC_PLV_AC_ID, r.AC_PLV_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_PLV_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_PLV_PositedAt DESC,
                                r.AC_PLV_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_PLV,
                            po.AC_PLV_ID,
                            an.AC_PLV_PositedAt,
                            an.AC_PLV_Positor,
                            an.AC_PLV_Reliability,
                            an.AC_PLV_Assertion,
                            po.AC_PLV_AC_ID,
                            po.AC_PLV_PLV_ID,
                            po.AC_PLV_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_PLV_ID, an.AC_PLV_Positor
                                ORDER BY an.AC_PLV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit po
                        JOIN
                            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex an
                        ON
                            an.AC_PLV_ID = po.AC_PLV_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_PLV_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "PLV"
        ON
            "PLV".AC_PLV_AC_ID = "AC".AC_ID
        AND
            "PLV".AC_PLV_Positor = timepoints.inspectedPositor
        AND
            "PLV".AC_PLV_Assertion = '+'
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
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tPR_Föreställning (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
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
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Positor,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Assertion,
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Positor,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Assertion,
            "LEN".PR_LEN_Föreställning_Längd
        FROM
            anchors.PR_Föreställning "PR"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_NAM_Positor, x.PR_NAM_PR_ID
                        ORDER BY
                            x.PR_NAM_PositedAt DESC,
                            x.PR_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Positor,
                            an.PR_NAM_Reliability,
                            an.PR_NAM_Assertion,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Föreställning_Namn,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID, an.PR_NAM_Positor
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_NAM_Föreställning_Namn_Posit po
                        JOIN
                            attributes.PR_NAM_Föreställning_Namn_Annex an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_NAM_Assertion = COALESCE(assertion, x.PR_NAM_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_LEN_Positor, x.PR_LEN_PR_ID
                        ORDER BY
                            x.PR_LEN_ChangedAt DESC,
                            x.PR_LEN_PositedAt DESC,
                            x.PR_LEN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.PR_LEN_Assertion <> '?' THEN r.PR_LEN_ChangedAt END) OVER (
                            PARTITION BY r.PR_LEN_Positor, r.PR_LEN_PR_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Positor,
                            an.PR_LEN_Reliability,
                            an.PR_LEN_Assertion,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Föreställning_Längd,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Positor
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Föreställning_Längd_Posit po
                        JOIN
                            attributes.PR_LEN_Föreställning_Längd_Annex an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_LEN_Assertion = COALESCE(assertion, x.PR_LEN_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.PR_LEN_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tPR_Föreställning;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Föreställning (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Positor,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Assertion,
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Positor,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Assertion,
            "LEN".PR_LEN_Föreställning_Längd
        FROM
            anchors.PR_Föreställning "PR"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_NAM_Positor, x.PR_NAM_PR_ID
                        ORDER BY
                            x.PR_NAM_PositedAt DESC,
                            x.PR_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_PR_NAM,
                            po.PR_NAM_ID,
                            an.PR_NAM_PositedAt,
                            an.PR_NAM_Positor,
                            an.PR_NAM_Reliability,
                            an.PR_NAM_Assertion,
                            po.PR_NAM_PR_ID,
                            po.PR_NAM_Föreställning_Namn,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_NAM_ID, an.PR_NAM_Positor
                                ORDER BY an.PR_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_NAM_Föreställning_Namn_Posit po
                        JOIN
                            attributes.PR_NAM_Föreställning_Namn_Annex an
                        ON
                            an.PR_NAM_ID = po.PR_NAM_ID
                        WHERE
                            an.PR_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_NAM_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.PR_LEN_Positor, x.PR_LEN_PR_ID
                        ORDER BY
                            x.PR_LEN_ChangedAt DESC,
                            x.PR_LEN_PositedAt DESC,
                            x.PR_LEN_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.PR_LEN_Assertion <> '?' THEN r.PR_LEN_ChangedAt END) OVER (
                            PARTITION BY r.PR_LEN_Positor, r.PR_LEN_PR_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Positor,
                            an.PR_LEN_Reliability,
                            an.PR_LEN_Assertion,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Föreställning_Längd,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Positor
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Föreställning_Längd_Posit po
                        JOIN
                            attributes.PR_LEN_Föreställning_Längd_Annex an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                        WHERE
                            po.PR_LEN_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.PR_LEN_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.PR_LEN_Assertion = '+'
                AND
                    x.PR_LEN_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Positor = positorTable.Positor
    ]';
END pPR_Föreställning;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Föreställning
AS
SELECT
    *
FROM
    anchors.pPR_Föreställning(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
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
            positorTable.Positor,
            timepoints.inspectedTimepoint,
            "PR".PR_ID,
            "PR".Metadata_PR,
            "NAM".PR_NAM_PR_ID,
            "NAM".Metadata_PR_NAM,
            "NAM".PR_NAM_ID,
            "NAM".PR_NAM_PositedAt,
            "NAM".PR_NAM_Positor,
            "NAM".PR_NAM_Reliability,
            "NAM".PR_NAM_Assertion,
            "NAM".PR_NAM_Föreställning_Namn,
            "LEN".PR_LEN_PR_ID,
            "LEN".Metadata_PR_LEN,
            "LEN".PR_LEN_ID,
            "LEN".PR_LEN_ChangedAt,
            "LEN".PR_LEN_PositedAt,
            "LEN".PR_LEN_Positor,
            "LEN".PR_LEN_Reliability,
            "LEN".PR_LEN_Assertion,
            "LEN".PR_LEN_Föreställning_Längd
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_LEN_Positor AS inspectedPositor,
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
        ON
            timepoints.inspectedPositor = positorTable.Positor
        JOIN
            anchors.PR_Föreställning "PR"
        ON
            "PR".PR_ID = timepoints.PR_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.PR_NAM_Positor, r.PR_NAM_PR_ID
                        ORDER BY
                            r.PR_NAM_PositedAt DESC,
                            r.PR_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_PR_NAM,
                        po.PR_NAM_ID,
                        an.PR_NAM_PositedAt,
                        an.PR_NAM_Positor,
                        an.PR_NAM_Reliability,
                        an.PR_NAM_Assertion,
                        po.PR_NAM_PR_ID,
                        po.PR_NAM_Föreställning_Namn,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_NAM_ID, an.PR_NAM_Positor
                            ORDER BY an.PR_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.PR_NAM_Föreställning_Namn_Posit po
                    JOIN
                        attributes.PR_NAM_Föreställning_Namn_Annex an
                    ON
                        an.PR_NAM_ID = po.PR_NAM_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.PR_NAM_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".PR_NAM_PR_ID = "PR".PR_ID
        AND
            "NAM".PR_NAM_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.PR_LEN_ChangedAt) OVER (
                    PARTITION BY y.PR_LEN_Positor, y.PR_LEN_PR_ID
                    ORDER BY y.PR_LEN_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.PR_LEN_Positor, r.PR_LEN_PR_ID, r.PR_LEN_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_LEN_Assertion = '+' THEN 0 ELSE 1 END,
                                r.PR_LEN_PositedAt DESC,
                                r.PR_LEN_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_LEN,
                            po.PR_LEN_ID,
                            an.PR_LEN_PositedAt,
                            an.PR_LEN_Positor,
                            an.PR_LEN_Reliability,
                            an.PR_LEN_Assertion,
                            po.PR_LEN_PR_ID,
                            po.PR_LEN_Föreställning_Längd,
                            po.PR_LEN_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_LEN_ID, an.PR_LEN_Positor
                                ORDER BY an.PR_LEN_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.PR_LEN_Föreställning_Längd_Posit po
                        JOIN
                            attributes.PR_LEN_Föreställning_Längd_Annex an
                        ON
                            an.PR_LEN_ID = po.PR_LEN_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_LEN_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LEN"
        ON
            "LEN".PR_LEN_PR_ID = "PR".PR_ID
        AND
            "LEN".PR_LEN_Positor = timepoints.inspectedPositor
        AND
            "LEN".PR_LEN_Assertion = '+'
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
-- CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pEV_Event(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.tEV_Händelse (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
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
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Positor,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Assertion,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Positor,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Assertion,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Positor,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Assertion,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Positor,
            "STA".EV_STA_Reliability,
            "STA".EV_STA_Assertion,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Positor,
            "UTL".EV_UTL_Reliability,
            "UTL".EV_UTL_Assertion,
            "UTL".EV_UTL_UTL_Utnyttjande,
            "UTL".EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Positor,
            "LVL".EV_LVL_Reliability,
            "LVL".EV_LVL_Assertion,
            "LVL".EV_LVL_PLV_Checksum,
            "LVL".EV_LVL_PLV_Yrkesnivå,
            "LVL".EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Händelse "EV"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN
            knots.ETY_Händelsetyp "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_DAT_Positor, x.EV_DAT_EV_ID
                        ORDER BY
                            x.EV_DAT_PositedAt DESC,
                            x.EV_DAT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_DAT,
                            po.EV_DAT_ID,
                            an.EV_DAT_PositedAt,
                            an.EV_DAT_Positor,
                            an.EV_DAT_Reliability,
                            an.EV_DAT_Assertion,
                            po.EV_DAT_EV_ID,
                            po.EV_DAT_Händelse_Datum,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_DAT_ID, an.EV_DAT_Positor
                                ORDER BY an.EV_DAT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_DAT_Händelse_Datum_Posit po
                        JOIN
                            attributes.EV_DAT_Händelse_Datum_Annex an
                        ON
                            an.EV_DAT_ID = po.EV_DAT_ID
                        WHERE
                            an.EV_DAT_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_DAT_Assertion = COALESCE(assertion, x.EV_DAT_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_AUD_Positor, x.EV_AUD_EV_ID
                        ORDER BY
                            x.EV_AUD_PositedAt DESC,
                            x.EV_AUD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_AUD,
                            po.EV_AUD_ID,
                            an.EV_AUD_PositedAt,
                            an.EV_AUD_Positor,
                            an.EV_AUD_Reliability,
                            an.EV_AUD_Assertion,
                            po.EV_AUD_EV_ID,
                            po.EV_AUD_Händelse_Publik,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_AUD_ID, an.EV_AUD_Positor
                                ORDER BY an.EV_AUD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_AUD_Händelse_Publik_Posit po
                        JOIN
                            attributes.EV_AUD_Händelse_Publik_Annex an
                        ON
                            an.EV_AUD_ID = po.EV_AUD_ID
                        WHERE
                            an.EV_AUD_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_AUD_Assertion = COALESCE(assertion, x.EV_AUD_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_REV_Positor, x.EV_REV_EV_ID
                        ORDER BY
                            x.EV_REV_PositedAt DESC,
                            x.EV_REV_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_REV,
                            po.EV_REV_ID,
                            an.EV_REV_PositedAt,
                            an.EV_REV_Positor,
                            an.EV_REV_Reliability,
                            an.EV_REV_Assertion,
                            po.EV_REV_EV_ID,
                            po.EV_REV_Händelse_Intäkt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_REV_ID, an.EV_REV_Positor
                                ORDER BY an.EV_REV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_REV_Händelse_Intäkt_Posit po
                        JOIN
                            attributes.EV_REV_Händelse_Intäkt_Annex an
                        ON
                            an.EV_REV_ID = po.EV_REV_ID
                        WHERE
                            an.EV_REV_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_REV_Assertion = COALESCE(assertion, x.EV_REV_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_STA_Positor, x.EV_STA_EV_ID
                        ORDER BY
                            x.EV_STA_ChangedAt DESC,
                            x.EV_STA_PositedAt DESC,
                            x.EV_STA_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_STA_Assertion <> '?' THEN r.EV_STA_ChangedAt END) OVER (
                            PARTITION BY r.EV_STA_Positor, r.EV_STA_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Positor,
                            an.EV_STA_Reliability,
                            an.EV_STA_Assertion,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Händelse_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Positor
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Händelse_Status_Posit po
                        JOIN
                            attributes.EV_STA_Händelse_Status_Annex an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                        WHERE
                            po.EV_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_STA_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_STA_Assertion = COALESCE(assertion, x.EV_STA_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_STA_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS EV_UTL_Metadata_UTL,
                k.UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_UTL_Positor, x.EV_UTL_EV_ID
                        ORDER BY
                            x.EV_UTL_PositedAt DESC,
                            x.EV_UTL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_UTL,
                            po.EV_UTL_ID,
                            an.EV_UTL_PositedAt,
                            an.EV_UTL_Positor,
                            an.EV_UTL_Reliability,
                            an.EV_UTL_Assertion,
                            po.EV_UTL_EV_ID,
                            po.EV_UTL_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_UTL_ID, an.EV_UTL_Positor
                                ORDER BY an.EV_UTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_UTL_Händelse_Utnyttjande_Posit po
                        JOIN
                            attributes.EV_UTL_Händelse_Utnyttjande_Annex an
                        ON
                            an.EV_UTL_ID = po.EV_UTL_ID
                        WHERE
                            an.EV_UTL_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_UTL_Assertion = COALESCE(assertion, x.EV_UTL_Assertion)
            ) y
            LEFT JOIN
                knots.UTL_Utnyttjande k
            ON
                k.UTL_ID = y.EV_UTL_UTL_ID
            WHERE
                y.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS EV_LVL_PLV_Checksum,
                k.Metadata_PLV AS EV_LVL_Metadata_PLV,
                k.PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_LVL_Positor, x.EV_LVL_EV_ID
                        ORDER BY
                            x.EV_LVL_ChangedAt DESC,
                            x.EV_LVL_PositedAt DESC,
                            x.EV_LVL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_LVL_Assertion <> '?' THEN r.EV_LVL_ChangedAt END) OVER (
                            PARTITION BY r.EV_LVL_Positor, r.EV_LVL_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Positor,
                            an.EV_LVL_Reliability,
                            an.EV_LVL_Assertion,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Positor
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Händelse_Level_Posit po
                        JOIN
                            attributes.EV_LVL_Händelse_Level_Annex an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                        WHERE
                            po.EV_LVL_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.EV_LVL_PositedAt <= CAST(positingTimepoint AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_LVL_Assertion = COALESCE(assertion, x.EV_LVL_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.EV_LVL_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                knots.PLV_Yrkesnivå k
            ON
                k.PLV_ID = y.EV_LVL_PLV_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tEV_Händelse;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses.pEV_Händelse (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_hölls,
            "EV".PR_ID_spelades,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Positor,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Assertion,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Positor,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Assertion,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Positor,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Assertion,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Positor,
            "STA".EV_STA_Reliability,
            "STA".EV_STA_Assertion,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Positor,
            "UTL".EV_UTL_Reliability,
            "UTL".EV_UTL_Assertion,
            "UTL".EV_UTL_UTL_Utnyttjande,
            "UTL".EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Positor,
            "LVL".EV_LVL_Reliability,
            "LVL".EV_LVL_Assertion,
            "LVL".EV_LVL_PLV_Checksum,
            "LVL".EV_LVL_PLV_Yrkesnivå,
            "LVL".EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            nexuses.EV_Händelse "EV"
        CROSS JOIN
            dw.Positor_ positorTable
        LEFT JOIN
            knots.ETY_Händelsetyp "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_DAT_Positor, x.EV_DAT_EV_ID
                        ORDER BY
                            x.EV_DAT_PositedAt DESC,
                            x.EV_DAT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_DAT,
                            po.EV_DAT_ID,
                            an.EV_DAT_PositedAt,
                            an.EV_DAT_Positor,
                            an.EV_DAT_Reliability,
                            an.EV_DAT_Assertion,
                            po.EV_DAT_EV_ID,
                            po.EV_DAT_Händelse_Datum,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_DAT_ID, an.EV_DAT_Positor
                                ORDER BY an.EV_DAT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_DAT_Händelse_Datum_Posit po
                        JOIN
                            attributes.EV_DAT_Händelse_Datum_Annex an
                        ON
                            an.EV_DAT_ID = po.EV_DAT_ID
                        WHERE
                            an.EV_DAT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_DAT_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_AUD_Positor, x.EV_AUD_EV_ID
                        ORDER BY
                            x.EV_AUD_PositedAt DESC,
                            x.EV_AUD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_AUD,
                            po.EV_AUD_ID,
                            an.EV_AUD_PositedAt,
                            an.EV_AUD_Positor,
                            an.EV_AUD_Reliability,
                            an.EV_AUD_Assertion,
                            po.EV_AUD_EV_ID,
                            po.EV_AUD_Händelse_Publik,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_AUD_ID, an.EV_AUD_Positor
                                ORDER BY an.EV_AUD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_AUD_Händelse_Publik_Posit po
                        JOIN
                            attributes.EV_AUD_Händelse_Publik_Annex an
                        ON
                            an.EV_AUD_ID = po.EV_AUD_ID
                        WHERE
                            an.EV_AUD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_AUD_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_REV_Positor, x.EV_REV_EV_ID
                        ORDER BY
                            x.EV_REV_PositedAt DESC,
                            x.EV_REV_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_REV,
                            po.EV_REV_ID,
                            an.EV_REV_PositedAt,
                            an.EV_REV_Positor,
                            an.EV_REV_Reliability,
                            an.EV_REV_Assertion,
                            po.EV_REV_EV_ID,
                            po.EV_REV_Händelse_Intäkt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_REV_ID, an.EV_REV_Positor
                                ORDER BY an.EV_REV_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_REV_Händelse_Intäkt_Posit po
                        JOIN
                            attributes.EV_REV_Händelse_Intäkt_Annex an
                        ON
                            an.EV_REV_ID = po.EV_REV_ID
                        WHERE
                            an.EV_REV_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_REV_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_STA_Positor, x.EV_STA_EV_ID
                        ORDER BY
                            x.EV_STA_ChangedAt DESC,
                            x.EV_STA_PositedAt DESC,
                            x.EV_STA_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_STA_Assertion <> '?' THEN r.EV_STA_ChangedAt END) OVER (
                            PARTITION BY r.EV_STA_Positor, r.EV_STA_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Positor,
                            an.EV_STA_Reliability,
                            an.EV_STA_Assertion,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Händelse_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Positor
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Händelse_Status_Posit po
                        JOIN
                            attributes.EV_STA_Händelse_Status_Annex an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                        WHERE
                            po.EV_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                        AND
                            an.EV_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_STA_Assertion = '+'
                AND
                    x.EV_STA_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_UTL AS EV_UTL_Metadata_UTL,
                k.UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_UTL_Positor, x.EV_UTL_EV_ID
                        ORDER BY
                            x.EV_UTL_PositedAt DESC,
                            x.EV_UTL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_EV_UTL,
                            po.EV_UTL_ID,
                            an.EV_UTL_PositedAt,
                            an.EV_UTL_Positor,
                            an.EV_UTL_Reliability,
                            an.EV_UTL_Assertion,
                            po.EV_UTL_EV_ID,
                            po.EV_UTL_UTL_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_UTL_ID, an.EV_UTL_Positor
                                ORDER BY an.EV_UTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_UTL_Händelse_Utnyttjande_Posit po
                        JOIN
                            attributes.EV_UTL_Händelse_Utnyttjande_Annex an
                        ON
                            an.EV_UTL_ID = po.EV_UTL_ID
                        WHERE
                            an.EV_UTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_UTL_Assertion = '+'
            ) y
            LEFT JOIN
                knots.UTL_Utnyttjande k
            ON
                k.UTL_ID = y.EV_UTL_UTL_ID
            WHERE
                y.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.PLV_Checksum AS EV_LVL_PLV_Checksum,
                k.Metadata_PLV AS EV_LVL_Metadata_PLV,
                k.PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.EV_LVL_Positor, x.EV_LVL_EV_ID
                        ORDER BY
                            x.EV_LVL_ChangedAt DESC,
                            x.EV_LVL_PositedAt DESC,
                            x.EV_LVL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.EV_LVL_Assertion <> '?' THEN r.EV_LVL_ChangedAt END) OVER (
                            PARTITION BY r.EV_LVL_Positor, r.EV_LVL_EV_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Positor,
                            an.EV_LVL_Reliability,
                            an.EV_LVL_Assertion,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Positor
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Händelse_Level_Posit po
                        JOIN
                            attributes.EV_LVL_Händelse_Level_Annex an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                        WHERE
                            po.EV_LVL_ChangedAt <= CAST(changingTimepoint AS date)
                        AND
                            an.EV_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                ) x
                WHERE
                    x.EV_LVL_Assertion = '+'
                AND
                    x.EV_LVL_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                knots.PLV_Yrkesnivå k
            ON
                k.PLV_ID = y.EV_LVL_PLV_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Positor = positorTable.Positor
    ]';
END pEV_Händelse;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.lEV_Händelse
AS
SELECT
    *
FROM
    nexuses.pEV_Händelse(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
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
            positorTable.Positor,
            timepoints.inspectedTimepoint,
            "EV".EV_ID,
            "EV".Metadata_EV,
            "EV".ST_ID_hölls,
            "EV".PR_ID_spelades,
            "kETY_of".ETY_Checksum AS of_ETY_Checksum,
            "kETY_of".ETY_Händelsetyp AS of_ETY_Händelsetyp,
            "kETY_of".Metadata_ETY AS of_Metadata_ETY,
            "EV".ETY_ID_of,
            "DAT".EV_DAT_EV_ID,
            "DAT".Metadata_EV_DAT,
            "DAT".EV_DAT_ID,
            "DAT".EV_DAT_PositedAt,
            "DAT".EV_DAT_Positor,
            "DAT".EV_DAT_Reliability,
            "DAT".EV_DAT_Assertion,
            "DAT".EV_DAT_Händelse_Datum,
            "AUD".EV_AUD_EV_ID,
            "AUD".Metadata_EV_AUD,
            "AUD".EV_AUD_ID,
            "AUD".EV_AUD_PositedAt,
            "AUD".EV_AUD_Positor,
            "AUD".EV_AUD_Reliability,
            "AUD".EV_AUD_Assertion,
            "AUD".EV_AUD_Händelse_Publik,
            "REV".EV_REV_EV_ID,
            "REV".Metadata_EV_REV,
            "REV".EV_REV_ID,
            "REV".EV_REV_PositedAt,
            "REV".EV_REV_Positor,
            "REV".EV_REV_Reliability,
            "REV".EV_REV_Assertion,
            "REV".EV_REV_Händelse_Intäkt,
            "STA".EV_STA_EV_ID,
            "STA".Metadata_EV_STA,
            "STA".EV_STA_ID,
            "STA".EV_STA_ChangedAt,
            "STA".EV_STA_PositedAt,
            "STA".EV_STA_Positor,
            "STA".EV_STA_Reliability,
            "STA".EV_STA_Assertion,
            "STA".EV_STA_Händelse_Status,
            "UTL".EV_UTL_EV_ID,
            "UTL".Metadata_EV_UTL,
            "UTL".EV_UTL_ID,
            "UTL".EV_UTL_PositedAt,
            "UTL".EV_UTL_Positor,
            "UTL".EV_UTL_Reliability,
            "UTL".EV_UTL_Assertion,
            "kUTL".UTL_Utnyttjande AS EV_UTL_UTL_Utnyttjande,
            "kUTL".Metadata_UTL AS EV_UTL_Metadata_UTL,
            "UTL".EV_UTL_UTL_ID,
            "LVL".EV_LVL_EV_ID,
            "LVL".Metadata_EV_LVL,
            "LVL".EV_LVL_ID,
            "LVL".EV_LVL_ChangedAt,
            "LVL".EV_LVL_PositedAt,
            "LVL".EV_LVL_Positor,
            "LVL".EV_LVL_Reliability,
            "LVL".EV_LVL_Assertion,
            "kLVL".PLV_Checksum AS EV_LVL_PLV_Checksum,
            "kLVL".PLV_Yrkesnivå AS EV_LVL_PLV_Yrkesnivå,
            "kLVL".Metadata_PLV AS EV_LVL_Metadata_PLV,
            "LVL".EV_LVL_PLV_ID
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.EV_STA_Positor AS inspectedPositor,
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
                h.EV_LVL_Positor AS inspectedPositor,
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
        ON
            timepoints.inspectedPositor = positorTable.Positor
        JOIN
            nexuses.EV_Händelse "EV"
        ON
            "EV".EV_ID = timepoints.EV_ID
        LEFT JOIN
            knots.ETY_Händelsetyp "kETY_of"
        ON
            "kETY_of".ETY_ID = "EV".ETY_ID_of
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_DAT_Positor, r.EV_DAT_EV_ID
                        ORDER BY
                            r.EV_DAT_PositedAt DESC,
                            r.EV_DAT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_DAT,
                        po.EV_DAT_ID,
                        an.EV_DAT_PositedAt,
                        an.EV_DAT_Positor,
                        an.EV_DAT_Reliability,
                        an.EV_DAT_Assertion,
                        po.EV_DAT_EV_ID,
                        po.EV_DAT_Händelse_Datum,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_DAT_ID, an.EV_DAT_Positor
                            ORDER BY an.EV_DAT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_DAT_Händelse_Datum_Posit po
                    JOIN
                        attributes.EV_DAT_Händelse_Datum_Annex an
                    ON
                        an.EV_DAT_ID = po.EV_DAT_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_DAT_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "DAT"
        ON
            "DAT".EV_DAT_EV_ID = "EV".EV_ID
        AND
            "DAT".EV_DAT_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_AUD_Positor, r.EV_AUD_EV_ID
                        ORDER BY
                            r.EV_AUD_PositedAt DESC,
                            r.EV_AUD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_AUD,
                        po.EV_AUD_ID,
                        an.EV_AUD_PositedAt,
                        an.EV_AUD_Positor,
                        an.EV_AUD_Reliability,
                        an.EV_AUD_Assertion,
                        po.EV_AUD_EV_ID,
                        po.EV_AUD_Händelse_Publik,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_AUD_ID, an.EV_AUD_Positor
                            ORDER BY an.EV_AUD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_AUD_Händelse_Publik_Posit po
                    JOIN
                        attributes.EV_AUD_Händelse_Publik_Annex an
                    ON
                        an.EV_AUD_ID = po.EV_AUD_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_AUD_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "AUD"
        ON
            "AUD".EV_AUD_EV_ID = "EV".EV_ID
        AND
            "AUD".EV_AUD_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_REV_Positor, r.EV_REV_EV_ID
                        ORDER BY
                            r.EV_REV_PositedAt DESC,
                            r.EV_REV_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_REV,
                        po.EV_REV_ID,
                        an.EV_REV_PositedAt,
                        an.EV_REV_Positor,
                        an.EV_REV_Reliability,
                        an.EV_REV_Assertion,
                        po.EV_REV_EV_ID,
                        po.EV_REV_Händelse_Intäkt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_REV_ID, an.EV_REV_Positor
                            ORDER BY an.EV_REV_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_REV_Händelse_Intäkt_Posit po
                    JOIN
                        attributes.EV_REV_Händelse_Intäkt_Annex an
                    ON
                        an.EV_REV_ID = po.EV_REV_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_REV_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "REV"
        ON
            "REV".EV_REV_EV_ID = "EV".EV_ID
        AND
            "REV".EV_REV_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_STA_ChangedAt) OVER (
                    PARTITION BY y.EV_STA_Positor, y.EV_STA_EV_ID
                    ORDER BY y.EV_STA_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_STA_Positor, r.EV_STA_EV_ID, r.EV_STA_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_STA_Assertion = '+' THEN 0 ELSE 1 END,
                                r.EV_STA_PositedAt DESC,
                                r.EV_STA_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_STA,
                            po.EV_STA_ID,
                            an.EV_STA_PositedAt,
                            an.EV_STA_Positor,
                            an.EV_STA_Reliability,
                            an.EV_STA_Assertion,
                            po.EV_STA_EV_ID,
                            po.EV_STA_Händelse_Status,
                            po.EV_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_STA_ID, an.EV_STA_Positor
                                ORDER BY an.EV_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_STA_Händelse_Status_Posit po
                        JOIN
                            attributes.EV_STA_Händelse_Status_Annex an
                        ON
                            an.EV_STA_ID = po.EV_STA_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_STA_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "STA"
        ON
            "STA".EV_STA_EV_ID = "EV".EV_ID
        AND
            "STA".EV_STA_Positor = timepoints.inspectedPositor
        AND
            "STA".EV_STA_Assertion = '+'
        AND
            "STA".EV_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.EV_UTL_Positor, r.EV_UTL_EV_ID
                        ORDER BY
                            r.EV_UTL_PositedAt DESC,
                            r.EV_UTL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_EV_UTL,
                        po.EV_UTL_ID,
                        an.EV_UTL_PositedAt,
                        an.EV_UTL_Positor,
                        an.EV_UTL_Reliability,
                        an.EV_UTL_Assertion,
                        po.EV_UTL_EV_ID,
                        po.EV_UTL_UTL_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_UTL_ID, an.EV_UTL_Positor
                            ORDER BY an.EV_UTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        attributes.EV_UTL_Händelse_Utnyttjande_Posit po
                    JOIN
                        attributes.EV_UTL_Händelse_Utnyttjande_Annex an
                    ON
                        an.EV_UTL_ID = po.EV_UTL_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.EV_UTL_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "UTL"
        ON
            "UTL".EV_UTL_EV_ID = "EV".EV_ID
        AND
            "UTL".EV_UTL_Positor = timepoints.inspectedPositor
        LEFT JOIN
            knots.UTL_Utnyttjande "kUTL"
        ON
            "kUTL".UTL_ID = "UTL".EV_UTL_UTL_ID
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.EV_LVL_ChangedAt) OVER (
                    PARTITION BY y.EV_LVL_Positor, y.EV_LVL_EV_ID
                    ORDER BY y.EV_LVL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.EV_LVL_Positor, r.EV_LVL_EV_ID, r.EV_LVL_ChangedAt
                            ORDER BY
                                CASE WHEN r.EV_LVL_Assertion = '+' THEN 0 ELSE 1 END,
                                r.EV_LVL_PositedAt DESC,
                                r.EV_LVL_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_EV_LVL,
                            po.EV_LVL_ID,
                            an.EV_LVL_PositedAt,
                            an.EV_LVL_Positor,
                            an.EV_LVL_Reliability,
                            an.EV_LVL_Assertion,
                            po.EV_LVL_EV_ID,
                            po.EV_LVL_PLV_ID,
                            po.EV_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.EV_LVL_ID, an.EV_LVL_Positor
                                ORDER BY an.EV_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            attributes.EV_LVL_Händelse_Level_Posit po
                        JOIN
                            attributes.EV_LVL_Händelse_Level_Annex an
                        ON
                            an.EV_LVL_ID = po.EV_LVL_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.EV_LVL_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LVL"
        ON
            "LVL".EV_LVL_EV_ID = "EV".EV_ID
        AND
            "LVL".EV_LVL_Positor = timepoints.inspectedPositor
        AND
            "LVL".EV_LVL_Assertion = '+'
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
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_partner_AC_with_ONG_currently_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently_Posit (
            AC_partner_AC_with_ONG_currently_ID number(10) default ties.AC_partner_AC_with_ONG_currently_Posit_ID_SEQ.nextval not null, 
            AC_ID_partner number(5) not null, 
            AC_ID_with number(5) not null, 
            ONG_ID_currently number(3) not null,
            AC_partner_AC_with_ONG_currently_ChangedAt timestamp not null,
            constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
                AC_ID_partner
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
                AC_ID_with
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
                ONG_ID_currently
            ) references knots.ONG_Pågående(ONG_ID),
            constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
                AC_ID_partner,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
                AC_ID_with,
                AC_partner_AC_with_ONG_currently_ChangedAt
            ),
            constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
                AC_partner_AC_with_ONG_currently_ID
            ),
            constraint uqAC_partner_AC_with_ONG_currently unique (
                AC_partner_AC_with_ONG_currently_ChangedAt,
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_partner_AC_with_ONG_currently_Annex (
            AC_partner_AC_with_ONG_currently_ID number(10) not null,
            AC_partner_AC_with_ONG_currently_PositedAt timestamp not null,
            AC_partner_AC_with_ONG_currently_Positor number(3) not null,
            AC_partner_AC_with_ONG_currently_Reliability number(5,2) not null,
            AC_partner_AC_with_ONG_currently_Assertion char(1) generated always as (
                case
                    when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
                    when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
            constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
                AC_partner_AC_with_ONG_currently_ID
            ) references ties.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID),
            constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
                AC_partner_AC_with_ONG_currently_ID,
                AC_partner_AC_with_ONG_currently_Positor,
                AC_partner_AC_with_ONG_currently_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_subset_PN_of_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_subset_PN_of_Posit (
            AC_subset_PN_of_ID number(10) default ties.AC_subset_PN_of_Posit_ID_SEQ.nextval not null, 
            AC_ID_subset number(5) not null, 
            PN_ID_of number(19) not null, 
            constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
                AC_ID_subset
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
                PN_ID_of
            ) references anchors.PN_Person(PN_ID),
            constraint AC_subset_PN_of_Posit_uqAC_subset unique (
                AC_ID_subset
            ),
            constraint AC_subset_PN_of_Posit_uqPN_of unique (
                PN_ID_of
            ),
            constraint pkAC_subset_PN_of_Posit primary key (
                AC_subset_PN_of_ID
            ),
            constraint uqAC_subset_PN_of unique (
                AC_ID_subset,
                PN_ID_of
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_subset_PN_of_Annex (
            AC_subset_PN_of_ID number(10) not null,
            AC_subset_PN_of_PositedAt timestamp not null,
            AC_subset_PN_of_Positor number(3) not null,
            AC_subset_PN_of_Reliability number(5,2) not null,
            AC_subset_PN_of_Assertion char(1) generated always as (
                case
                    when AC_subset_PN_of_Reliability > 0 then '+'
                    when AC_subset_PN_of_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_subset_PN_of number(10) not null,
            constraint fkAC_subset_PN_of_Annex foreign key (
                AC_subset_PN_of_ID
            ) references ties.AC_subset_PN_of_Posit(AC_subset_PN_of_ID),
            constraint pkAC_subset_PN_of_Annex primary key (
                AC_subset_PN_of_ID,
                AC_subset_PN_of_Positor,
                AC_subset_PN_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.EV_in_AC_rollsattes_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_rollsattes_Posit (
            EV_in_AC_rollsattes_ID number(10) default ties.EV_in_AC_rollsattes_Posit_ID_SEQ.nextval not null, 
            EV_ID_in number(12,0) not null, 
            AC_ID_rollsattes number(5) not null, 
            constraint EV_in_AC_rollsattes_Posit_fkEV_in foreign key (
                EV_ID_in
            ) references nexuses.EV_Händelse(EV_ID),
            constraint EV_in_AC_rollsattes_Posit_fkAC_rollsattes foreign key (
                AC_ID_rollsattes
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint pkEV_in_AC_rollsattes_Posit primary key (
                EV_in_AC_rollsattes_ID
            ),
            constraint uqEV_in_AC_rollsattes unique (
                EV_ID_in,
                AC_ID_rollsattes
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.EV_in_AC_rollsattes_Annex (
            EV_in_AC_rollsattes_ID number(10) not null,
            EV_in_AC_rollsattes_PositedAt timestamp not null,
            EV_in_AC_rollsattes_Positor number(3) not null,
            EV_in_AC_rollsattes_Reliability number(5,2) not null,
            EV_in_AC_rollsattes_Assertion char(1) generated always as (
                case
                    when EV_in_AC_rollsattes_Reliability > 0 then '+'
                    when EV_in_AC_rollsattes_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_EV_in_AC_rollsattes number(10) not null,
            constraint fkEV_in_AC_rollsattes_Annex foreign key (
                EV_in_AC_rollsattes_ID
            ) references ties.EV_in_AC_rollsattes_Posit(EV_in_AC_rollsattes_ID),
            constraint pkEV_in_AC_rollsattes_Annex primary key (
                EV_in_AC_rollsattes_ID,
                EV_in_AC_rollsattes_Positor,
                EV_in_AC_rollsattes_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_deltar_PR_in_RAT_fick_Posit (
            AC_deltar_PR_in_RAT_fick_ID number(10) default ties.AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ.nextval not null, 
            AC_ID_deltar number(5) not null, 
            PR_ID_in number(19) not null, 
            RAT_ID_fick number(3) not null,
            AC_deltar_PR_in_RAT_fick_ChangedAt timestamp not null,
            constraint AC_deltar_PR_in_RAT_fick_Posit_fkAC_deltar foreign key (
                AC_ID_deltar
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_deltar_PR_in_RAT_fick_Posit_fkPR_in foreign key (
                PR_ID_in
            ) references anchors.PR_Föreställning(PR_ID),
            constraint AC_deltar_PR_in_RAT_fick_Posit_fkRAT_fick foreign key (
                RAT_ID_fick
            ) references knots.RAT_Betyg(RAT_ID),
            constraint pkAC_deltar_PR_in_RAT_fick_Posit primary key (
                AC_deltar_PR_in_RAT_fick_ID
            ),
            constraint uqAC_deltar_PR_in_RAT_fick unique (
                AC_ID_deltar,
                PR_ID_in,
                AC_deltar_PR_in_RAT_fick_ChangedAt,
                RAT_ID_fick
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_deltar_PR_in_RAT_fick_Annex (
            AC_deltar_PR_in_RAT_fick_ID number(10) not null,
            AC_deltar_PR_in_RAT_fick_PositedAt timestamp not null,
            AC_deltar_PR_in_RAT_fick_Positor number(3) not null,
            AC_deltar_PR_in_RAT_fick_Reliability number(5,2) not null,
            AC_deltar_PR_in_RAT_fick_Assertion char(1) generated always as (
                case
                    when AC_deltar_PR_in_RAT_fick_Reliability > 0 then '+'
                    when AC_deltar_PR_in_RAT_fick_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_deltar_PR_in_RAT_fick number(10) not null,
            constraint fkAC_deltar_PR_in_RAT_fick_Annex foreign key (
                AC_deltar_PR_in_RAT_fick_ID
            ) references ties.AC_deltar_PR_in_RAT_fick_Posit(AC_deltar_PR_in_RAT_fick_ID),
            constraint pkAC_deltar_PR_in_RAT_fick_Annex primary key (
                AC_deltar_PR_in_RAT_fick_ID,
                AC_deltar_PR_in_RAT_fick_Positor,
                AC_deltar_PR_in_RAT_fick_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.ST_at_PR_spelas_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_spelas_Posit (
            ST_at_PR_spelas_ID number(10) default ties.ST_at_PR_spelas_Posit_ID_SEQ.nextval not null, 
            ST_ID_at number(10) not null, 
            PR_ID_spelas number(19) not null, 
            ST_at_PR_spelas_ChangedAt timestamp not null,
            constraint ST_at_PR_spelas_Posit_fkST_at foreign key (
                ST_ID_at
            ) references anchors.ST_Scen(ST_ID),
            constraint ST_at_PR_spelas_Posit_fkPR_spelas foreign key (
                PR_ID_spelas
            ) references anchors.PR_Föreställning(PR_ID),
            constraint pkST_at_PR_spelas_Posit primary key (
                ST_at_PR_spelas_ID
            ),
            constraint uqST_at_PR_spelas unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.ST_at_PR_spelas_Annex (
            ST_at_PR_spelas_ID number(10) not null,
            ST_at_PR_spelas_PositedAt timestamp not null,
            ST_at_PR_spelas_Positor number(3) not null,
            ST_at_PR_spelas_Reliability number(5,2) not null,
            ST_at_PR_spelas_Assertion char(1) generated always as (
                case
                    when ST_at_PR_spelas_Reliability > 0 then '+'
                    when ST_at_PR_spelas_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_ST_at_PR_spelas number(10) not null,
            constraint fkST_at_PR_spelas_Annex foreign key (
                ST_at_PR_spelas_ID
            ) references ties.ST_at_PR_spelas_Posit(ST_at_PR_spelas_ID),
            constraint pkST_at_PR_spelas_Annex primary key (
                ST_at_PR_spelas_ID,
                ST_at_PR_spelas_Positor,
                ST_at_PR_spelas_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_förälder_AC_barn_PAT_har_Posit (
            AC_förälder_AC_barn_PAT_har_ID number(10) default ties.AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ.nextval not null, 
            AC_ID_förälder number(5) not null, 
            AC_ID_barn number(5) not null, 
            PAT_ID_har number(3) not null,
            constraint AC_förälder_AC_barn_PAT_har_Posit_fkAC_förälder foreign key (
                AC_ID_förälder
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_förälder_AC_barn_PAT_har_Posit_fkAC_barn foreign key (
                AC_ID_barn
            ) references anchors.AC_Skådespelare(AC_ID),
            constraint AC_förälder_AC_barn_PAT_har_Posit_fkPAT_har foreign key (
                PAT_ID_har
            ) references knots.PAT_Föräldratyp(PAT_ID),
            constraint pkAC_förälder_AC_barn_PAT_har_Posit primary key (
                AC_förälder_AC_barn_PAT_har_ID
            ),
            constraint uqAC_förälder_AC_barn_PAT_har unique (
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.AC_förälder_AC_barn_PAT_har_Annex (
            AC_förälder_AC_barn_PAT_har_ID number(10) not null,
            AC_förälder_AC_barn_PAT_har_PositedAt timestamp not null,
            AC_förälder_AC_barn_PAT_har_Positor number(3) not null,
            AC_förälder_AC_barn_PAT_har_Reliability number(5,2) not null,
            AC_förälder_AC_barn_PAT_har_Assertion char(1) generated always as (
                case
                    when AC_förälder_AC_barn_PAT_har_Reliability > 0 then '+'
                    when AC_förälder_AC_barn_PAT_har_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_AC_förälder_AC_barn_PAT_har number(10) not null,
            constraint fkAC_förälder_AC_barn_PAT_har_Annex foreign key (
                AC_förälder_AC_barn_PAT_har_ID
            ) references ties.AC_förälder_AC_barn_PAT_har_Posit(AC_förälder_AC_barn_PAT_har_ID),
            constraint pkAC_förälder_AC_barn_PAT_har_Annex primary key (
                AC_förälder_AC_barn_PAT_har_ID,
                AC_förälder_AC_barn_PAT_har_Positor,
                AC_förälder_AC_barn_PAT_har_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[CREATE SEQUENCE ties.PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ START WITH 1 INCREMENT BY 1]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_innehåll_ST_plats_EV_of_Posit (
            PR_innehåll_ST_plats_EV_of_ID number(10) default ties.PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ.nextval not null, 
            PR_ID_innehåll number(19) not null, 
            ST_ID_plats number(10) not null, 
            EV_ID_of number(12,0) not null, 
            PR_innehåll_ST_plats_EV_of_ChangedAt timestamp not null,
            constraint PR_innehåll_ST_plats_EV_of_Posit_fkPR_innehåll foreign key (
                PR_ID_innehåll
            ) references anchors.PR_Föreställning(PR_ID),
            constraint PR_innehåll_ST_plats_EV_of_Posit_fkST_plats foreign key (
                ST_ID_plats
            ) references anchors.ST_Scen(ST_ID),
            constraint PR_innehåll_ST_plats_EV_of_Posit_fkEV_of foreign key (
                EV_ID_of
            ) references nexuses.EV_Händelse(EV_ID),
            constraint PR_innehåll_ST_plats_EV_of_Posit_uqPR_innehåll unique (
                PR_ID_innehåll,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            ),
            constraint PR_innehåll_ST_plats_EV_of_Posit_uqST_plats unique (
                ST_ID_plats,
                PR_innehåll_ST_plats_EV_of_ChangedAt
            ),
            constraint pkPR_innehåll_ST_plats_EV_of_Posit primary key (
                PR_innehåll_ST_plats_EV_of_ID
            ),
            constraint uqPR_innehåll_ST_plats_EV_of unique (
                PR_innehåll_ST_plats_EV_of_ChangedAt,
                PR_ID_innehåll,
                ST_ID_plats,
                EV_ID_of
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE ties.PR_innehåll_ST_plats_EV_of_Annex (
            PR_innehåll_ST_plats_EV_of_ID number(10) not null,
            PR_innehåll_ST_plats_EV_of_PositedAt timestamp not null,
            PR_innehåll_ST_plats_EV_of_Positor number(3) not null,
            PR_innehåll_ST_plats_EV_of_Reliability number(5,2) not null,
            PR_innehåll_ST_plats_EV_of_Assertion char(1) generated always as (
                case
                    when PR_innehåll_ST_plats_EV_of_Reliability > 0 then '+'
                    when PR_innehåll_ST_plats_EV_of_Reliability = 0 then '?'
                    else '-'
                end
            ) virtual,
            Metadata_PR_innehåll_ST_plats_EV_of number(10) not null,
            constraint fkPR_innehåll_ST_plats_EV_of_Annex foreign key (
                PR_innehåll_ST_plats_EV_of_ID
            ) references ties.PR_innehåll_ST_plats_EV_of_Posit(PR_innehåll_ST_plats_EV_of_ID),
            constraint pkPR_innehåll_ST_plats_EV_of_Annex primary key (
                PR_innehåll_ST_plats_EV_of_ID,
                PR_innehåll_ST_plats_EV_of_Positor,
                PR_innehåll_ST_plats_EV_of_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW ties.AC_partner_AC_with_ONG_currently AS
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Positor,
    a.AC_partner_AC_with_ONG_currently_Reliability,
    a.AC_partner_AC_with_ONG_currently_Assertion
FROM
    ties.AC_partner_AC_with_ONG_currently_Posit p
JOIN
    ties.AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
;
CREATE OR REPLACE VIEW ties.AC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion
FROM
    ties.AC_subset_PN_of_Posit p
JOIN
    ties.AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
;
CREATE OR REPLACE VIEW ties.EV_in_AC_rollsattes AS
SELECT
    a.Metadata_EV_in_AC_rollsattes,
    p.EV_in_AC_rollsattes_ID,
    p.EV_ID_in,
    p.AC_ID_rollsattes,
    a.EV_in_AC_rollsattes_PositedAt,
    a.EV_in_AC_rollsattes_Positor,
    a.EV_in_AC_rollsattes_Reliability,
    a.EV_in_AC_rollsattes_Assertion
FROM
    ties.EV_in_AC_rollsattes_Posit p
JOIN
    ties.EV_in_AC_rollsattes_Annex a
ON
    a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
;
CREATE OR REPLACE VIEW ties.AC_deltar_PR_in_RAT_fick AS
SELECT
    a.Metadata_AC_deltar_PR_in_RAT_fick,
    p.AC_deltar_PR_in_RAT_fick_ID,
    p.AC_ID_deltar,
    p.PR_ID_in,
    p.RAT_ID_fick,
    p.AC_deltar_PR_in_RAT_fick_ChangedAt,
    a.AC_deltar_PR_in_RAT_fick_PositedAt,
    a.AC_deltar_PR_in_RAT_fick_Positor,
    a.AC_deltar_PR_in_RAT_fick_Reliability,
    a.AC_deltar_PR_in_RAT_fick_Assertion
FROM
    ties.AC_deltar_PR_in_RAT_fick_Posit p
JOIN
    ties.AC_deltar_PR_in_RAT_fick_Annex a
ON
    a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
;
CREATE OR REPLACE VIEW ties.ST_at_PR_spelas AS
SELECT
    a.Metadata_ST_at_PR_spelas,
    p.ST_at_PR_spelas_ID,
    p.ST_ID_at,
    p.PR_ID_spelas,
    p.ST_at_PR_spelas_ChangedAt,
    a.ST_at_PR_spelas_PositedAt,
    a.ST_at_PR_spelas_Positor,
    a.ST_at_PR_spelas_Reliability,
    a.ST_at_PR_spelas_Assertion
FROM
    ties.ST_at_PR_spelas_Posit p
JOIN
    ties.ST_at_PR_spelas_Annex a
ON
    a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
;
CREATE OR REPLACE VIEW ties.AC_förälder_AC_barn_PAT_har AS
SELECT
    a.Metadata_AC_förälder_AC_barn_PAT_har,
    p.AC_förälder_AC_barn_PAT_har_ID,
    p.AC_ID_förälder,
    p.AC_ID_barn,
    p.PAT_ID_har,
    a.AC_förälder_AC_barn_PAT_har_PositedAt,
    a.AC_förälder_AC_barn_PAT_har_Positor,
    a.AC_förälder_AC_barn_PAT_har_Reliability,
    a.AC_förälder_AC_barn_PAT_har_Assertion
FROM
    ties.AC_förälder_AC_barn_PAT_har_Posit p
JOIN
    ties.AC_förälder_AC_barn_PAT_har_Annex a
ON
    a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
;
CREATE OR REPLACE VIEW ties.PR_innehåll_ST_plats_EV_of AS
SELECT
    a.Metadata_PR_innehåll_ST_plats_EV_of,
    p.PR_innehåll_ST_plats_EV_of_ID,
    p.PR_ID_innehåll,
    p.ST_ID_plats,
    p.EV_ID_of,
    p.PR_innehåll_ST_plats_EV_of_ChangedAt,
    a.PR_innehåll_ST_plats_EV_of_PositedAt,
    a.PR_innehåll_ST_plats_EV_of_Positor,
    a.PR_innehåll_ST_plats_EV_of_Reliability,
    a.PR_innehåll_ST_plats_EV_of_Assertion
FROM
    ties.PR_innehåll_ST_plats_EV_of_Posit p
JOIN
    ties.PR_innehåll_ST_plats_EV_of_Annex a
ON
    a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null. They are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): functions that return
-- the text of a query, in which the parameters stand for the values given, called in the FROM clause like a table.
-- The macros do not call each other, they do what the others do in their own query.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        FROM
            ties.AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        FROM
            ties.AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
    ]';
END fAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_Reliability,
            AC_partner_AC_with_ONG_currently_Assertion
        FROM
            ties.AC_partner_AC_with_ONG_currently_Annex
        WHERE
            AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_Reliability,
            AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Positor,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                a.AC_partner_AC_with_ONG_currently_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID,
                        a.AC_partner_AC_with_ONG_currently_Positor
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                a.AC_partner_AC_with_ONG_currently_Positor = COALESCE(positor, a.AC_partner_AC_with_ONG_currently_Positor)
            WHERE
                p.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_partner_AC_with_ONG_currently;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_Reliability,
            AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Positor,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                a.AC_partner_AC_with_ONG_currently_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID,
                        a.AC_partner_AC_with_ONG_currently_Positor
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                a.AC_partner_AC_with_ONG_currently_Positor = COALESCE(positor, a.AC_partner_AC_with_ONG_currently_Positor)
            WHERE
                p.AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_partner_AC_with_ONG_currently;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_Reliability,
            AC_subset_PN_of_Assertion
        FROM
            ties.AC_subset_PN_of_Annex
        WHERE
            AC_subset_PN_of_PositedAt <= positingTimepoint
    ]';
END rAC_subset_PN_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_Reliability,
            AC_subset_PN_of_Assertion
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Positor,
                a.AC_subset_PN_of_Reliability,
                a.AC_subset_PN_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID,
                        a.AC_subset_PN_of_Positor
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Posit p
            JOIN
                ties.AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                a.AC_subset_PN_of_Positor = COALESCE(positor, a.AC_subset_PN_of_Positor)
            WHERE
                a.AC_subset_PN_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_subset_PN_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_Reliability,
            AC_subset_PN_of_Assertion
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Positor,
                a.AC_subset_PN_of_Reliability,
                a.AC_subset_PN_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID,
                        a.AC_subset_PN_of_Positor
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Posit p
            JOIN
                ties.AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                a.AC_subset_PN_of_Positor = COALESCE(positor, a.AC_subset_PN_of_Positor)
            WHERE
                a.AC_subset_PN_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_subset_PN_of;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_rollsattes_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_Reliability,
            EV_in_AC_rollsattes_Assertion
        FROM
            ties.EV_in_AC_rollsattes_Annex
        WHERE
            EV_in_AC_rollsattes_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_rollsattes_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_rollsattes (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_ID_in,
            AC_ID_rollsattes,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_Reliability,
            EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                a.Metadata_EV_in_AC_rollsattes,
                p.EV_in_AC_rollsattes_ID,
                p.EV_ID_in,
                p.AC_ID_rollsattes,
                a.EV_in_AC_rollsattes_PositedAt,
                a.EV_in_AC_rollsattes_Positor,
                a.EV_in_AC_rollsattes_Reliability,
                a.EV_in_AC_rollsattes_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_rollsattes_ID,
                        a.EV_in_AC_rollsattes_Positor
                    ORDER BY
                        a.EV_in_AC_rollsattes_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_rollsattes_Posit p
            JOIN
                ties.EV_in_AC_rollsattes_Annex a
            ON
                a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
            AND
                a.EV_in_AC_rollsattes_Positor = COALESCE(positor, a.EV_in_AC_rollsattes_Positor)
            WHERE
                a.EV_in_AC_rollsattes_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_in_AC_rollsattes;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_rollsattes (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_ID_in,
            AC_ID_rollsattes,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_Reliability,
            EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                a.Metadata_EV_in_AC_rollsattes,
                p.EV_in_AC_rollsattes_ID,
                p.EV_ID_in,
                p.AC_ID_rollsattes,
                a.EV_in_AC_rollsattes_PositedAt,
                a.EV_in_AC_rollsattes_Positor,
                a.EV_in_AC_rollsattes_Reliability,
                a.EV_in_AC_rollsattes_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_rollsattes_ID,
                        a.EV_in_AC_rollsattes_Positor
                    ORDER BY
                        a.EV_in_AC_rollsattes_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_rollsattes_Posit p
            JOIN
                ties.EV_in_AC_rollsattes_Annex a
            ON
                a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
            AND
                a.EV_in_AC_rollsattes_Positor = COALESCE(positor, a.EV_in_AC_rollsattes_Positor)
            WHERE
                a.EV_in_AC_rollsattes_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_in_AC_rollsattes;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_deltar_PR_in_RAT_fick_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit
        WHERE
            AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
    ]';
END rAC_deltar_PR_in_RAT_fick_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_deltar_PR_in_RAT_fick_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit
        WHERE
            AC_deltar_PR_in_RAT_fick_ChangedAt > changingTimepoint
    ]';
END fAC_deltar_PR_in_RAT_fick_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_deltar_PR_in_RAT_fick_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_Reliability,
            AC_deltar_PR_in_RAT_fick_Assertion
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Annex
        WHERE
            AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint
    ]';
END rAC_deltar_PR_in_RAT_fick_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_deltar_PR_in_RAT_fick (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_Reliability,
            AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                a.Metadata_AC_deltar_PR_in_RAT_fick,
                p.AC_deltar_PR_in_RAT_fick_ID,
                p.AC_ID_deltar,
                p.PR_ID_in,
                p.RAT_ID_fick,
                p.AC_deltar_PR_in_RAT_fick_ChangedAt,
                a.AC_deltar_PR_in_RAT_fick_PositedAt,
                a.AC_deltar_PR_in_RAT_fick_Positor,
                a.AC_deltar_PR_in_RAT_fick_Reliability,
                a.AC_deltar_PR_in_RAT_fick_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_deltar_PR_in_RAT_fick_ID,
                        a.AC_deltar_PR_in_RAT_fick_Positor
                    ORDER BY
                        a.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_deltar_PR_in_RAT_fick_Posit p
            JOIN
                ties.AC_deltar_PR_in_RAT_fick_Annex a
            ON
                a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
            AND
                a.AC_deltar_PR_in_RAT_fick_Positor = COALESCE(positor, a.AC_deltar_PR_in_RAT_fick_Positor)
            WHERE
                p.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
            AND
                a.AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_deltar_PR_in_RAT_fick;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_deltar_PR_in_RAT_fick (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_Reliability,
            AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                a.Metadata_AC_deltar_PR_in_RAT_fick,
                p.AC_deltar_PR_in_RAT_fick_ID,
                p.AC_ID_deltar,
                p.PR_ID_in,
                p.RAT_ID_fick,
                p.AC_deltar_PR_in_RAT_fick_ChangedAt,
                a.AC_deltar_PR_in_RAT_fick_PositedAt,
                a.AC_deltar_PR_in_RAT_fick_Positor,
                a.AC_deltar_PR_in_RAT_fick_Reliability,
                a.AC_deltar_PR_in_RAT_fick_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_deltar_PR_in_RAT_fick_ID,
                        a.AC_deltar_PR_in_RAT_fick_Positor
                    ORDER BY
                        a.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_deltar_PR_in_RAT_fick_Posit p
            JOIN
                ties.AC_deltar_PR_in_RAT_fick_Annex a
            ON
                a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
            AND
                a.AC_deltar_PR_in_RAT_fick_Positor = COALESCE(positor, a.AC_deltar_PR_in_RAT_fick_Positor)
            WHERE
                p.AC_deltar_PR_in_RAT_fick_ChangedAt > changingTimepoint
            AND
                a.AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_deltar_PR_in_RAT_fick;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_spelas_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt
        FROM
            ties.ST_at_PR_spelas_Posit
        WHERE
            ST_at_PR_spelas_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_spelas_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_spelas_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt
        FROM
            ties.ST_at_PR_spelas_Posit
        WHERE
            ST_at_PR_spelas_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_spelas_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_spelas_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_Reliability,
            ST_at_PR_spelas_Assertion
        FROM
            ties.ST_at_PR_spelas_Annex
        WHERE
            ST_at_PR_spelas_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_spelas_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_spelas (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_Reliability,
            ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                a.Metadata_ST_at_PR_spelas,
                p.ST_at_PR_spelas_ID,
                p.ST_ID_at,
                p.PR_ID_spelas,
                p.ST_at_PR_spelas_ChangedAt,
                a.ST_at_PR_spelas_PositedAt,
                a.ST_at_PR_spelas_Positor,
                a.ST_at_PR_spelas_Reliability,
                a.ST_at_PR_spelas_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_spelas_ID,
                        a.ST_at_PR_spelas_Positor
                    ORDER BY
                        a.ST_at_PR_spelas_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_spelas_Posit p
            JOIN
                ties.ST_at_PR_spelas_Annex a
            ON
                a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
            AND
                a.ST_at_PR_spelas_Positor = COALESCE(positor, a.ST_at_PR_spelas_Positor)
            WHERE
                p.ST_at_PR_spelas_ChangedAt <= changingTimepoint
            AND
                a.ST_at_PR_spelas_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_at_PR_spelas;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_spelas (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_Reliability,
            ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                a.Metadata_ST_at_PR_spelas,
                p.ST_at_PR_spelas_ID,
                p.ST_ID_at,
                p.PR_ID_spelas,
                p.ST_at_PR_spelas_ChangedAt,
                a.ST_at_PR_spelas_PositedAt,
                a.ST_at_PR_spelas_Positor,
                a.ST_at_PR_spelas_Reliability,
                a.ST_at_PR_spelas_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_spelas_ID,
                        a.ST_at_PR_spelas_Positor
                    ORDER BY
                        a.ST_at_PR_spelas_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_spelas_Posit p
            JOIN
                ties.ST_at_PR_spelas_Annex a
            ON
                a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
            AND
                a.ST_at_PR_spelas_Positor = COALESCE(positor, a.ST_at_PR_spelas_Positor)
            WHERE
                p.ST_at_PR_spelas_ChangedAt > changingTimepoint
            AND
                a.ST_at_PR_spelas_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_at_PR_spelas;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_förälder_AC_barn_PAT_har_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_Reliability,
            AC_förälder_AC_barn_PAT_har_Assertion
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Annex
        WHERE
            AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint
    ]';
END rAC_förälder_AC_barn_PAT_har_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_förälder_AC_barn_PAT_har (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_ID_förälder,
            AC_ID_barn,
            PAT_ID_har,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_Reliability,
            AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                a.Metadata_AC_förälder_AC_barn_PAT_har,
                p.AC_förälder_AC_barn_PAT_har_ID,
                p.AC_ID_förälder,
                p.AC_ID_barn,
                p.PAT_ID_har,
                a.AC_förälder_AC_barn_PAT_har_PositedAt,
                a.AC_förälder_AC_barn_PAT_har_Positor,
                a.AC_förälder_AC_barn_PAT_har_Reliability,
                a.AC_förälder_AC_barn_PAT_har_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_förälder_AC_barn_PAT_har_ID,
                        a.AC_förälder_AC_barn_PAT_har_Positor
                    ORDER BY
                        a.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_förälder_AC_barn_PAT_har_Posit p
            JOIN
                ties.AC_förälder_AC_barn_PAT_har_Annex a
            ON
                a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
            AND
                a.AC_förälder_AC_barn_PAT_har_Positor = COALESCE(positor, a.AC_förälder_AC_barn_PAT_har_Positor)
            WHERE
                a.AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_förälder_AC_barn_PAT_har;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_förälder_AC_barn_PAT_har (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_ID_förälder,
            AC_ID_barn,
            PAT_ID_har,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_Reliability,
            AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                a.Metadata_AC_förälder_AC_barn_PAT_har,
                p.AC_förälder_AC_barn_PAT_har_ID,
                p.AC_ID_förälder,
                p.AC_ID_barn,
                p.PAT_ID_har,
                a.AC_förälder_AC_barn_PAT_har_PositedAt,
                a.AC_förälder_AC_barn_PAT_har_Positor,
                a.AC_förälder_AC_barn_PAT_har_Reliability,
                a.AC_förälder_AC_barn_PAT_har_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_förälder_AC_barn_PAT_har_ID,
                        a.AC_förälder_AC_barn_PAT_har_Positor
                    ORDER BY
                        a.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_förälder_AC_barn_PAT_har_Posit p
            JOIN
                ties.AC_förälder_AC_barn_PAT_har_Annex a
            ON
                a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
            AND
                a.AC_förälder_AC_barn_PAT_har_Positor = COALESCE(positor, a.AC_förälder_AC_barn_PAT_har_Positor)
            WHERE
                a.AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_förälder_AC_barn_PAT_har;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_innehåll_ST_plats_EV_of_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Posit
        WHERE
            PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
    ]';
END rPR_innehåll_ST_plats_EV_of_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_innehåll_ST_plats_EV_of_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Posit
        WHERE
            PR_innehåll_ST_plats_EV_of_ChangedAt > changingTimepoint
    ]';
END fPR_innehåll_ST_plats_EV_of_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_innehåll_ST_plats_EV_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_Reliability,
            PR_innehåll_ST_plats_EV_of_Assertion
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Annex
        WHERE
            PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_innehåll_ST_plats_EV_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_innehåll_ST_plats_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_Reliability,
            PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                a.Metadata_PR_innehåll_ST_plats_EV_of,
                p.PR_innehåll_ST_plats_EV_of_ID,
                p.PR_ID_innehåll,
                p.ST_ID_plats,
                p.EV_ID_of,
                p.PR_innehåll_ST_plats_EV_of_ChangedAt,
                a.PR_innehåll_ST_plats_EV_of_PositedAt,
                a.PR_innehåll_ST_plats_EV_of_Positor,
                a.PR_innehåll_ST_plats_EV_of_Reliability,
                a.PR_innehåll_ST_plats_EV_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_innehåll_ST_plats_EV_of_ID,
                        a.PR_innehåll_ST_plats_EV_of_Positor
                    ORDER BY
                        a.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_innehåll_ST_plats_EV_of_Posit p
            JOIN
                ties.PR_innehåll_ST_plats_EV_of_Annex a
            ON
                a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
            AND
                a.PR_innehåll_ST_plats_EV_of_Positor = COALESCE(positor, a.PR_innehåll_ST_plats_EV_of_Positor)
            WHERE
                p.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
            AND
                a.PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_innehåll_ST_plats_EV_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_innehåll_ST_plats_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_Reliability,
            PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                a.Metadata_PR_innehåll_ST_plats_EV_of,
                p.PR_innehåll_ST_plats_EV_of_ID,
                p.PR_ID_innehåll,
                p.ST_ID_plats,
                p.EV_ID_of,
                p.PR_innehåll_ST_plats_EV_of_ChangedAt,
                a.PR_innehåll_ST_plats_EV_of_PositedAt,
                a.PR_innehåll_ST_plats_EV_of_Positor,
                a.PR_innehåll_ST_plats_EV_of_Reliability,
                a.PR_innehåll_ST_plats_EV_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_innehåll_ST_plats_EV_of_ID,
                        a.PR_innehåll_ST_plats_EV_of_Positor
                    ORDER BY
                        a.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_innehåll_ST_plats_EV_of_Posit p
            JOIN
                ties.PR_innehåll_ST_plats_EV_of_Annex a
            ON
                a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
            AND
                a.PR_innehåll_ST_plats_EV_of_Positor = COALESCE(positor, a.PR_innehåll_ST_plats_EV_of_Positor)
            WHERE
                p.PR_innehåll_ST_plats_EV_of_ChangedAt > changingTimepoint
            AND
                a.PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_innehåll_ST_plats_EV_of;
/
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_wasPlayed(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the
-- tie joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Positor,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Assertion <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Positor,
                            r.AC_ID_partner,
                            r.AC_ID_with,
                            r.ONG_ID_currently
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_partner_AC_with_ONG_currently,
                        po.AC_partner_AC_with_ONG_currently_ID,
                        po.AC_ID_partner,
                        po.AC_ID_with,
                        po.ONG_ID_currently,
                        po.AC_partner_AC_with_ONG_currently_ChangedAt,
                        an.AC_partner_AC_with_ONG_currently_PositedAt,
                        an.AC_partner_AC_with_ONG_currently_Positor,
                        an.AC_partner_AC_with_ONG_currently_Reliability,
                        an.AC_partner_AC_with_ONG_currently_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Positor
                            ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_partner_AC_with_ONG_currently_Posit po
                    JOIN
                        ties.AC_partner_AC_with_ONG_currently_Annex an
                    ON
                        an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    WHERE
                        po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Assertion = COALESCE(assertion, s.AC_partner_AC_with_ONG_currently_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.AC_partner_AC_with_ONG_currently_Positor = forPositor
        AND
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END tAC_partner_AC_with_ONG_currently;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Positor,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Assertion <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Positor,
                            r.AC_ID_partner,
                            r.AC_ID_with,
                            r.ONG_ID_currently
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_partner_AC_with_ONG_currently,
                        po.AC_partner_AC_with_ONG_currently_ID,
                        po.AC_ID_partner,
                        po.AC_ID_with,
                        po.ONG_ID_currently,
                        po.AC_partner_AC_with_ONG_currently_ChangedAt,
                        an.AC_partner_AC_with_ONG_currently_PositedAt,
                        an.AC_partner_AC_with_ONG_currently_Positor,
                        an.AC_partner_AC_with_ONG_currently_Reliability,
                        an.AC_partner_AC_with_ONG_currently_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Positor
                            ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_partner_AC_with_ONG_currently_Posit po
                    JOIN
                        ties.AC_partner_AC_with_ONG_currently_Annex an
                    ON
                        an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    WHERE
                        po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Assertion = '+'
            AND
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_partner_AC_with_ONG_currently_Positor
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END pAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            q.Positor,
            q.inspectedTimepoint,
            q.Metadata_AC_partner_AC_with_ONG_currently,
            q.AC_ID_partner,
            q.AC_ID_with,
            q.currently_ONG_Pågående,
            q.currently_Metadata_ONG,
            q.ONG_ID_currently,
            q.AC_partner_AC_with_ONG_currently_ChangedAt,
            q.AC_partner_AC_with_ONG_currently_PositedAt,
            q.AC_partner_AC_with_ONG_currently_Positor,
            q.AC_partner_AC_with_ONG_currently_Reliability,
            q.AC_partner_AC_with_ONG_currently_Assertion
        FROM (
        SELECT
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Positor,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_partner_AC_with_ONG_currently_Assertion,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_partner
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Reliability DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_partner,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_with
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Reliability DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_with
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_partner_AC_with_ONG_currently_Positor AS inspectedPositor,
                CAST(h.AC_partner_AC_with_ONG_currently_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_partner_AC_with_ONG_currently h
            WHERE
                h.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_partner_AC_with_ONG_currently_Positor,
                        y.AC_ID_partner,
                        y.AC_ID_with,
                        y.ONG_ID_currently
                    ORDER BY y.AC_partner_AC_with_ONG_currently_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_partner_AC_with_ONG_currently_Positor,
                                r.AC_ID_partner,
                                r.AC_ID_with,
                                r.ONG_ID_currently,
                                r.AC_partner_AC_with_ONG_currently_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_partner_AC_with_ONG_currently_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                                r.AC_partner_AC_with_ONG_currently_Reliability DESC,
                                r.AC_partner_AC_with_ONG_currently_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_partner_AC_with_ONG_currently,
                            po.AC_partner_AC_with_ONG_currently_ID,
                            po.AC_ID_partner,
                            po.AC_ID_with,
                            po.ONG_ID_currently,
                            po.AC_partner_AC_with_ONG_currently_ChangedAt,
                            an.AC_partner_AC_with_ONG_currently_PositedAt,
                            an.AC_partner_AC_with_ONG_currently_Positor,
                            an.AC_partner_AC_with_ONG_currently_Reliability,
                            an.AC_partner_AC_with_ONG_currently_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Positor
                                ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.AC_partner_AC_with_ONG_currently_Posit po
                        JOIN
                            ties.AC_partner_AC_with_ONG_currently_Annex an
                        ON
                            an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_partner_AC_with_ONG_currently_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_partner_AC_with_ONG_currently_Positor = tp.inspectedPositor
        AND
            t.AC_partner_AC_with_ONG_currently_Assertion = '+'
        AND
            t.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        ) q
        WHERE
            q.latestPositAC_ID_partner = 1
        AND
            q.latestPositAC_ID_with = 1
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Positor,
            t.AC_subset_PN_of_Reliability,
            t.AC_subset_PN_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_subset_PN_of,
                        po.AC_subset_PN_of_ID,
                        po.AC_ID_subset,
                        po.PN_ID_of,
                        an.AC_subset_PN_of_PositedAt,
                        an.AC_subset_PN_of_Positor,
                        an.AC_subset_PN_of_Reliability,
                        an.AC_subset_PN_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Positor
                            ORDER BY an.AC_subset_PN_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_subset_PN_of_Posit po
                    JOIN
                        ties.AC_subset_PN_of_Annex an
                    ON
                        an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                    WHERE
                        an.AC_subset_PN_of_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_subset_PN_of_Assertion = COALESCE(assertion, s.AC_subset_PN_of_Assertion)
        ) t
        WHERE
            t.AC_subset_PN_of_Positor = forPositor
        AND
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END tAC_subset_PN_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Positor,
            t.AC_subset_PN_of_Reliability,
            t.AC_subset_PN_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_subset_PN_of,
                        po.AC_subset_PN_of_ID,
                        po.AC_ID_subset,
                        po.PN_ID_of,
                        an.AC_subset_PN_of_PositedAt,
                        an.AC_subset_PN_of_Positor,
                        an.AC_subset_PN_of_Reliability,
                        an.AC_subset_PN_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Positor
                            ORDER BY an.AC_subset_PN_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_subset_PN_of_Posit po
                    JOIN
                        ties.AC_subset_PN_of_Annex an
                    ON
                        an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                    WHERE
                        an.AC_subset_PN_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_subset_PN_of_Assertion = '+'
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_subset_PN_of_Positor
        WHERE
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END pAC_subset_PN_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_rollsattes (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_EV_in_AC_rollsattes,
            t.EV_ID_in,
            t.AC_ID_rollsattes,
            t.EV_in_AC_rollsattes_PositedAt,
            t.EV_in_AC_rollsattes_Positor,
            t.EV_in_AC_rollsattes_Reliability,
            t.EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_rollsattes_Positor,
                        s.EV_ID_in,
                        s.AC_ID_rollsattes
                    ORDER BY
                        s.EV_in_AC_rollsattes_PositedAt DESC,
                        s.EV_in_AC_rollsattes_Reliability DESC,
                        s.EV_in_AC_rollsattes_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_rollsattes,
                        po.EV_in_AC_rollsattes_ID,
                        po.EV_ID_in,
                        po.AC_ID_rollsattes,
                        an.EV_in_AC_rollsattes_PositedAt,
                        an.EV_in_AC_rollsattes_Positor,
                        an.EV_in_AC_rollsattes_Reliability,
                        an.EV_in_AC_rollsattes_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_rollsattes_ID, an.EV_in_AC_rollsattes_Positor
                            ORDER BY an.EV_in_AC_rollsattes_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.EV_in_AC_rollsattes_Posit po
                    JOIN
                        ties.EV_in_AC_rollsattes_Annex an
                    ON
                        an.EV_in_AC_rollsattes_ID = po.EV_in_AC_rollsattes_ID
                    WHERE
                        an.EV_in_AC_rollsattes_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.EV_in_AC_rollsattes_Assertion = COALESCE(assertion, s.EV_in_AC_rollsattes_Assertion)
        ) t
        WHERE
            t.EV_in_AC_rollsattes_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tEV_in_AC_rollsattes;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_EV_in_AC_rollsattes,
            t.EV_ID_in,
            t.AC_ID_rollsattes,
            t.EV_in_AC_rollsattes_PositedAt,
            t.EV_in_AC_rollsattes_Positor,
            t.EV_in_AC_rollsattes_Reliability,
            t.EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_rollsattes_Positor,
                        s.EV_ID_in,
                        s.AC_ID_rollsattes
                    ORDER BY
                        s.EV_in_AC_rollsattes_PositedAt DESC,
                        s.EV_in_AC_rollsattes_Reliability DESC,
                        s.EV_in_AC_rollsattes_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_rollsattes,
                        po.EV_in_AC_rollsattes_ID,
                        po.EV_ID_in,
                        po.AC_ID_rollsattes,
                        an.EV_in_AC_rollsattes_PositedAt,
                        an.EV_in_AC_rollsattes_Positor,
                        an.EV_in_AC_rollsattes_Reliability,
                        an.EV_in_AC_rollsattes_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_rollsattes_ID, an.EV_in_AC_rollsattes_Positor
                            ORDER BY an.EV_in_AC_rollsattes_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.EV_in_AC_rollsattes_Posit po
                    JOIN
                        ties.EV_in_AC_rollsattes_Annex an
                    ON
                        an.EV_in_AC_rollsattes_ID = po.EV_in_AC_rollsattes_ID
                    WHERE
                        an.EV_in_AC_rollsattes_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.EV_in_AC_rollsattes_Assertion = '+'
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.EV_in_AC_rollsattes_Positor
        WHERE
            t.latestPosit = 1
    ]';
END pEV_in_AC_rollsattes;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes
AS
SELECT
    *
FROM
    ties.pEV_in_AC_rollsattes(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes
AS
SELECT
    *
FROM
    ties.pEV_in_AC_rollsattes(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_deltar_PR_in_RAT_fick (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Positor,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_deltar_PR_in_RAT_fick_Positor,
                        s.AC_ID_deltar,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_Reliability DESC,
                        s.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_deltar_PR_in_RAT_fick_Assertion <> '?' THEN r.AC_deltar_PR_in_RAT_fick_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_deltar_PR_in_RAT_fick_Positor,
                            r.AC_ID_deltar,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_deltar_PR_in_RAT_fick,
                        po.AC_deltar_PR_in_RAT_fick_ID,
                        po.AC_ID_deltar,
                        po.PR_ID_in,
                        po.RAT_ID_fick,
                        po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                        an.AC_deltar_PR_in_RAT_fick_PositedAt,
                        an.AC_deltar_PR_in_RAT_fick_Positor,
                        an.AC_deltar_PR_in_RAT_fick_Reliability,
                        an.AC_deltar_PR_in_RAT_fick_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID, an.AC_deltar_PR_in_RAT_fick_Positor
                            ORDER BY an.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_deltar_PR_in_RAT_fick_Posit po
                    JOIN
                        ties.AC_deltar_PR_in_RAT_fick_Annex an
                    ON
                        an.AC_deltar_PR_in_RAT_fick_ID = po.AC_deltar_PR_in_RAT_fick_ID
                    WHERE
                        po.AC_deltar_PR_in_RAT_fick_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_deltar_PR_in_RAT_fick_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_deltar_PR_in_RAT_fick_Assertion = COALESCE(assertion, s.AC_deltar_PR_in_RAT_fick_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_deltar_PR_in_RAT_fick_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
        WHERE
            t.AC_deltar_PR_in_RAT_fick_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_deltar_PR_in_RAT_fick;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Positor,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_deltar_PR_in_RAT_fick_Positor,
                        s.AC_ID_deltar,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_Reliability DESC,
                        s.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_deltar_PR_in_RAT_fick_Assertion <> '?' THEN r.AC_deltar_PR_in_RAT_fick_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_deltar_PR_in_RAT_fick_Positor,
                            r.AC_ID_deltar,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_deltar_PR_in_RAT_fick,
                        po.AC_deltar_PR_in_RAT_fick_ID,
                        po.AC_ID_deltar,
                        po.PR_ID_in,
                        po.RAT_ID_fick,
                        po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                        an.AC_deltar_PR_in_RAT_fick_PositedAt,
                        an.AC_deltar_PR_in_RAT_fick_Positor,
                        an.AC_deltar_PR_in_RAT_fick_Reliability,
                        an.AC_deltar_PR_in_RAT_fick_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID, an.AC_deltar_PR_in_RAT_fick_Positor
                            ORDER BY an.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_deltar_PR_in_RAT_fick_Posit po
                    JOIN
                        ties.AC_deltar_PR_in_RAT_fick_Annex an
                    ON
                        an.AC_deltar_PR_in_RAT_fick_ID = po.AC_deltar_PR_in_RAT_fick_ID
                    WHERE
                        po.AC_deltar_PR_in_RAT_fick_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_deltar_PR_in_RAT_fick_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_deltar_PR_in_RAT_fick_Assertion = '+'
            AND
                s.AC_deltar_PR_in_RAT_fick_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_deltar_PR_in_RAT_fick_Positor
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
        WHERE
            t.latestPosit = 1
    ]';
END pAC_deltar_PR_in_RAT_fick;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick
AS
SELECT
    *
FROM
    ties.pAC_deltar_PR_in_RAT_fick(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Positor,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_deltar_PR_in_RAT_fick_Assertion
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_deltar_PR_in_RAT_fick_Positor AS inspectedPositor,
                CAST(h.AC_deltar_PR_in_RAT_fick_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_deltar_PR_in_RAT_fick h
            WHERE
                h.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_deltar_PR_in_RAT_fick_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_deltar_PR_in_RAT_fick_Positor,
                        y.AC_ID_deltar,
                        y.PR_ID_in
                    ORDER BY y.AC_deltar_PR_in_RAT_fick_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_deltar_PR_in_RAT_fick_Positor,
                                r.AC_ID_deltar,
                                r.PR_ID_in,
                                r.AC_deltar_PR_in_RAT_fick_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_deltar_PR_in_RAT_fick_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                                r.AC_deltar_PR_in_RAT_fick_Reliability DESC,
                                r.AC_deltar_PR_in_RAT_fick_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_deltar_PR_in_RAT_fick,
                            po.AC_deltar_PR_in_RAT_fick_ID,
                            po.AC_ID_deltar,
                            po.PR_ID_in,
                            po.RAT_ID_fick,
                            po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                            an.AC_deltar_PR_in_RAT_fick_PositedAt,
                            an.AC_deltar_PR_in_RAT_fick_Positor,
                            an.AC_deltar_PR_in_RAT_fick_Reliability,
                            an.AC_deltar_PR_in_RAT_fick_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID, an.AC_deltar_PR_in_RAT_fick_Positor
                                ORDER BY an.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.AC_deltar_PR_in_RAT_fick_Posit po
                        JOIN
                            ties.AC_deltar_PR_in_RAT_fick_Annex an
                        ON
                            an.AC_deltar_PR_in_RAT_fick_ID = po.AC_deltar_PR_in_RAT_fick_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_deltar_PR_in_RAT_fick_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_deltar_PR_in_RAT_fick_Positor = tp.inspectedPositor
        AND
            t.AC_deltar_PR_in_RAT_fick_Assertion = '+'
        AND
            t.AC_deltar_PR_in_RAT_fick_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
    ]';
END dAC_deltar_PR_in_RAT_fick;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_spelas (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_ST_at_PR_spelas,
            t.ST_ID_at,
            t.PR_ID_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Positor,
            t.ST_at_PR_spelas_Reliability,
            t.ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_spelas_Positor,
                        s.ST_ID_at,
                        s.PR_ID_spelas
                    ORDER BY
                        s.ST_at_PR_spelas_ChangedAt DESC,
                        s.ST_at_PR_spelas_PositedAt DESC,
                        s.ST_at_PR_spelas_Reliability DESC,
                        s.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_spelas_Assertion <> '?' THEN r.ST_at_PR_spelas_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_spelas_Positor,
                            r.ST_ID_at,
                            r.PR_ID_spelas
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_spelas,
                        po.ST_at_PR_spelas_ID,
                        po.ST_ID_at,
                        po.PR_ID_spelas,
                        po.ST_at_PR_spelas_ChangedAt,
                        an.ST_at_PR_spelas_PositedAt,
                        an.ST_at_PR_spelas_Positor,
                        an.ST_at_PR_spelas_Reliability,
                        an.ST_at_PR_spelas_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_spelas_ID, an.ST_at_PR_spelas_Positor
                            ORDER BY an.ST_at_PR_spelas_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.ST_at_PR_spelas_Posit po
                    JOIN
                        ties.ST_at_PR_spelas_Annex an
                    ON
                        an.ST_at_PR_spelas_ID = po.ST_at_PR_spelas_ID
                    WHERE
                        po.ST_at_PR_spelas_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_at_PR_spelas_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.ST_at_PR_spelas_Assertion = COALESCE(assertion, s.ST_at_PR_spelas_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.ST_at_PR_spelas_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.ST_at_PR_spelas_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tST_at_PR_spelas;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_ST_at_PR_spelas,
            t.ST_ID_at,
            t.PR_ID_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Positor,
            t.ST_at_PR_spelas_Reliability,
            t.ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_spelas_Positor,
                        s.ST_ID_at,
                        s.PR_ID_spelas
                    ORDER BY
                        s.ST_at_PR_spelas_ChangedAt DESC,
                        s.ST_at_PR_spelas_PositedAt DESC,
                        s.ST_at_PR_spelas_Reliability DESC,
                        s.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_spelas_Assertion <> '?' THEN r.ST_at_PR_spelas_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_spelas_Positor,
                            r.ST_ID_at,
                            r.PR_ID_spelas
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_spelas,
                        po.ST_at_PR_spelas_ID,
                        po.ST_ID_at,
                        po.PR_ID_spelas,
                        po.ST_at_PR_spelas_ChangedAt,
                        an.ST_at_PR_spelas_PositedAt,
                        an.ST_at_PR_spelas_Positor,
                        an.ST_at_PR_spelas_Reliability,
                        an.ST_at_PR_spelas_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_spelas_ID, an.ST_at_PR_spelas_Positor
                            ORDER BY an.ST_at_PR_spelas_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.ST_at_PR_spelas_Posit po
                    JOIN
                        ties.ST_at_PR_spelas_Annex an
                    ON
                        an.ST_at_PR_spelas_ID = po.ST_at_PR_spelas_ID
                    WHERE
                        po.ST_at_PR_spelas_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_at_PR_spelas_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.ST_at_PR_spelas_Assertion = '+'
            AND
                s.ST_at_PR_spelas_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.ST_at_PR_spelas_Positor
        WHERE
            t.latestPosit = 1
    ]';
END pST_at_PR_spelas;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas
AS
SELECT
    *
FROM
    ties.pST_at_PR_spelas(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_ST_at_PR_spelas,
            t.ST_ID_at,
            t.PR_ID_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Positor,
            t.ST_at_PR_spelas_Reliability,
            t.ST_at_PR_spelas_Assertion
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_at_PR_spelas_Positor AS inspectedPositor,
                CAST(h.ST_at_PR_spelas_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.ST_at_PR_spelas h
            WHERE
                h.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.ST_at_PR_spelas_ChangedAt) OVER (
                    PARTITION BY
                        y.ST_at_PR_spelas_Positor,
                        y.ST_ID_at,
                        y.PR_ID_spelas
                    ORDER BY y.ST_at_PR_spelas_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.ST_at_PR_spelas_Positor,
                                r.ST_ID_at,
                                r.PR_ID_spelas,
                                r.ST_at_PR_spelas_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_at_PR_spelas_Assertion = '+' THEN 0 ELSE 1 END,
                                r.ST_at_PR_spelas_PositedAt DESC,
                                r.ST_at_PR_spelas_Reliability DESC,
                                r.ST_at_PR_spelas_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_at_PR_spelas,
                            po.ST_at_PR_spelas_ID,
                            po.ST_ID_at,
                            po.PR_ID_spelas,
                            po.ST_at_PR_spelas_ChangedAt,
                            an.ST_at_PR_spelas_PositedAt,
                            an.ST_at_PR_spelas_Positor,
                            an.ST_at_PR_spelas_Reliability,
                            an.ST_at_PR_spelas_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_at_PR_spelas_ID, an.ST_at_PR_spelas_Positor
                                ORDER BY an.ST_at_PR_spelas_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.ST_at_PR_spelas_Posit po
                        JOIN
                            ties.ST_at_PR_spelas_Annex an
                        ON
                            an.ST_at_PR_spelas_ID = po.ST_at_PR_spelas_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_at_PR_spelas_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.ST_at_PR_spelas_Positor = tp.inspectedPositor
        AND
            t.ST_at_PR_spelas_Assertion = '+'
        AND
            t.ST_at_PR_spelas_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
    ]';
END dST_at_PR_spelas;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_förälder_AC_barn_PAT_har (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_AC_förälder_AC_barn_PAT_har,
            t.AC_ID_förälder,
            t.AC_ID_barn,
            "kPAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "kPAT_har".Metadata_PAT AS har_Metadata_PAT,
            t.PAT_ID_har,
            t.AC_förälder_AC_barn_PAT_har_PositedAt,
            t.AC_förälder_AC_barn_PAT_har_Positor,
            t.AC_förälder_AC_barn_PAT_har_Reliability,
            t.AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_förälder_AC_barn_PAT_har_Positor,
                        s.AC_ID_förälder,
                        s.AC_ID_barn,
                        s.PAT_ID_har
                    ORDER BY
                        s.AC_förälder_AC_barn_PAT_har_PositedAt DESC,
                        s.AC_förälder_AC_barn_PAT_har_Reliability DESC,
                        s.AC_förälder_AC_barn_PAT_har_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_förälder_AC_barn_PAT_har,
                        po.AC_förälder_AC_barn_PAT_har_ID,
                        po.AC_ID_förälder,
                        po.AC_ID_barn,
                        po.PAT_ID_har,
                        an.AC_förälder_AC_barn_PAT_har_PositedAt,
                        an.AC_förälder_AC_barn_PAT_har_Positor,
                        an.AC_förälder_AC_barn_PAT_har_Reliability,
                        an.AC_förälder_AC_barn_PAT_har_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_förälder_AC_barn_PAT_har_ID, an.AC_förälder_AC_barn_PAT_har_Positor
                            ORDER BY an.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_förälder_AC_barn_PAT_har_Posit po
                    JOIN
                        ties.AC_förälder_AC_barn_PAT_har_Annex an
                    ON
                        an.AC_förälder_AC_barn_PAT_har_ID = po.AC_förälder_AC_barn_PAT_har_ID
                    WHERE
                        an.AC_förälder_AC_barn_PAT_har_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_förälder_AC_barn_PAT_har_Assertion = COALESCE(assertion, s.AC_förälder_AC_barn_PAT_har_Assertion)
        ) t
        LEFT JOIN
            knots.PAT_Föräldratyp "kPAT_har"
        ON
            "kPAT_har".PAT_ID = t.PAT_ID_har
        WHERE
            t.AC_förälder_AC_barn_PAT_har_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_förälder_AC_barn_PAT_har;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_förälder_AC_barn_PAT_har,
            t.AC_ID_förälder,
            t.AC_ID_barn,
            "kPAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "kPAT_har".Metadata_PAT AS har_Metadata_PAT,
            t.PAT_ID_har,
            t.AC_förälder_AC_barn_PAT_har_PositedAt,
            t.AC_förälder_AC_barn_PAT_har_Positor,
            t.AC_förälder_AC_barn_PAT_har_Reliability,
            t.AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_förälder_AC_barn_PAT_har_Positor,
                        s.AC_ID_förälder,
                        s.AC_ID_barn,
                        s.PAT_ID_har
                    ORDER BY
                        s.AC_förälder_AC_barn_PAT_har_PositedAt DESC,
                        s.AC_förälder_AC_barn_PAT_har_Reliability DESC,
                        s.AC_förälder_AC_barn_PAT_har_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_förälder_AC_barn_PAT_har,
                        po.AC_förälder_AC_barn_PAT_har_ID,
                        po.AC_ID_förälder,
                        po.AC_ID_barn,
                        po.PAT_ID_har,
                        an.AC_förälder_AC_barn_PAT_har_PositedAt,
                        an.AC_förälder_AC_barn_PAT_har_Positor,
                        an.AC_förälder_AC_barn_PAT_har_Reliability,
                        an.AC_förälder_AC_barn_PAT_har_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_förälder_AC_barn_PAT_har_ID, an.AC_förälder_AC_barn_PAT_har_Positor
                            ORDER BY an.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_förälder_AC_barn_PAT_har_Posit po
                    JOIN
                        ties.AC_förälder_AC_barn_PAT_har_Annex an
                    ON
                        an.AC_förälder_AC_barn_PAT_har_ID = po.AC_förälder_AC_barn_PAT_har_ID
                    WHERE
                        an.AC_förälder_AC_barn_PAT_har_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_förälder_AC_barn_PAT_har_Assertion = '+'
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_förälder_AC_barn_PAT_har_Positor
        LEFT JOIN
            knots.PAT_Föräldratyp "kPAT_har"
        ON
            "kPAT_har".PAT_ID = t.PAT_ID_har
        WHERE
            t.latestPosit = 1
    ]';
END pAC_förälder_AC_barn_PAT_har;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har
AS
SELECT
    *
FROM
    ties.pAC_förälder_AC_barn_PAT_har(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har
AS
SELECT
    *
FROM
    ties.pAC_förälder_AC_barn_PAT_har(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_innehåll_ST_plats_EV_of (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Positor,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.PR_ID_innehåll
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.ST_ID_plats
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_innehåll_ST_plats_EV_of_Assertion <> '?' THEN r.PR_innehåll_ST_plats_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_innehåll_ST_plats_EV_of_Positor,
                            r.PR_ID_innehåll,
                            r.ST_ID_plats,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_innehåll_ST_plats_EV_of,
                        po.PR_innehåll_ST_plats_EV_of_ID,
                        po.PR_ID_innehåll,
                        po.ST_ID_plats,
                        po.EV_ID_of,
                        po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                        an.PR_innehåll_ST_plats_EV_of_PositedAt,
                        an.PR_innehåll_ST_plats_EV_of_Positor,
                        an.PR_innehåll_ST_plats_EV_of_Reliability,
                        an.PR_innehåll_ST_plats_EV_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID, an.PR_innehåll_ST_plats_EV_of_Positor
                            ORDER BY an.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.PR_innehåll_ST_plats_EV_of_Posit po
                    JOIN
                        ties.PR_innehåll_ST_plats_EV_of_Annex an
                    ON
                        an.PR_innehåll_ST_plats_EV_of_ID = po.PR_innehåll_ST_plats_EV_of_ID
                    WHERE
                        po.PR_innehåll_ST_plats_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.PR_innehåll_ST_plats_EV_of_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.PR_innehåll_ST_plats_EV_of_Assertion = COALESCE(assertion, s.PR_innehåll_ST_plats_EV_of_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.PR_innehåll_ST_plats_EV_of_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.PR_innehåll_ST_plats_EV_of_Positor = forPositor
        AND
            t.latestPositPR_ID_innehåll = 1
        AND
            t.latestPositST_ID_plats = 1
    ]';
END tPR_innehåll_ST_plats_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Positor,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.PR_ID_innehåll
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.ST_ID_plats
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_innehåll_ST_plats_EV_of_Assertion <> '?' THEN r.PR_innehåll_ST_plats_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_innehåll_ST_plats_EV_of_Positor,
                            r.PR_ID_innehåll,
                            r.ST_ID_plats,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_innehåll_ST_plats_EV_of,
                        po.PR_innehåll_ST_plats_EV_of_ID,
                        po.PR_ID_innehåll,
                        po.ST_ID_plats,
                        po.EV_ID_of,
                        po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                        an.PR_innehåll_ST_plats_EV_of_PositedAt,
                        an.PR_innehåll_ST_plats_EV_of_Positor,
                        an.PR_innehåll_ST_plats_EV_of_Reliability,
                        an.PR_innehåll_ST_plats_EV_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID, an.PR_innehåll_ST_plats_EV_of_Positor
                            ORDER BY an.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.PR_innehåll_ST_plats_EV_of_Posit po
                    JOIN
                        ties.PR_innehåll_ST_plats_EV_of_Annex an
                    ON
                        an.PR_innehåll_ST_plats_EV_of_ID = po.PR_innehåll_ST_plats_EV_of_ID
                    WHERE
                        po.PR_innehåll_ST_plats_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.PR_innehåll_ST_plats_EV_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.PR_innehåll_ST_plats_EV_of_Assertion = '+'
            AND
                s.PR_innehåll_ST_plats_EV_of_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.PR_innehåll_ST_plats_EV_of_Positor
        WHERE
            t.latestPositPR_ID_innehåll = 1
        AND
            t.latestPositST_ID_plats = 1
    ]';
END pPR_innehåll_ST_plats_EV_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of
AS
SELECT
    *
FROM
    ties.pPR_innehåll_ST_plats_EV_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            q.Positor,
            q.inspectedTimepoint,
            q.Metadata_PR_innehåll_ST_plats_EV_of,
            q.PR_ID_innehåll,
            q.ST_ID_plats,
            q.EV_ID_of,
            q.PR_innehåll_ST_plats_EV_of_ChangedAt,
            q.PR_innehåll_ST_plats_EV_of_PositedAt,
            q.PR_innehåll_ST_plats_EV_of_Positor,
            q.PR_innehåll_ST_plats_EV_of_Reliability,
            q.PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
        SELECT
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Positor,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_innehåll_ST_plats_EV_of_Assertion,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.PR_ID_innehåll
                ORDER BY
                    t.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                    t.PR_innehåll_ST_plats_EV_of_ID DESC
            ) AS latestPositPR_ID_innehåll,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.ST_ID_plats
                ORDER BY
                    t.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                    t.PR_innehåll_ST_plats_EV_of_ID DESC
            ) AS latestPositST_ID_plats
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_innehåll_ST_plats_EV_of_Positor AS inspectedPositor,
                CAST(h.PR_innehåll_ST_plats_EV_of_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.PR_innehåll_ST_plats_EV_of h
            WHERE
                h.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (
                    PARTITION BY
                        y.PR_innehåll_ST_plats_EV_of_Positor,
                        y.PR_ID_innehåll,
                        y.ST_ID_plats,
                        y.EV_ID_of
                    ORDER BY y.PR_innehåll_ST_plats_EV_of_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.PR_innehåll_ST_plats_EV_of_Positor,
                                r.PR_ID_innehåll,
                                r.ST_ID_plats,
                                r.EV_ID_of,
                                r.PR_innehåll_ST_plats_EV_of_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_innehåll_ST_plats_EV_of_Assertion = '+' THEN 0 ELSE 1 END,
                                r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                                r.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                                r.PR_innehåll_ST_plats_EV_of_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_innehåll_ST_plats_EV_of,
                            po.PR_innehåll_ST_plats_EV_of_ID,
                            po.PR_ID_innehåll,
                            po.ST_ID_plats,
                            po.EV_ID_of,
                            po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                            an.PR_innehåll_ST_plats_EV_of_PositedAt,
                            an.PR_innehåll_ST_plats_EV_of_Positor,
                            an.PR_innehåll_ST_plats_EV_of_Reliability,
                            an.PR_innehåll_ST_plats_EV_of_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID, an.PR_innehåll_ST_plats_EV_of_Positor
                                ORDER BY an.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.PR_innehåll_ST_plats_EV_of_Posit po
                        JOIN
                            ties.PR_innehåll_ST_plats_EV_of_Annex an
                        ON
                            an.PR_innehåll_ST_plats_EV_of_ID = po.PR_innehåll_ST_plats_EV_of_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_innehåll_ST_plats_EV_of_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.PR_innehåll_ST_plats_EV_of_Positor = tp.inspectedPositor
        AND
            t.PR_innehåll_ST_plats_EV_of_Assertion = '+'
        AND
            t.PR_innehåll_ST_plats_EV_of_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        ) q
        WHERE
            q.latestPositPR_ID_innehåll = 1
        AND
            q.latestPositST_ID_plats = 1
    ]';
END dPR_innehåll_ST_plats_EV_of;
/
-- ATTRIBUTE INSERT PROCEDURES ----------------------------------------------------------------------------------------
--
-- The procedures here state one posit of an attribute and what a positor asserts of it, in the way that the model says,
-- like the triggers on the assembled views do in PostgreSQL: the positor is 0, the positing time is now and the
-- reliability is 1 where they are not given. They are procedures and not triggers on the assembled views (which are views
-- that Oracle would need an INSTEAD OF trigger on) or on the posit and annex tables, since Oracle does not let a row
-- trigger read the table it is on (ORA-04091), which these rules do. The INSTEAD OF triggers on the latest views of the
-- anchors, and those of the nexuses, call them, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_value => 'Ann', p_changing => SYSTIMESTAMP, p_positor => 0, p_reliability => 1, p_metadata => 1); END;
--
-- ip_<attribute.name> (one for every attribute of an anchor or a nexus, named as the attribute is in the model, written in
-- front of its schema if it has one). Its parameters are named, and all except the owner and the value may be left out (or
-- be null), when the default of the one left out is used:
--
--     p_owner        the entity that has the attribute, a column of the posit table: the entity reference of the attribute
--     p_value        the value that is posited, as it is in the posit table: for a knotted attribute the identity of the value in the
--                    knot, for an attribute with a checksum the value (the checksum is made by the table)
--     p_changing     only for a historized attribute: from when the value is valid. Default: now (current_timestamp)
--     p_positor      the positor that asserts the posit. Default: 0
--     p_positing     when the positor asserts it. Default: now
--     p_reliability  how reliable the positor says that it is: positive asserts the posit, negative asserts that it is not so, and
--                    0 retracts the assertion of it. Default: 1
--     p_metadata     only when the model has metadata: the metadata of the annex row. Default: 0
--
-- A posit that is not there is created. A retraction of what the positor does not hold states nothing. An error is raised
-- (RAISE_APPLICATION_ERROR) for a contradiction (-20001: the positor asserts another reliability of the same posit at the
-- same positing time, or in the model where positors are decisive another value for the same entity and changing time, or
-- in the model where positors are indecisive, alternatives with reliabilities that sum up to more than one) and for a
-- restatement (-20002: the value is the same as that of the version before or after it, where the attribute may not be
-- restated). A call that raises an error is undone, as is the statement that made it.
--
-- Two functions help the procedures and may be used in a query as well:
--
--     eq_<attribute.name>(p_left, p_right)         1 if two values of the attribute are the same, else 0
--     he_<attribute.name>(p_id, p_positor, p_positing)   the reliability that the positor holds for the posit with the identity
--                                                  at the positing time (that of its latest annex row up to then), null if it holds nothing
--
-- Positors are decisive: a positor holds one assertion at a time for an entity (and a changing time), so an assertion that
-- is not a retraction, positive or negative, of another value retracts, at its own positing time, the posit that the
-- positor holds, which is a correction.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_DAT_Händelse_Datum tells whether two values of EV_DAT_Händelse_Datum are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_DAT_Händelse_Datum (
    p_left IN attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_Händelse_Datum%TYPE,
    p_right IN attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_Händelse_Datum%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_DAT_Händelse_Datum;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Händelse_Datum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_DAT_Händelse_Datum (
    p_id IN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_ID%TYPE,
    p_positor IN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_Positor%TYPE,
    p_positing IN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_PositedAt%TYPE
) RETURN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_DAT_Reliability
        FROM
            attributes.EV_DAT_Händelse_Datum_Annex a
        WHERE
            a.EV_DAT_ID = p_id
        AND
            a.EV_DAT_Positor = p_positor
        AND
            a.EV_DAT_PositedAt <= p_positing
        ORDER BY
            a.EV_DAT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_DAT_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_DAT_Händelse_Datum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Händelse_Datum states a value of EV_DAT_Händelse_Datum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Händelse_Datum (
    p_owner IN attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_Händelse_Datum%TYPE,
    p_positor IN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_DAT_Händelse_Datum_Annex.EV_DAT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_DAT_Händelse_Datum_Annex.Metadata_EV_DAT%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_DAT_Händelse_Datum_Annex (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Positor,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_DAT_Händelse_Datum_Annex x
                WHERE
                    x.EV_DAT_ID = p_id
                AND
                    x.EV_DAT_Positor = v_positor
                AND
                    x.EV_DAT_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Händelse_Datum_Posit p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Händelse_Datum(p.EV_DAT_Händelse_Datum, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_DAT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Händelse_Datum_Annex a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Positor = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Händelse_Datum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Händelse_Datum_Posit p
        JOIN
            attributes.EV_DAT_Händelse_Datum_Annex a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Händelse_Datum(p.EV_DAT_Händelse_Datum, p_value) = 0
        AND
            a.EV_DAT_Positor = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Händelse_Datum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Händelse_Datum_Annex a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Positor = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_DAT_Händelse_Datum(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_DAT_Händelse_Datum_Annex (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Positor,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Händelse_Datum_Posit p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Händelse_Datum(p.EV_DAT_Händelse_Datum, p_value) = 0
        AND
            COALESCE(attributes.he_EV_DAT_Händelse_Datum(p.EV_DAT_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_DAT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_DAT_Händelse_Datum_Posit (
            EV_DAT_EV_ID,
            EV_DAT_Händelse_Datum
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_DAT_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_DAT_Händelse_Datum_Annex (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_DAT_Händelse_Datum;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Händelse_Publik tells whether two values of EV_AUD_Händelse_Publik are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_AUD_Händelse_Publik (
    p_left IN attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_Händelse_Publik%TYPE,
    p_right IN attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_Händelse_Publik%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_AUD_Händelse_Publik;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Händelse_Publik is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_AUD_Händelse_Publik (
    p_id IN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_ID%TYPE,
    p_positor IN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_Positor%TYPE,
    p_positing IN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_PositedAt%TYPE
) RETURN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_AUD_Reliability
        FROM
            attributes.EV_AUD_Händelse_Publik_Annex a
        WHERE
            a.EV_AUD_ID = p_id
        AND
            a.EV_AUD_Positor = p_positor
        AND
            a.EV_AUD_PositedAt <= p_positing
        ORDER BY
            a.EV_AUD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_AUD_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_AUD_Händelse_Publik;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Händelse_Publik states a value of EV_AUD_Händelse_Publik
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Händelse_Publik (
    p_owner IN attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_Händelse_Publik%TYPE,
    p_positor IN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_AUD_Händelse_Publik_Annex.EV_AUD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_AUD_Händelse_Publik_Annex.Metadata_EV_AUD%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_AUD_Händelse_Publik_Annex (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Positor,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_AUD_Händelse_Publik_Annex x
                WHERE
                    x.EV_AUD_ID = p_id
                AND
                    x.EV_AUD_Positor = v_positor
                AND
                    x.EV_AUD_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Händelse_Publik_Posit p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Händelse_Publik(p.EV_AUD_Händelse_Publik, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_AUD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Händelse_Publik_Annex a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Positor = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Händelse_Publik for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Händelse_Publik_Posit p
        JOIN
            attributes.EV_AUD_Händelse_Publik_Annex a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Händelse_Publik(p.EV_AUD_Händelse_Publik, p_value) = 0
        AND
            a.EV_AUD_Positor = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Händelse_Publik for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Händelse_Publik_Annex a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Positor = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_AUD_Händelse_Publik(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_AUD_Händelse_Publik_Annex (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Positor,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Händelse_Publik_Posit p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Händelse_Publik(p.EV_AUD_Händelse_Publik, p_value) = 0
        AND
            COALESCE(attributes.he_EV_AUD_Händelse_Publik(p.EV_AUD_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_AUD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_AUD_Händelse_Publik_Posit (
            EV_AUD_EV_ID,
            EV_AUD_Händelse_Publik
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_AUD_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_AUD_Händelse_Publik_Annex (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_AUD_Händelse_Publik;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Händelse_Intäkt tells whether two values of EV_REV_Händelse_Intäkt are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_REV_Händelse_Intäkt (
    p_left IN attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_Händelse_Intäkt%TYPE,
    p_right IN attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_Händelse_Intäkt%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_REV_Händelse_Intäkt;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Händelse_Intäkt is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_REV_Händelse_Intäkt (
    p_id IN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_ID%TYPE,
    p_positor IN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_Positor%TYPE,
    p_positing IN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_PositedAt%TYPE
) RETURN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_REV_Reliability
        FROM
            attributes.EV_REV_Händelse_Intäkt_Annex a
        WHERE
            a.EV_REV_ID = p_id
        AND
            a.EV_REV_Positor = p_positor
        AND
            a.EV_REV_PositedAt <= p_positing
        ORDER BY
            a.EV_REV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_REV_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_REV_Händelse_Intäkt;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Händelse_Intäkt states a value of EV_REV_Händelse_Intäkt
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Händelse_Intäkt (
    p_owner IN attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_Händelse_Intäkt%TYPE,
    p_positor IN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_REV_Händelse_Intäkt_Annex.EV_REV_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_REV_Händelse_Intäkt_Annex.Metadata_EV_REV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_REV_Händelse_Intäkt_Annex (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Positor,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_REV_Händelse_Intäkt_Annex x
                WHERE
                    x.EV_REV_ID = p_id
                AND
                    x.EV_REV_Positor = v_positor
                AND
                    x.EV_REV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Händelse_Intäkt_Posit p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Händelse_Intäkt(p.EV_REV_Händelse_Intäkt, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_REV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Händelse_Intäkt_Annex a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Positor = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Händelse_Intäkt for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Händelse_Intäkt_Posit p
        JOIN
            attributes.EV_REV_Händelse_Intäkt_Annex a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Händelse_Intäkt(p.EV_REV_Händelse_Intäkt, p_value) = 0
        AND
            a.EV_REV_Positor = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Händelse_Intäkt for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Händelse_Intäkt_Annex a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Positor = v_positor
        AND
            a.EV_REV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_REV_Händelse_Intäkt(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_REV_Händelse_Intäkt_Annex (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Positor,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Händelse_Intäkt_Posit p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Händelse_Intäkt(p.EV_REV_Händelse_Intäkt, p_value) = 0
        AND
            COALESCE(attributes.he_EV_REV_Händelse_Intäkt(p.EV_REV_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_REV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_REV_Händelse_Intäkt_Posit (
            EV_REV_EV_ID,
            EV_REV_Händelse_Intäkt
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_REV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_REV_Händelse_Intäkt_Annex (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_REV_Händelse_Intäkt;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_STA_Händelse_Status tells whether two values of EV_STA_Händelse_Status are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_STA_Händelse_Status (
    p_left IN attributes.EV_STA_Händelse_Status_Posit.EV_STA_Händelse_Status%TYPE,
    p_right IN attributes.EV_STA_Händelse_Status_Posit.EV_STA_Händelse_Status%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_STA_Händelse_Status;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_STA_Händelse_Status is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_STA_Händelse_Status (
    p_id IN attributes.EV_STA_Händelse_Status_Annex.EV_STA_ID%TYPE,
    p_positor IN attributes.EV_STA_Händelse_Status_Annex.EV_STA_Positor%TYPE,
    p_positing IN attributes.EV_STA_Händelse_Status_Annex.EV_STA_PositedAt%TYPE
) RETURN attributes.EV_STA_Händelse_Status_Annex.EV_STA_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_STA_Reliability
        FROM
            attributes.EV_STA_Händelse_Status_Annex a
        WHERE
            a.EV_STA_ID = p_id
        AND
            a.EV_STA_Positor = p_positor
        AND
            a.EV_STA_PositedAt <= p_positing
        ORDER BY
            a.EV_STA_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_STA_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_STA_Händelse_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Händelse_Status states a value of EV_STA_Händelse_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Händelse_Status (
    p_owner IN attributes.EV_STA_Händelse_Status_Posit.EV_STA_EV_ID%TYPE,
    p_value IN attributes.EV_STA_Händelse_Status_Posit.EV_STA_Händelse_Status%TYPE,
    p_changing IN attributes.EV_STA_Händelse_Status_Posit.EV_STA_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.EV_STA_Händelse_Status_Annex.EV_STA_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_STA_Händelse_Status_Annex.EV_STA_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_STA_Händelse_Status_Annex.EV_STA_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_STA_Händelse_Status_Annex.Metadata_EV_STA%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit attributes.EV_STA_Händelse_Status_Posit.EV_STA_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_STA_Händelse_Status_Posit.EV_STA_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_STA_Händelse_Status_Annex (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Positor,
            EV_STA_PositedAt,
            EV_STA_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_STA_Händelse_Status_Annex x
                WHERE
                    x.EV_STA_ID = p_id
                AND
                    x.EV_STA_Positor = v_positor
                AND
                    x.EV_STA_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Händelse_Status_Posit p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Händelse_Status(p.EV_STA_Händelse_Status, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_STA_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Händelse_Status_Annex a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_Positor = v_positor
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Händelse_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Händelse_Status_Posit p
        JOIN
            attributes.EV_STA_Händelse_Status_Annex a
        ON
            a.EV_STA_ID = p.EV_STA_ID
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Händelse_Status(p.EV_STA_Händelse_Status, p_value) = 0
        AND
            a.EV_STA_Positor = v_positor
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Händelse_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Händelse_Status_Annex a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_Positor = v_positor
        AND
            a.EV_STA_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_STA_Händelse_Status(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_STA_Händelse_Status_Annex (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Positor,
            EV_STA_PositedAt,
            EV_STA_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Händelse_Status_Posit p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Händelse_Status(p.EV_STA_Händelse_Status, p_value) = 0
        AND
            COALESCE(attributes.he_EV_STA_Händelse_Status(p.EV_STA_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_STA_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_STA_Händelse_Status_Posit (
            EV_STA_EV_ID,
            EV_STA_ChangedAt,
            EV_STA_Händelse_Status
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_STA_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_STA_Händelse_Status_Annex (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Positor,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_STA_Händelse_Status;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Händelse_Utnyttjande tells whether two values of EV_UTL_Händelse_Utnyttjande are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_UTL_Händelse_Utnyttjande (
    p_left IN attributes.EV_UTL_Händelse_Utnyttjande_Posit.EV_UTL_UTL_ID%TYPE,
    p_right IN attributes.EV_UTL_Händelse_Utnyttjande_Posit.EV_UTL_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_UTL_Händelse_Utnyttjande;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_UTL_Händelse_Utnyttjande is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_UTL_Händelse_Utnyttjande (
    p_id IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_ID%TYPE,
    p_positor IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_Positor%TYPE,
    p_positing IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_PositedAt%TYPE
) RETURN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_UTL_Reliability
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Annex a
        WHERE
            a.EV_UTL_ID = p_id
        AND
            a.EV_UTL_Positor = p_positor
        AND
            a.EV_UTL_PositedAt <= p_positing
        ORDER BY
            a.EV_UTL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_UTL_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_UTL_Händelse_Utnyttjande;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Händelse_Utnyttjande states a value of EV_UTL_Händelse_Utnyttjande
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Händelse_Utnyttjande (
    p_owner IN attributes.EV_UTL_Händelse_Utnyttjande_Posit.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Händelse_Utnyttjande_Posit.EV_UTL_UTL_ID%TYPE,
    p_positor IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.EV_UTL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_UTL_Händelse_Utnyttjande_Annex.Metadata_EV_UTL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.EV_UTL_Händelse_Utnyttjande_Posit.EV_UTL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_UTL_Händelse_Utnyttjande_Posit.EV_UTL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande_Annex (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Positor,
            EV_UTL_PositedAt,
            EV_UTL_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_UTL_Händelse_Utnyttjande_Annex x
                WHERE
                    x.EV_UTL_ID = p_id
                AND
                    x.EV_UTL_Positor = v_positor
                AND
                    x.EV_UTL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Posit p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Händelse_Utnyttjande(p.EV_UTL_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_UTL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Annex a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_Positor = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Händelse_Utnyttjande for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Posit p
        JOIN
            attributes.EV_UTL_Händelse_Utnyttjande_Annex a
        ON
            a.EV_UTL_ID = p.EV_UTL_ID
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Händelse_Utnyttjande(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            a.EV_UTL_Positor = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Händelse_Utnyttjande for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Annex a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_Positor = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_UTL_Händelse_Utnyttjande(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande_Annex (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Positor,
            EV_UTL_PositedAt,
            EV_UTL_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Posit p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Händelse_Utnyttjande(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_UTL_Händelse_Utnyttjande(p.EV_UTL_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_UTL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande_Posit (
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_UTL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande_Annex (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Positor,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_UTL_Händelse_Utnyttjande;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Händelse_Level tells whether two values of EV_LVL_Händelse_Level are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_LVL_Händelse_Level (
    p_left IN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_PLV_ID%TYPE,
    p_right IN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_LVL_Händelse_Level;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_LVL_Händelse_Level is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_LVL_Händelse_Level (
    p_id IN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_ID%TYPE,
    p_positor IN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_Positor%TYPE,
    p_positing IN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_PositedAt%TYPE
) RETURN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_LVL_Reliability
        FROM
            attributes.EV_LVL_Händelse_Level_Annex a
        WHERE
            a.EV_LVL_ID = p_id
        AND
            a.EV_LVL_Positor = p_positor
        AND
            a.EV_LVL_PositedAt <= p_positing
        ORDER BY
            a.EV_LVL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_LVL_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_LVL_Händelse_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Händelse_Level states a value of EV_LVL_Händelse_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Händelse_Level (
    p_owner IN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_EV_ID%TYPE,
    p_value IN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_PLV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_LVL_Händelse_Level_Annex.EV_LVL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_LVL_Händelse_Level_Annex.Metadata_EV_LVL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing date;
    v_posit attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_LVL_Händelse_Level_Annex (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Positor,
            EV_LVL_PositedAt,
            EV_LVL_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_LVL_Händelse_Level_Annex x
                WHERE
                    x.EV_LVL_ID = p_id
                AND
                    x.EV_LVL_Positor = v_positor
                AND
                    x.EV_LVL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Händelse_Level_Posit p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Händelse_Level(p.EV_LVL_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_LVL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Händelse_Level_Annex a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_Positor = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Händelse_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Händelse_Level_Posit p
        JOIN
            attributes.EV_LVL_Händelse_Level_Annex a
        ON
            a.EV_LVL_ID = p.EV_LVL_ID
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Händelse_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            a.EV_LVL_Positor = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Händelse_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Händelse_Level_Annex a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_Positor = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_LVL_Händelse_Level(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_LVL_Händelse_Level_Annex (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Positor,
            EV_LVL_PositedAt,
            EV_LVL_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Händelse_Level_Posit p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Händelse_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_LVL_Händelse_Level(p.EV_LVL_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_LVL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_LVL_Händelse_Level_Posit (
            EV_LVL_EV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_LVL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_LVL_Händelse_Level_Annex (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Positor,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_LVL_Händelse_Level;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Scen_Namn tells whether two values of ST_NAM_Scen_Namn are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_NAM_Scen_Namn (
    p_left IN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_Scen_Namn%TYPE,
    p_right IN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_Scen_Namn%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_NAM_Scen_Namn;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Scen_Namn is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_NAM_Scen_Namn (
    p_id IN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_ID%TYPE,
    p_positor IN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_Positor%TYPE,
    p_positing IN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_PositedAt%TYPE
) RETURN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_NAM_Reliability
        FROM
            attributes.ST_NAM_Scen_Namn_Annex a
        WHERE
            a.ST_NAM_ID = p_id
        AND
            a.ST_NAM_Positor = p_positor
        AND
            a.ST_NAM_PositedAt <= p_positing
        ORDER BY
            a.ST_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_NAM_Scen_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Scen_Namn states a value of ST_NAM_Scen_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Scen_Namn (
    p_owner IN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_ST_ID%TYPE,
    p_value IN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_Scen_Namn%TYPE,
    p_changing IN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_NAM_Scen_Namn_Annex.ST_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_NAM_Scen_Namn_Annex.Metadata_ST_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_NAM_Scen_Namn_Annex (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Positor,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_NAM_Scen_Namn_Annex x
                WHERE
                    x.ST_NAM_ID = p_id
                AND
                    x.ST_NAM_Positor = v_positor
                AND
                    x.ST_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            attributes.ST_NAM_Scen_Namn_Posit p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Scen_Namn(p.ST_NAM_Scen_Namn, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Scen_Namn_Annex a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Positor = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Scen_Namn for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Scen_Namn_Posit p
        JOIN
            attributes.ST_NAM_Scen_Namn_Annex a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Scen_Namn(p.ST_NAM_Scen_Namn, p_value) = 0
        AND
            a.ST_NAM_Positor = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Scen_Namn for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Scen_Namn_Annex a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Positor = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_NAM_Scen_Namn(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_NAM_Scen_Namn_Annex (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Positor,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            attributes.ST_NAM_Scen_Namn_Posit p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Scen_Namn(p.ST_NAM_Scen_Namn, p_value) = 0
        AND
            COALESCE(attributes.he_ST_NAM_Scen_Namn(p.ST_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_NAM_Scen_Namn_Posit (
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Scen_Namn
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_NAM_Scen_Namn_Annex (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_NAM_Scen_Namn;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Scen_Plats tells whether two values of ST_LOC_Scen_Plats are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_LOC_Scen_Plats (
    p_left IN attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_Scen_Plats%TYPE,
    p_right IN attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_Scen_Plats%TYPE
) RETURN NUMBER
IS
    v_same NUMBER;
BEGIN
    SELECT CASE WHEN STANDARD_HASH(p_left, 'MD5') = STANDARD_HASH(p_right, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
    RETURN v_same;
END eq_ST_LOC_Scen_Plats;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Scen_Plats is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_LOC_Scen_Plats (
    p_id IN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_ID%TYPE,
    p_positor IN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_Positor%TYPE,
    p_positing IN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_PositedAt%TYPE
) RETURN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_LOC_Reliability
        FROM
            attributes.ST_LOC_Scen_Plats_Annex a
        WHERE
            a.ST_LOC_ID = p_id
        AND
            a.ST_LOC_Positor = p_positor
        AND
            a.ST_LOC_PositedAt <= p_positing
        ORDER BY
            a.ST_LOC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_LOC_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_LOC_Scen_Plats;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Scen_Plats states a value of ST_LOC_Scen_Plats
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Scen_Plats (
    p_owner IN attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_Scen_Plats%TYPE,
    p_positor IN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_LOC_Scen_Plats_Annex.ST_LOC_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_LOC_Scen_Plats_Annex.Metadata_ST_LOC%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_LOC_Scen_Plats_Annex (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Positor,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_LOC_Scen_Plats_Annex x
                WHERE
                    x.ST_LOC_ID = p_id
                AND
                    x.ST_LOC_Positor = v_positor
                AND
                    x.ST_LOC_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Scen_Plats_Posit p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Scen_Plats(p.ST_LOC_Scen_Plats, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_LOC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Scen_Plats_Annex a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Positor = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Scen_Plats for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Scen_Plats_Posit p
        JOIN
            attributes.ST_LOC_Scen_Plats_Annex a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Scen_Plats(p.ST_LOC_Scen_Plats, p_value) = 0
        AND
            a.ST_LOC_Positor = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Scen_Plats for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Scen_Plats_Annex a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Positor = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_LOC_Scen_Plats(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_LOC_Scen_Plats_Annex (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Positor,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Scen_Plats_Posit p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Scen_Plats(p.ST_LOC_Scen_Plats, p_value) = 0
        AND
            COALESCE(attributes.he_ST_LOC_Scen_Plats(p.ST_LOC_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_LOC_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_LOC_Scen_Plats_Posit (
            ST_LOC_ST_ID,
            ST_LOC_Scen_Plats
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_LOC_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_LOC_Scen_Plats_Annex (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_LOC_Scen_Plats;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Scen_Medel tells whether two values of ST_AVG_Scen_Medel are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_AVG_Scen_Medel (
    p_left IN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_UTL_ID%TYPE,
    p_right IN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_AVG_Scen_Medel;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Scen_Medel is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_AVG_Scen_Medel (
    p_id IN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_ID%TYPE,
    p_positor IN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_Positor%TYPE,
    p_positing IN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_PositedAt%TYPE
) RETURN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_AVG_Reliability
        FROM
            attributes.ST_AVG_Scen_Medel_Annex a
        WHERE
            a.ST_AVG_ID = p_id
        AND
            a.ST_AVG_Positor = p_positor
        AND
            a.ST_AVG_PositedAt <= p_positing
        ORDER BY
            a.ST_AVG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_AVG_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_AVG_Scen_Medel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Scen_Medel states a value of ST_AVG_Scen_Medel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Scen_Medel (
    p_owner IN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_ST_ID%TYPE,
    p_value IN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_UTL_ID%TYPE,
    p_changing IN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_AVG_Scen_Medel_Annex.ST_AVG_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_AVG_Scen_Medel_Annex.Metadata_ST_AVG%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_AVG_Scen_Medel_Annex (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_AVG_Scen_Medel_Annex x
                WHERE
                    x.ST_AVG_ID = p_id
                AND
                    x.ST_AVG_Positor = v_positor
                AND
                    x.ST_AVG_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            attributes.ST_AVG_Scen_Medel_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Scen_Medel(p.ST_AVG_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_AVG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Scen_Medel_Annex a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Positor = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Scen_Medel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Scen_Medel_Posit p
        JOIN
            attributes.ST_AVG_Scen_Medel_Annex a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Scen_Medel(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            a.ST_AVG_Positor = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Scen_Medel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Scen_Medel_Annex a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Positor = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_AVG_Scen_Medel(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_AVG_Scen_Medel_Annex (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            attributes.ST_AVG_Scen_Medel_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Scen_Medel(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_AVG_Scen_Medel(p.ST_AVG_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_AVG_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Scen_Medel(p.ST_AVG_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN attributes.he_ST_AVG_Scen_Medel(p.ST_AVG_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Scen_Medel(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.ST_AVG_ID,
            f.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel_Posit f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Scen_Medel(f.ST_AVG_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN attributes.he_ST_AVG_Scen_Medel(f.ST_AVG_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Scen_Medel(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.ST_AVG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_AVG_Scen_Medel_Posit (
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_AVG_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_AVG_Scen_Medel_Annex (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_AVG_Scen_Medel;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Scen_Minimum tells whether two values of ST_MIN_Scen_Minimum are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_MIN_Scen_Minimum (
    p_left IN attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_UTL_ID%TYPE,
    p_right IN attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_MIN_Scen_Minimum;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Scen_Minimum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_ST_MIN_Scen_Minimum (
    p_id IN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_ID%TYPE,
    p_positor IN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_Positor%TYPE,
    p_positing IN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_PositedAt%TYPE
) RETURN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_MIN_Reliability
        FROM
            attributes.ST_MIN_Scen_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = p_id
        AND
            a.ST_MIN_Positor = p_positor
        AND
            a.ST_MIN_PositedAt <= p_positing
        ORDER BY
            a.ST_MIN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_MIN_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_MIN_Scen_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Scen_Minimum states a value of ST_MIN_Scen_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Scen_Minimum (
    p_owner IN attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_UTL_ID%TYPE,
    p_positor IN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_MIN_Scen_Minimum_Annex.ST_MIN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_MIN_Scen_Minimum_Annex.Metadata_ST_MIN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_MIN_Scen_Minimum_Annex (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Positor,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_MIN_Scen_Minimum_Annex x
                WHERE
                    x.ST_MIN_ID = p_id
                AND
                    x.ST_MIN_Positor = v_positor
                AND
                    x.ST_MIN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Scen_Minimum_Posit p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Scen_Minimum(p.ST_MIN_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_MIN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Scen_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Positor = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Scen_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Scen_Minimum_Posit p
        JOIN
            attributes.ST_MIN_Scen_Minimum_Annex a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Scen_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            a.ST_MIN_Positor = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Scen_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Scen_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Positor = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_MIN_Scen_Minimum(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_MIN_Scen_Minimum_Annex (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Positor,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Scen_Minimum_Posit p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Scen_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_MIN_Scen_Minimum(p.ST_MIN_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_MIN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_MIN_Scen_Minimum_Posit (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_MIN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_MIN_Scen_Minimum_Annex (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_MIN_Scen_Minimum;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Skådespelare_Namn tells whether two values of AC_NAM_Skådespelare_Namn are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_NAM_Skådespelare_Namn (
    p_left IN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_Skådespelare_Namn%TYPE,
    p_right IN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_Skådespelare_Namn%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_NAM_Skådespelare_Namn;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Skådespelare_Namn is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_NAM_Skådespelare_Namn (
    p_id IN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_ID%TYPE,
    p_positor IN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_Positor%TYPE,
    p_positing IN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_PositedAt%TYPE
) RETURN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_NAM_Reliability
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Annex a
        WHERE
            a.AC_NAM_ID = p_id
        AND
            a.AC_NAM_Positor = p_positor
        AND
            a.AC_NAM_PositedAt <= p_positing
        ORDER BY
            a.AC_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_NAM_Skådespelare_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Skådespelare_Namn states a value of AC_NAM_Skådespelare_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Skådespelare_Namn (
    p_owner IN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_AC_ID%TYPE,
    p_value IN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_Skådespelare_Namn%TYPE,
    p_changing IN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_NAM_Skådespelare_Namn_Annex.AC_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_NAM_Skådespelare_Namn_Annex.Metadata_AC_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_NAM_Skådespelare_Namn_Annex (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Positor,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_NAM_Skådespelare_Namn_Annex x
                WHERE
                    x.AC_NAM_ID = p_id
                AND
                    x.AC_NAM_Positor = v_positor
                AND
                    x.AC_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Skådespelare_Namn(p.AC_NAM_Skådespelare_Namn, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Annex a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Positor = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit p
        JOIN
            attributes.AC_NAM_Skådespelare_Namn_Annex a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Skådespelare_Namn(p.AC_NAM_Skådespelare_Namn, p_value) = 0
        AND
            a.AC_NAM_Positor = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Annex a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Positor = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_NAM_Skådespelare_Namn(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_NAM_Skådespelare_Namn_Annex (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Positor,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Skådespelare_Namn(p.AC_NAM_Skådespelare_Namn, p_value) = 0
        AND
            COALESCE(attributes.he_AC_NAM_Skådespelare_Namn(p.AC_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.AC_NAM_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Skådespelare_Namn(p.AC_NAM_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN attributes.he_AC_NAM_Skådespelare_Namn(p.AC_NAM_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Skådespelare_Namn(r.AC_NAM_Skådespelare_Namn, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.AC_NAM_ID,
            f.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Posit f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Skådespelare_Namn(f.AC_NAM_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN attributes.he_AC_NAM_Skådespelare_Namn(f.AC_NAM_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Skådespelare_Namn(r.AC_NAM_Skådespelare_Namn, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_NAM_Skådespelare_Namn_Posit (
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Skådespelare_Namn
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_NAM_Skådespelare_Namn_Annex (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_NAM_Skådespelare_Namn;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Skådespelare_Kön tells whether two values of AC_GEN_Skådespelare_Kön are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_GEN_Skådespelare_Kön (
    p_left IN attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_GEN_ID%TYPE,
    p_right IN attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_GEN_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_GEN_Skådespelare_Kön;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Skådespelare_Kön is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_GEN_Skådespelare_Kön (
    p_id IN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_ID%TYPE,
    p_positor IN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_Positor%TYPE,
    p_positing IN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_PositedAt%TYPE
) RETURN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_GEN_Reliability
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Annex a
        WHERE
            a.AC_GEN_ID = p_id
        AND
            a.AC_GEN_Positor = p_positor
        AND
            a.AC_GEN_PositedAt <= p_positing
        ORDER BY
            a.AC_GEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_GEN_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_GEN_Skådespelare_Kön;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Skådespelare_Kön states a value of AC_GEN_Skådespelare_Kön
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Skådespelare_Kön (
    p_owner IN attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_GEN_ID%TYPE,
    p_positor IN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_GEN_Skådespelare_Kön_Annex.AC_GEN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_GEN_Skådespelare_Kön_Annex.Metadata_AC_GEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_GEN_Skådespelare_Kön_Annex (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Positor,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_GEN_Skådespelare_Kön_Annex x
                WHERE
                    x.AC_GEN_ID = p_id
                AND
                    x.AC_GEN_Positor = v_positor
                AND
                    x.AC_GEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Posit p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Skådespelare_Kön(p.AC_GEN_GEN_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_GEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Annex a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Positor = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Skådespelare_Kön for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Posit p
        JOIN
            attributes.AC_GEN_Skådespelare_Kön_Annex a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Skådespelare_Kön(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            a.AC_GEN_Positor = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Skådespelare_Kön for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Annex a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Positor = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_GEN_Skådespelare_Kön(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_GEN_Skådespelare_Kön_Annex (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Positor,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Posit p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Skådespelare_Kön(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_GEN_Skådespelare_Kön(p.AC_GEN_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.AC_GEN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_GEN_Skådespelare_Kön_Posit (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING AC_GEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_GEN_Skådespelare_Kön_Annex (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_GEN_Skådespelare_Kön;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Skådespelare_Yrkesnivå tells whether two values of AC_PLV_Skådespelare_Yrkesnivå are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_AC_PLV_Skådespelare_Yrkesnivå (
    p_left IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_PLV_ID%TYPE,
    p_right IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_PLV_Skådespelare_Yrkesnivå;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Skådespelare_Yrkesnivå is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_AC_PLV_Skådespelare_Yrkesnivå (
    p_id IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_ID%TYPE,
    p_positor IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_Positor%TYPE,
    p_positing IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_PositedAt%TYPE
) RETURN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_PLV_Reliability
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
        WHERE
            a.AC_PLV_ID = p_id
        AND
            a.AC_PLV_Positor = p_positor
        AND
            a.AC_PLV_PositedAt <= p_positing
        ORDER BY
            a.AC_PLV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_PLV_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_PLV_Skådespelare_Yrkesnivå;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Skådespelare_Yrkesnivå states a value of AC_PLV_Skådespelare_Yrkesnivå
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Skådespelare_Yrkesnivå (
    p_owner IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_AC_ID%TYPE,
    p_value IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_PLV_ID%TYPE,
    p_changing IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.AC_PLV_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex.Metadata_AC_PLV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Positor,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex x
                WHERE
                    x.AC_PLV_ID = p_id
                AND
                    x.AC_PLV_Positor = v_positor
                AND
                    x.AC_PLV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Skådespelare_Yrkesnivå(p.AC_PLV_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_PLV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Positor = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
        JOIN
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Skådespelare_Yrkesnivå(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            a.AC_PLV_Positor = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Positor = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_PLV_Skådespelare_Yrkesnivå(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Positor,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Skådespelare_Yrkesnivå(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_PLV_Skådespelare_Yrkesnivå(p.AC_PLV_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.AC_PLV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit (
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_PLV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_PLV_Skådespelare_Yrkesnivå;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Föreställning_Namn tells whether two values of PR_NAM_Föreställning_Namn are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_PR_NAM_Föreställning_Namn (
    p_left IN attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_Föreställning_Namn%TYPE,
    p_right IN attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_Föreställning_Namn%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_NAM_Föreställning_Namn;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Föreställning_Namn is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_PR_NAM_Föreställning_Namn (
    p_id IN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_ID%TYPE,
    p_positor IN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_Positor%TYPE,
    p_positing IN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_PositedAt%TYPE
) RETURN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_NAM_Reliability
        FROM
            attributes.PR_NAM_Föreställning_Namn_Annex a
        WHERE
            a.PR_NAM_ID = p_id
        AND
            a.PR_NAM_Positor = p_positor
        AND
            a.PR_NAM_PositedAt <= p_positing
        ORDER BY
            a.PR_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_NAM_Föreställning_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Föreställning_Namn states a value of PR_NAM_Föreställning_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Föreställning_Namn (
    p_owner IN attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_Föreställning_Namn%TYPE,
    p_positor IN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_NAM_Föreställning_Namn_Annex.PR_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_NAM_Föreställning_Namn_Annex.Metadata_PR_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_NAM_Föreställning_Namn_Annex (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Positor,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_NAM_Föreställning_Namn_Annex x
                WHERE
                    x.PR_NAM_ID = p_id
                AND
                    x.PR_NAM_Positor = v_positor
                AND
                    x.PR_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Föreställning_Namn_Posit p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Föreställning_Namn(p.PR_NAM_Föreställning_Namn, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Föreställning_Namn_Annex a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Positor = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Föreställning_Namn for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Föreställning_Namn_Posit p
        JOIN
            attributes.PR_NAM_Föreställning_Namn_Annex a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Föreställning_Namn(p.PR_NAM_Föreställning_Namn, p_value) = 0
        AND
            a.PR_NAM_Positor = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Föreställning_Namn for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Föreställning_Namn_Annex a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Positor = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_PR_NAM_Föreställning_Namn(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_NAM_Föreställning_Namn_Annex (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Positor,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Föreställning_Namn_Posit p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Föreställning_Namn(p.PR_NAM_Föreställning_Namn, p_value) = 0
        AND
            COALESCE(attributes.he_PR_NAM_Föreställning_Namn(p.PR_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.PR_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_NAM_Föreställning_Namn_Posit (
            PR_NAM_PR_ID,
            PR_NAM_Föreställning_Namn
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING PR_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_NAM_Föreställning_Namn_Annex (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_NAM_Föreställning_Namn;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Föreställning_Längd tells whether two values of PR_LEN_Föreställning_Längd are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_PR_LEN_Föreställning_Längd (
    p_left IN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_Föreställning_Längd%TYPE,
    p_right IN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_Föreställning_Längd%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_LEN_Föreställning_Längd;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Föreställning_Längd is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_PR_LEN_Föreställning_Längd (
    p_id IN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_ID%TYPE,
    p_positor IN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_Positor%TYPE,
    p_positing IN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_PositedAt%TYPE
) RETURN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_LEN_Reliability
        FROM
            attributes.PR_LEN_Föreställning_Längd_Annex a
        WHERE
            a.PR_LEN_ID = p_id
        AND
            a.PR_LEN_Positor = p_positor
        AND
            a.PR_LEN_PositedAt <= p_positing
        ORDER BY
            a.PR_LEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_LEN_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_LEN_Föreställning_Längd;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Föreställning_Längd states a value of PR_LEN_Föreställning_Längd
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Föreställning_Längd (
    p_owner IN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_PR_ID%TYPE,
    p_value IN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_Föreställning_Längd%TYPE,
    p_changing IN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_Positor%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_LEN_Föreställning_Längd_Annex.PR_LEN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_LEN_Föreställning_Längd_Annex.Metadata_PR_LEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing date;
    v_posit attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_LEN_Föreställning_Längd_Annex (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_LEN_Föreställning_Längd_Annex x
                WHERE
                    x.PR_LEN_ID = p_id
                AND
                    x.PR_LEN_Positor = v_positor
                AND
                    x.PR_LEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Föreställning_Längd(p.PR_LEN_Föreställning_Längd, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_LEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Föreställning_Längd_Annex a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Positor = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Föreställning_Längd for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit p
        JOIN
            attributes.PR_LEN_Föreställning_Längd_Annex a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Föreställning_Längd(p.PR_LEN_Föreställning_Längd, p_value) = 0
        AND
            a.PR_LEN_Positor = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Föreställning_Längd for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Föreställning_Längd_Annex a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Positor = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_PR_LEN_Föreställning_Längd(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_LEN_Föreställning_Längd_Annex (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Föreställning_Längd(p.PR_LEN_Föreställning_Längd, p_value) = 0
        AND
            COALESCE(attributes.he_PR_LEN_Föreställning_Längd(p.PR_LEN_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.PR_LEN_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Föreställning_Längd(p.PR_LEN_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN attributes.he_PR_LEN_Föreställning_Längd(p.PR_LEN_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Föreställning_Längd(r.PR_LEN_Föreställning_Längd, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.PR_LEN_ID,
            f.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd_Posit f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Föreställning_Längd(f.PR_LEN_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN attributes.he_PR_LEN_Föreställning_Längd(f.PR_LEN_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Föreställning_Längd(r.PR_LEN_Föreställning_Längd, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.PR_LEN_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_LEN_Föreställning_Längd_Posit (
            PR_LEN_PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Föreställning_Längd
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING PR_LEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_LEN_Föreställning_Längd_Annex (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_LEN_Föreställning_Längd;
/
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the positor
-- is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
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
            p_value => :NEW.ST_NAM_Scen_Namn,
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_ST_NAM, :NEW.Metadata_ST)
        );
    END IF;
    IF :NEW.ST_LOC_Scen_Plats IS NOT NULL THEN
        attributes.ip_ST_LOC_Scen_Plats(
            p_owner => COALESCE(:NEW.ST_LOC_ST_ID, v_id),
            p_value => :NEW.ST_LOC_Scen_Plats,
            p_positor => COALESCE(:NEW.ST_LOC_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_LOC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_LOC_Reliability, :NEW.Reliability, 1),
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
            p_value => v_AVG,
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_AVG_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_AVG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_AVG_Reliability, :NEW.Reliability, 1),
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
            p_positor => COALESCE(:NEW.ST_MIN_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_MIN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_MIN_Reliability, :NEW.Reliability, 1),
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
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_AVG number(3);
    v_AVG_changing timestamp;
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_ST <> :OLD.Metadata_ST
        OR (:NEW.Metadata_ST IS NULL AND :OLD.Metadata_ST IS NOT NULL)
        OR (:NEW.Metadata_ST IS NOT NULL AND :OLD.Metadata_ST IS NULL)) THEN TRUE ELSE FALSE END;
    -- ST_NAM_Scen_Namn
    IF (:NEW.ST_NAM_ID <> :OLD.ST_NAM_ID
        OR (:NEW.ST_NAM_ID IS NULL AND :OLD.ST_NAM_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ID IS NOT NULL AND :OLD.ST_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_ST_ID <> :OLD.ST_NAM_ST_ID
        OR (:NEW.ST_NAM_ST_ID IS NULL AND :OLD.ST_NAM_ST_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ST_ID IS NOT NULL AND :OLD.ST_NAM_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_NAM_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_NAM_Scen_Namn, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_NAM_Reliability <> :OLD.ST_NAM_Reliability
        OR (:NEW.ST_NAM_Reliability IS NULL AND :OLD.ST_NAM_Reliability IS NOT NULL)
        OR (:NEW.ST_NAM_Reliability IS NOT NULL AND :OLD.ST_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_NAM_Reliability;
    END IF;
    IF (:NEW.ST_NAM_Positor <> :OLD.ST_NAM_Positor
        OR (:NEW.ST_NAM_Positor IS NULL AND :OLD.ST_NAM_Positor IS NOT NULL)
        OR (:NEW.ST_NAM_Positor IS NOT NULL AND :OLD.ST_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_NAM_PositedAt <> :OLD.ST_NAM_PositedAt
        OR (:NEW.ST_NAM_PositedAt IS NULL AND :OLD.ST_NAM_PositedAt IS NOT NULL)
        OR (:NEW.ST_NAM_PositedAt IS NOT NULL AND :OLD.ST_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_NAM_Scen_Namn IS NULL THEN
        v_positing := :NEW.ST_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_NAM_Scen_Namn <> :OLD.ST_NAM_Scen_Namn
        OR (:NEW.ST_NAM_Scen_Namn IS NULL AND :OLD.ST_NAM_Scen_Namn IS NOT NULL)
        OR (:NEW.ST_NAM_Scen_Namn IS NOT NULL AND :OLD.ST_NAM_Scen_Namn IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_NAM <> :OLD.Metadata_ST_NAM
        OR (:NEW.Metadata_ST_NAM IS NULL AND :OLD.Metadata_ST_NAM IS NOT NULL)
        OR (:NEW.Metadata_ST_NAM IS NOT NULL AND :OLD.Metadata_ST_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_NAM
        END, :NEW.Metadata_ST);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.ST_NAM_Scen_Namn IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_NAM_Scen_Namn IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_NAM_Reliability IS NULL
            OR :OLD.ST_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_NAM_Positor IS NULL
            OR :OLD.ST_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_ST_NAM_Scen_Namn(
                    p_owner => COALESCE(:NEW.ST_NAM_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_NAM_Scen_Namn,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_NAM_Scen_Namn IS NULL AND :OLD.ST_NAM_Scen_Namn IS NOT NULL THEN
            attributes.ip_ST_NAM_Scen_Namn(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_NAM_Scen_Namn,
                p_changing => :OLD.ST_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_LOC_Scen_Plats
    IF (:NEW.ST_LOC_ID <> :OLD.ST_LOC_ID
        OR (:NEW.ST_LOC_ID IS NULL AND :OLD.ST_LOC_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ID IS NOT NULL AND :OLD.ST_LOC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_LOC_ID is not updatable.');
    END IF;
    IF (:NEW.ST_LOC_ST_ID <> :OLD.ST_LOC_ST_ID
        OR (:NEW.ST_LOC_ST_ID IS NULL AND :OLD.ST_LOC_ST_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ST_ID IS NOT NULL AND :OLD.ST_LOC_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_LOC_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_LOC_Scen_Plats, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_LOC_Reliability <> :OLD.ST_LOC_Reliability
        OR (:NEW.ST_LOC_Reliability IS NULL AND :OLD.ST_LOC_Reliability IS NOT NULL)
        OR (:NEW.ST_LOC_Reliability IS NOT NULL AND :OLD.ST_LOC_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_LOC_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_LOC_Reliability;
    END IF;
    IF (:NEW.ST_LOC_Positor <> :OLD.ST_LOC_Positor
        OR (:NEW.ST_LOC_Positor IS NULL AND :OLD.ST_LOC_Positor IS NOT NULL)
        OR (:NEW.ST_LOC_Positor IS NOT NULL AND :OLD.ST_LOC_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_LOC_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_LOC_PositedAt <> :OLD.ST_LOC_PositedAt
        OR (:NEW.ST_LOC_PositedAt IS NULL AND :OLD.ST_LOC_PositedAt IS NOT NULL)
        OR (:NEW.ST_LOC_PositedAt IS NOT NULL AND :OLD.ST_LOC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_LOC_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_LOC_Scen_Plats <> :OLD.ST_LOC_Scen_Plats
        OR (:NEW.ST_LOC_Scen_Plats IS NULL AND :OLD.ST_LOC_Scen_Plats IS NOT NULL)
        OR (:NEW.ST_LOC_Scen_Plats IS NOT NULL AND :OLD.ST_LOC_Scen_Plats IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_LOC <> :OLD.Metadata_ST_LOC
        OR (:NEW.Metadata_ST_LOC IS NULL AND :OLD.Metadata_ST_LOC IS NOT NULL)
        OR (:NEW.Metadata_ST_LOC IS NOT NULL AND :OLD.Metadata_ST_LOC IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_LOC
        END, :NEW.Metadata_ST);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.ST_LOC_Scen_Plats IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_LOC_Scen_Plats IS NULL
            OR v_positing_diff
            OR :OLD.ST_LOC_Reliability IS NULL
            OR :OLD.ST_LOC_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_LOC_Positor IS NULL
            OR :OLD.ST_LOC_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_ST_LOC_Scen_Plats(
                    p_owner => COALESCE(:NEW.ST_LOC_ST_ID, :NEW.ST_ID),
                    p_value => :NEW.ST_LOC_Scen_Plats,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_LOC_Scen_Plats IS NULL AND :OLD.ST_LOC_Scen_Plats IS NOT NULL THEN
            attributes.ip_ST_LOC_Scen_Plats(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_LOC_Scen_Plats,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_AVG_Scen_Medel
    IF (:NEW.ST_AVG_ID <> :OLD.ST_AVG_ID
        OR (:NEW.ST_AVG_ID IS NULL AND :OLD.ST_AVG_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ID IS NOT NULL AND :OLD.ST_AVG_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_AVG_ID is not updatable.');
    END IF;
    IF (:NEW.ST_AVG_ST_ID <> :OLD.ST_AVG_ST_ID
        OR (:NEW.ST_AVG_ST_ID IS NULL AND :OLD.ST_AVG_ST_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ST_ID IS NOT NULL AND :OLD.ST_AVG_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_AVG_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_AVG_Scen_Medel, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_AVG_Reliability <> :OLD.ST_AVG_Reliability
        OR (:NEW.ST_AVG_Reliability IS NULL AND :OLD.ST_AVG_Reliability IS NOT NULL)
        OR (:NEW.ST_AVG_Reliability IS NOT NULL AND :OLD.ST_AVG_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_AVG_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_AVG_Reliability;
    END IF;
    IF (:NEW.ST_AVG_Positor <> :OLD.ST_AVG_Positor
        OR (:NEW.ST_AVG_Positor IS NULL AND :OLD.ST_AVG_Positor IS NOT NULL)
        OR (:NEW.ST_AVG_Positor IS NOT NULL AND :OLD.ST_AVG_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_AVG_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_AVG_PositedAt <> :OLD.ST_AVG_PositedAt
        OR (:NEW.ST_AVG_PositedAt IS NULL AND :OLD.ST_AVG_PositedAt IS NOT NULL)
        OR (:NEW.ST_AVG_PositedAt IS NOT NULL AND :OLD.ST_AVG_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_AVG_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_AVG_UTL_ID IS NULL THEN
        v_positing := :NEW.ST_AVG_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_AVG_UTL_ID <> :OLD.ST_AVG_UTL_ID
        OR (:NEW.ST_AVG_UTL_ID IS NULL AND :OLD.ST_AVG_UTL_ID IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_ID IS NOT NULL AND :OLD.ST_AVG_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_AVG <> :OLD.Metadata_ST_AVG
        OR (:NEW.Metadata_ST_AVG IS NULL AND :OLD.Metadata_ST_AVG IS NOT NULL)
        OR (:NEW.Metadata_ST_AVG IS NOT NULL AND :OLD.Metadata_ST_AVG IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_AVG
        END, :NEW.Metadata_ST);
    v_knot_diff := CASE WHEN (:NEW.ST_AVG_UTL_Utnyttjande <> :OLD.ST_AVG_UTL_Utnyttjande
        OR (:NEW.ST_AVG_UTL_Utnyttjande IS NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_AVG := :NEW.ST_AVG_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_AVG := NULL;
        IF :NEW.ST_AVG_UTL_Utnyttjande IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSIF :OLD.ST_AVG_UTL_ID = v_AVG THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSE
            v_AVG_changing := v_now;
        END IF;
        IF v_AVG IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_AVG_UTL_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_AVG_Reliability IS NULL
            OR :OLD.ST_AVG_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_AVG_Positor IS NULL
            OR :OLD.ST_AVG_Positor <> v_positor
            OR :OLD.ST_AVG_UTL_ID <> v_AVG
            THEN
                attributes.ip_ST_AVG_Scen_Medel(
                    p_owner => COALESCE(:NEW.ST_AVG_ST_ID, :NEW.ST_ID),
                    p_value => v_AVG,
                    p_changing => v_AVG_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.ST_AVG_UTL_ID IS NOT NULL AND (
            :NEW.ST_AVG_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.ST_AVG_UTL_Utnyttjande IS NULL AND :OLD.ST_AVG_UTL_Utnyttjande IS NOT NULL
            )
        ) THEN
            attributes.ip_ST_AVG_Scen_Medel(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_AVG_UTL_ID,
                p_changing => :OLD.ST_AVG_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- ST_MIN_Scen_Minimum
    IF (:NEW.ST_MIN_ID <> :OLD.ST_MIN_ID
        OR (:NEW.ST_MIN_ID IS NULL AND :OLD.ST_MIN_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ID IS NOT NULL AND :OLD.ST_MIN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_MIN_ID is not updatable.');
    END IF;
    IF (:NEW.ST_MIN_ST_ID <> :OLD.ST_MIN_ST_ID
        OR (:NEW.ST_MIN_ST_ID IS NULL AND :OLD.ST_MIN_ST_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ST_ID IS NOT NULL AND :OLD.ST_MIN_ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column ST_MIN_ST_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_MIN_Scen_Minimum, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_MIN_Reliability <> :OLD.ST_MIN_Reliability
        OR (:NEW.ST_MIN_Reliability IS NULL AND :OLD.ST_MIN_Reliability IS NOT NULL)
        OR (:NEW.ST_MIN_Reliability IS NOT NULL AND :OLD.ST_MIN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_MIN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_MIN_Reliability;
    END IF;
    IF (:NEW.ST_MIN_Positor <> :OLD.ST_MIN_Positor
        OR (:NEW.ST_MIN_Positor IS NULL AND :OLD.ST_MIN_Positor IS NOT NULL)
        OR (:NEW.ST_MIN_Positor IS NOT NULL AND :OLD.ST_MIN_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_MIN_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_MIN_PositedAt <> :OLD.ST_MIN_PositedAt
        OR (:NEW.ST_MIN_PositedAt IS NULL AND :OLD.ST_MIN_PositedAt IS NOT NULL)
        OR (:NEW.ST_MIN_PositedAt IS NOT NULL AND :OLD.ST_MIN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_MIN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_MIN_UTL_ID <> :OLD.ST_MIN_UTL_ID
        OR (:NEW.ST_MIN_UTL_ID IS NULL AND :OLD.ST_MIN_UTL_ID IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_ID IS NOT NULL AND :OLD.ST_MIN_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_ST_MIN <> :OLD.Metadata_ST_MIN
        OR (:NEW.Metadata_ST_MIN IS NULL AND :OLD.Metadata_ST_MIN IS NOT NULL)
        OR (:NEW.Metadata_ST_MIN IS NOT NULL AND :OLD.Metadata_ST_MIN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_ST
            ELSE :NEW.Metadata_ST_MIN
        END, :NEW.Metadata_ST);
    v_knot_diff := CASE WHEN (:NEW.ST_MIN_UTL_Utnyttjande <> :OLD.ST_MIN_UTL_Utnyttjande
        OR (:NEW.ST_MIN_UTL_Utnyttjande IS NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_MIN := :NEW.ST_MIN_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_MIN := NULL;
        IF :NEW.ST_MIN_UTL_Utnyttjande IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_MIN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_MIN_UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.ST_MIN_Reliability IS NULL
            OR :OLD.ST_MIN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_MIN_Positor IS NULL
            OR :OLD.ST_MIN_Positor <> v_positor
            OR :OLD.ST_MIN_UTL_ID <> v_MIN
            THEN
                attributes.ip_ST_MIN_Scen_Minimum(
                    p_owner => COALESCE(:NEW.ST_MIN_ST_ID, :NEW.ST_ID),
                    p_value => v_MIN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.ST_MIN_UTL_ID IS NOT NULL AND (
            :NEW.ST_MIN_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.ST_MIN_UTL_Utnyttjande IS NULL AND :OLD.ST_MIN_UTL_Utnyttjande IS NOT NULL
            )
        ) THEN
            attributes.ip_ST_MIN_Scen_Minimum(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_MIN_UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lST_Scen;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Scen instead of DELETE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER anchors.dt_lST_Scen
INSTEAD OF DELETE ON anchors.lST_Scen
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of ST_NAM_Scen_Namn is retracted
    INSERT INTO attributes.ST_NAM_Scen_Namn_Annex (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_ST_NAM,
        :OLD.ST_NAM_ID,
        COALESCE(:OLD.ST_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_NAM_Scen_Namn_Annex x
            WHERE
                x.ST_NAM_ID = :OLD.ST_NAM_ID
            AND
                x.ST_NAM_Positor = COALESCE(:OLD.ST_NAM_Positor, :OLD.Positor, 0)
            AND
                x.ST_NAM_PositedAt = v_now
        );
    -- what is shown of ST_LOC_Scen_Plats is retracted
    INSERT INTO attributes.ST_LOC_Scen_Plats_Annex (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        :OLD.Metadata_ST_LOC,
        :OLD.ST_LOC_ID,
        COALESCE(:OLD.ST_LOC_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_LOC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_LOC_Scen_Plats_Annex x
            WHERE
                x.ST_LOC_ID = :OLD.ST_LOC_ID
            AND
                x.ST_LOC_Positor = COALESCE(:OLD.ST_LOC_Positor, :OLD.Positor, 0)
            AND
                x.ST_LOC_PositedAt = v_now
        );
    -- what is shown of ST_AVG_Scen_Medel is retracted
    INSERT INTO attributes.ST_AVG_Scen_Medel_Annex (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        :OLD.Metadata_ST_AVG,
        :OLD.ST_AVG_ID,
        COALESCE(:OLD.ST_AVG_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_AVG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_AVG_Scen_Medel_Annex x
            WHERE
                x.ST_AVG_ID = :OLD.ST_AVG_ID
            AND
                x.ST_AVG_Positor = COALESCE(:OLD.ST_AVG_Positor, :OLD.Positor, 0)
            AND
                x.ST_AVG_PositedAt = v_now
        );
    -- what is shown of ST_MIN_Scen_Minimum is retracted
    INSERT INTO attributes.ST_MIN_Scen_Minimum_Annex (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        :OLD.Metadata_ST_MIN,
        :OLD.ST_MIN_ID,
        COALESCE(:OLD.ST_MIN_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_MIN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.ST_MIN_Scen_Minimum_Annex x
            WHERE
                x.ST_MIN_ID = :OLD.ST_MIN_ID
            AND
                x.ST_MIN_Positor = COALESCE(:OLD.ST_MIN_Positor, :OLD.Positor, 0)
            AND
                x.ST_MIN_PositedAt = v_now
        );
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
            p_value => :NEW.AC_NAM_Skådespelare_Namn,
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.AC_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_NAM_Reliability, :NEW.Reliability, 1),
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
            p_positor => COALESCE(:NEW.AC_GEN_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.AC_GEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_GEN_Reliability, :NEW.Reliability, 1),
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
            p_value => v_PLV,
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_PLV_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.AC_PLV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_PLV_Reliability, :NEW.Reliability, 1),
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
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_GEN number(3);
    v_PLV number(3);
    v_PLV_changing timestamp;
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_AC <> :OLD.Metadata_AC
        OR (:NEW.Metadata_AC IS NULL AND :OLD.Metadata_AC IS NOT NULL)
        OR (:NEW.Metadata_AC IS NOT NULL AND :OLD.Metadata_AC IS NULL)) THEN TRUE ELSE FALSE END;
    -- AC_NAM_Skådespelare_Namn
    IF (:NEW.AC_NAM_ID <> :OLD.AC_NAM_ID
        OR (:NEW.AC_NAM_ID IS NULL AND :OLD.AC_NAM_ID IS NOT NULL)
        OR (:NEW.AC_NAM_ID IS NOT NULL AND :OLD.AC_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_AC_ID <> :OLD.AC_NAM_AC_ID
        OR (:NEW.AC_NAM_AC_ID IS NULL AND :OLD.AC_NAM_AC_ID IS NOT NULL)
        OR (:NEW.AC_NAM_AC_ID IS NOT NULL AND :OLD.AC_NAM_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_NAM_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_NAM_Skådespelare_Namn, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_NAM_Reliability <> :OLD.AC_NAM_Reliability
        OR (:NEW.AC_NAM_Reliability IS NULL AND :OLD.AC_NAM_Reliability IS NOT NULL)
        OR (:NEW.AC_NAM_Reliability IS NOT NULL AND :OLD.AC_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_NAM_Reliability;
    END IF;
    IF (:NEW.AC_NAM_Positor <> :OLD.AC_NAM_Positor
        OR (:NEW.AC_NAM_Positor IS NULL AND :OLD.AC_NAM_Positor IS NOT NULL)
        OR (:NEW.AC_NAM_Positor IS NOT NULL AND :OLD.AC_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_NAM_PositedAt <> :OLD.AC_NAM_PositedAt
        OR (:NEW.AC_NAM_PositedAt IS NULL AND :OLD.AC_NAM_PositedAt IS NOT NULL)
        OR (:NEW.AC_NAM_PositedAt IS NOT NULL AND :OLD.AC_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_NAM_Skådespelare_Namn IS NULL THEN
        v_positing := :NEW.AC_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_NAM_Skådespelare_Namn <> :OLD.AC_NAM_Skådespelare_Namn
        OR (:NEW.AC_NAM_Skådespelare_Namn IS NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NOT NULL)
        OR (:NEW.AC_NAM_Skådespelare_Namn IS NOT NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_NAM <> :OLD.Metadata_AC_NAM
        OR (:NEW.Metadata_AC_NAM IS NULL AND :OLD.Metadata_AC_NAM IS NOT NULL)
        OR (:NEW.Metadata_AC_NAM IS NOT NULL AND :OLD.Metadata_AC_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_NAM
        END, :NEW.Metadata_AC);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.AC_NAM_Skådespelare_Namn IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_NAM_Skådespelare_Namn IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_NAM_Reliability IS NULL
            OR :OLD.AC_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_NAM_Positor IS NULL
            OR :OLD.AC_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_AC_NAM_Skådespelare_Namn(
                    p_owner => COALESCE(:NEW.AC_NAM_AC_ID, :NEW.AC_ID),
                    p_value => :NEW.AC_NAM_Skådespelare_Namn,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.AC_NAM_Skådespelare_Namn IS NULL AND :OLD.AC_NAM_Skådespelare_Namn IS NOT NULL THEN
            attributes.ip_AC_NAM_Skådespelare_Namn(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_NAM_Skådespelare_Namn,
                p_changing => :OLD.AC_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- AC_GEN_Skådespelare_Kön
    IF (:NEW.AC_GEN_ID <> :OLD.AC_GEN_ID
        OR (:NEW.AC_GEN_ID IS NULL AND :OLD.AC_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_ID IS NOT NULL AND :OLD.AC_GEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_GEN_ID is not updatable.');
    END IF;
    IF (:NEW.AC_GEN_AC_ID <> :OLD.AC_GEN_AC_ID
        OR (:NEW.AC_GEN_AC_ID IS NULL AND :OLD.AC_GEN_AC_ID IS NOT NULL)
        OR (:NEW.AC_GEN_AC_ID IS NOT NULL AND :OLD.AC_GEN_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_GEN_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_GEN_Skådespelare_Kön, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_GEN_Reliability <> :OLD.AC_GEN_Reliability
        OR (:NEW.AC_GEN_Reliability IS NULL AND :OLD.AC_GEN_Reliability IS NOT NULL)
        OR (:NEW.AC_GEN_Reliability IS NOT NULL AND :OLD.AC_GEN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_GEN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_GEN_Reliability;
    END IF;
    IF (:NEW.AC_GEN_Positor <> :OLD.AC_GEN_Positor
        OR (:NEW.AC_GEN_Positor IS NULL AND :OLD.AC_GEN_Positor IS NOT NULL)
        OR (:NEW.AC_GEN_Positor IS NOT NULL AND :OLD.AC_GEN_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_GEN_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_GEN_PositedAt <> :OLD.AC_GEN_PositedAt
        OR (:NEW.AC_GEN_PositedAt IS NULL AND :OLD.AC_GEN_PositedAt IS NOT NULL)
        OR (:NEW.AC_GEN_PositedAt IS NOT NULL AND :OLD.AC_GEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_GEN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_GEN_GEN_ID <> :OLD.AC_GEN_GEN_ID
        OR (:NEW.AC_GEN_GEN_ID IS NULL AND :OLD.AC_GEN_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_ID IS NOT NULL AND :OLD.AC_GEN_GEN_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_GEN <> :OLD.Metadata_AC_GEN
        OR (:NEW.Metadata_AC_GEN IS NULL AND :OLD.Metadata_AC_GEN IS NOT NULL)
        OR (:NEW.Metadata_AC_GEN IS NOT NULL AND :OLD.Metadata_AC_GEN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_GEN
        END, :NEW.Metadata_AC);
    v_knot_diff := CASE WHEN (:NEW.AC_GEN_GEN_Kön <> :OLD.AC_GEN_GEN_Kön
        OR (:NEW.AC_GEN_GEN_Kön IS NULL AND :OLD.AC_GEN_GEN_Kön IS NOT NULL)
        OR (:NEW.AC_GEN_GEN_Kön IS NOT NULL AND :OLD.AC_GEN_GEN_Kön IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GEN := :NEW.AC_GEN_GEN_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_GEN := NULL;
        IF :NEW.AC_GEN_GEN_Kön IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_GEN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_GEN_GEN_ID IS NULL
            OR v_positing_diff
            OR :OLD.AC_GEN_Reliability IS NULL
            OR :OLD.AC_GEN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_GEN_Positor IS NULL
            OR :OLD.AC_GEN_Positor <> v_positor
            OR :OLD.AC_GEN_GEN_ID <> v_GEN
            THEN
                attributes.ip_AC_GEN_Skådespelare_Kön(
                    p_owner => COALESCE(:NEW.AC_GEN_AC_ID, :NEW.AC_ID),
                    p_value => v_GEN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.AC_GEN_GEN_ID IS NOT NULL AND (
            :NEW.AC_GEN_GEN_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.AC_GEN_GEN_Kön IS NULL AND :OLD.AC_GEN_GEN_Kön IS NOT NULL
            )
        ) THEN
            attributes.ip_AC_GEN_Skådespelare_Kön(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_GEN_GEN_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- AC_PLV_Skådespelare_Yrkesnivå
    IF (:NEW.AC_PLV_ID <> :OLD.AC_PLV_ID
        OR (:NEW.AC_PLV_ID IS NULL AND :OLD.AC_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_ID IS NOT NULL AND :OLD.AC_PLV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_PLV_ID is not updatable.');
    END IF;
    IF (:NEW.AC_PLV_AC_ID <> :OLD.AC_PLV_AC_ID
        OR (:NEW.AC_PLV_AC_ID IS NULL AND :OLD.AC_PLV_AC_ID IS NOT NULL)
        OR (:NEW.AC_PLV_AC_ID IS NOT NULL AND :OLD.AC_PLV_AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column AC_PLV_AC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_PLV_Skådespelare_Yrkesnivå, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_PLV_Reliability <> :OLD.AC_PLV_Reliability
        OR (:NEW.AC_PLV_Reliability IS NULL AND :OLD.AC_PLV_Reliability IS NOT NULL)
        OR (:NEW.AC_PLV_Reliability IS NOT NULL AND :OLD.AC_PLV_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_PLV_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_PLV_Reliability;
    END IF;
    IF (:NEW.AC_PLV_Positor <> :OLD.AC_PLV_Positor
        OR (:NEW.AC_PLV_Positor IS NULL AND :OLD.AC_PLV_Positor IS NOT NULL)
        OR (:NEW.AC_PLV_Positor IS NOT NULL AND :OLD.AC_PLV_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_PLV_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_PLV_PositedAt <> :OLD.AC_PLV_PositedAt
        OR (:NEW.AC_PLV_PositedAt IS NULL AND :OLD.AC_PLV_PositedAt IS NOT NULL)
        OR (:NEW.AC_PLV_PositedAt IS NOT NULL AND :OLD.AC_PLV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_PLV_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_PLV_PLV_ID IS NULL THEN
        v_positing := :NEW.AC_PLV_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_PLV_PLV_ID <> :OLD.AC_PLV_PLV_ID
        OR (:NEW.AC_PLV_PLV_ID IS NULL AND :OLD.AC_PLV_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_ID IS NOT NULL AND :OLD.AC_PLV_PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_AC_PLV <> :OLD.Metadata_AC_PLV
        OR (:NEW.Metadata_AC_PLV IS NULL AND :OLD.Metadata_AC_PLV IS NOT NULL)
        OR (:NEW.Metadata_AC_PLV IS NOT NULL AND :OLD.Metadata_AC_PLV IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_AC
            ELSE :NEW.Metadata_AC_PLV
        END, :NEW.Metadata_AC);
    v_knot_diff := CASE WHEN (:NEW.AC_PLV_PLV_Yrkesnivå <> :OLD.AC_PLV_PLV_Yrkesnivå
        OR (:NEW.AC_PLV_PLV_Yrkesnivå IS NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NOT NULL)
        OR (:NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_PLV := :NEW.AC_PLV_PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_PLV := NULL;
        IF :NEW.AC_PLV_PLV_Yrkesnivå IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSIF :OLD.AC_PLV_PLV_ID = v_PLV THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSE
            v_PLV_changing := v_now;
        END IF;
        IF v_PLV IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_PLV_PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_PLV_Reliability IS NULL
            OR :OLD.AC_PLV_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_PLV_Positor IS NULL
            OR :OLD.AC_PLV_Positor <> v_positor
            OR :OLD.AC_PLV_PLV_ID <> v_PLV
            THEN
                attributes.ip_AC_PLV_Skådespelare_Yrkesnivå(
                    p_owner => COALESCE(:NEW.AC_PLV_AC_ID, :NEW.AC_ID),
                    p_value => v_PLV,
                    p_changing => v_PLV_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.AC_PLV_PLV_ID IS NOT NULL AND (
            :NEW.AC_PLV_PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.AC_PLV_PLV_Yrkesnivå IS NULL AND :OLD.AC_PLV_PLV_Yrkesnivå IS NOT NULL
            )
        ) THEN
            attributes.ip_AC_PLV_Skådespelare_Yrkesnivå(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_PLV_PLV_ID,
                p_changing => :OLD.AC_PLV_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of AC_NAM_Skådespelare_Namn is retracted
    INSERT INTO attributes.AC_NAM_Skådespelare_Namn_Annex (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_AC_NAM,
        :OLD.AC_NAM_ID,
        COALESCE(:OLD.AC_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_NAM_Skådespelare_Namn_Annex x
            WHERE
                x.AC_NAM_ID = :OLD.AC_NAM_ID
            AND
                x.AC_NAM_Positor = COALESCE(:OLD.AC_NAM_Positor, :OLD.Positor, 0)
            AND
                x.AC_NAM_PositedAt = v_now
        );
    -- what is shown of AC_GEN_Skådespelare_Kön is retracted
    INSERT INTO attributes.AC_GEN_Skådespelare_Kön_Annex (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        :OLD.Metadata_AC_GEN,
        :OLD.AC_GEN_ID,
        COALESCE(:OLD.AC_GEN_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_GEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_GEN_Skådespelare_Kön_Annex x
            WHERE
                x.AC_GEN_ID = :OLD.AC_GEN_ID
            AND
                x.AC_GEN_Positor = COALESCE(:OLD.AC_GEN_Positor, :OLD.Positor, 0)
            AND
                x.AC_GEN_PositedAt = v_now
        );
    -- what is shown of AC_PLV_Skådespelare_Yrkesnivå is retracted
    INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        :OLD.Metadata_AC_PLV,
        :OLD.AC_PLV_ID,
        COALESCE(:OLD.AC_PLV_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_PLV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex x
            WHERE
                x.AC_PLV_ID = :OLD.AC_PLV_ID
            AND
                x.AC_PLV_Positor = COALESCE(:OLD.AC_PLV_Positor, :OLD.Positor, 0)
            AND
                x.AC_PLV_PositedAt = v_now
        );
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
            p_positor => COALESCE(:NEW.PR_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.PR_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_NAM_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_PR_NAM, :NEW.Metadata_PR)
        );
    END IF;
    IF :NEW.PR_LEN_Föreställning_Längd IS NOT NULL THEN
        attributes.ip_PR_LEN_Föreställning_Längd(
            p_owner => COALESCE(:NEW.PR_LEN_PR_ID, v_id),
            p_value => :NEW.PR_LEN_Föreställning_Längd,
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.PR_LEN_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.PR_LEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_LEN_Reliability, :NEW.Reliability, 1),
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
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_anchor_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_LEN_changing date;
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_anchor_meta_diff := CASE WHEN (:NEW.Metadata_PR <> :OLD.Metadata_PR
        OR (:NEW.Metadata_PR IS NULL AND :OLD.Metadata_PR IS NOT NULL)
        OR (:NEW.Metadata_PR IS NOT NULL AND :OLD.Metadata_PR IS NULL)) THEN TRUE ELSE FALSE END;
    -- PR_NAM_Föreställning_Namn
    IF (:NEW.PR_NAM_ID <> :OLD.PR_NAM_ID
        OR (:NEW.PR_NAM_ID IS NULL AND :OLD.PR_NAM_ID IS NOT NULL)
        OR (:NEW.PR_NAM_ID IS NOT NULL AND :OLD.PR_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_NAM_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_PR_ID <> :OLD.PR_NAM_PR_ID
        OR (:NEW.PR_NAM_PR_ID IS NULL AND :OLD.PR_NAM_PR_ID IS NOT NULL)
        OR (:NEW.PR_NAM_PR_ID IS NOT NULL AND :OLD.PR_NAM_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_NAM_PR_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_NAM_Föreställning_Namn, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_NAM_Reliability <> :OLD.PR_NAM_Reliability
        OR (:NEW.PR_NAM_Reliability IS NULL AND :OLD.PR_NAM_Reliability IS NOT NULL)
        OR (:NEW.PR_NAM_Reliability IS NOT NULL AND :OLD.PR_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.PR_NAM_Reliability;
    END IF;
    IF (:NEW.PR_NAM_Positor <> :OLD.PR_NAM_Positor
        OR (:NEW.PR_NAM_Positor IS NULL AND :OLD.PR_NAM_Positor IS NOT NULL)
        OR (:NEW.PR_NAM_Positor IS NOT NULL AND :OLD.PR_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_NAM_PositedAt <> :OLD.PR_NAM_PositedAt
        OR (:NEW.PR_NAM_PositedAt IS NULL AND :OLD.PR_NAM_PositedAt IS NOT NULL)
        OR (:NEW.PR_NAM_PositedAt IS NOT NULL AND :OLD.PR_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_NAM_Föreställning_Namn <> :OLD.PR_NAM_Föreställning_Namn
        OR (:NEW.PR_NAM_Föreställning_Namn IS NULL AND :OLD.PR_NAM_Föreställning_Namn IS NOT NULL)
        OR (:NEW.PR_NAM_Föreställning_Namn IS NOT NULL AND :OLD.PR_NAM_Föreställning_Namn IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_PR_NAM <> :OLD.Metadata_PR_NAM
        OR (:NEW.Metadata_PR_NAM IS NULL AND :OLD.Metadata_PR_NAM IS NOT NULL)
        OR (:NEW.Metadata_PR_NAM IS NOT NULL AND :OLD.Metadata_PR_NAM IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_PR
            ELSE :NEW.Metadata_PR_NAM
        END, :NEW.Metadata_PR);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.PR_NAM_Föreställning_Namn IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_NAM_Föreställning_Namn IS NULL
            OR v_positing_diff
            OR :OLD.PR_NAM_Reliability IS NULL
            OR :OLD.PR_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.PR_NAM_Positor IS NULL
            OR :OLD.PR_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_PR_NAM_Föreställning_Namn(
                    p_owner => COALESCE(:NEW.PR_NAM_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_NAM_Föreställning_Namn,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_NAM_Föreställning_Namn IS NULL AND :OLD.PR_NAM_Föreställning_Namn IS NOT NULL THEN
            attributes.ip_PR_NAM_Föreställning_Namn(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_NAM_Föreställning_Namn,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- PR_LEN_Föreställning_Längd
    IF (:NEW.PR_LEN_ID <> :OLD.PR_LEN_ID
        OR (:NEW.PR_LEN_ID IS NULL AND :OLD.PR_LEN_ID IS NOT NULL)
        OR (:NEW.PR_LEN_ID IS NOT NULL AND :OLD.PR_LEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_LEN_ID is not updatable.');
    END IF;
    IF (:NEW.PR_LEN_PR_ID <> :OLD.PR_LEN_PR_ID
        OR (:NEW.PR_LEN_PR_ID IS NULL AND :OLD.PR_LEN_PR_ID IS NOT NULL)
        OR (:NEW.PR_LEN_PR_ID IS NOT NULL AND :OLD.PR_LEN_PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column PR_LEN_PR_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_LEN_Föreställning_Längd, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_LEN_Reliability <> :OLD.PR_LEN_Reliability
        OR (:NEW.PR_LEN_Reliability IS NULL AND :OLD.PR_LEN_Reliability IS NOT NULL)
        OR (:NEW.PR_LEN_Reliability IS NOT NULL AND :OLD.PR_LEN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_LEN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.PR_LEN_Reliability;
    END IF;
    IF (:NEW.PR_LEN_Positor <> :OLD.PR_LEN_Positor
        OR (:NEW.PR_LEN_Positor IS NULL AND :OLD.PR_LEN_Positor IS NOT NULL)
        OR (:NEW.PR_LEN_Positor IS NOT NULL AND :OLD.PR_LEN_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_LEN_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_LEN_PositedAt <> :OLD.PR_LEN_PositedAt
        OR (:NEW.PR_LEN_PositedAt IS NULL AND :OLD.PR_LEN_PositedAt IS NOT NULL)
        OR (:NEW.PR_LEN_PositedAt IS NOT NULL AND :OLD.PR_LEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_LEN_PositedAt;
    ELSIF v_changing_diff AND :NEW.PR_LEN_Föreställning_Längd IS NULL THEN
        v_positing := :NEW.PR_LEN_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_LEN_Föreställning_Längd <> :OLD.PR_LEN_Föreställning_Längd
        OR (:NEW.PR_LEN_Föreställning_Längd IS NULL AND :OLD.PR_LEN_Föreställning_Längd IS NOT NULL)
        OR (:NEW.PR_LEN_Föreställning_Längd IS NOT NULL AND :OLD.PR_LEN_Föreställning_Längd IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_PR_LEN <> :OLD.Metadata_PR_LEN
        OR (:NEW.Metadata_PR_LEN IS NULL AND :OLD.Metadata_PR_LEN IS NOT NULL)
        OR (:NEW.Metadata_PR_LEN IS NOT NULL AND :OLD.Metadata_PR_LEN IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_anchor_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_PR
            ELSE :NEW.Metadata_PR_LEN
        END, :NEW.Metadata_PR);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSE
            v_LEN_changing := v_now;
        END IF;
        IF :NEW.PR_LEN_Föreställning_Längd IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_LEN_Föreställning_Längd IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.PR_LEN_Reliability IS NULL
            OR :OLD.PR_LEN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.PR_LEN_Positor IS NULL
            OR :OLD.PR_LEN_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_PR_LEN_Föreställning_Längd(
                    p_owner => COALESCE(:NEW.PR_LEN_PR_ID, :NEW.PR_ID),
                    p_value => :NEW.PR_LEN_Föreställning_Längd,
                    p_changing => v_LEN_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_LEN_Föreställning_Längd IS NULL AND :OLD.PR_LEN_Föreställning_Längd IS NOT NULL THEN
            attributes.ip_PR_LEN_Föreställning_Längd(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_LEN_Föreställning_Längd,
                p_changing => :OLD.PR_LEN_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of PR_NAM_Föreställning_Namn is retracted
    INSERT INTO attributes.PR_NAM_Föreställning_Namn_Annex (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        :OLD.Metadata_PR_NAM,
        :OLD.PR_NAM_ID,
        COALESCE(:OLD.PR_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.PR_NAM_Föreställning_Namn_Annex x
            WHERE
                x.PR_NAM_ID = :OLD.PR_NAM_ID
            AND
                x.PR_NAM_Positor = COALESCE(:OLD.PR_NAM_Positor, :OLD.Positor, 0)
            AND
                x.PR_NAM_PositedAt = v_now
        );
    -- what is shown of PR_LEN_Föreställning_Längd is retracted
    INSERT INTO attributes.PR_LEN_Föreställning_Längd_Annex (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        :OLD.Metadata_PR_LEN,
        :OLD.PR_LEN_ID,
        COALESCE(:OLD.PR_LEN_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_LEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.PR_LEN_Föreställning_Längd_Annex x
            WHERE
                x.PR_LEN_ID = :OLD.PR_LEN_ID
            AND
                x.PR_LEN_Positor = COALESCE(:OLD.PR_LEN_Positor, :OLD.Positor, 0)
            AND
                x.PR_LEN_PositedAt = v_now
        );
END dt_lPR_Föreställning;
/
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the positor
-- is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
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
    v_UTL number(3);
    v_LVL number(3);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO nexuses.EV_Händelse (
            ST_ID_hölls,
            PR_ID_spelades,
            ETY_ID_of,
            Metadata_EV
        )
        VALUES (
            :NEW.ST_ID_hölls,
            :NEW.PR_ID_spelades,
            :NEW.ETY_ID_of,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_DAT_Händelse_Datum IS NOT NULL THEN
        attributes.ip_EV_DAT_Händelse_Datum(
            p_owner => COALESCE(:NEW.EV_DAT_EV_ID, v_id),
            p_value => :NEW.EV_DAT_Händelse_Datum,
            p_positor => COALESCE(:NEW.EV_DAT_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_DAT_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_DAT_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_DAT, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_AUD_Händelse_Publik IS NOT NULL THEN
        attributes.ip_EV_AUD_Händelse_Publik(
            p_owner => COALESCE(:NEW.EV_AUD_EV_ID, v_id),
            p_value => :NEW.EV_AUD_Händelse_Publik,
            p_positor => COALESCE(:NEW.EV_AUD_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_AUD_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_AUD_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_AUD, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_REV_Händelse_Intäkt IS NOT NULL THEN
        attributes.ip_EV_REV_Händelse_Intäkt(
            p_owner => COALESCE(:NEW.EV_REV_EV_ID, v_id),
            p_value => :NEW.EV_REV_Händelse_Intäkt,
            p_positor => COALESCE(:NEW.EV_REV_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_REV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_REV_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_REV, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_STA_Händelse_Status IS NOT NULL THEN
        attributes.ip_EV_STA_Händelse_Status(
            p_owner => COALESCE(:NEW.EV_STA_EV_ID, v_id),
            p_value => :NEW.EV_STA_Händelse_Status,
            p_changing => COALESCE(:NEW.EV_STA_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_STA_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_STA_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_STA_Reliability, :NEW.Reliability, 1),
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
            p_positor => COALESCE(:NEW.EV_UTL_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_UTL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_UTL_Reliability, :NEW.Reliability, 1),
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
            p_value => v_LVL,
            p_changing => COALESCE(:NEW.EV_LVL_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_LVL_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_LVL_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_LVL_Reliability, :NEW.Reliability, 1),
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
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_nexus_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_STA_changing timestamp;
    v_UTL number(3);
    v_LVL number(3);
    v_LVL_changing date;
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
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_nexus_meta_diff := CASE WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
        OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
        OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL)) THEN TRUE ELSE FALSE END;
    -- EV_DAT_Händelse_Datum
    IF (:NEW.EV_DAT_ID <> :OLD.EV_DAT_ID
        OR (:NEW.EV_DAT_ID IS NULL AND :OLD.EV_DAT_ID IS NOT NULL)
        OR (:NEW.EV_DAT_ID IS NOT NULL AND :OLD.EV_DAT_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_DAT_ID is not updatable.');
    END IF;
    IF (:NEW.EV_DAT_EV_ID <> :OLD.EV_DAT_EV_ID
        OR (:NEW.EV_DAT_EV_ID IS NULL AND :OLD.EV_DAT_EV_ID IS NOT NULL)
        OR (:NEW.EV_DAT_EV_ID IS NOT NULL AND :OLD.EV_DAT_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_DAT_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_DAT_Händelse_Datum, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_DAT_Reliability <> :OLD.EV_DAT_Reliability
        OR (:NEW.EV_DAT_Reliability IS NULL AND :OLD.EV_DAT_Reliability IS NOT NULL)
        OR (:NEW.EV_DAT_Reliability IS NOT NULL AND :OLD.EV_DAT_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_DAT_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_DAT_Reliability;
    END IF;
    IF (:NEW.EV_DAT_Positor <> :OLD.EV_DAT_Positor
        OR (:NEW.EV_DAT_Positor IS NULL AND :OLD.EV_DAT_Positor IS NOT NULL)
        OR (:NEW.EV_DAT_Positor IS NOT NULL AND :OLD.EV_DAT_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_DAT_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_DAT_PositedAt <> :OLD.EV_DAT_PositedAt
        OR (:NEW.EV_DAT_PositedAt IS NULL AND :OLD.EV_DAT_PositedAt IS NOT NULL)
        OR (:NEW.EV_DAT_PositedAt IS NOT NULL AND :OLD.EV_DAT_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_DAT_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_DAT_Händelse_Datum <> :OLD.EV_DAT_Händelse_Datum
        OR (:NEW.EV_DAT_Händelse_Datum IS NULL AND :OLD.EV_DAT_Händelse_Datum IS NOT NULL)
        OR (:NEW.EV_DAT_Händelse_Datum IS NOT NULL AND :OLD.EV_DAT_Händelse_Datum IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_DAT <> :OLD.Metadata_EV_DAT
        OR (:NEW.Metadata_EV_DAT IS NULL AND :OLD.Metadata_EV_DAT IS NOT NULL)
        OR (:NEW.Metadata_EV_DAT IS NOT NULL AND :OLD.Metadata_EV_DAT IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_DAT
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_DAT_Händelse_Datum IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_DAT_Händelse_Datum IS NULL
            OR v_positing_diff
            OR :OLD.EV_DAT_Reliability IS NULL
            OR :OLD.EV_DAT_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_DAT_Positor IS NULL
            OR :OLD.EV_DAT_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_DAT_Händelse_Datum(
                    p_owner => COALESCE(:NEW.EV_DAT_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_DAT_Händelse_Datum,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_DAT_Händelse_Datum IS NULL AND :OLD.EV_DAT_Händelse_Datum IS NOT NULL THEN
            attributes.ip_EV_DAT_Händelse_Datum(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_DAT_Händelse_Datum,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_AUD_Händelse_Publik
    IF (:NEW.EV_AUD_ID <> :OLD.EV_AUD_ID
        OR (:NEW.EV_AUD_ID IS NULL AND :OLD.EV_AUD_ID IS NOT NULL)
        OR (:NEW.EV_AUD_ID IS NOT NULL AND :OLD.EV_AUD_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_AUD_ID is not updatable.');
    END IF;
    IF (:NEW.EV_AUD_EV_ID <> :OLD.EV_AUD_EV_ID
        OR (:NEW.EV_AUD_EV_ID IS NULL AND :OLD.EV_AUD_EV_ID IS NOT NULL)
        OR (:NEW.EV_AUD_EV_ID IS NOT NULL AND :OLD.EV_AUD_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_AUD_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_AUD_Händelse_Publik, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_AUD_Reliability <> :OLD.EV_AUD_Reliability
        OR (:NEW.EV_AUD_Reliability IS NULL AND :OLD.EV_AUD_Reliability IS NOT NULL)
        OR (:NEW.EV_AUD_Reliability IS NOT NULL AND :OLD.EV_AUD_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_AUD_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_AUD_Reliability;
    END IF;
    IF (:NEW.EV_AUD_Positor <> :OLD.EV_AUD_Positor
        OR (:NEW.EV_AUD_Positor IS NULL AND :OLD.EV_AUD_Positor IS NOT NULL)
        OR (:NEW.EV_AUD_Positor IS NOT NULL AND :OLD.EV_AUD_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_AUD_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_AUD_PositedAt <> :OLD.EV_AUD_PositedAt
        OR (:NEW.EV_AUD_PositedAt IS NULL AND :OLD.EV_AUD_PositedAt IS NOT NULL)
        OR (:NEW.EV_AUD_PositedAt IS NOT NULL AND :OLD.EV_AUD_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_AUD_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_AUD_Händelse_Publik <> :OLD.EV_AUD_Händelse_Publik
        OR (:NEW.EV_AUD_Händelse_Publik IS NULL AND :OLD.EV_AUD_Händelse_Publik IS NOT NULL)
        OR (:NEW.EV_AUD_Händelse_Publik IS NOT NULL AND :OLD.EV_AUD_Händelse_Publik IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_AUD <> :OLD.Metadata_EV_AUD
        OR (:NEW.Metadata_EV_AUD IS NULL AND :OLD.Metadata_EV_AUD IS NOT NULL)
        OR (:NEW.Metadata_EV_AUD IS NOT NULL AND :OLD.Metadata_EV_AUD IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_AUD
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_AUD_Händelse_Publik IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_AUD_Händelse_Publik IS NULL
            OR v_positing_diff
            OR :OLD.EV_AUD_Reliability IS NULL
            OR :OLD.EV_AUD_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_AUD_Positor IS NULL
            OR :OLD.EV_AUD_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_AUD_Händelse_Publik(
                    p_owner => COALESCE(:NEW.EV_AUD_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_AUD_Händelse_Publik,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_AUD_Händelse_Publik IS NULL AND :OLD.EV_AUD_Händelse_Publik IS NOT NULL THEN
            attributes.ip_EV_AUD_Händelse_Publik(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_AUD_Händelse_Publik,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_REV_Händelse_Intäkt
    IF (:NEW.EV_REV_ID <> :OLD.EV_REV_ID
        OR (:NEW.EV_REV_ID IS NULL AND :OLD.EV_REV_ID IS NOT NULL)
        OR (:NEW.EV_REV_ID IS NOT NULL AND :OLD.EV_REV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_REV_ID is not updatable.');
    END IF;
    IF (:NEW.EV_REV_EV_ID <> :OLD.EV_REV_EV_ID
        OR (:NEW.EV_REV_EV_ID IS NULL AND :OLD.EV_REV_EV_ID IS NOT NULL)
        OR (:NEW.EV_REV_EV_ID IS NOT NULL AND :OLD.EV_REV_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_REV_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_REV_Händelse_Intäkt, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_REV_Reliability <> :OLD.EV_REV_Reliability
        OR (:NEW.EV_REV_Reliability IS NULL AND :OLD.EV_REV_Reliability IS NOT NULL)
        OR (:NEW.EV_REV_Reliability IS NOT NULL AND :OLD.EV_REV_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_REV_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_REV_Reliability;
    END IF;
    IF (:NEW.EV_REV_Positor <> :OLD.EV_REV_Positor
        OR (:NEW.EV_REV_Positor IS NULL AND :OLD.EV_REV_Positor IS NOT NULL)
        OR (:NEW.EV_REV_Positor IS NOT NULL AND :OLD.EV_REV_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_REV_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_REV_PositedAt <> :OLD.EV_REV_PositedAt
        OR (:NEW.EV_REV_PositedAt IS NULL AND :OLD.EV_REV_PositedAt IS NOT NULL)
        OR (:NEW.EV_REV_PositedAt IS NOT NULL AND :OLD.EV_REV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_REV_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_REV_Händelse_Intäkt <> :OLD.EV_REV_Händelse_Intäkt
        OR (:NEW.EV_REV_Händelse_Intäkt IS NULL AND :OLD.EV_REV_Händelse_Intäkt IS NOT NULL)
        OR (:NEW.EV_REV_Händelse_Intäkt IS NOT NULL AND :OLD.EV_REV_Händelse_Intäkt IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_REV <> :OLD.Metadata_EV_REV
        OR (:NEW.Metadata_EV_REV IS NULL AND :OLD.Metadata_EV_REV IS NOT NULL)
        OR (:NEW.Metadata_EV_REV IS NOT NULL AND :OLD.Metadata_EV_REV IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_REV
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_REV_Händelse_Intäkt IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_REV_Händelse_Intäkt IS NULL
            OR v_positing_diff
            OR :OLD.EV_REV_Reliability IS NULL
            OR :OLD.EV_REV_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_REV_Positor IS NULL
            OR :OLD.EV_REV_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_REV_Händelse_Intäkt(
                    p_owner => COALESCE(:NEW.EV_REV_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_REV_Händelse_Intäkt,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_REV_Händelse_Intäkt IS NULL AND :OLD.EV_REV_Händelse_Intäkt IS NOT NULL THEN
            attributes.ip_EV_REV_Händelse_Intäkt(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_REV_Händelse_Intäkt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_STA_Händelse_Status
    IF (:NEW.EV_STA_ID <> :OLD.EV_STA_ID
        OR (:NEW.EV_STA_ID IS NULL AND :OLD.EV_STA_ID IS NOT NULL)
        OR (:NEW.EV_STA_ID IS NOT NULL AND :OLD.EV_STA_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_STA_ID is not updatable.');
    END IF;
    IF (:NEW.EV_STA_EV_ID <> :OLD.EV_STA_EV_ID
        OR (:NEW.EV_STA_EV_ID IS NULL AND :OLD.EV_STA_EV_ID IS NOT NULL)
        OR (:NEW.EV_STA_EV_ID IS NOT NULL AND :OLD.EV_STA_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_STA_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_STA_Händelse_Status, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_STA_Reliability <> :OLD.EV_STA_Reliability
        OR (:NEW.EV_STA_Reliability IS NULL AND :OLD.EV_STA_Reliability IS NOT NULL)
        OR (:NEW.EV_STA_Reliability IS NOT NULL AND :OLD.EV_STA_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_STA_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_STA_Reliability;
    END IF;
    IF (:NEW.EV_STA_Positor <> :OLD.EV_STA_Positor
        OR (:NEW.EV_STA_Positor IS NULL AND :OLD.EV_STA_Positor IS NOT NULL)
        OR (:NEW.EV_STA_Positor IS NOT NULL AND :OLD.EV_STA_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_STA_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_STA_PositedAt <> :OLD.EV_STA_PositedAt
        OR (:NEW.EV_STA_PositedAt IS NULL AND :OLD.EV_STA_PositedAt IS NOT NULL)
        OR (:NEW.EV_STA_PositedAt IS NOT NULL AND :OLD.EV_STA_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_STA_ChangedAt <> :OLD.EV_STA_ChangedAt
        OR (:NEW.EV_STA_ChangedAt IS NULL AND :OLD.EV_STA_ChangedAt IS NOT NULL)
        OR (:NEW.EV_STA_ChangedAt IS NOT NULL AND :OLD.EV_STA_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_STA_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_STA_Händelse_Status IS NULL THEN
        v_positing := :NEW.EV_STA_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_STA_Händelse_Status <> :OLD.EV_STA_Händelse_Status
        OR (:NEW.EV_STA_Händelse_Status IS NULL AND :OLD.EV_STA_Händelse_Status IS NOT NULL)
        OR (:NEW.EV_STA_Händelse_Status IS NOT NULL AND :OLD.EV_STA_Händelse_Status IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_STA <> :OLD.Metadata_EV_STA
        OR (:NEW.Metadata_EV_STA IS NULL AND :OLD.Metadata_EV_STA IS NOT NULL)
        OR (:NEW.Metadata_EV_STA IS NOT NULL AND :OLD.Metadata_EV_STA IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_STA
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_STA_changing := :NEW.EV_STA_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_STA_changing := :NEW.EV_STA_ChangedAt;
        ELSE
            v_STA_changing := v_now;
        END IF;
        IF :NEW.EV_STA_Händelse_Status IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_STA_Händelse_Status IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_STA_Reliability IS NULL
            OR :OLD.EV_STA_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_STA_Positor IS NULL
            OR :OLD.EV_STA_Positor <> v_positor
            OR v_value_diff
            THEN
                attributes.ip_EV_STA_Händelse_Status(
                    p_owner => COALESCE(:NEW.EV_STA_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_STA_Händelse_Status,
                    p_changing => v_STA_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_STA_Händelse_Status IS NULL AND :OLD.EV_STA_Händelse_Status IS NOT NULL THEN
            attributes.ip_EV_STA_Händelse_Status(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_STA_Händelse_Status,
                p_changing => :OLD.EV_STA_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_UTL_Händelse_Utnyttjande
    IF (:NEW.EV_UTL_ID <> :OLD.EV_UTL_ID
        OR (:NEW.EV_UTL_ID IS NULL AND :OLD.EV_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_ID IS NOT NULL AND :OLD.EV_UTL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_UTL_ID is not updatable.');
    END IF;
    IF (:NEW.EV_UTL_EV_ID <> :OLD.EV_UTL_EV_ID
        OR (:NEW.EV_UTL_EV_ID IS NULL AND :OLD.EV_UTL_EV_ID IS NOT NULL)
        OR (:NEW.EV_UTL_EV_ID IS NOT NULL AND :OLD.EV_UTL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_UTL_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_UTL_Händelse_Utnyttjande, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_UTL_Reliability <> :OLD.EV_UTL_Reliability
        OR (:NEW.EV_UTL_Reliability IS NULL AND :OLD.EV_UTL_Reliability IS NOT NULL)
        OR (:NEW.EV_UTL_Reliability IS NOT NULL AND :OLD.EV_UTL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_UTL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_UTL_Reliability;
    END IF;
    IF (:NEW.EV_UTL_Positor <> :OLD.EV_UTL_Positor
        OR (:NEW.EV_UTL_Positor IS NULL AND :OLD.EV_UTL_Positor IS NOT NULL)
        OR (:NEW.EV_UTL_Positor IS NOT NULL AND :OLD.EV_UTL_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_UTL_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_UTL_PositedAt <> :OLD.EV_UTL_PositedAt
        OR (:NEW.EV_UTL_PositedAt IS NULL AND :OLD.EV_UTL_PositedAt IS NOT NULL)
        OR (:NEW.EV_UTL_PositedAt IS NOT NULL AND :OLD.EV_UTL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_UTL_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_UTL_UTL_ID <> :OLD.EV_UTL_UTL_ID
        OR (:NEW.EV_UTL_UTL_ID IS NULL AND :OLD.EV_UTL_UTL_ID IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_ID IS NOT NULL AND :OLD.EV_UTL_UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_UTL <> :OLD.Metadata_EV_UTL
        OR (:NEW.Metadata_EV_UTL IS NULL AND :OLD.Metadata_EV_UTL IS NOT NULL)
        OR (:NEW.Metadata_EV_UTL IS NOT NULL AND :OLD.Metadata_EV_UTL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_UTL
        END, :NEW.Metadata_EV);
    v_knot_diff := CASE WHEN (:NEW.EV_UTL_UTL_Utnyttjande <> :OLD.EV_UTL_UTL_Utnyttjande
        OR (:NEW.EV_UTL_UTL_Utnyttjande IS NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NOT NULL)
        OR (:NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_UTL := :NEW.EV_UTL_UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_UTL := NULL;
        IF :NEW.EV_UTL_UTL_Utnyttjande IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_UTL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_UTL_UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.EV_UTL_Reliability IS NULL
            OR :OLD.EV_UTL_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_UTL_Positor IS NULL
            OR :OLD.EV_UTL_Positor <> v_positor
            OR :OLD.EV_UTL_UTL_ID <> v_UTL
            THEN
                attributes.ip_EV_UTL_Händelse_Utnyttjande(
                    p_owner => COALESCE(:NEW.EV_UTL_EV_ID, :NEW.EV_ID),
                    p_value => v_UTL,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.EV_UTL_UTL_ID IS NOT NULL AND (
            :NEW.EV_UTL_UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.EV_UTL_UTL_Utnyttjande IS NULL AND :OLD.EV_UTL_UTL_Utnyttjande IS NOT NULL
            )
        ) THEN
            attributes.ip_EV_UTL_Händelse_Utnyttjande(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_UTL_UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_LVL_Händelse_Level
    IF (:NEW.EV_LVL_ID <> :OLD.EV_LVL_ID
        OR (:NEW.EV_LVL_ID IS NULL AND :OLD.EV_LVL_ID IS NOT NULL)
        OR (:NEW.EV_LVL_ID IS NOT NULL AND :OLD.EV_LVL_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_LVL_ID is not updatable.');
    END IF;
    IF (:NEW.EV_LVL_EV_ID <> :OLD.EV_LVL_EV_ID
        OR (:NEW.EV_LVL_EV_ID IS NULL AND :OLD.EV_LVL_EV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_EV_ID IS NOT NULL AND :OLD.EV_LVL_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_LVL_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_LVL_Händelse_Level, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_LVL_Reliability <> :OLD.EV_LVL_Reliability
        OR (:NEW.EV_LVL_Reliability IS NULL AND :OLD.EV_LVL_Reliability IS NOT NULL)
        OR (:NEW.EV_LVL_Reliability IS NOT NULL AND :OLD.EV_LVL_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_LVL_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_LVL_Reliability;
    END IF;
    IF (:NEW.EV_LVL_Positor <> :OLD.EV_LVL_Positor
        OR (:NEW.EV_LVL_Positor IS NULL AND :OLD.EV_LVL_Positor IS NOT NULL)
        OR (:NEW.EV_LVL_Positor IS NOT NULL AND :OLD.EV_LVL_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_LVL_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_LVL_PositedAt <> :OLD.EV_LVL_PositedAt
        OR (:NEW.EV_LVL_PositedAt IS NULL AND :OLD.EV_LVL_PositedAt IS NOT NULL)
        OR (:NEW.EV_LVL_PositedAt IS NOT NULL AND :OLD.EV_LVL_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_LVL_ChangedAt <> :OLD.EV_LVL_ChangedAt
        OR (:NEW.EV_LVL_ChangedAt IS NULL AND :OLD.EV_LVL_ChangedAt IS NOT NULL)
        OR (:NEW.EV_LVL_ChangedAt IS NOT NULL AND :OLD.EV_LVL_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_LVL_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_LVL_PLV_ID IS NULL THEN
        v_positing := :NEW.EV_LVL_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_LVL_PLV_ID <> :OLD.EV_LVL_PLV_ID
        OR (:NEW.EV_LVL_PLV_ID IS NULL AND :OLD.EV_LVL_PLV_ID IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_ID IS NOT NULL AND :OLD.EV_LVL_PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_LVL <> :OLD.Metadata_EV_LVL
        OR (:NEW.Metadata_EV_LVL IS NULL AND :OLD.Metadata_EV_LVL IS NOT NULL)
        OR (:NEW.Metadata_EV_LVL IS NOT NULL AND :OLD.Metadata_EV_LVL IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_LVL
        END, :NEW.Metadata_EV);
    v_knot_diff := CASE WHEN (:NEW.EV_LVL_PLV_Yrkesnivå <> :OLD.EV_LVL_PLV_Yrkesnivå
        OR (:NEW.EV_LVL_PLV_Yrkesnivå IS NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NOT NULL)
        OR (:NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_LVL := :NEW.EV_LVL_PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_LVL := NULL;
        IF :NEW.EV_LVL_PLV_Yrkesnivå IS NOT NULL THEN
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
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LVL_changing := :NEW.EV_LVL_ChangedAt;
        ELSIF :OLD.EV_LVL_PLV_ID = v_LVL THEN
            v_LVL_changing := :NEW.EV_LVL_ChangedAt;
        ELSE
            v_LVL_changing := v_now;
        END IF;
        IF v_LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_LVL_PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_LVL_Reliability IS NULL
            OR :OLD.EV_LVL_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_LVL_Positor IS NULL
            OR :OLD.EV_LVL_Positor <> v_positor
            OR :OLD.EV_LVL_PLV_ID <> v_LVL
            THEN
                attributes.ip_EV_LVL_Händelse_Level(
                    p_owner => COALESCE(:NEW.EV_LVL_EV_ID, :NEW.EV_ID),
                    p_value => v_LVL,
                    p_changing => v_LVL_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.EV_LVL_PLV_ID IS NOT NULL AND (
            :NEW.EV_LVL_PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.EV_LVL_PLV_Yrkesnivå IS NULL AND :OLD.EV_LVL_PLV_Yrkesnivå IS NOT NULL
            )
        ) THEN
            attributes.ip_EV_LVL_Händelse_Level(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_LVL_PLV_ID,
                p_changing => :OLD.EV_LVL_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of EV_DAT_Händelse_Datum is retracted
    INSERT INTO attributes.EV_DAT_Händelse_Datum_Annex (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        :OLD.Metadata_EV_DAT,
        :OLD.EV_DAT_ID,
        COALESCE(:OLD.EV_DAT_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_DAT_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_DAT_Händelse_Datum_Annex x
            WHERE
                x.EV_DAT_ID = :OLD.EV_DAT_ID
            AND
                x.EV_DAT_Positor = COALESCE(:OLD.EV_DAT_Positor, :OLD.Positor, 0)
            AND
                x.EV_DAT_PositedAt = v_now
        );
    -- what is shown of EV_AUD_Händelse_Publik is retracted
    INSERT INTO attributes.EV_AUD_Händelse_Publik_Annex (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        :OLD.Metadata_EV_AUD,
        :OLD.EV_AUD_ID,
        COALESCE(:OLD.EV_AUD_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_AUD_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_AUD_Händelse_Publik_Annex x
            WHERE
                x.EV_AUD_ID = :OLD.EV_AUD_ID
            AND
                x.EV_AUD_Positor = COALESCE(:OLD.EV_AUD_Positor, :OLD.Positor, 0)
            AND
                x.EV_AUD_PositedAt = v_now
        );
    -- what is shown of EV_REV_Händelse_Intäkt is retracted
    INSERT INTO attributes.EV_REV_Händelse_Intäkt_Annex (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        :OLD.Metadata_EV_REV,
        :OLD.EV_REV_ID,
        COALESCE(:OLD.EV_REV_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_REV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_REV_Händelse_Intäkt_Annex x
            WHERE
                x.EV_REV_ID = :OLD.EV_REV_ID
            AND
                x.EV_REV_Positor = COALESCE(:OLD.EV_REV_Positor, :OLD.Positor, 0)
            AND
                x.EV_REV_PositedAt = v_now
        );
    -- what is shown of EV_STA_Händelse_Status is retracted
    INSERT INTO attributes.EV_STA_Händelse_Status_Annex (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Positor,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    SELECT
        :OLD.Metadata_EV_STA,
        :OLD.EV_STA_ID,
        COALESCE(:OLD.EV_STA_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_STA_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_STA_Händelse_Status_Annex x
            WHERE
                x.EV_STA_ID = :OLD.EV_STA_ID
            AND
                x.EV_STA_Positor = COALESCE(:OLD.EV_STA_Positor, :OLD.Positor, 0)
            AND
                x.EV_STA_PositedAt = v_now
        );
    -- what is shown of EV_UTL_Händelse_Utnyttjande is retracted
    INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande_Annex (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Positor,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    SELECT
        :OLD.Metadata_EV_UTL,
        :OLD.EV_UTL_ID,
        COALESCE(:OLD.EV_UTL_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_UTL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_UTL_Händelse_Utnyttjande_Annex x
            WHERE
                x.EV_UTL_ID = :OLD.EV_UTL_ID
            AND
                x.EV_UTL_Positor = COALESCE(:OLD.EV_UTL_Positor, :OLD.Positor, 0)
            AND
                x.EV_UTL_PositedAt = v_now
        );
    -- what is shown of EV_LVL_Händelse_Level is retracted
    INSERT INTO attributes.EV_LVL_Händelse_Level_Annex (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Positor,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    SELECT
        :OLD.Metadata_EV_LVL,
        :OLD.EV_LVL_ID,
        COALESCE(:OLD.EV_LVL_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_LVL_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                attributes.EV_LVL_Händelse_Level_Annex x
            WHERE
                x.EV_LVL_ID = :OLD.EV_LVL_ID
            AND
                x.EV_LVL_Positor = COALESCE(:OLD.EV_LVL_Positor, :OLD.Positor, 0)
            AND
                x.EV_LVL_PositedAt = v_now
        );
END dt_lEV_Händelse;
/
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the positor is 0, the changing and
-- positing times are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is about the values of the identifiers (at a changing time):
-- a decisive positor holds one assertion at a time for them, so an assertion of other values retracts, at its own positing
-- time, the posit that the positor holds, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures, ip_<tie>, and not in triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The triggers on the views call them, and so can
-- a load, with the roles and what else is to be stated (what is left out gets its default: the positor is 0, the changing
-- and positing times are now, the reliability is 1):
--
--     BEGIN
--         ip_<tie>(
--             p_<role> => ...,                  one for each role, the identity of the entity or knot
--             p_changing => ...,                a historized tie
--             p_positor => ..., p_positing => ..., p_reliability => ...,
--             p_metadata => ...                 when the model has metadata
--         );
--     END;
--
-- A row put straight into a posit or annex table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so the rows of an insert are taken in the order they have. Whether a
-- column is set in an UPDATE is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_partner_AC_with_ONG_currently is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_partner_AC_with_ONG_currently (
    p_id IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_partner_AC_with_ONG_currently_Reliability
        FROM
            ties.AC_partner_AC_with_ONG_currently_Annex a
        WHERE
            a.AC_partner_AC_with_ONG_currently_ID = p_id
        AND
            a.AC_partner_AC_with_ONG_currently_Positor = p_positor
        AND
            a.AC_partner_AC_with_ONG_currently_PositedAt <= p_positing
        ORDER BY
            a.AC_partner_AC_with_ONG_currently_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_partner_AC_with_ONG_currently_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_partner_AC_with_ONG_currently;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_partner_AC_with_ONG_currently tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_partner_AC_with_ONG_currently (
    p_id IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_partner_AC_with_ONG_currently(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a posit of AC_partner_AC_with_ONG_currently, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN ties.AC_partner_AC_with_ONG_currently_Posit.AC_ID_partner%TYPE,
    p_AC_with IN ties.AC_partner_AC_with_ONG_currently_Posit.AC_ID_with%TYPE,
    p_ONG_currently IN ties.AC_partner_AC_with_ONG_currently_Posit.ONG_ID_currently%TYPE,
    p_changing IN ties.AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_partner_AC_with_ONG_currently_Annex.Metadata_AC_partner_AC_with_ONG_currently%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE;
    v_positing ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE;
    v_reliability ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE;
    v_held ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE;
    v_changing ties.AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_posit ties.AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Annex (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = p_id
                AND
                    a.AC_partner_AC_with_ONG_currently_Positor = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_partner_AC_with_ONG_currently_ID
        FROM
            ties.AC_partner_AC_with_ONG_currently_Posit p
        WHERE
            p.AC_ID_partner = p_AC_partner
        AND
            p.AC_ID_with = p_AC_with
        AND
            p.ONG_ID_currently = p_ONG_currently
        AND
            p.AC_partner_AC_with_ONG_currently_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_partner_AC_with_ONG_currently_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_Positor = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
                AND
                    a.AC_partner_AC_with_ONG_currently_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_partner_AC_with_ONG_currently for: ' ||
                p_AC_partner || ', ' ||
                p_AC_with || ', ' ||
                p_ONG_currently || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_Positor = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_partner_AC_with_ONG_currently(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Annex (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Posit (
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        )
        VALUES (
            p_AC_partner,
            p_AC_with,
            p_ONG_currently,
            v_changing
        )
        RETURNING AC_partner_AC_with_ONG_currently_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_partner_AC_with_ONG_currently_Annex (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.AC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => :NEW.ONG_ID_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positor => :NEW.AC_partner_AC_with_ONG_currently_Positor,
        p_positing => :NEW.AC_partner_AC_with_ONG_currently_PositedAt,
        p_reliability => :NEW.AC_partner_AC_with_ONG_currently_Reliability,
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
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
        p_changing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.currently_ONG_Pågående <> :OLD.currently_ONG_Pågående
        OR (:NEW.currently_ONG_Pågående IS NULL AND :OLD.currently_ONG_Pågående IS NOT NULL)
        OR (:NEW.currently_ONG_Pågående IS NOT NULL AND :OLD.currently_ONG_Pågående IS NULL))
    AND (:NEW.ONG_ID_currently = :OLD.ONG_ID_currently
        OR (:NEW.ONG_ID_currently IS NULL AND :OLD.ONG_ID_currently IS NULL)) THEN
        v_ONG_currently := NULL;
        IF :NEW.currently_ONG_Pågående IS NOT NULL THEN
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
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_partner_AC_with_ONG_currently_Positor <> :OLD.AC_partner_AC_with_ONG_currently_Positor
            OR (:NEW.AC_partner_AC_with_ONG_currently_Positor IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Positor IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Positor IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Positor IS NULL))
        THEN :NEW.AC_partner_AC_with_ONG_currently_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_partner_AC_with_ONG_currently_PositedAt <> :OLD.AC_partner_AC_with_ONG_currently_PositedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NULL))
        THEN :NEW.AC_partner_AC_with_ONG_currently_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_partner <> :OLD.AC_ID_partner
            OR (:NEW.AC_ID_partner IS NULL AND :OLD.AC_ID_partner IS NOT NULL)
            OR (:NEW.AC_ID_partner IS NOT NULL AND :OLD.AC_ID_partner IS NULL)) OR
        (:NEW.AC_ID_with <> :OLD.AC_ID_with
            OR (:NEW.AC_ID_with IS NULL AND :OLD.AC_ID_with IS NOT NULL)
            OR (:NEW.AC_ID_with IS NOT NULL AND :OLD.AC_ID_with IS NULL)) OR
        (v_ONG_currently <> :OLD.ONG_ID_currently
            OR (v_ONG_currently IS NULL AND :OLD.ONG_ID_currently IS NOT NULL)
            OR (v_ONG_currently IS NOT NULL AND :OLD.ONG_ID_currently IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_PositedAt <> :OLD.AC_partner_AC_with_ONG_currently_PositedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_Reliability <> :OLD.AC_partner_AC_with_ONG_currently_Reliability
            OR (:NEW.AC_partner_AC_with_ONG_currently_Reliability IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Reliability IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Reliability IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_partner IS NOT NULL
        AND
            :NEW.AC_ID_with IS NOT NULL
        AND
            v_ONG_currently IS NOT NULL
        THEN
            ties.ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :NEW.AC_ID_partner,
                p_AC_with => :NEW.AC_ID_with,
                p_ONG_currently => v_ONG_currently,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
                        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL))
                    THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
                    WHEN
                        :NEW.AC_ID_partner = :OLD.AC_ID_partner
                    AND
                        :NEW.AC_ID_with = :OLD.AC_ID_with
                    AND
                        v_ONG_currently = :OLD.ONG_ID_currently
                    THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :OLD.AC_ID_partner,
                p_AC_with => :OLD.AC_ID_with,
                p_ONG_currently => :OLD.ONG_ID_currently,
                p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        END IF;
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :OLD.AC_ID_partner,
        p_AC_with => :OLD.AC_ID_with,
        p_ONG_currently => :OLD.ONG_ID_currently,
        p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positor => COALESCE(:OLD.AC_partner_AC_with_ONG_currently_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_partner_AC_with_ONG_currently
    );
END dt_lAC_partner_AC_with_ONG_currently;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_subset_PN_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_subset_PN_of (
    p_id IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE,
    p_positor IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE,
    p_positing IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE
) RETURN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_subset_PN_of_Reliability
        FROM
            ties.AC_subset_PN_of_Annex a
        WHERE
            a.AC_subset_PN_of_ID = p_id
        AND
            a.AC_subset_PN_of_Positor = p_positor
        AND
            a.AC_subset_PN_of_PositedAt <= p_positing
        ORDER BY
            a.AC_subset_PN_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_subset_PN_of_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_subset_PN_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_subset_PN_of (
    p_id IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE,
    p_positor IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE,
    p_positing IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_subset_PN_of(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a posit of AC_subset_PN_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_subset_PN_of (
    p_AC_subset IN ties.AC_subset_PN_of_Posit.AC_ID_subset%TYPE,
    p_PN_of IN ties.AC_subset_PN_of_Posit.PN_ID_of%TYPE,
    p_positor IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_subset_PN_of_Annex.Metadata_AC_subset_PN_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE;
    v_positing ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE;
    v_reliability ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE;
    v_held ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE;
    v_posit ties.AC_subset_PN_of_Posit.AC_subset_PN_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_subset_PN_of_Annex (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = p_id
                AND
                    a.AC_subset_PN_of_Positor = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_subset_PN_of_ID
        FROM
            ties.AC_subset_PN_of_Posit p
        WHERE
            p.AC_ID_subset = p_AC_subset
        AND
            p.PN_ID_of = p_PN_of
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_subset_PN_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_Positor = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
                AND
                    a.AC_subset_PN_of_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_subset_PN_of for: ' ||
                p_AC_subset || ', ' ||
                p_PN_of || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_Positor = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_subset_PN_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_subset_PN_of_Annex (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_subset_PN_of_Posit (
            AC_ID_subset,
            PN_ID_of
        )
        VALUES (
            p_AC_subset,
            p_PN_of
        )
        RETURNING AC_subset_PN_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_subset_PN_of_Annex (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_subset_PN_of
INSTEAD OF INSERT ON ties.AC_subset_PN_of
FOR EACH ROW
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positor => :NEW.AC_subset_PN_of_Positor,
        p_positing => :NEW.AC_subset_PN_of_PositedAt,
        p_reliability => :NEW.AC_subset_PN_of_Reliability,
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_subset_PN_of
INSTEAD OF INSERT ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positor => COALESCE(:NEW.AC_subset_PN_of_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_subset_PN_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_subset_PN_of_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_subset_PN_of_Positor <> :OLD.AC_subset_PN_of_Positor
            OR (:NEW.AC_subset_PN_of_Positor IS NULL AND :OLD.AC_subset_PN_of_Positor IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Positor IS NOT NULL AND :OLD.AC_subset_PN_of_Positor IS NULL))
        THEN :NEW.AC_subset_PN_of_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_subset_PN_of_PositedAt <> :OLD.AC_subset_PN_of_PositedAt
            OR (:NEW.AC_subset_PN_of_PositedAt IS NULL AND :OLD.AC_subset_PN_of_PositedAt IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_PositedAt IS NOT NULL AND :OLD.AC_subset_PN_of_PositedAt IS NULL))
        THEN :NEW.AC_subset_PN_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_subset <> :OLD.AC_ID_subset
            OR (:NEW.AC_ID_subset IS NULL AND :OLD.AC_ID_subset IS NOT NULL)
            OR (:NEW.AC_ID_subset IS NOT NULL AND :OLD.AC_ID_subset IS NULL)) OR
        (:NEW.PN_ID_of <> :OLD.PN_ID_of
            OR (:NEW.PN_ID_of IS NULL AND :OLD.PN_ID_of IS NOT NULL)
            OR (:NEW.PN_ID_of IS NOT NULL AND :OLD.PN_ID_of IS NULL)) OR
        (:NEW.AC_subset_PN_of_PositedAt <> :OLD.AC_subset_PN_of_PositedAt
            OR (:NEW.AC_subset_PN_of_PositedAt IS NULL AND :OLD.AC_subset_PN_of_PositedAt IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_PositedAt IS NOT NULL AND :OLD.AC_subset_PN_of_PositedAt IS NULL)) OR
        (:NEW.AC_subset_PN_of_Reliability <> :OLD.AC_subset_PN_of_Reliability
            OR (:NEW.AC_subset_PN_of_Reliability IS NULL AND :OLD.AC_subset_PN_of_Reliability IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Reliability IS NOT NULL AND :OLD.AC_subset_PN_of_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_subset IS NOT NULL
        AND
            :NEW.PN_ID_of IS NOT NULL
        THEN
            ties.ip_AC_subset_PN_of(
                p_AC_subset => :NEW.AC_ID_subset,
                p_PN_of => :NEW.PN_ID_of,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_subset_PN_of_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_subset_PN_of(
                p_AC_subset => :OLD.AC_ID_subset,
                p_PN_of => :OLD.PN_ID_of,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        END IF;
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_subset_PN_of
INSTEAD OF DELETE ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :OLD.AC_ID_subset,
        p_PN_of => :OLD.PN_ID_of,
        p_positor => COALESCE(:OLD.AC_subset_PN_of_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_subset_PN_of
    );
END dt_lAC_subset_PN_of;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_in_AC_rollsattes is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_EV_in_AC_rollsattes (
    p_id IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_ID%TYPE,
    p_positor IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE,
    p_positing IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE
) RETURN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_in_AC_rollsattes_Reliability
        FROM
            ties.EV_in_AC_rollsattes_Annex a
        WHERE
            a.EV_in_AC_rollsattes_ID = p_id
        AND
            a.EV_in_AC_rollsattes_Positor = p_positor
        AND
            a.EV_in_AC_rollsattes_PositedAt <= p_positing
        ORDER BY
            a.EV_in_AC_rollsattes_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_in_AC_rollsattes_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_in_AC_rollsattes;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_rollsattes tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_EV_in_AC_rollsattes (
    p_id IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_ID%TYPE,
    p_positor IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE,
    p_positing IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_EV_in_AC_rollsattes(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_EV_in_AC_rollsattes;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_rollsattes states a posit of EV_in_AC_rollsattes, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_rollsattes (
    p_EV_in IN ties.EV_in_AC_rollsattes_Posit.EV_ID_in%TYPE,
    p_AC_rollsattes IN ties.EV_in_AC_rollsattes_Posit.AC_ID_rollsattes%TYPE,
    p_positor IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.EV_in_AC_rollsattes_Annex.Metadata_EV_in_AC_rollsattes%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE;
    v_positing ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE;
    v_reliability ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE;
    v_held ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE;
    v_posit ties.EV_in_AC_rollsattes_Posit.EV_in_AC_rollsattes_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.EV_in_AC_rollsattes_Annex (
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_rollsattes_Annex a
                WHERE
                    a.EV_in_AC_rollsattes_ID = p_id
                AND
                    a.EV_in_AC_rollsattes_Positor = v_positor
                AND
                    a.EV_in_AC_rollsattes_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.EV_in_AC_rollsattes_ID
        FROM
            ties.EV_in_AC_rollsattes_Posit p
        WHERE
            p.EV_ID_in = p_EV_in
        AND
            p.AC_ID_rollsattes = p_AC_rollsattes
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_in_AC_rollsattes_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_rollsattes_Annex a
                WHERE
                    a.EV_in_AC_rollsattes_ID = v_posit
                AND
                    a.EV_in_AC_rollsattes_Positor = v_positor
                AND
                    a.EV_in_AC_rollsattes_PositedAt = v_positing
                AND
                    a.EV_in_AC_rollsattes_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_in_AC_rollsattes for: ' ||
                p_EV_in || ', ' ||
                p_AC_rollsattes || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_rollsattes_Annex a
                WHERE
                    a.EV_in_AC_rollsattes_ID = v_posit
                AND
                    a.EV_in_AC_rollsattes_Positor = v_positor
                AND
                    a.EV_in_AC_rollsattes_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_EV_in_AC_rollsattes(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.EV_in_AC_rollsattes_Annex (
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.EV_in_AC_rollsattes_Posit (
            EV_ID_in,
            AC_ID_rollsattes
        )
        VALUES (
            p_EV_in,
            p_AC_rollsattes
        )
        RETURNING EV_in_AC_rollsattes_ID INTO v_posit;
    END IF;
    INSERT INTO ties.EV_in_AC_rollsattes_Annex (
        Metadata_EV_in_AC_rollsattes,
        EV_in_AC_rollsattes_ID,
        EV_in_AC_rollsattes_Positor,
        EV_in_AC_rollsattes_PositedAt,
        EV_in_AC_rollsattes_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_in_AC_rollsattes;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_rollsattes instead of INSERT trigger on EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_EV_in_AC_rollsattes
INSTEAD OF INSERT ON ties.EV_in_AC_rollsattes
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_rollsattes => :NEW.AC_ID_rollsattes,
        p_positor => :NEW.EV_in_AC_rollsattes_Positor,
        p_positing => :NEW.EV_in_AC_rollsattes_PositedAt,
        p_reliability => :NEW.EV_in_AC_rollsattes_Reliability,
        p_metadata => :NEW.Metadata_EV_in_AC_rollsattes
    );
END it_EV_in_AC_rollsattes;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_rollsattes
INSTEAD OF INSERT ON ties.lEV_in_AC_rollsattes
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_rollsattes => :NEW.AC_ID_rollsattes,
        p_positor => COALESCE(:NEW.EV_in_AC_rollsattes_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.EV_in_AC_rollsattes_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.EV_in_AC_rollsattes_Reliability, 1),
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :OLD.EV_ID_in,
        p_AC_rollsattes => :OLD.AC_ID_rollsattes,
        p_positor => COALESCE(:OLD.EV_in_AC_rollsattes_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_EV_in_AC_rollsattes
    );
END dt_lEV_in_AC_rollsattes;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_deltar_PR_in_RAT_fick is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_deltar_PR_in_RAT_fick (
    p_id IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_ID%TYPE,
    p_positor IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE,
    p_positing IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE
) RETURN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_deltar_PR_in_RAT_fick_Reliability
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Annex a
        WHERE
            a.AC_deltar_PR_in_RAT_fick_ID = p_id
        AND
            a.AC_deltar_PR_in_RAT_fick_Positor = p_positor
        AND
            a.AC_deltar_PR_in_RAT_fick_PositedAt <= p_positing
        ORDER BY
            a.AC_deltar_PR_in_RAT_fick_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_deltar_PR_in_RAT_fick_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_deltar_PR_in_RAT_fick;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_deltar_PR_in_RAT_fick tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_deltar_PR_in_RAT_fick (
    p_id IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_ID%TYPE,
    p_positor IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE,
    p_positing IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_deltar_PR_in_RAT_fick(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_deltar_PR_in_RAT_fick;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_deltar_PR_in_RAT_fick states a posit of AC_deltar_PR_in_RAT_fick, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_deltar_PR_in_RAT_fick (
    p_AC_deltar IN ties.AC_deltar_PR_in_RAT_fick_Posit.AC_ID_deltar%TYPE,
    p_PR_in IN ties.AC_deltar_PR_in_RAT_fick_Posit.PR_ID_in%TYPE,
    p_RAT_fick IN ties.AC_deltar_PR_in_RAT_fick_Posit.RAT_ID_fick%TYPE,
    p_changing IN ties.AC_deltar_PR_in_RAT_fick_Posit.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_deltar_PR_in_RAT_fick_Annex.Metadata_AC_deltar_PR_in_RAT_fick%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE;
    v_positing ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE;
    v_reliability ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE;
    v_held ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE;
    v_changing ties.AC_deltar_PR_in_RAT_fick_Posit.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE;
    v_posit ties.AC_deltar_PR_in_RAT_fick_Posit.AC_deltar_PR_in_RAT_fick_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Annex (
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                WHERE
                    a.AC_deltar_PR_in_RAT_fick_ID = p_id
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_deltar_PR_in_RAT_fick_ID
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit p
        WHERE
            p.AC_ID_deltar = p_AC_deltar
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.RAT_ID_fick = p_RAT_fick
        AND
            p.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_deltar_PR_in_RAT_fick_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                WHERE
                    a.AC_deltar_PR_in_RAT_fick_ID = v_posit
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
                AND
                    a.AC_deltar_PR_in_RAT_fick_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_deltar_PR_in_RAT_fick for: ' ||
                p_AC_deltar || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_fick || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF v_reliability <> 0 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Posit p
                JOIN
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                ON
                    a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
                WHERE
                    p.AC_ID_deltar = p_AC_deltar
                AND
                    p.PR_ID_in = p_PR_in
                AND
                    p.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
                AND
                    NOT (
                        p.RAT_ID_fick = p_RAT_fick
                    )
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
                AND
                    a.AC_deltar_PR_in_RAT_fick_Reliability <> 0
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_deltar_PR_in_RAT_fick for: ' ||
                p_AC_deltar || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_fick || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                WHERE
                    a.AC_deltar_PR_in_RAT_fick_ID = v_posit
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_deltar_PR_in_RAT_fick(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Annex (
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_deltar_PR_in_RAT_fick_ID
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit p
        WHERE
            p.AC_ID_deltar = p_AC_deltar
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        AND
            NOT (
                p.RAT_ID_fick = p_RAT_fick
            )
        AND
            ties.ie_AC_deltar_PR_in_RAT_fick(p.AC_deltar_PR_in_RAT_fick_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.AC_deltar_PR_in_RAT_fick_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Posit (
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt
        )
        VALUES (
            p_AC_deltar,
            p_PR_in,
            p_RAT_fick,
            v_changing
        )
        RETURNING AC_deltar_PR_in_RAT_fick_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Annex (
        Metadata_AC_deltar_PR_in_RAT_fick,
        AC_deltar_PR_in_RAT_fick_ID,
        AC_deltar_PR_in_RAT_fick_Positor,
        AC_deltar_PR_in_RAT_fick_PositedAt,
        AC_deltar_PR_in_RAT_fick_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_deltar_PR_in_RAT_fick;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_deltar_PR_in_RAT_fick instead of INSERT trigger on AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_deltar_PR_in_RAT_fick
INSTEAD OF INSERT ON ties.AC_deltar_PR_in_RAT_fick
FOR EACH ROW
BEGIN
    ties.ip_AC_deltar_PR_in_RAT_fick(
        p_AC_deltar => :NEW.AC_ID_deltar,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_fick => :NEW.RAT_ID_fick,
        p_changing => :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt,
        p_positor => :NEW.AC_deltar_PR_in_RAT_fick_Positor,
        p_positing => :NEW.AC_deltar_PR_in_RAT_fick_PositedAt,
        p_reliability => :NEW.AC_deltar_PR_in_RAT_fick_Reliability,
        p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
    );
END it_AC_deltar_PR_in_RAT_fick;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_deltar_PR_in_RAT_fick
INSTEAD OF INSERT ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_RAT_fick number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
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
        p_changing => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
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
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_fick := :NEW.RAT_ID_fick;
    IF (:NEW.fick_RAT_Betyg <> :OLD.fick_RAT_Betyg
        OR (:NEW.fick_RAT_Betyg IS NULL AND :OLD.fick_RAT_Betyg IS NOT NULL)
        OR (:NEW.fick_RAT_Betyg IS NOT NULL AND :OLD.fick_RAT_Betyg IS NULL))
    AND (:NEW.RAT_ID_fick = :OLD.RAT_ID_fick
        OR (:NEW.RAT_ID_fick IS NULL AND :OLD.RAT_ID_fick IS NULL)) THEN
        v_RAT_fick := NULL;
        IF :NEW.fick_RAT_Betyg IS NOT NULL THEN
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
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_deltar_PR_in_RAT_fick_Positor <> :OLD.AC_deltar_PR_in_RAT_fick_Positor
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Positor IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Positor IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Positor IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Positor IS NULL))
        THEN :NEW.AC_deltar_PR_in_RAT_fick_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt <> :OLD.AC_deltar_PR_in_RAT_fick_PositedAt
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL))
        THEN :NEW.AC_deltar_PR_in_RAT_fick_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_deltar <> :OLD.AC_ID_deltar
            OR (:NEW.AC_ID_deltar IS NULL AND :OLD.AC_ID_deltar IS NOT NULL)
            OR (:NEW.AC_ID_deltar IS NOT NULL AND :OLD.AC_ID_deltar IS NULL)) OR
        (:NEW.PR_ID_in <> :OLD.PR_ID_in
            OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
            OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) OR
        (v_RAT_fick <> :OLD.RAT_ID_fick
            OR (v_RAT_fick IS NULL AND :OLD.RAT_ID_fick IS NOT NULL)
            OR (v_RAT_fick IS NOT NULL AND :OLD.RAT_ID_fick IS NULL)) OR
        (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt <> :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
            OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL)) OR
        (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt <> :OLD.AC_deltar_PR_in_RAT_fick_PositedAt
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL)) OR
        (:NEW.AC_deltar_PR_in_RAT_fick_Reliability <> :OLD.AC_deltar_PR_in_RAT_fick_Reliability
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Reliability IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Reliability IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Reliability IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_deltar IS NOT NULL
        AND
            :NEW.PR_ID_in IS NOT NULL
        AND
            v_RAT_fick IS NOT NULL
        THEN
            ties.ip_AC_deltar_PR_in_RAT_fick(
                p_AC_deltar => :NEW.AC_ID_deltar,
                p_PR_in => :NEW.PR_ID_in,
                p_RAT_fick => v_RAT_fick,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt <> :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
                        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL))
                    THEN :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt
                    WHEN
                        :NEW.AC_ID_deltar = :OLD.AC_ID_deltar
                    AND
                        :NEW.PR_ID_in = :OLD.PR_ID_in
                    AND
                        v_RAT_fick = :OLD.RAT_ID_fick
                    THEN :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_deltar_PR_in_RAT_fick(
                p_AC_deltar => :OLD.AC_ID_deltar,
                p_PR_in => :OLD.PR_ID_in,
                p_RAT_fick => :OLD.RAT_ID_fick,
                p_changing => :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
            );
        END IF;
    END IF;
END ut_lAC_deltar_PR_in_RAT_fick;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_deltar_PR_in_RAT_fick
INSTEAD OF DELETE ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_deltar_PR_in_RAT_fick(
        p_AC_deltar => :OLD.AC_ID_deltar,
        p_PR_in => :OLD.PR_ID_in,
        p_RAT_fick => :OLD.RAT_ID_fick,
        p_changing => :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt,
        p_positor => COALESCE(:OLD.AC_deltar_PR_in_RAT_fick_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_deltar_PR_in_RAT_fick
    );
END dt_lAC_deltar_PR_in_RAT_fick;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_at_PR_spelas is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_ST_at_PR_spelas (
    p_id IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_ID%TYPE,
    p_positor IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE,
    p_positing IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE
) RETURN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_at_PR_spelas_Reliability
        FROM
            ties.ST_at_PR_spelas_Annex a
        WHERE
            a.ST_at_PR_spelas_ID = p_id
        AND
            a.ST_at_PR_spelas_Positor = p_positor
        AND
            a.ST_at_PR_spelas_PositedAt <= p_positing
        ORDER BY
            a.ST_at_PR_spelas_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_at_PR_spelas_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_at_PR_spelas;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_spelas tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_ST_at_PR_spelas (
    p_id IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_ID%TYPE,
    p_positor IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE,
    p_positing IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_ST_at_PR_spelas(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_ST_at_PR_spelas;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_spelas states a posit of ST_at_PR_spelas, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_spelas (
    p_ST_at IN ties.ST_at_PR_spelas_Posit.ST_ID_at%TYPE,
    p_PR_spelas IN ties.ST_at_PR_spelas_Posit.PR_ID_spelas%TYPE,
    p_changing IN ties.ST_at_PR_spelas_Posit.ST_at_PR_spelas_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.ST_at_PR_spelas_Annex.Metadata_ST_at_PR_spelas%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE;
    v_positing ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE;
    v_reliability ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE;
    v_held ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE;
    v_changing ties.ST_at_PR_spelas_Posit.ST_at_PR_spelas_ChangedAt%TYPE;
    v_posit ties.ST_at_PR_spelas_Posit.ST_at_PR_spelas_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.ST_at_PR_spelas_Annex (
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_spelas_Annex a
                WHERE
                    a.ST_at_PR_spelas_ID = p_id
                AND
                    a.ST_at_PR_spelas_Positor = v_positor
                AND
                    a.ST_at_PR_spelas_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.ST_at_PR_spelas_ID
        FROM
            ties.ST_at_PR_spelas_Posit p
        WHERE
            p.ST_ID_at = p_ST_at
        AND
            p.PR_ID_spelas = p_PR_spelas
        AND
            p.ST_at_PR_spelas_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_at_PR_spelas_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_spelas_Annex a
                WHERE
                    a.ST_at_PR_spelas_ID = v_posit
                AND
                    a.ST_at_PR_spelas_Positor = v_positor
                AND
                    a.ST_at_PR_spelas_PositedAt = v_positing
                AND
                    a.ST_at_PR_spelas_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_at_PR_spelas for: ' ||
                p_ST_at || ', ' ||
                p_PR_spelas || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_spelas_Annex a
                WHERE
                    a.ST_at_PR_spelas_ID = v_posit
                AND
                    a.ST_at_PR_spelas_Positor = v_positor
                AND
                    a.ST_at_PR_spelas_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_ST_at_PR_spelas(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.ST_at_PR_spelas_Annex (
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.ST_at_PR_spelas_Posit (
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt
        )
        VALUES (
            p_ST_at,
            p_PR_spelas,
            v_changing
        )
        RETURNING ST_at_PR_spelas_ID INTO v_posit;
    END IF;
    INSERT INTO ties.ST_at_PR_spelas_Annex (
        Metadata_ST_at_PR_spelas,
        ST_at_PR_spelas_ID,
        ST_at_PR_spelas_Positor,
        ST_at_PR_spelas_PositedAt,
        ST_at_PR_spelas_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_at_PR_spelas;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_spelas instead of INSERT trigger on ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_ST_at_PR_spelas
INSTEAD OF INSERT ON ties.ST_at_PR_spelas
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_spelas => :NEW.PR_ID_spelas,
        p_changing => :NEW.ST_at_PR_spelas_ChangedAt,
        p_positor => :NEW.ST_at_PR_spelas_Positor,
        p_positing => :NEW.ST_at_PR_spelas_PositedAt,
        p_reliability => :NEW.ST_at_PR_spelas_Reliability,
        p_metadata => :NEW.Metadata_ST_at_PR_spelas
    );
END it_ST_at_PR_spelas;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_spelas
INSTEAD OF INSERT ON ties.lST_at_PR_spelas
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_spelas => :NEW.PR_ID_spelas,
        p_changing => COALESCE(:NEW.ST_at_PR_spelas_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.ST_at_PR_spelas_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.ST_at_PR_spelas_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.ST_at_PR_spelas_Reliability, 1),
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :OLD.ST_ID_at,
        p_PR_spelas => :OLD.PR_ID_spelas,
        p_changing => :OLD.ST_at_PR_spelas_ChangedAt,
        p_positor => COALESCE(:OLD.ST_at_PR_spelas_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_ST_at_PR_spelas
    );
END dt_lST_at_PR_spelas;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_förälder_AC_barn_PAT_har is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_förälder_AC_barn_PAT_har (
    p_id IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_ID%TYPE,
    p_positor IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE,
    p_positing IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE
) RETURN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_förälder_AC_barn_PAT_har_Reliability
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Annex a
        WHERE
            a.AC_förälder_AC_barn_PAT_har_ID = p_id
        AND
            a.AC_förälder_AC_barn_PAT_har_Positor = p_positor
        AND
            a.AC_förälder_AC_barn_PAT_har_PositedAt <= p_positing
        ORDER BY
            a.AC_förälder_AC_barn_PAT_har_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_förälder_AC_barn_PAT_har_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_förälder_AC_barn_PAT_har;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_förälder_AC_barn_PAT_har tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_förälder_AC_barn_PAT_har (
    p_id IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_ID%TYPE,
    p_positor IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE,
    p_positing IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_förälder_AC_barn_PAT_har(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_förälder_AC_barn_PAT_har;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_förälder_AC_barn_PAT_har states a posit of AC_förälder_AC_barn_PAT_har, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_förälder_AC_barn_PAT_har (
    p_AC_förälder IN ties.AC_förälder_AC_barn_PAT_har_Posit.AC_ID_förälder%TYPE,
    p_AC_barn IN ties.AC_förälder_AC_barn_PAT_har_Posit.AC_ID_barn%TYPE,
    p_PAT_har IN ties.AC_förälder_AC_barn_PAT_har_Posit.PAT_ID_har%TYPE,
    p_positor IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_förälder_AC_barn_PAT_har_Annex.Metadata_AC_förälder_AC_barn_PAT_har%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE;
    v_positing ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE;
    v_reliability ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE;
    v_held ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE;
    v_posit ties.AC_förälder_AC_barn_PAT_har_Posit.AC_förälder_AC_barn_PAT_har_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Annex (
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_förälder_AC_barn_PAT_har_Annex a
                WHERE
                    a.AC_förälder_AC_barn_PAT_har_ID = p_id
                AND
                    a.AC_förälder_AC_barn_PAT_har_Positor = v_positor
                AND
                    a.AC_förälder_AC_barn_PAT_har_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_förälder_AC_barn_PAT_har_ID
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Posit p
        WHERE
            p.AC_ID_förälder = p_AC_förälder
        AND
            p.AC_ID_barn = p_AC_barn
        AND
            p.PAT_ID_har = p_PAT_har
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_förälder_AC_barn_PAT_har_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_förälder_AC_barn_PAT_har_Annex a
                WHERE
                    a.AC_förälder_AC_barn_PAT_har_ID = v_posit
                AND
                    a.AC_förälder_AC_barn_PAT_har_Positor = v_positor
                AND
                    a.AC_förälder_AC_barn_PAT_har_PositedAt = v_positing
                AND
                    a.AC_förälder_AC_barn_PAT_har_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_förälder_AC_barn_PAT_har for: ' ||
                p_AC_förälder || ', ' ||
                p_AC_barn || ', ' ||
                p_PAT_har || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_förälder_AC_barn_PAT_har_Annex a
                WHERE
                    a.AC_förälder_AC_barn_PAT_har_ID = v_posit
                AND
                    a.AC_förälder_AC_barn_PAT_har_Positor = v_positor
                AND
                    a.AC_förälder_AC_barn_PAT_har_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_förälder_AC_barn_PAT_har(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Annex (
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Posit (
            AC_ID_förälder,
            AC_ID_barn,
            PAT_ID_har
        )
        VALUES (
            p_AC_förälder,
            p_AC_barn,
            p_PAT_har
        )
        RETURNING AC_förälder_AC_barn_PAT_har_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Annex (
        Metadata_AC_förälder_AC_barn_PAT_har,
        AC_förälder_AC_barn_PAT_har_ID,
        AC_förälder_AC_barn_PAT_har_Positor,
        AC_förälder_AC_barn_PAT_har_PositedAt,
        AC_förälder_AC_barn_PAT_har_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_förälder_AC_barn_PAT_har;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_förälder_AC_barn_PAT_har instead of INSERT trigger on AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_förälder_AC_barn_PAT_har
INSTEAD OF INSERT ON ties.AC_förälder_AC_barn_PAT_har
FOR EACH ROW
BEGIN
    ties.ip_AC_förälder_AC_barn_PAT_har(
        p_AC_förälder => :NEW.AC_ID_förälder,
        p_AC_barn => :NEW.AC_ID_barn,
        p_PAT_har => :NEW.PAT_ID_har,
        p_positor => :NEW.AC_förälder_AC_barn_PAT_har_Positor,
        p_positing => :NEW.AC_förälder_AC_barn_PAT_har_PositedAt,
        p_reliability => :NEW.AC_förälder_AC_barn_PAT_har_Reliability,
        p_metadata => :NEW.Metadata_AC_förälder_AC_barn_PAT_har
    );
END it_AC_förälder_AC_barn_PAT_har;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_förälder_AC_barn_PAT_har
INSTEAD OF INSERT ON ties.lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_PAT_har number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
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
        p_positor => COALESCE(:NEW.AC_förälder_AC_barn_PAT_har_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_förälder_AC_barn_PAT_har_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_förälder_AC_barn_PAT_har_Reliability, 1),
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_förälder_AC_barn_PAT_har(
        p_AC_förälder => :OLD.AC_ID_förälder,
        p_AC_barn => :OLD.AC_ID_barn,
        p_PAT_har => :OLD.PAT_ID_har,
        p_positor => COALESCE(:OLD.AC_förälder_AC_barn_PAT_har_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_förälder_AC_barn_PAT_har
    );
END dt_lAC_förälder_AC_barn_PAT_har;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_innehåll_ST_plats_EV_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_PR_innehåll_ST_plats_EV_of (
    p_id IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_ID%TYPE,
    p_positor IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE,
    p_positing IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE
) RETURN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_innehåll_ST_plats_EV_of_Reliability
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Annex a
        WHERE
            a.PR_innehåll_ST_plats_EV_of_ID = p_id
        AND
            a.PR_innehåll_ST_plats_EV_of_Positor = p_positor
        AND
            a.PR_innehåll_ST_plats_EV_of_PositedAt <= p_positing
        ORDER BY
            a.PR_innehåll_ST_plats_EV_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_innehåll_ST_plats_EV_of_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_innehåll_ST_plats_EV_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_innehåll_ST_plats_EV_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_PR_innehåll_ST_plats_EV_of (
    p_id IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_ID%TYPE,
    p_positor IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE,
    p_positing IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_PR_innehåll_ST_plats_EV_of(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_PR_innehåll_ST_plats_EV_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_innehåll_ST_plats_EV_of states a posit of PR_innehåll_ST_plats_EV_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_innehåll_ST_plats_EV_of (
    p_PR_innehåll IN ties.PR_innehåll_ST_plats_EV_of_Posit.PR_ID_innehåll%TYPE,
    p_ST_plats IN ties.PR_innehåll_ST_plats_EV_of_Posit.ST_ID_plats%TYPE,
    p_EV_of IN ties.PR_innehåll_ST_plats_EV_of_Posit.EV_ID_of%TYPE,
    p_changing IN ties.PR_innehåll_ST_plats_EV_of_Posit.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.PR_innehåll_ST_plats_EV_of_Annex.Metadata_PR_innehåll_ST_plats_EV_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE;
    v_positing ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE;
    v_reliability ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE;
    v_held ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE;
    v_changing ties.PR_innehåll_ST_plats_EV_of_Posit.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE;
    v_posit ties.PR_innehåll_ST_plats_EV_of_Posit.PR_innehåll_ST_plats_EV_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Annex (
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Annex a
                WHERE
                    a.PR_innehåll_ST_plats_EV_of_ID = p_id
                AND
                    a.PR_innehåll_ST_plats_EV_of_Positor = v_positor
                AND
                    a.PR_innehåll_ST_plats_EV_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.PR_innehåll_ST_plats_EV_of_ID
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Posit p
        WHERE
            p.PR_ID_innehåll = p_PR_innehåll
        AND
            p.ST_ID_plats = p_ST_plats
        AND
            p.EV_ID_of = p_EV_of
        AND
            p.PR_innehåll_ST_plats_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_innehåll_ST_plats_EV_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Annex a
                WHERE
                    a.PR_innehåll_ST_plats_EV_of_ID = v_posit
                AND
                    a.PR_innehåll_ST_plats_EV_of_Positor = v_positor
                AND
                    a.PR_innehåll_ST_plats_EV_of_PositedAt = v_positing
                AND
                    a.PR_innehåll_ST_plats_EV_of_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_innehåll_ST_plats_EV_of for: ' ||
                p_PR_innehåll || ', ' ||
                p_ST_plats || ', ' ||
                p_EV_of || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Annex a
                WHERE
                    a.PR_innehåll_ST_plats_EV_of_ID = v_posit
                AND
                    a.PR_innehåll_ST_plats_EV_of_Positor = v_positor
                AND
                    a.PR_innehåll_ST_plats_EV_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_PR_innehåll_ST_plats_EV_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Annex (
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Posit (
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt
        )
        VALUES (
            p_PR_innehåll,
            p_ST_plats,
            p_EV_of,
            v_changing
        )
        RETURNING PR_innehåll_ST_plats_EV_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Annex (
        Metadata_PR_innehåll_ST_plats_EV_of,
        PR_innehåll_ST_plats_EV_of_ID,
        PR_innehåll_ST_plats_EV_of_Positor,
        PR_innehåll_ST_plats_EV_of_PositedAt,
        PR_innehåll_ST_plats_EV_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_innehåll_ST_plats_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_innehåll_ST_plats_EV_of instead of INSERT trigger on PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_PR_innehåll_ST_plats_EV_of
INSTEAD OF INSERT ON ties.PR_innehåll_ST_plats_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :NEW.PR_ID_innehåll,
        p_ST_plats => :NEW.ST_ID_plats,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt,
        p_positor => :NEW.PR_innehåll_ST_plats_EV_of_Positor,
        p_positing => :NEW.PR_innehåll_ST_plats_EV_of_PositedAt,
        p_reliability => :NEW.PR_innehåll_ST_plats_EV_of_Reliability,
        p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
    );
END it_PR_innehåll_ST_plats_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_innehåll_ST_plats_EV_of
INSTEAD OF INSERT ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :NEW.PR_ID_innehåll,
        p_ST_plats => :NEW.ST_ID_plats,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.PR_innehåll_ST_plats_EV_of_Positor <> :OLD.PR_innehåll_ST_plats_EV_of_Positor
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Positor IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Positor IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Positor IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Positor IS NULL))
        THEN :NEW.PR_innehåll_ST_plats_EV_of_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt <> :OLD.PR_innehåll_ST_plats_EV_of_PositedAt
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL))
        THEN :NEW.PR_innehåll_ST_plats_EV_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.PR_ID_innehåll <> :OLD.PR_ID_innehåll
            OR (:NEW.PR_ID_innehåll IS NULL AND :OLD.PR_ID_innehåll IS NOT NULL)
            OR (:NEW.PR_ID_innehåll IS NOT NULL AND :OLD.PR_ID_innehåll IS NULL)) OR
        (:NEW.ST_ID_plats <> :OLD.ST_ID_plats
            OR (:NEW.ST_ID_plats IS NULL AND :OLD.ST_ID_plats IS NOT NULL)
            OR (:NEW.ST_ID_plats IS NOT NULL AND :OLD.ST_ID_plats IS NULL)) OR
        (:NEW.EV_ID_of <> :OLD.EV_ID_of
            OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
            OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) OR
        (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt <> :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
            OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL)) OR
        (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt <> :OLD.PR_innehåll_ST_plats_EV_of_PositedAt
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL)) OR
        (:NEW.PR_innehåll_ST_plats_EV_of_Reliability <> :OLD.PR_innehåll_ST_plats_EV_of_Reliability
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Reliability IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Reliability IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Reliability IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Reliability IS NULL))
    THEN
        IF
            :NEW.PR_ID_innehåll IS NOT NULL
        AND
            :NEW.ST_ID_plats IS NOT NULL
        AND
            :NEW.EV_ID_of IS NOT NULL
        THEN
            ties.ip_PR_innehåll_ST_plats_EV_of(
                p_PR_innehåll => :NEW.PR_ID_innehåll,
                p_ST_plats => :NEW.ST_ID_plats,
                p_EV_of => :NEW.EV_ID_of,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt <> :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
                        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL))
                    THEN :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt
                    WHEN
                        :NEW.PR_ID_innehåll = :OLD.PR_ID_innehåll
                    AND
                        :NEW.ST_ID_plats = :OLD.ST_ID_plats
                    AND
                        :NEW.EV_ID_of = :OLD.EV_ID_of
                    THEN :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_Reliability, 1),
                p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_PR_innehåll_ST_plats_EV_of(
                p_PR_innehåll => :OLD.PR_ID_innehåll,
                p_ST_plats => :OLD.ST_ID_plats,
                p_EV_of => :OLD.EV_ID_of,
                p_changing => :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
            );
        END IF;
    END IF;
END ut_lPR_innehåll_ST_plats_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_innehåll_ST_plats_EV_of
INSTEAD OF DELETE ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :OLD.PR_ID_innehåll,
        p_ST_plats => :OLD.ST_ID_plats,
        p_EV_of => :OLD.EV_ID_of,
        p_changing => :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt,
        p_positor => COALESCE(:OLD.PR_innehåll_ST_plats_EV_of_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_PR_innehåll_ST_plats_EV_of
    );
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
-- Every key is per positor, as the perspectives are.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Scen_1st (
    Positor,
    ST_ID,
    ST_LOC_Scen_Plats,
    ST_LOC_Checksum
)
AS
SELECT
    "ST".Positor,
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
        'Positor' VALUE Positor,
        'ST_LOC_Checksum' VALUE ST_LOC_Checksum
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Scen_1st
WHERE
    ST_LOC_Checksum IS NOT NULL
GROUP BY
    Positor,
    ST_LOC_Checksum
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Scen_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Scen_1st
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_ST_Scen_2nd (
    Positor,
    ST_ID,
    ST_NAM_Scen_Namn
)
AS
SELECT
    "ST".Positor,
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
            "ST".Positor,
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
        'Positor' VALUE Positor,
        'ST_NAM_Scen_Namn' VALUE ST_NAM_Scen_Namn
    ),
    COUNT(DISTINCT ST_ID)
FROM
    anchors.key_ST_Scen_2nd
WHERE
    ST_NAM_Scen_Namn IS NOT NULL
GROUP BY
    Positor,
    ST_NAM_Scen_Namn
HAVING
    COUNT(DISTINCT ST_ID) > 1
UNION ALL
SELECT
    'key_ST_Scen_2nd',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'ST_ID' VALUE ST_ID
    ),
    COUNT(*)
FROM
    anchors.key_ST_Scen_2nd
GROUP BY
    Positor,
    ST_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_AC_Skådespelare_1st (
    Positor,
    AC_ID,
    AC_NAM_Skådespelare_Namn
)
AS
SELECT
    "AC".Positor,
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
            "AC".Positor,
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
        'Positor' VALUE Positor,
        'AC_NAM_Skådespelare_Namn' VALUE AC_NAM_Skådespelare_Namn
    ),
    COUNT(DISTINCT AC_ID)
FROM
    anchors.key_AC_Skådespelare_1st
WHERE
    AC_NAM_Skådespelare_Namn IS NOT NULL
GROUP BY
    Positor,
    AC_NAM_Skådespelare_Namn
HAVING
    COUNT(DISTINCT AC_ID) > 1
UNION ALL
SELECT
    'key_AC_Skådespelare_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'AC_ID' VALUE AC_ID
    ),
    COUNT(*)
FROM
    anchors.key_AC_Skådespelare_1st
GROUP BY
    Positor,
    AC_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.key_PR_Föreställning_1st (
    Positor,
    PR_ID,
    PR_NAM_Föreställning_Namn
)
AS
SELECT
    "PR".Positor,
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
        'Positor' VALUE Positor,
        'PR_NAM_Föreställning_Namn' VALUE PR_NAM_Föreställning_Namn
    ),
    COUNT(DISTINCT PR_ID)
FROM
    anchors.key_PR_Föreställning_1st
WHERE
    PR_NAM_Föreställning_Namn IS NOT NULL
GROUP BY
    Positor,
    PR_NAM_Föreställning_Namn
HAVING
    COUNT(DISTINCT PR_ID) > 1
UNION ALL
SELECT
    'key_PR_Föreställning_1st',
    'more than one natural key',
    JSON_OBJECT(
        'Positor' VALUE Positor,
        'PR_ID' VALUE PR_ID
    ),
    COUNT(*)
FROM
    anchors.key_PR_Föreställning_1st
GROUP BY
    Positor,
    PR_ID
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.key_EV_Händelse_1st (
    Positor,
    EV_ID,
    EV_DAT_Händelse_Datum,
    hölls_ST_LOC_Scen_Plats,
    hölls_ST_LOC_Checksum,
    spelades_PR_NAM_Föreställning_Namn
)
AS
SELECT
    "EV".Positor,
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
AND
    "s2".Positor = "EV".Positor
LEFT JOIN
    anchors.lPR_Föreställning "s4"
ON
    "s4".PR_ID = "EV".PR_ID_spelades
AND
    "s4".Positor = "EV".Positor
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
        'Positor' VALUE Positor,
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
    Positor,
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
        'Positor' VALUE Positor,
        'EV_ID' VALUE EV_ID
    ),
    COUNT(*)
FROM
    nexuses.key_EV_Händelse_1st
GROUP BY
    Positor,
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
COMMENT ON COLUMN attributes.EV_DAT_Händelse_Datum_Posit.EV_DAT_Händelse_Datum IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes.EV_AUD_Händelse_Publik_Posit.EV_AUD_Händelse_Publik IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes.EV_REV_Händelse_Intäkt_Posit.EV_REV_Händelse_Intäkt IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes.EV_STA_Händelse_Status_Posit.EV_STA_Händelse_Status IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes.EV_LVL_Händelse_Level_Posit.EV_LVL_PLV_ID IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes.ST_NAM_Scen_Namn_Posit.ST_NAM_Scen_Namn IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes.ST_LOC_Scen_Plats_Posit.ST_LOC_Scen_Plats IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes.ST_AVG_Scen_Medel_Posit.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes.ST_MIN_Scen_Minimum_Posit.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes.AC_NAM_Skådespelare_Namn_Posit.AC_NAM_Skådespelare_Namn IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes.AC_GEN_Skådespelare_Kön_Posit.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes.PR_NAM_Föreställning_Namn_Posit.PR_NAM_Föreställning_Namn IS 'Name or title of the program.';
COMMENT ON COLUMN attributes.PR_LEN_Föreställning_Längd_Posit.PR_LEN_Föreställning_Längd IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors.ST_Scen IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors.AC_Skådespelare IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses.EV_Händelse IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses.EV_Händelse.ST_ID_hölls IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses.EV_Händelse.PR_ID_spelades IS 'The program that was played at the event.';
COMMENT ON TABLE ties.AC_partner_AC_with_ONG_currently_Posit IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Posit.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Posit.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties.AC_partner_AC_with_ONG_currently_Posit.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties.AC_subset_PN_of_Posit.AC_ID_subset IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties.AC_subset_PN_of_Posit.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE ties.EV_in_AC_rollsattes_Posit IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties.EV_in_AC_rollsattes_Posit.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties.EV_in_AC_rollsattes_Posit.AC_ID_rollsattes IS 'An actor cast in the event.';
COMMENT ON TABLE ties.AC_deltar_PR_in_RAT_fick_Posit IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties.AC_deltar_PR_in_RAT_fick_Posit.AC_ID_deltar IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties.AC_deltar_PR_in_RAT_fick_Posit.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties.AC_deltar_PR_in_RAT_fick_Posit.RAT_ID_fick IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties.ST_at_PR_spelas_Posit IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties.ST_at_PR_spelas_Posit.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties.ST_at_PR_spelas_Posit.PR_ID_spelas IS 'The program playing at the stage.';
COMMENT ON TABLE ties.AC_förälder_AC_barn_PAT_har_Posit IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties.AC_förälder_AC_barn_PAT_har_Posit.AC_ID_förälder IS 'The actor who is the parent.';
COMMENT ON COLUMN ties.AC_förälder_AC_barn_PAT_har_Posit.AC_ID_barn IS 'The actor who is the child.';
COMMENT ON COLUMN ties.AC_förälder_AC_barn_PAT_har_Posit.PAT_ID_har IS 'The type of parental relationship.';
COMMENT ON TABLE ties.PR_innehåll_ST_plats_EV_of_Posit IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties.PR_innehåll_ST_plats_EV_of_Posit.PR_ID_innehåll IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties.PR_innehåll_ST_plats_EV_of_Posit.ST_ID_plats IS 'The stage where the event was located.';
COMMENT ON COLUMN ties.PR_innehåll_ST_plats_EV_of_Posit.EV_ID_of IS 'The event.';
