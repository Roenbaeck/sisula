-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
-- Every object is made inside a block that lets one that is already there be, so a script can be run again.
-- (ORA-00955: name is already used by an existing object)
--
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_DAT_Händelse_Datum_Annex (
            EV_DAT_ID number(10) not null,
            EV_DAT_PositedAt timestamp not null,
            EV_DAT_Reliability number(5,2) not null,
            Metadata_EV_DAT number(10) not null,
            constraint fkEV_DAT_Händelse_Datum_Annex foreign key (
                EV_DAT_ID
            ) references attributes.EV_DAT_Händelse_Datum_Posit(EV_DAT_ID),
            constraint pkEV_DAT_Händelse_Datum_Annex primary key (
                EV_DAT_ID,
                EV_DAT_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_AUD_Händelse_Publik_Annex (
            EV_AUD_ID number(10) not null,
            EV_AUD_PositedAt timestamp not null,
            EV_AUD_Reliability number(5,2) not null,
            Metadata_EV_AUD number(10) not null,
            constraint fkEV_AUD_Händelse_Publik_Annex foreign key (
                EV_AUD_ID
            ) references attributes.EV_AUD_Händelse_Publik_Posit(EV_AUD_ID),
            constraint pkEV_AUD_Händelse_Publik_Annex primary key (
                EV_AUD_ID,
                EV_AUD_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_REV_Händelse_Intäkt_Annex (
            EV_REV_ID number(10) not null,
            EV_REV_PositedAt timestamp not null,
            EV_REV_Reliability number(5,2) not null,
            Metadata_EV_REV number(10) not null,
            constraint fkEV_REV_Händelse_Intäkt_Annex foreign key (
                EV_REV_ID
            ) references attributes.EV_REV_Händelse_Intäkt_Posit(EV_REV_ID),
            constraint pkEV_REV_Händelse_Intäkt_Annex primary key (
                EV_REV_ID,
                EV_REV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_STA_Händelse_Status_Annex (
            EV_STA_ID number(10) not null,
            EV_STA_PositedAt timestamp not null,
            EV_STA_Reliability number(5,2) not null,
            Metadata_EV_STA number(10) not null,
            constraint fkEV_STA_Händelse_Status_Annex foreign key (
                EV_STA_ID
            ) references attributes.EV_STA_Händelse_Status_Posit(EV_STA_ID),
            constraint pkEV_STA_Händelse_Status_Annex primary key (
                EV_STA_ID,
                EV_STA_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_UTL_Händelse_Utnyttjande_Annex (
            EV_UTL_ID number(10) not null,
            EV_UTL_PositedAt timestamp not null,
            EV_UTL_Reliability number(5,2) not null,
            Metadata_EV_UTL number(10) not null,
            constraint fkEV_UTL_Händelse_Utnyttjande_Annex foreign key (
                EV_UTL_ID
            ) references attributes.EV_UTL_Händelse_Utnyttjande_Posit(EV_UTL_ID),
            constraint pkEV_UTL_Händelse_Utnyttjande_Annex primary key (
                EV_UTL_ID,
                EV_UTL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.EV_LVL_Händelse_Level_Annex (
            EV_LVL_ID number(10) not null,
            EV_LVL_PositedAt timestamp not null,
            EV_LVL_Reliability number(5,2) not null,
            Metadata_EV_LVL number(10) not null,
            constraint fkEV_LVL_Händelse_Level_Annex foreign key (
                EV_LVL_ID
            ) references attributes.EV_LVL_Händelse_Level_Posit(EV_LVL_ID),
            constraint pkEV_LVL_Händelse_Level_Annex primary key (
                EV_LVL_ID,
                EV_LVL_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_NAM_Scen_Namn_Annex (
            ST_NAM_ID number(10) not null,
            ST_NAM_PositedAt timestamp not null,
            ST_NAM_Reliability number(5,2) not null,
            Metadata_ST_NAM number(10) not null,
            constraint fkST_NAM_Scen_Namn_Annex foreign key (
                ST_NAM_ID
            ) references attributes.ST_NAM_Scen_Namn_Posit(ST_NAM_ID),
            constraint pkST_NAM_Scen_Namn_Annex primary key (
                ST_NAM_ID,
                ST_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_LOC_Scen_Plats_Annex (
            ST_LOC_ID number(10) not null,
            ST_LOC_PositedAt timestamp not null,
            ST_LOC_Reliability number(5,2) not null,
            Metadata_ST_LOC number(10) not null,
            constraint fkST_LOC_Scen_Plats_Annex foreign key (
                ST_LOC_ID
            ) references attributes.ST_LOC_Scen_Plats_Posit(ST_LOC_ID),
            constraint pkST_LOC_Scen_Plats_Annex primary key (
                ST_LOC_ID,
                ST_LOC_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_AVG_Scen_Medel_Annex (
            ST_AVG_ID number(10) not null,
            ST_AVG_PositedAt timestamp not null,
            ST_AVG_Reliability number(5,2) not null,
            Metadata_ST_AVG number(10) not null,
            constraint fkST_AVG_Scen_Medel_Annex foreign key (
                ST_AVG_ID
            ) references attributes.ST_AVG_Scen_Medel_Posit(ST_AVG_ID),
            constraint pkST_AVG_Scen_Medel_Annex primary key (
                ST_AVG_ID,
                ST_AVG_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.ST_MIN_Scen_Minimum_Annex (
            ST_MIN_ID number(10) not null,
            ST_MIN_PositedAt timestamp not null,
            ST_MIN_Reliability number(5,2) not null,
            Metadata_ST_MIN number(10) not null,
            constraint fkST_MIN_Scen_Minimum_Annex foreign key (
                ST_MIN_ID
            ) references attributes.ST_MIN_Scen_Minimum_Posit(ST_MIN_ID),
            constraint pkST_MIN_Scen_Minimum_Annex primary key (
                ST_MIN_ID,
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_NAM_Skådespelare_Namn_Annex (
            AC_NAM_ID number(10) not null,
            AC_NAM_PositedAt timestamp not null,
            AC_NAM_Reliability number(5,2) not null,
            Metadata_AC_NAM number(10) not null,
            constraint fkAC_NAM_Skådespelare_Namn_Annex foreign key (
                AC_NAM_ID
            ) references attributes.AC_NAM_Skådespelare_Namn_Posit(AC_NAM_ID),
            constraint pkAC_NAM_Skådespelare_Namn_Annex primary key (
                AC_NAM_ID,
                AC_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_GEN_Skådespelare_Kön_Annex (
            AC_GEN_ID number(10) not null,
            AC_GEN_PositedAt timestamp not null,
            AC_GEN_Reliability number(5,2) not null,
            Metadata_AC_GEN number(10) not null,
            constraint fkAC_GEN_Skådespelare_Kön_Annex foreign key (
                AC_GEN_ID
            ) references attributes.AC_GEN_Skådespelare_Kön_Posit(AC_GEN_ID),
            constraint pkAC_GEN_Skådespelare_Kön_Annex primary key (
                AC_GEN_ID,
                AC_GEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
            AC_PLV_ID number(10) not null,
            AC_PLV_PositedAt timestamp not null,
            AC_PLV_Reliability number(5,2) not null,
            Metadata_AC_PLV number(10) not null,
            constraint fkAC_PLV_Skådespelare_Yrkesnivå_Annex foreign key (
                AC_PLV_ID
            ) references attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit(AC_PLV_ID),
            constraint pkAC_PLV_Skådespelare_Yrkesnivå_Annex primary key (
                AC_PLV_ID,
                AC_PLV_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_NAM_Föreställning_Namn_Annex (
            PR_NAM_ID number(10) not null,
            PR_NAM_PositedAt timestamp not null,
            PR_NAM_Reliability number(5,2) not null,
            Metadata_PR_NAM number(10) not null,
            constraint fkPR_NAM_Föreställning_Namn_Annex foreign key (
                PR_NAM_ID
            ) references attributes.PR_NAM_Föreställning_Namn_Posit(PR_NAM_ID),
            constraint pkPR_NAM_Föreställning_Namn_Annex primary key (
                PR_NAM_ID,
                PR_NAM_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
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
BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE attributes.PR_LEN_Föreställning_Längd_Annex (
            PR_LEN_ID number(10) not null,
            PR_LEN_PositedAt timestamp not null,
            PR_LEN_Reliability number(5,2) not null,
            Metadata_PR_LEN number(10) not null,
            constraint fkPR_LEN_Föreställning_Längd_Annex foreign key (
                PR_LEN_ID
            ) references attributes.PR_LEN_Föreställning_Längd_Posit(PR_LEN_ID),
            constraint pkPR_LEN_Föreställning_Längd_Annex primary key (
                PR_LEN_ID,
                PR_LEN_PositedAt
            )
        )
    ]';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -955 THEN RAISE; END IF;
END;
/
