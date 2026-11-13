-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw._Positor (
    Positor number(3) not null,
    constraint pk_Positor primary key (
        Positor
    )
);
MERGE INTO dw._Positor p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p.Positor
)
WHEN NOT MATCHED THEN
INSERT (
    Positor
)
VALUES (
    d._defaultPositor
);
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_Föräldratyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.PAT_Föräldratyp (
    PAT_ID number(3) not null,
    PAT_Föräldratyp nvarchar2(42) not null,
    Metadata_PAT number(10) not null,
    constraint pkPAT_Föräldratyp primary key (
        PAT_ID
    ),
    constraint uqPAT_Föräldratyp unique (
        PAT_Föräldratyp
    )
) CLUSTER BY (PAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.GEN_Kön (
    GEN_ID number(3) not null,
    GEN_Kön nvarchar2(42) not null,
    GEN_Checksum numeric(19,0) default hash(GEN_Kön),
    Metadata_GEN number(10) not null,
    constraint pkGEN_Kön primary key (
        GEN_ID
    ),
    constraint uqGEN_Kön unique (
        GEN_Checksum 
    )
) CLUSTER BY (GEN_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.PLV_Yrkesnivå (
    PLV_ID number(3) not null,
    PLV_Yrkesnivå nclob not null,
    PLV_Checksum numeric(19,0) default hash(PLV_Yrkesnivå),
    Metadata_PLV number(10) not null,
    constraint pkPLV_Yrkesnivå primary key (
        PLV_ID
    ),
    constraint uqPLV_Yrkesnivå unique (
        PLV_Checksum 
    )
) CLUSTER BY (PLV_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.UTL_Utnyttjande (
    UTL_ID number(3) not null,
    UTL_Utnyttjande number(3) not null,
    Metadata_UTL number(10) not null,
    constraint pkUTL_Utnyttjande primary key (
        UTL_ID
    ),
    constraint uqUTL_Utnyttjande unique (
        UTL_Utnyttjande
    )
) CLUSTER BY (UTL_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ONG_Pågående (
    ONG_ID number(3) not null,
    ONG_Pågående nvarchar2(3) not null,
    Metadata_ONG number(10) not null,
    constraint pkONG_Pågående primary key (
        ONG_ID
    ),
    constraint uqONG_Pågående unique (
        ONG_Pågående
    )
) CLUSTER BY (ONG_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.RAT_Betyg (
    RAT_ID number(3) IDENTITY(1,1) not null, 
    RAT_Betyg nvarchar2(42) not null,
    RAT_Checksum numeric(19,0) default hash(RAT_Betyg),
    Metadata_RAT number(10) not null,
    constraint pkRAT_Betyg primary key (
        RAT_ID
    ),
    constraint uqRAT_Betyg unique (
        RAT_Checksum 
    )
) CLUSTER BY (RAT_ID);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.ETY_Händelsetyp (
    ETY_ID number(3) not null,
    ETY_Händelsetyp nvarchar2(42) not null,
    ETY_Checksum numeric(19,0) default hash(ETY_Händelsetyp),
    Metadata_ETY number(10) not null,
    constraint pkETY_Händelsetyp primary key (
        ETY_ID
    ),
    constraint uqETY_Händelsetyp unique (
        ETY_Checksum 
    )
) CLUSTER BY (ETY_ID);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.PN_Person (
    PN_ID number(19) IDENTITY(1,1) not null, 
    Metadata_PN number(10) not null, 
    constraint pkPN_Person primary key (
        PN_ID
    )
) CLUSTER BY (PN_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.ST_Scen (
    ST_ID number(10) not null,
    Metadata_ST number(10) not null, 
    constraint pkST_Scen primary key (
        ST_ID
    )
) CLUSTER BY (ST_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.AC_Skådespelare (
    AC_ID number(5) IDENTITY(1,1) not null, 
    Metadata_AC number(10) not null, 
    constraint pkAC_Skådespelare primary key (
        AC_ID
    )
) CLUSTER BY (AC_ID);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.PR_Föreställning (
    PR_ID number(19) not null,
    Metadata_PR number(10) not null, 
    constraint pkPR_Föreställning primary key (
        PR_ID
    )
) CLUSTER BY (PR_ID);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Händelse table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.EV_Händelse (
    EV_ID number(12,0) not null,
    ST_ID_hölls number(10) not null, 
    PR_ID_spelades number(19) not null, 
    ETY_ID_of number(3) not null,
    constraint EV_Händelse_fkST_hölls foreign key (
        ST_ID_hölls
    ) references anchors.ST_Scen(ST_ID), 
    constraint EV_Händelse_fkPR_spelades foreign key (
        PR_ID_spelades
    ) references anchors.PR_Föreställning(PR_ID), 
    constraint EV_Händelse_fkETY_of foreign key (
        ETY_ID_of
    ) references knots.ETY_Händelsetyp(ETY_ID),
    Metadata_EV number(10) not null, 
    constraint pkEV_Händelse primary key (
        EV_ID
    )
) CLUSTER BY (EV_ID);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Händelse_Datum_Posit (
    EV_DAT_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (EV_DAT_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Annex table (of EV_DAT_Händelse_Datum_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_DAT_Händelse_Datum_Annex (
    EV_DAT_ID number(10) not null,
    EV_DAT_PositedAt timestamp not null,
    EV_DAT_Positor number(3) not null,
    EV_DAT_Reliability number(5,2) not null,
    EV_DAT_Assertion varchar2(4000) default (
        case
            when EV_DAT_Reliability > 0 then '+'
            when EV_DAT_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_DAT_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_DAT number(10) not null,
    constraint fkEV_DAT_Händelse_Datum_Annex foreign key (
        EV_DAT_ID
    ) references attributes.EV_DAT_Händelse_Datum_Posit(EV_DAT_ID),
    constraint pkEV_DAT_Händelse_Datum_Annex primary key (
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt
    )
) CLUSTER BY (EV_DAT_ID, EV_DAT_Positor, EV_DAT_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Händelse_Publik_Posit (
    EV_AUD_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (EV_AUD_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Annex table (of EV_AUD_Händelse_Publik_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_AUD_Händelse_Publik_Annex (
    EV_AUD_ID number(10) not null,
    EV_AUD_PositedAt timestamp not null,
    EV_AUD_Positor number(3) not null,
    EV_AUD_Reliability number(5,2) not null,
    EV_AUD_Assertion varchar2(4000) default (
        case
            when EV_AUD_Reliability > 0 then '+'
            when EV_AUD_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_AUD_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_AUD number(10) not null,
    constraint fkEV_AUD_Händelse_Publik_Annex foreign key (
        EV_AUD_ID
    ) references attributes.EV_AUD_Händelse_Publik_Posit(EV_AUD_ID),
    constraint pkEV_AUD_Händelse_Publik_Annex primary key (
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt
    )
) CLUSTER BY (EV_AUD_ID, EV_AUD_Positor, EV_AUD_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Händelse_Intäkt_Posit (
    EV_REV_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (EV_REV_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Annex table (of EV_REV_Händelse_Intäkt_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_REV_Händelse_Intäkt_Annex (
    EV_REV_ID number(10) not null,
    EV_REV_PositedAt timestamp not null,
    EV_REV_Positor number(3) not null,
    EV_REV_Reliability number(5,2) not null,
    EV_REV_Assertion varchar2(4000) default (
        case
            when EV_REV_Reliability > 0 then '+'
            when EV_REV_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_REV_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_REV number(10) not null,
    constraint fkEV_REV_Händelse_Intäkt_Annex foreign key (
        EV_REV_ID
    ) references attributes.EV_REV_Händelse_Intäkt_Posit(EV_REV_ID),
    constraint pkEV_REV_Händelse_Intäkt_Annex primary key (
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt
    )
) CLUSTER BY (EV_REV_ID, EV_REV_Positor, EV_REV_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Händelse_Status_Posit (
    EV_STA_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (EV_STA_EV_ID, EV_STA_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Annex table (of EV_STA_Händelse_Status_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_STA_Händelse_Status_Annex (
    EV_STA_ID number(10) not null,
    EV_STA_PositedAt timestamp not null,
    EV_STA_Positor number(3) not null,
    EV_STA_Reliability number(5,2) not null,
    EV_STA_Assertion varchar2(4000) default (
        case
            when EV_STA_Reliability > 0 then '+'
            when EV_STA_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_STA_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_STA number(10) not null,
    constraint fkEV_STA_Händelse_Status_Annex foreign key (
        EV_STA_ID
    ) references attributes.EV_STA_Händelse_Status_Posit(EV_STA_ID),
    constraint pkEV_STA_Händelse_Status_Annex primary key (
        EV_STA_ID,
        EV_STA_Positor,
        EV_STA_PositedAt
    )
) CLUSTER BY (EV_STA_ID, EV_STA_Positor, EV_STA_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Händelse_Utnyttjande_Posit (
    EV_UTL_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (EV_UTL_EV_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Annex table (of EV_UTL_Händelse_Utnyttjande_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_UTL_Händelse_Utnyttjande_Annex (
    EV_UTL_ID number(10) not null,
    EV_UTL_PositedAt timestamp not null,
    EV_UTL_Positor number(3) not null,
    EV_UTL_Reliability number(5,2) not null,
    EV_UTL_Assertion varchar2(4000) default (
        case
            when EV_UTL_Reliability > 0 then '+'
            when EV_UTL_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_UTL_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_UTL number(10) not null,
    constraint fkEV_UTL_Händelse_Utnyttjande_Annex foreign key (
        EV_UTL_ID
    ) references attributes.EV_UTL_Händelse_Utnyttjande_Posit(EV_UTL_ID),
    constraint pkEV_UTL_Händelse_Utnyttjande_Annex primary key (
        EV_UTL_ID,
        EV_UTL_Positor,
        EV_UTL_PositedAt
    )
) CLUSTER BY (EV_UTL_ID, EV_UTL_Positor, EV_UTL_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Händelse_Level_Posit (
    EV_LVL_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (EV_LVL_EV_ID, EV_LVL_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Annex table (of EV_LVL_Händelse_Level_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.EV_LVL_Händelse_Level_Annex (
    EV_LVL_ID number(10) not null,
    EV_LVL_PositedAt timestamp not null,
    EV_LVL_Positor number(3) not null,
    EV_LVL_Reliability number(5,2) not null,
    EV_LVL_Assertion varchar2(4000) default (
        case
            when EV_LVL_Reliability > 0 then '+'
            when EV_LVL_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_LVL_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_LVL number(10) not null,
    constraint fkEV_LVL_Händelse_Level_Annex foreign key (
        EV_LVL_ID
    ) references attributes.EV_LVL_Händelse_Level_Posit(EV_LVL_ID),
    constraint pkEV_LVL_Händelse_Level_Annex primary key (
        EV_LVL_ID,
        EV_LVL_Positor,
        EV_LVL_PositedAt
    )
) CLUSTER BY (EV_LVL_ID, EV_LVL_Positor, EV_LVL_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Scen_Namn_Posit (
    ST_NAM_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (ST_NAM_ST_ID, ST_NAM_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Annex table (of ST_NAM_Scen_Namn_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_NAM_Scen_Namn_Annex (
    ST_NAM_ID number(10) not null,
    ST_NAM_PositedAt timestamp not null,
    ST_NAM_Positor number(3) not null,
    ST_NAM_Reliability number(5,2) not null,
    ST_NAM_Assertion varchar2(4000) default (
        case
            when ST_NAM_Reliability > 0 then '+'
            when ST_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_NAM_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_NAM number(10) not null,
    constraint fkST_NAM_Scen_Namn_Annex foreign key (
        ST_NAM_ID
    ) references attributes.ST_NAM_Scen_Namn_Posit(ST_NAM_ID),
    constraint pkST_NAM_Scen_Namn_Annex primary key (
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt
    )
) CLUSTER BY (ST_NAM_ID, ST_NAM_Positor, ST_NAM_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Scen_Plats_Posit (
    ST_LOC_ID number(10) IDENTITY(1,1) not null, 
    ST_LOC_ST_ID number(10) not null,
    ST_LOC_Scen_Plats geography not null,
    ST_LOC_Checksum numeric(19,0) default hash(ST_LOC_Scen_Plats),
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
) CLUSTER BY (ST_LOC_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Annex table (of ST_LOC_Scen_Plats_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_LOC_Scen_Plats_Annex (
    ST_LOC_ID number(10) not null,
    ST_LOC_PositedAt timestamp not null,
    ST_LOC_Positor number(3) not null,
    ST_LOC_Reliability number(5,2) not null,
    ST_LOC_Assertion varchar2(4000) default (
        case
            when ST_LOC_Reliability > 0 then '+'
            when ST_LOC_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_LOC_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_LOC number(10) not null,
    constraint fkST_LOC_Scen_Plats_Annex foreign key (
        ST_LOC_ID
    ) references attributes.ST_LOC_Scen_Plats_Posit(ST_LOC_ID),
    constraint pkST_LOC_Scen_Plats_Annex primary key (
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt
    )
) CLUSTER BY (ST_LOC_ID, ST_LOC_Positor, ST_LOC_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Scen_Medel_Posit (
    ST_AVG_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (ST_AVG_ST_ID, ST_AVG_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Annex table (of ST_AVG_Scen_Medel_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_AVG_Scen_Medel_Annex (
    ST_AVG_ID number(10) not null,
    ST_AVG_PositedAt timestamp not null,
    ST_AVG_Positor number(3) not null,
    ST_AVG_Reliability number(5,2) not null,
    ST_AVG_Assertion varchar2(4000) default (
        case
            when ST_AVG_Reliability > 0 then '+'
            when ST_AVG_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_AVG_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_AVG number(10) not null,
    constraint fkST_AVG_Scen_Medel_Annex foreign key (
        ST_AVG_ID
    ) references attributes.ST_AVG_Scen_Medel_Posit(ST_AVG_ID),
    constraint pkST_AVG_Scen_Medel_Annex primary key (
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt
    )
) CLUSTER BY (ST_AVG_ID, ST_AVG_Positor, ST_AVG_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Scen_Minimum_Posit (
    ST_MIN_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (ST_MIN_ST_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Annex table (of ST_MIN_Scen_Minimum_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.ST_MIN_Scen_Minimum_Annex (
    ST_MIN_ID number(10) not null,
    ST_MIN_PositedAt timestamp not null,
    ST_MIN_Positor number(3) not null,
    ST_MIN_Reliability number(5,2) not null,
    ST_MIN_Assertion varchar2(4000) default (
        case
            when ST_MIN_Reliability > 0 then '+'
            when ST_MIN_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_MIN_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_MIN number(10) not null,
    constraint fkST_MIN_Scen_Minimum_Annex foreign key (
        ST_MIN_ID
    ) references attributes.ST_MIN_Scen_Minimum_Posit(ST_MIN_ID),
    constraint pkST_MIN_Scen_Minimum_Annex primary key (
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt
    )
) CLUSTER BY (ST_MIN_ID, ST_MIN_Positor, ST_MIN_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Skådespelare_Namn_Posit (
    AC_NAM_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (AC_NAM_AC_ID, AC_NAM_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Annex table (of AC_NAM_Skådespelare_Namn_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_NAM_Skådespelare_Namn_Annex (
    AC_NAM_ID number(10) not null,
    AC_NAM_PositedAt timestamp not null,
    AC_NAM_Positor number(3) not null,
    AC_NAM_Reliability number(5,2) not null,
    AC_NAM_Assertion varchar2(4000) default (
        case
            when AC_NAM_Reliability > 0 then '+'
            when AC_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_NAM_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_NAM number(10) not null,
    constraint fkAC_NAM_Skådespelare_Namn_Annex foreign key (
        AC_NAM_ID
    ) references attributes.AC_NAM_Skådespelare_Namn_Posit(AC_NAM_ID),
    constraint pkAC_NAM_Skådespelare_Namn_Annex primary key (
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt
    )
) CLUSTER BY (AC_NAM_ID, AC_NAM_Positor, AC_NAM_PositedAt);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Skådespelare_Kön_Posit (
    AC_GEN_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (AC_GEN_AC_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Annex table (of AC_GEN_Skådespelare_Kön_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_GEN_Skådespelare_Kön_Annex (
    AC_GEN_ID number(10) not null,
    AC_GEN_PositedAt timestamp not null,
    AC_GEN_Positor number(3) not null,
    AC_GEN_Reliability number(5,2) not null,
    AC_GEN_Assertion varchar2(4000) default (
        case
            when AC_GEN_Reliability > 0 then '+'
            when AC_GEN_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_GEN_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_GEN number(10) not null,
    constraint fkAC_GEN_Skådespelare_Kön_Annex foreign key (
        AC_GEN_ID
    ) references attributes.AC_GEN_Skådespelare_Kön_Posit(AC_GEN_ID),
    constraint pkAC_GEN_Skådespelare_Kön_Annex primary key (
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt
    )
) CLUSTER BY (AC_GEN_ID, AC_GEN_Positor, AC_GEN_PositedAt);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit (
    AC_PLV_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (AC_PLV_AC_ID, AC_PLV_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Annex table (of AC_PLV_Skådespelare_Yrkesnivå_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex (
    AC_PLV_ID number(10) not null,
    AC_PLV_PositedAt timestamp not null,
    AC_PLV_Positor number(3) not null,
    AC_PLV_Reliability number(5,2) not null,
    AC_PLV_Assertion varchar2(4000) default (
        case
            when AC_PLV_Reliability > 0 then '+'
            when AC_PLV_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_PLV_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_PLV number(10) not null,
    constraint fkAC_PLV_Skådespelare_Yrkesnivå_Annex foreign key (
        AC_PLV_ID
    ) references attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit(AC_PLV_ID),
    constraint pkAC_PLV_Skådespelare_Yrkesnivå_Annex primary key (
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt
    )
) CLUSTER BY (AC_PLV_ID, AC_PLV_Positor, AC_PLV_PositedAt);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Föreställning_Namn_Posit (
    PR_NAM_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (PR_NAM_PR_ID);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Annex table (of PR_NAM_Föreställning_Namn_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_NAM_Föreställning_Namn_Annex (
    PR_NAM_ID number(10) not null,
    PR_NAM_PositedAt timestamp not null,
    PR_NAM_Positor number(3) not null,
    PR_NAM_Reliability number(5,2) not null,
    PR_NAM_Assertion varchar2(4000) default (
        case
            when PR_NAM_Reliability > 0 then '+'
            when PR_NAM_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_NAM_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_NAM number(10) not null,
    constraint fkPR_NAM_Föreställning_Namn_Annex foreign key (
        PR_NAM_ID
    ) references attributes.PR_NAM_Föreställning_Namn_Posit(PR_NAM_ID),
    constraint pkPR_NAM_Föreställning_Namn_Annex primary key (
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt
    )
) CLUSTER BY (PR_NAM_ID, PR_NAM_Positor, PR_NAM_PositedAt);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Föreställning_Längd_Posit (
    PR_LEN_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (PR_LEN_PR_ID, PR_LEN_ChangedAt);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Annex table (of PR_LEN_Föreställning_Längd_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.PR_LEN_Föreställning_Längd_Annex (
    PR_LEN_ID number(10) not null,
    PR_LEN_PositedAt timestamp not null,
    PR_LEN_Positor number(3) not null,
    PR_LEN_Reliability number(5,2) not null,
    PR_LEN_Assertion varchar2(4000) default (
        case
            when PR_LEN_Reliability > 0 then '+'
            when PR_LEN_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_LEN_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_LEN number(10) not null,
    constraint fkPR_LEN_Föreställning_Längd_Annex foreign key (
        PR_LEN_ID
    ) references attributes.PR_LEN_Föreställning_Längd_Posit(PR_LEN_ID),
    constraint pkPR_LEN_Föreställning_Längd_Annex primary key (
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt
    )
) CLUSTER BY (PR_LEN_ID, PR_LEN_Positor, PR_LEN_PositedAt);
-- ATTRIBUTE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views. These provide a stable baseline
-- for perspectives and can later be expanded to parameterized SQL macros.
--
CREATE OR REPLACE VIEW attributes.rEV_DAT_Händelse_Datum AS
SELECT
    a.Metadata_EV_DAT,
    p.EV_DAT_ID,
    a.EV_DAT_PositedAt,
    a.EV_DAT_Positor,
    a.EV_DAT_Reliability,
    a.EV_DAT_Assertion,
    a.,
    p.EV_DAT_EV_ID,
    p.EV_DAT_Händelse_Datum
FROM
    attributes.EV_DAT_Händelse_Datum_Posit p
JOIN
    attributes.EV_DAT_Händelse_Datum_Annex a
ON
    a.EV_DAT_ID = p.EV_DAT_ID
WHERE
    a.EV_DAT_Positor = 0
AND
    a.EV_DAT_PositedAt = (
        SELECT
            MAX(sub.EV_DAT_PositedAt)
        FROM
            attributes.EV_DAT_Händelse_Datum_Annex sub
        WHERE
            sub.EV_DAT_ID = p.EV_DAT_ID
        AND
            sub.EV_DAT_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_AUD_Händelse_Publik AS
SELECT
    a.Metadata_EV_AUD,
    p.EV_AUD_ID,
    a.EV_AUD_PositedAt,
    a.EV_AUD_Positor,
    a.EV_AUD_Reliability,
    a.EV_AUD_Assertion,
    a.,
    p.EV_AUD_EV_ID,
    p.EV_AUD_Händelse_Publik
FROM
    attributes.EV_AUD_Händelse_Publik_Posit p
JOIN
    attributes.EV_AUD_Händelse_Publik_Annex a
ON
    a.EV_AUD_ID = p.EV_AUD_ID
WHERE
    a.EV_AUD_Positor = 0
AND
    a.EV_AUD_PositedAt = (
        SELECT
            MAX(sub.EV_AUD_PositedAt)
        FROM
            attributes.EV_AUD_Händelse_Publik_Annex sub
        WHERE
            sub.EV_AUD_ID = p.EV_AUD_ID
        AND
            sub.EV_AUD_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_REV_Händelse_Intäkt AS
SELECT
    a.Metadata_EV_REV,
    p.EV_REV_ID,
    a.EV_REV_PositedAt,
    a.EV_REV_Positor,
    a.EV_REV_Reliability,
    a.EV_REV_Assertion,
    a.,
    p.EV_REV_EV_ID,
    p.EV_REV_Händelse_Intäkt
FROM
    attributes.EV_REV_Händelse_Intäkt_Posit p
JOIN
    attributes.EV_REV_Händelse_Intäkt_Annex a
ON
    a.EV_REV_ID = p.EV_REV_ID
WHERE
    a.EV_REV_Positor = 0
AND
    a.EV_REV_PositedAt = (
        SELECT
            MAX(sub.EV_REV_PositedAt)
        FROM
            attributes.EV_REV_Händelse_Intäkt_Annex sub
        WHERE
            sub.EV_REV_ID = p.EV_REV_ID
        AND
            sub.EV_REV_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_STA_Händelse_Status AS
SELECT
    a.Metadata_EV_STA,
    p.EV_STA_ID,
    a.EV_STA_PositedAt,
    a.EV_STA_Positor,
    a.EV_STA_Reliability,
    a.EV_STA_Assertion,
    a.,
    p.EV_STA_EV_ID,
    p.EV_STA_Händelse_Status
    , p.EV_STA_ChangedAt
FROM
    attributes.EV_STA_Händelse_Status_Posit p
JOIN
    attributes.EV_STA_Händelse_Status_Annex a
ON
    a.EV_STA_ID = p.EV_STA_ID
WHERE
    a.EV_STA_Positor = 0
AND
    a.EV_STA_PositedAt = (
        SELECT
            MAX(sub.EV_STA_PositedAt)
        FROM
            attributes.EV_STA_Händelse_Status_Annex sub
        WHERE
            sub.EV_STA_ID = p.EV_STA_ID
        AND
            sub.EV_STA_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_UTL_Händelse_Utnyttjande AS
SELECT
    a.Metadata_EV_UTL,
    p.EV_UTL_ID,
    a.EV_UTL_PositedAt,
    a.EV_UTL_Positor,
    a.EV_UTL_Reliability,
    a.EV_UTL_Assertion,
    a.,
    p.EV_UTL_EV_ID,
    p.EV_UTL_UTL_ID
FROM
    attributes.EV_UTL_Händelse_Utnyttjande_Posit p
JOIN
    attributes.EV_UTL_Händelse_Utnyttjande_Annex a
ON
    a.EV_UTL_ID = p.EV_UTL_ID
WHERE
    a.EV_UTL_Positor = 0
AND
    a.EV_UTL_PositedAt = (
        SELECT
            MAX(sub.EV_UTL_PositedAt)
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande_Annex sub
        WHERE
            sub.EV_UTL_ID = p.EV_UTL_ID
        AND
            sub.EV_UTL_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rEV_LVL_Händelse_Level AS
SELECT
    a.Metadata_EV_LVL,
    p.EV_LVL_ID,
    a.EV_LVL_PositedAt,
    a.EV_LVL_Positor,
    a.EV_LVL_Reliability,
    a.EV_LVL_Assertion,
    a.,
    p.EV_LVL_EV_ID,
    p.EV_LVL_PLV_ID
    , p.EV_LVL_ChangedAt
FROM
    attributes.EV_LVL_Händelse_Level_Posit p
JOIN
    attributes.EV_LVL_Händelse_Level_Annex a
ON
    a.EV_LVL_ID = p.EV_LVL_ID
WHERE
    a.EV_LVL_Positor = 0
AND
    a.EV_LVL_PositedAt = (
        SELECT
            MAX(sub.EV_LVL_PositedAt)
        FROM
            attributes.EV_LVL_Händelse_Level_Annex sub
        WHERE
            sub.EV_LVL_ID = p.EV_LVL_ID
        AND
            sub.EV_LVL_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_NAM_Scen_Namn AS
SELECT
    a.Metadata_ST_NAM,
    p.ST_NAM_ID,
    a.ST_NAM_PositedAt,
    a.ST_NAM_Positor,
    a.ST_NAM_Reliability,
    a.ST_NAM_Assertion,
    a.,
    p.ST_NAM_ST_ID,
    p.ST_NAM_Scen_Namn
    , p.ST_NAM_ChangedAt
FROM
    attributes.ST_NAM_Scen_Namn_Posit p
JOIN
    attributes.ST_NAM_Scen_Namn_Annex a
ON
    a.ST_NAM_ID = p.ST_NAM_ID
WHERE
    a.ST_NAM_Positor = 0
AND
    a.ST_NAM_PositedAt = (
        SELECT
            MAX(sub.ST_NAM_PositedAt)
        FROM
            attributes.ST_NAM_Scen_Namn_Annex sub
        WHERE
            sub.ST_NAM_ID = p.ST_NAM_ID
        AND
            sub.ST_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_LOC_Scen_Plats AS
SELECT
    a.Metadata_ST_LOC,
    p.ST_LOC_ID,
    a.ST_LOC_PositedAt,
    a.ST_LOC_Positor,
    a.ST_LOC_Reliability,
    a.ST_LOC_Assertion,
    a.,
    p.ST_LOC_ST_ID,
    p.ST_LOC_Checksum,
    p.ST_LOC_Scen_Plats
FROM
    attributes.ST_LOC_Scen_Plats_Posit p
JOIN
    attributes.ST_LOC_Scen_Plats_Annex a
ON
    a.ST_LOC_ID = p.ST_LOC_ID
WHERE
    a.ST_LOC_Positor = 0
AND
    a.ST_LOC_PositedAt = (
        SELECT
            MAX(sub.ST_LOC_PositedAt)
        FROM
            attributes.ST_LOC_Scen_Plats_Annex sub
        WHERE
            sub.ST_LOC_ID = p.ST_LOC_ID
        AND
            sub.ST_LOC_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_AVG_Scen_Medel AS
SELECT
    a.Metadata_ST_AVG,
    p.ST_AVG_ID,
    a.ST_AVG_PositedAt,
    a.ST_AVG_Positor,
    a.ST_AVG_Reliability,
    a.ST_AVG_Assertion,
    a.,
    p.ST_AVG_ST_ID,
    p.ST_AVG_UTL_ID
    , p.ST_AVG_ChangedAt
FROM
    attributes.ST_AVG_Scen_Medel_Posit p
JOIN
    attributes.ST_AVG_Scen_Medel_Annex a
ON
    a.ST_AVG_ID = p.ST_AVG_ID
WHERE
    a.ST_AVG_Positor = 0
AND
    a.ST_AVG_PositedAt = (
        SELECT
            MAX(sub.ST_AVG_PositedAt)
        FROM
            attributes.ST_AVG_Scen_Medel_Annex sub
        WHERE
            sub.ST_AVG_ID = p.ST_AVG_ID
        AND
            sub.ST_AVG_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rST_MIN_Scen_Minimum AS
SELECT
    a.Metadata_ST_MIN,
    p.ST_MIN_ID,
    a.ST_MIN_PositedAt,
    a.ST_MIN_Positor,
    a.ST_MIN_Reliability,
    a.ST_MIN_Assertion,
    a.,
    p.ST_MIN_ST_ID,
    p.ST_MIN_UTL_ID
FROM
    attributes.ST_MIN_Scen_Minimum_Posit p
JOIN
    attributes.ST_MIN_Scen_Minimum_Annex a
ON
    a.ST_MIN_ID = p.ST_MIN_ID
WHERE
    a.ST_MIN_Positor = 0
AND
    a.ST_MIN_PositedAt = (
        SELECT
            MAX(sub.ST_MIN_PositedAt)
        FROM
            attributes.ST_MIN_Scen_Minimum_Annex sub
        WHERE
            sub.ST_MIN_ID = p.ST_MIN_ID
        AND
            sub.ST_MIN_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_NAM_Skådespelare_Namn AS
SELECT
    a.Metadata_AC_NAM,
    p.AC_NAM_ID,
    a.AC_NAM_PositedAt,
    a.AC_NAM_Positor,
    a.AC_NAM_Reliability,
    a.AC_NAM_Assertion,
    a.,
    p.AC_NAM_AC_ID,
    p.AC_NAM_Skådespelare_Namn
    , p.AC_NAM_ChangedAt
FROM
    attributes.AC_NAM_Skådespelare_Namn_Posit p
JOIN
    attributes.AC_NAM_Skådespelare_Namn_Annex a
ON
    a.AC_NAM_ID = p.AC_NAM_ID
WHERE
    a.AC_NAM_Positor = 0
AND
    a.AC_NAM_PositedAt = (
        SELECT
            MAX(sub.AC_NAM_PositedAt)
        FROM
            attributes.AC_NAM_Skådespelare_Namn_Annex sub
        WHERE
            sub.AC_NAM_ID = p.AC_NAM_ID
        AND
            sub.AC_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_GEN_Skådespelare_Kön AS
SELECT
    a.Metadata_AC_GEN,
    p.AC_GEN_ID,
    a.AC_GEN_PositedAt,
    a.AC_GEN_Positor,
    a.AC_GEN_Reliability,
    a.AC_GEN_Assertion,
    a.,
    p.AC_GEN_AC_ID,
    p.AC_GEN_GEN_ID
FROM
    attributes.AC_GEN_Skådespelare_Kön_Posit p
JOIN
    attributes.AC_GEN_Skådespelare_Kön_Annex a
ON
    a.AC_GEN_ID = p.AC_GEN_ID
WHERE
    a.AC_GEN_Positor = 0
AND
    a.AC_GEN_PositedAt = (
        SELECT
            MAX(sub.AC_GEN_PositedAt)
        FROM
            attributes.AC_GEN_Skådespelare_Kön_Annex sub
        WHERE
            sub.AC_GEN_ID = p.AC_GEN_ID
        AND
            sub.AC_GEN_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rAC_PLV_Skådespelare_Yrkesnivå AS
SELECT
    a.Metadata_AC_PLV,
    p.AC_PLV_ID,
    a.AC_PLV_PositedAt,
    a.AC_PLV_Positor,
    a.AC_PLV_Reliability,
    a.AC_PLV_Assertion,
    a.,
    p.AC_PLV_AC_ID,
    p.AC_PLV_PLV_ID
    , p.AC_PLV_ChangedAt
FROM
    attributes.AC_PLV_Skådespelare_Yrkesnivå_Posit p
JOIN
    attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex a
ON
    a.AC_PLV_ID = p.AC_PLV_ID
WHERE
    a.AC_PLV_Positor = 0
AND
    a.AC_PLV_PositedAt = (
        SELECT
            MAX(sub.AC_PLV_PositedAt)
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå_Annex sub
        WHERE
            sub.AC_PLV_ID = p.AC_PLV_ID
        AND
            sub.AC_PLV_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_NAM_Föreställning_Namn AS
SELECT
    a.Metadata_PR_NAM,
    p.PR_NAM_ID,
    a.PR_NAM_PositedAt,
    a.PR_NAM_Positor,
    a.PR_NAM_Reliability,
    a.PR_NAM_Assertion,
    a.,
    p.PR_NAM_PR_ID,
    p.PR_NAM_Föreställning_Namn
FROM
    attributes.PR_NAM_Föreställning_Namn_Posit p
JOIN
    attributes.PR_NAM_Föreställning_Namn_Annex a
ON
    a.PR_NAM_ID = p.PR_NAM_ID
WHERE
    a.PR_NAM_Positor = 0
AND
    a.PR_NAM_PositedAt = (
        SELECT
            MAX(sub.PR_NAM_PositedAt)
        FROM
            attributes.PR_NAM_Föreställning_Namn_Annex sub
        WHERE
            sub.PR_NAM_ID = p.PR_NAM_ID
        AND
            sub.PR_NAM_Positor = 0
    )
;
CREATE OR REPLACE VIEW attributes.rPR_LEN_Föreställning_Längd AS
SELECT
    a.Metadata_PR_LEN,
    p.PR_LEN_ID,
    a.PR_LEN_PositedAt,
    a.PR_LEN_Positor,
    a.PR_LEN_Reliability,
    a.PR_LEN_Assertion,
    a.,
    p.PR_LEN_PR_ID,
    p.PR_LEN_Föreställning_Längd
    , p.PR_LEN_ChangedAt
FROM
    attributes.PR_LEN_Föreställning_Längd_Posit p
JOIN
    attributes.PR_LEN_Föreställning_Längd_Annex a
ON
    a.PR_LEN_ID = p.PR_LEN_ID
WHERE
    a.PR_LEN_Positor = 0
AND
    a.PR_LEN_PositedAt = (
        SELECT
            MAX(sub.PR_LEN_PositedAt)
        FROM
            attributes.PR_LEN_Föreställning_Längd_Annex sub
        WHERE
            sub.PR_LEN_ID = p.PR_LEN_ID
        AND
            sub.PR_LEN_Positor = 0
    )
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Posit (
    AC_partner_AC_with_ONG_currently_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
    AC_partner_AC_with_ONG_currently_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.AC_partner_AC_with_ONG_currently_Annex (
    AC_partner_AC_with_ONG_currently_ID number(10) not null,
    AC_partner_AC_with_ONG_currently_PositedAt timestamp not null,
    AC_partner_AC_with_ONG_currently_Positor number(3) not null,
    AC_partner_AC_with_ONG_currently_Reliability number(5,2) not null,
    AC_partner_AC_with_ONG_currently_Assertion varchar2(4000) default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
            when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_partner_AC_with_ONG_currently number(10) not null,
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references ties.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID),
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt
    )
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_Positor, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Posit (
    AC_subset_PN_of_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
);

CREATE TABLE IF NOT EXISTS ties.AC_subset_PN_of_Annex (
    AC_subset_PN_of_ID number(10) not null,
    AC_subset_PN_of_PositedAt timestamp not null,
    AC_subset_PN_of_Positor number(3) not null,
    AC_subset_PN_of_Reliability number(5,2) not null,
    AC_subset_PN_of_Assertion varchar2(4000) default (
        case
            when AC_subset_PN_of_Reliability > 0 then '+'
            when AC_subset_PN_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_subset_PN_of_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_subset_PN_of number(10) not null,
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references ties.AC_subset_PN_of_Posit(AC_subset_PN_of_ID),
    constraint pkAC_subset_PN_of_Annex primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt
    )
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_Positor, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS ties.EV_in_AC_rollsattes_Posit (
    EV_in_AC_rollsattes_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
    EV_ID_in,
    AC_ID_rollsattes
);

CREATE TABLE IF NOT EXISTS ties.EV_in_AC_rollsattes_Annex (
    EV_in_AC_rollsattes_ID number(10) not null,
    EV_in_AC_rollsattes_PositedAt timestamp not null,
    EV_in_AC_rollsattes_Positor number(3) not null,
    EV_in_AC_rollsattes_Reliability number(5,2) not null,
    EV_in_AC_rollsattes_Assertion varchar2(4000) default (
        case
            when EV_in_AC_rollsattes_Reliability > 0 then '+'
            when EV_in_AC_rollsattes_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when EV_in_AC_rollsattes_Reliability <  then 0
            else 1
        end
    ),
    Metadata_EV_in_AC_rollsattes number(10) not null,
    constraint fkEV_in_AC_rollsattes_Annex foreign key (
        EV_in_AC_rollsattes_ID
    ) references ties.EV_in_AC_rollsattes_Posit(EV_in_AC_rollsattes_ID),
    constraint pkEV_in_AC_rollsattes_Annex primary key (
        EV_in_AC_rollsattes_ID,
        EV_in_AC_rollsattes_Positor,
        EV_in_AC_rollsattes_PositedAt
    )
) CLUSTER BY (EV_in_AC_rollsattes_ID, EV_in_AC_rollsattes_Positor, EV_in_AC_rollsattes_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_deltar_PR_in_RAT_fick_Posit (
    AC_deltar_PR_in_RAT_fick_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
    AC_ID_deltar,
    PR_ID_in,
    AC_deltar_PR_in_RAT_fick_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.AC_deltar_PR_in_RAT_fick_Annex (
    AC_deltar_PR_in_RAT_fick_ID number(10) not null,
    AC_deltar_PR_in_RAT_fick_PositedAt timestamp not null,
    AC_deltar_PR_in_RAT_fick_Positor number(3) not null,
    AC_deltar_PR_in_RAT_fick_Reliability number(5,2) not null,
    AC_deltar_PR_in_RAT_fick_Assertion varchar2(4000) default (
        case
            when AC_deltar_PR_in_RAT_fick_Reliability > 0 then '+'
            when AC_deltar_PR_in_RAT_fick_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_deltar_PR_in_RAT_fick_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_deltar_PR_in_RAT_fick number(10) not null,
    constraint fkAC_deltar_PR_in_RAT_fick_Annex foreign key (
        AC_deltar_PR_in_RAT_fick_ID
    ) references ties.AC_deltar_PR_in_RAT_fick_Posit(AC_deltar_PR_in_RAT_fick_ID),
    constraint pkAC_deltar_PR_in_RAT_fick_Annex primary key (
        AC_deltar_PR_in_RAT_fick_ID,
        AC_deltar_PR_in_RAT_fick_Positor,
        AC_deltar_PR_in_RAT_fick_PositedAt
    )
) CLUSTER BY (AC_deltar_PR_in_RAT_fick_ID, AC_deltar_PR_in_RAT_fick_Positor, AC_deltar_PR_in_RAT_fick_PositedAt);
CREATE TABLE IF NOT EXISTS ties.ST_at_PR_spelas_Posit (
    ST_at_PR_spelas_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
    ST_ID_at,
    PR_ID_spelas,
    ST_at_PR_spelas_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.ST_at_PR_spelas_Annex (
    ST_at_PR_spelas_ID number(10) not null,
    ST_at_PR_spelas_PositedAt timestamp not null,
    ST_at_PR_spelas_Positor number(3) not null,
    ST_at_PR_spelas_Reliability number(5,2) not null,
    ST_at_PR_spelas_Assertion varchar2(4000) default (
        case
            when ST_at_PR_spelas_Reliability > 0 then '+'
            when ST_at_PR_spelas_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when ST_at_PR_spelas_Reliability <  then 0
            else 1
        end
    ),
    Metadata_ST_at_PR_spelas number(10) not null,
    constraint fkST_at_PR_spelas_Annex foreign key (
        ST_at_PR_spelas_ID
    ) references ties.ST_at_PR_spelas_Posit(ST_at_PR_spelas_ID),
    constraint pkST_at_PR_spelas_Annex primary key (
        ST_at_PR_spelas_ID,
        ST_at_PR_spelas_Positor,
        ST_at_PR_spelas_PositedAt
    )
) CLUSTER BY (ST_at_PR_spelas_ID, ST_at_PR_spelas_Positor, ST_at_PR_spelas_PositedAt);
CREATE TABLE IF NOT EXISTS ties.AC_förälder_AC_barn_PAT_har_Posit (
    AC_förälder_AC_barn_PAT_har_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
    AC_ID_förälder,
    AC_ID_barn,
    PAT_ID_har
);

CREATE TABLE IF NOT EXISTS ties.AC_förälder_AC_barn_PAT_har_Annex (
    AC_förälder_AC_barn_PAT_har_ID number(10) not null,
    AC_förälder_AC_barn_PAT_har_PositedAt timestamp not null,
    AC_förälder_AC_barn_PAT_har_Positor number(3) not null,
    AC_förälder_AC_barn_PAT_har_Reliability number(5,2) not null,
    AC_förälder_AC_barn_PAT_har_Assertion varchar2(4000) default (
        case
            when AC_förälder_AC_barn_PAT_har_Reliability > 0 then '+'
            when AC_förälder_AC_barn_PAT_har_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when AC_förälder_AC_barn_PAT_har_Reliability <  then 0
            else 1
        end
    ),
    Metadata_AC_förälder_AC_barn_PAT_har number(10) not null,
    constraint fkAC_förälder_AC_barn_PAT_har_Annex foreign key (
        AC_förälder_AC_barn_PAT_har_ID
    ) references ties.AC_förälder_AC_barn_PAT_har_Posit(AC_förälder_AC_barn_PAT_har_ID),
    constraint pkAC_förälder_AC_barn_PAT_har_Annex primary key (
        AC_förälder_AC_barn_PAT_har_ID,
        AC_förälder_AC_barn_PAT_har_Positor,
        AC_förälder_AC_barn_PAT_har_PositedAt
    )
) CLUSTER BY (AC_förälder_AC_barn_PAT_har_ID, AC_förälder_AC_barn_PAT_har_Positor, AC_förälder_AC_barn_PAT_har_PositedAt);
CREATE TABLE IF NOT EXISTS ties.PR_innehåll_ST_plats_EV_of_Posit (
    PR_innehåll_ST_plats_EV_of_ID number(10) IDENTITY(1,1) not null, 
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
) CLUSTER BY (
    PR_innehåll_ST_plats_EV_of_ChangedAt
);

CREATE TABLE IF NOT EXISTS ties.PR_innehåll_ST_plats_EV_of_Annex (
    PR_innehåll_ST_plats_EV_of_ID number(10) not null,
    PR_innehåll_ST_plats_EV_of_PositedAt timestamp not null,
    PR_innehåll_ST_plats_EV_of_Positor number(3) not null,
    PR_innehåll_ST_plats_EV_of_Reliability number(5,2) not null,
    PR_innehåll_ST_plats_EV_of_Assertion varchar2(4000) default (
        case
            when PR_innehåll_ST_plats_EV_of_Reliability > 0 then '+'
            when PR_innehåll_ST_plats_EV_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     number(10) default (
        case
            when PR_innehåll_ST_plats_EV_of_Reliability <  then 0
            else 1
        end
    ),
    Metadata_PR_innehåll_ST_plats_EV_of number(10) not null,
    constraint fkPR_innehåll_ST_plats_EV_of_Annex foreign key (
        PR_innehåll_ST_plats_EV_of_ID
    ) references ties.PR_innehåll_ST_plats_EV_of_Posit(PR_innehåll_ST_plats_EV_of_ID),
    constraint pkPR_innehåll_ST_plats_EV_of_Annex primary key (
        PR_innehåll_ST_plats_EV_of_ID,
        PR_innehåll_ST_plats_EV_of_Positor,
        PR_innehåll_ST_plats_EV_of_PositedAt
    )
) CLUSTER BY (PR_innehåll_ST_plats_EV_of_ID, PR_innehåll_ST_plats_EV_of_Positor, PR_innehåll_ST_plats_EV_of_PositedAt);
-- TIE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views for ties.
--
CREATE OR REPLACE VIEW ties.rAC_partner_AC_with_ONG_currently AS
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
    a.
FROM
    ties.AC_partner_AC_with_ONG_currently_Posit p
JOIN
    ties.AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
WHERE
    a.AC_partner_AC_with_ONG_currently_Positor = 0
AND
    a.AC_partner_AC_with_ONG_currently_PositedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_PositedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently_Annex sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
        AND
            sub.AC_partner_AC_with_ONG_currently_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion,
    a.
FROM
    ties.AC_subset_PN_of_Posit p
JOIN
    ties.AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
WHERE
    a.AC_subset_PN_of_Positor = 0
AND
    a.AC_subset_PN_of_PositedAt = (
        SELECT
            MAX(sub.AC_subset_PN_of_PositedAt)
        FROM
            ties.AC_subset_PN_of_Annex sub
        WHERE
            sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
        AND
            sub.AC_subset_PN_of_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rEV_in_AC_rollsattes AS
SELECT
    a.Metadata_EV_in_AC_rollsattes,
    p.EV_in_AC_rollsattes_ID,
    p.EV_ID_in,
    p.AC_ID_rollsattes,
    a.EV_in_AC_rollsattes_PositedAt,
    a.EV_in_AC_rollsattes_Positor,
    a.EV_in_AC_rollsattes_Reliability,
    a.EV_in_AC_rollsattes_Assertion,
    a.
FROM
    ties.EV_in_AC_rollsattes_Posit p
JOIN
    ties.EV_in_AC_rollsattes_Annex a
ON
    a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
WHERE
    a.EV_in_AC_rollsattes_Positor = 0
AND
    a.EV_in_AC_rollsattes_PositedAt = (
        SELECT
            MAX(sub.EV_in_AC_rollsattes_PositedAt)
        FROM
            ties.EV_in_AC_rollsattes_Annex sub
        WHERE
            sub.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
        AND
            sub.EV_in_AC_rollsattes_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_deltar_PR_in_RAT_fick AS
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
    a.
FROM
    ties.AC_deltar_PR_in_RAT_fick_Posit p
JOIN
    ties.AC_deltar_PR_in_RAT_fick_Annex a
ON
    a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
WHERE
    a.AC_deltar_PR_in_RAT_fick_Positor = 0
AND
    a.AC_deltar_PR_in_RAT_fick_PositedAt = (
        SELECT
            MAX(sub.AC_deltar_PR_in_RAT_fick_PositedAt)
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Annex sub
        WHERE
            sub.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
        AND
            sub.AC_deltar_PR_in_RAT_fick_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rST_at_PR_spelas AS
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
    a.
FROM
    ties.ST_at_PR_spelas_Posit p
JOIN
    ties.ST_at_PR_spelas_Annex a
ON
    a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
WHERE
    a.ST_at_PR_spelas_Positor = 0
AND
    a.ST_at_PR_spelas_PositedAt = (
        SELECT
            MAX(sub.ST_at_PR_spelas_PositedAt)
        FROM
            ties.ST_at_PR_spelas_Annex sub
        WHERE
            sub.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
        AND
            sub.ST_at_PR_spelas_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_förälder_AC_barn_PAT_har AS
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
    a.
FROM
    ties.AC_förälder_AC_barn_PAT_har_Posit p
JOIN
    ties.AC_förälder_AC_barn_PAT_har_Annex a
ON
    a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
WHERE
    a.AC_förälder_AC_barn_PAT_har_Positor = 0
AND
    a.AC_förälder_AC_barn_PAT_har_PositedAt = (
        SELECT
            MAX(sub.AC_förälder_AC_barn_PAT_har_PositedAt)
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Annex sub
        WHERE
            sub.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
        AND
            sub.AC_förälder_AC_barn_PAT_har_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rPR_innehåll_ST_plats_EV_of AS
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
    a.
FROM
    ties.PR_innehåll_ST_plats_EV_of_Posit p
JOIN
    ties.PR_innehåll_ST_plats_EV_of_Annex a
ON
    a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
WHERE
    a.PR_innehåll_ST_plats_EV_of_Positor = 0
AND
    a.PR_innehåll_ST_plats_EV_of_PositedAt = (
        SELECT
            MAX(sub.PR_innehåll_ST_plats_EV_of_PositedAt)
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Annex sub
        WHERE
            sub.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
        AND
            sub.PR_innehåll_ST_plats_EV_of_Positor = 0
    )
;
-- ANCHOR CRT PERSPECTIVES --------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT anchors.
--
CREATE OR REPLACE VIEW anchors.lST_Scen AS
SELECT
    a.ST_ID,
    a.Metadata_ST,
    rNAM.ST_NAM_Scen_Namn,
    rNAM.ST_NAM_ChangedAt,
    rNAM.ST_NAM_PositedAt,
    rNAM.ST_NAM_Positor,
    rNAM.ST_NAM_Reliability,
    rNAM.ST_NAM_Assertion,
    rNAM.,
    rLOC.ST_LOC_Scen_Plats,
    rLOC.ST_LOC_PositedAt,
    rLOC.ST_LOC_Positor,
    rLOC.ST_LOC_Reliability,
    rLOC.ST_LOC_Assertion,
    rLOC.,
    rAVG.ST_AVG_UTL_ID,
    rAVG.ST_AVG_ChangedAt,
    rAVG.ST_AVG_PositedAt,
    rAVG.ST_AVG_Positor,
    rAVG.ST_AVG_Reliability,
    rAVG.ST_AVG_Assertion,
    rAVG.,
    rMIN.ST_MIN_UTL_ID,
    rMIN.ST_MIN_PositedAt,
    rMIN.ST_MIN_Positor,
    rMIN.ST_MIN_Reliability,
    rMIN.ST_MIN_Assertion,
    rMIN.
FROM
    anchors.ST_Scen a
LEFT JOIN
    attributes.rST_NAM_Scen_Namn rNAM
ON
    rNAM.ST_NAM_ST_ID = a.ST_ID
LEFT JOIN
    attributes.rST_LOC_Scen_Plats rLOC
ON
    rLOC.ST_LOC_ST_ID = a.ST_ID
LEFT JOIN
    attributes.rST_AVG_Scen_Medel rAVG
ON
    rAVG.ST_AVG_ST_ID = a.ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande kAVG
ON
    kAVG.UTL_ID = rAVG.ST_AVG_UTL_ID
LEFT JOIN
    attributes.rST_MIN_Scen_Minimum rMIN
ON
    rMIN.ST_MIN_ST_ID = a.ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande kMIN
ON
    kMIN.UTL_ID = rMIN.ST_MIN_UTL_ID
;

CREATE OR REPLACE VIEW anchors.nST_Scen AS
SELECT
    *
FROM
    anchors.lST_Scen
;

CREATE OR REPLACE FUNCTION anchors.tST_Scen (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lST_Scen t
        WHERE
            (
                positor IS NULL
                OR (
                    t.ST_NAM_Positor = positor OR
                    t.ST_LOC_Positor = positor OR
                    t.ST_AVG_Positor = positor OR
                    t.ST_MIN_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.ST_NAM_Assertion = assertion OR
                    t.ST_LOC_Assertion = assertion OR
                    t.ST_AVG_Assertion = assertion OR
                    t.ST_MIN_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.ST_NAM_ChangedAt <= changingTimepoint OR
                    t.ST_AVG_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.ST_NAM_PositedAt <= positingTimepoint OR
                    t.ST_LOC_PositedAt <= positingTimepoint OR
                    t.ST_AVG_PositedAt <= positingTimepoint OR
                    t.ST_MIN_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION anchors.pST_Scen (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lST_Scen t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.ST_NAM_ChangedAt <= changingTimepoint OR
                    t.ST_AVG_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION anchors.dST_Scen (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lST_Scen t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd OR
                    t.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
CREATE OR REPLACE VIEW anchors.lAC_Skådespelare AS
SELECT
    a.AC_ID,
    a.Metadata_AC,
    rNAM.AC_NAM_Skådespelare_Namn,
    rNAM.AC_NAM_ChangedAt,
    rNAM.AC_NAM_PositedAt,
    rNAM.AC_NAM_Positor,
    rNAM.AC_NAM_Reliability,
    rNAM.AC_NAM_Assertion,
    rNAM.,
    rGEN.AC_GEN_GEN_ID,
    rGEN.AC_GEN_PositedAt,
    rGEN.AC_GEN_Positor,
    rGEN.AC_GEN_Reliability,
    rGEN.AC_GEN_Assertion,
    rGEN.,
    rPLV.AC_PLV_PLV_ID,
    rPLV.AC_PLV_ChangedAt,
    rPLV.AC_PLV_PositedAt,
    rPLV.AC_PLV_Positor,
    rPLV.AC_PLV_Reliability,
    rPLV.AC_PLV_Assertion,
    rPLV.
FROM
    anchors.AC_Skådespelare a
LEFT JOIN
    attributes.rAC_NAM_Skådespelare_Namn rNAM
ON
    rNAM.AC_NAM_AC_ID = a.AC_ID
LEFT JOIN
    attributes.rAC_GEN_Skådespelare_Kön rGEN
ON
    rGEN.AC_GEN_AC_ID = a.AC_ID
LEFT JOIN
    knots.GEN_Kön kGEN
ON
    kGEN.GEN_ID = rGEN.AC_GEN_GEN_ID
LEFT JOIN
    attributes.rAC_PLV_Skådespelare_Yrkesnivå rPLV
ON
    rPLV.AC_PLV_AC_ID = a.AC_ID
LEFT JOIN
    knots.PLV_Yrkesnivå kPLV
ON
    kPLV.PLV_ID = rPLV.AC_PLV_PLV_ID
;

CREATE OR REPLACE VIEW anchors.nAC_Skådespelare AS
SELECT
    *
FROM
    anchors.lAC_Skådespelare
;

CREATE OR REPLACE FUNCTION anchors.tAC_Skådespelare (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lAC_Skådespelare t
        WHERE
            (
                positor IS NULL
                OR (
                    t.AC_NAM_Positor = positor OR
                    t.AC_GEN_Positor = positor OR
                    t.AC_PLV_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.AC_NAM_Assertion = assertion OR
                    t.AC_GEN_Assertion = assertion OR
                    t.AC_PLV_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.AC_NAM_ChangedAt <= changingTimepoint OR
                    t.AC_PLV_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.AC_NAM_PositedAt <= positingTimepoint OR
                    t.AC_GEN_PositedAt <= positingTimepoint OR
                    t.AC_PLV_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION anchors.pAC_Skådespelare (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lAC_Skådespelare t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.AC_NAM_ChangedAt <= changingTimepoint OR
                    t.AC_PLV_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION anchors.dAC_Skådespelare (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lAC_Skådespelare t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd OR
                    t.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
CREATE OR REPLACE VIEW anchors.lPR_Föreställning AS
SELECT
    a.PR_ID,
    a.Metadata_PR,
    rNAM.PR_NAM_Föreställning_Namn,
    rNAM.PR_NAM_PositedAt,
    rNAM.PR_NAM_Positor,
    rNAM.PR_NAM_Reliability,
    rNAM.PR_NAM_Assertion,
    rNAM.,
    rLEN.PR_LEN_Föreställning_Längd,
    rLEN.PR_LEN_ChangedAt,
    rLEN.PR_LEN_PositedAt,
    rLEN.PR_LEN_Positor,
    rLEN.PR_LEN_Reliability,
    rLEN.PR_LEN_Assertion,
    rLEN.
FROM
    anchors.PR_Föreställning a
LEFT JOIN
    attributes.rPR_NAM_Föreställning_Namn rNAM
ON
    rNAM.PR_NAM_PR_ID = a.PR_ID
LEFT JOIN
    attributes.rPR_LEN_Föreställning_Längd rLEN
ON
    rLEN.PR_LEN_PR_ID = a.PR_ID
;

CREATE OR REPLACE VIEW anchors.nPR_Föreställning AS
SELECT
    *
FROM
    anchors.lPR_Föreställning
;

CREATE OR REPLACE FUNCTION anchors.tPR_Föreställning (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lPR_Föreställning t
        WHERE
            (
                positor IS NULL
                OR (
                    t.PR_NAM_Positor = positor OR
                    t.PR_LEN_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.PR_NAM_Assertion = assertion OR
                    t.PR_LEN_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.PR_LEN_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.PR_NAM_PositedAt <= positingTimepoint OR
                    t.PR_LEN_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION anchors.pPR_Föreställning (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lPR_Föreställning t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.PR_LEN_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION anchors.dPR_Föreställning (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            anchors.lPR_Föreställning t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
-- NEXUS CRT PERSPECTIVES ---------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT nexuses.
--
CREATE OR REPLACE VIEW nexuses.lEV_Händelse AS
SELECT
    n.EV_ID,
    n.Metadata_EV,
    n.ST_ID_hölls,
    n.PR_ID_spelades,
    n.ETY_ID_of,
    rDAT.EV_DAT_Händelse_Datum,
    rDAT.EV_DAT_PositedAt,
    rDAT.EV_DAT_Positor,
    rDAT.EV_DAT_Reliability,
    rDAT.EV_DAT_Assertion,
    rDAT.,
    rAUD.EV_AUD_Händelse_Publik,
    rAUD.EV_AUD_PositedAt,
    rAUD.EV_AUD_Positor,
    rAUD.EV_AUD_Reliability,
    rAUD.EV_AUD_Assertion,
    rAUD.,
    rREV.EV_REV_Händelse_Intäkt,
    rREV.EV_REV_PositedAt,
    rREV.EV_REV_Positor,
    rREV.EV_REV_Reliability,
    rREV.EV_REV_Assertion,
    rREV.,
    rSTA.EV_STA_Händelse_Status,
    rSTA.EV_STA_ChangedAt,
    rSTA.EV_STA_PositedAt,
    rSTA.EV_STA_Positor,
    rSTA.EV_STA_Reliability,
    rSTA.EV_STA_Assertion,
    rSTA.,
    rUTL.EV_UTL_UTL_ID,
    rUTL.EV_UTL_PositedAt,
    rUTL.EV_UTL_Positor,
    rUTL.EV_UTL_Reliability,
    rUTL.EV_UTL_Assertion,
    rUTL.,
    rLVL.EV_LVL_PLV_ID,
    rLVL.EV_LVL_ChangedAt,
    rLVL.EV_LVL_PositedAt,
    rLVL.EV_LVL_Positor,
    rLVL.EV_LVL_Reliability,
    rLVL.EV_LVL_Assertion,
    rLVL.
FROM
    nexuses.EV_Händelse n
LEFT JOIN
    attributes.rEV_DAT_Händelse_Datum rDAT
ON
    rDAT.EV_DAT_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_AUD_Händelse_Publik rAUD
ON
    rAUD.EV_AUD_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_REV_Händelse_Intäkt rREV
ON
    rREV.EV_REV_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_STA_Händelse_Status rSTA
ON
    rSTA.EV_STA_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_UTL_Händelse_Utnyttjande rUTL
ON
    rUTL.EV_UTL_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_LVL_Händelse_Level rLVL
ON
    rLVL.EV_LVL_EV_ID = n.EV_ID
;

CREATE OR REPLACE VIEW nexuses.nEV_Händelse AS
SELECT
    *
FROM
    nexuses.lEV_Händelse
;

CREATE OR REPLACE FUNCTION nexuses.tEV_Händelse (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Händelse t
        WHERE
            (
                positor IS NULL
                OR (
                    t.EV_DAT_Positor = positor OR
                    t.EV_AUD_Positor = positor OR
                    t.EV_REV_Positor = positor OR
                    t.EV_STA_Positor = positor OR
                    t.EV_UTL_Positor = positor OR
                    t.EV_LVL_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.EV_DAT_Assertion = assertion OR
                    t.EV_AUD_Assertion = assertion OR
                    t.EV_REV_Assertion = assertion OR
                    t.EV_STA_Assertion = assertion OR
                    t.EV_UTL_Assertion = assertion OR
                    t.EV_LVL_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR (
                    t.EV_STA_ChangedAt <= changingTimepoint OR
                    t.EV_LVL_ChangedAt <= changingTimepoint 
                )
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.EV_DAT_PositedAt <= positingTimepoint OR
                    t.EV_AUD_PositedAt <= positingTimepoint OR
                    t.EV_REV_PositedAt <= positingTimepoint OR
                    t.EV_STA_PositedAt <= positingTimepoint OR
                    t.EV_UTL_PositedAt <= positingTimepoint OR
                    t.EV_LVL_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION nexuses.pEV_Händelse (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Händelse t
        WHERE
            (
                changingTimepoint IS NULL
                OR (
                    t.EV_STA_ChangedAt <= changingTimepoint OR
                    t.EV_LVL_ChangedAt <= changingTimepoint 
            )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION nexuses.dEV_Händelse (
    intervalStart timestamp(9),
    intervalEnd timestamp(9),
    selection varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Händelse t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR (
                    t.EV_STA_ChangedAt BETWEEN intervalStart AND intervalEnd OR
                    t.EV_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd 
                )
            )
    ]';
END;
/
-- TIE CRT PERSPECTIVES -----------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT ties.
--
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently AS
SELECT
    r.AC_partner_AC_with_ONG_currently_ID,
    r.Metadata_AC_partner_AC_with_ONG_currently,
    r.AC_ID_partner,
    r.AC_ID_with,
    kONG_currently.ONG_Pågående AS currently_ONG_Pågående,
    r.ONG_ID_currently
    r.AC_partner_AC_with_ONG_currently_ChangedAt,
    r.AC_partner_AC_with_ONG_currently_PositedAt,
    r.AC_partner_AC_with_ONG_currently_Positor,
    r.AC_partner_AC_with_ONG_currently_Reliability,
    r.AC_partner_AC_with_ONG_currently_Assertion,
    r.
FROM
    ties.rAC_partner_AC_with_ONG_currently r
LEFT JOIN
    knots.ONG_Pågående kONG_currently
ON
    kONG_currently.ONG_ID = r.ONG_ID_currently
;

CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    ties.lAC_partner_AC_with_ONG_currently
;

CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (positor IS NULL OR t.AC_partner_AC_with_ONG_currently_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_partner_AC_with_ONG_currently_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of AS
SELECT
    r.AC_subset_PN_of_ID,
    r.Metadata_AC_subset_PN_of,
    r.AC_ID_subset,
    r.PN_ID_of
    r.AC_subset_PN_of_PositedAt,
    r.AC_subset_PN_of_Positor,
    r.AC_subset_PN_of_Reliability,
    r.AC_subset_PN_of_Assertion,
    r.
FROM
    ties.rAC_subset_PN_of r
;

CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    ties.lAC_subset_PN_of
;

CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (positor IS NULL OR t.AC_subset_PN_of_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_subset_PN_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_subset_PN_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_subset_PN_of (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes AS
SELECT
    r.EV_in_AC_rollsattes_ID,
    r.Metadata_EV_in_AC_rollsattes,
    r.EV_ID_in,
    r.AC_ID_rollsattes
    r.EV_in_AC_rollsattes_PositedAt,
    r.EV_in_AC_rollsattes_Positor,
    r.EV_in_AC_rollsattes_Reliability,
    r.EV_in_AC_rollsattes_Assertion,
    r.
FROM
    ties.rEV_in_AC_rollsattes r
;

CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes AS
SELECT
    *
FROM
    ties.lEV_in_AC_rollsattes
;

CREATE OR REPLACE FUNCTION ties.tEV_in_AC_rollsattes (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_rollsattes t
        WHERE
            (positor IS NULL OR t.EV_in_AC_rollsattes_Positor = positor)
        AND
            (assertion IS NULL OR t.EV_in_AC_rollsattes_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.EV_in_AC_rollsattes_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_rollsattes t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dEV_in_AC_rollsattes (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_rollsattes t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick AS
SELECT
    r.AC_deltar_PR_in_RAT_fick_ID,
    r.Metadata_AC_deltar_PR_in_RAT_fick,
    r.AC_ID_deltar,
    r.PR_ID_in,
    kRAT_fick.RAT_Betyg AS fick_RAT_Betyg,
    r.RAT_ID_fick
    r.AC_deltar_PR_in_RAT_fick_ChangedAt,
    r.AC_deltar_PR_in_RAT_fick_PositedAt,
    r.AC_deltar_PR_in_RAT_fick_Positor,
    r.AC_deltar_PR_in_RAT_fick_Reliability,
    r.AC_deltar_PR_in_RAT_fick_Assertion,
    r.
FROM
    ties.rAC_deltar_PR_in_RAT_fick r
LEFT JOIN
    knots.RAT_Betyg kRAT_fick
ON
    kRAT_fick.RAT_ID = r.RAT_ID_fick
;

CREATE OR REPLACE VIEW ties.nAC_deltar_PR_in_RAT_fick AS
SELECT
    *
FROM
    ties.lAC_deltar_PR_in_RAT_fick
;

CREATE OR REPLACE FUNCTION ties.tAC_deltar_PR_in_RAT_fick (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_deltar_PR_in_RAT_fick t
        WHERE
            (positor IS NULL OR t.AC_deltar_PR_in_RAT_fick_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_deltar_PR_in_RAT_fick_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_deltar_PR_in_RAT_fick t
        WHERE
            (changingTimepoint IS NULL OR t.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_deltar_PR_in_RAT_fick (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_deltar_PR_in_RAT_fick t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas AS
SELECT
    r.ST_at_PR_spelas_ID,
    r.Metadata_ST_at_PR_spelas,
    r.ST_ID_at,
    r.PR_ID_spelas
    r.ST_at_PR_spelas_ChangedAt,
    r.ST_at_PR_spelas_PositedAt,
    r.ST_at_PR_spelas_Positor,
    r.ST_at_PR_spelas_Reliability,
    r.ST_at_PR_spelas_Assertion,
    r.
FROM
    ties.rST_at_PR_spelas r
;

CREATE OR REPLACE VIEW ties.nST_at_PR_spelas AS
SELECT
    *
FROM
    ties.lST_at_PR_spelas
;

CREATE OR REPLACE FUNCTION ties.tST_at_PR_spelas (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_spelas t
        WHERE
            (positor IS NULL OR t.ST_at_PR_spelas_Positor = positor)
        AND
            (assertion IS NULL OR t.ST_at_PR_spelas_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.ST_at_PR_spelas_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.ST_at_PR_spelas_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_spelas t
        WHERE
            (changingTimepoint IS NULL OR t.ST_at_PR_spelas_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dST_at_PR_spelas (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_spelas t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har AS
SELECT
    r.AC_förälder_AC_barn_PAT_har_ID,
    r.Metadata_AC_förälder_AC_barn_PAT_har,
    r.AC_ID_förälder,
    r.AC_ID_barn,
    kPAT_har.PAT_Föräldratyp AS har_PAT_Föräldratyp,
    r.PAT_ID_har
    r.AC_förälder_AC_barn_PAT_har_PositedAt,
    r.AC_förälder_AC_barn_PAT_har_Positor,
    r.AC_förälder_AC_barn_PAT_har_Reliability,
    r.AC_förälder_AC_barn_PAT_har_Assertion,
    r.
FROM
    ties.rAC_förälder_AC_barn_PAT_har r
LEFT JOIN
    knots.PAT_Föräldratyp kPAT_har
ON
    kPAT_har.PAT_ID = r.PAT_ID_har
;

CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har AS
SELECT
    *
FROM
    ties.lAC_förälder_AC_barn_PAT_har
;

CREATE OR REPLACE FUNCTION ties.tAC_förälder_AC_barn_PAT_har (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_förälder_AC_barn_PAT_har t
        WHERE
            (positor IS NULL OR t.AC_förälder_AC_barn_PAT_har_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_förälder_AC_barn_PAT_har_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_förälder_AC_barn_PAT_har t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_förälder_AC_barn_PAT_har (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_förälder_AC_barn_PAT_har t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of AS
SELECT
    r.PR_innehåll_ST_plats_EV_of_ID,
    r.Metadata_PR_innehåll_ST_plats_EV_of,
    r.PR_ID_innehåll,
    r.ST_ID_plats,
    r.EV_ID_of
    r.PR_innehåll_ST_plats_EV_of_ChangedAt,
    r.PR_innehåll_ST_plats_EV_of_PositedAt,
    r.PR_innehåll_ST_plats_EV_of_Positor,
    r.PR_innehåll_ST_plats_EV_of_Reliability,
    r.PR_innehåll_ST_plats_EV_of_Assertion,
    r.
FROM
    ties.rPR_innehåll_ST_plats_EV_of r
;

CREATE OR REPLACE VIEW ties.nPR_innehåll_ST_plats_EV_of AS
SELECT
    *
FROM
    ties.lPR_innehåll_ST_plats_EV_of
;

CREATE OR REPLACE FUNCTION ties.tPR_innehåll_ST_plats_EV_of (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_innehåll_ST_plats_EV_of t
        WHERE
            (positor IS NULL OR t.PR_innehåll_ST_plats_EV_of_Positor = positor)
        AND
            (assertion IS NULL OR t.PR_innehåll_ST_plats_EV_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_innehåll_ST_plats_EV_of t
        WHERE
            (changingTimepoint IS NULL OR t.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dPR_innehåll_ST_plats_EV_of (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_innehåll_ST_plats_EV_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
