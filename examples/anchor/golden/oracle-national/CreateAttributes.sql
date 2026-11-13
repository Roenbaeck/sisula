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
