-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Posit" (
    "EV_DAT_ID" integer default nextval('attributes."EV_DAT_Händelse_Datum_Posit_ID_SEQ"') not null, 
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Händelse_Datum" timestamp not null,
    constraint "fkEV_DAT_Händelse_Datum_Posit" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_DAT_Händelse_Datum_Posit" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Händelse_Datum_Posit" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Händelse_Datum"
    )
) ORDER BY "EV_DAT_EV_ID" SEGMENTED BY MODULARHASH("EV_DAT_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Annex" (
    "EV_DAT_ID" integer not null,
    "EV_DAT_PositedAt" timestamp not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Händelse_Datum_Annex" foreign key (
        "EV_DAT_ID"
    ) references attributes."EV_DAT_Händelse_Datum_Posit"("EV_DAT_ID"),
    constraint "pkEV_DAT_Händelse_Datum_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_PositedAt"
    )
) ORDER BY "EV_DAT_ID", "EV_DAT_PositedAt" SEGMENTED BY MODULARHASH("EV_DAT_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Posit" (
    "EV_AUD_ID" integer default nextval('attributes."EV_AUD_Händelse_Publik_Posit_ID_SEQ"') not null, 
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Händelse_Publik" integer not null,
    constraint "fkEV_AUD_Händelse_Publik_Posit" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_AUD_Händelse_Publik_Posit" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Händelse_Publik_Posit" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Händelse_Publik"
    )
) ORDER BY "EV_AUD_EV_ID" SEGMENTED BY MODULARHASH("EV_AUD_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Annex" (
    "EV_AUD_ID" integer not null,
    "EV_AUD_PositedAt" timestamp not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Händelse_Publik_Annex" foreign key (
        "EV_AUD_ID"
    ) references attributes."EV_AUD_Händelse_Publik_Posit"("EV_AUD_ID"),
    constraint "pkEV_AUD_Händelse_Publik_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_PositedAt"
    )
) ORDER BY "EV_AUD_ID", "EV_AUD_PositedAt" SEGMENTED BY MODULARHASH("EV_AUD_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Posit" (
    "EV_REV_ID" integer default nextval('attributes."EV_REV_Händelse_Intäkt_Posit_ID_SEQ"') not null, 
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Händelse_Intäkt" decimal(19,4) not null,
    constraint "fkEV_REV_Händelse_Intäkt_Posit" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_REV_Händelse_Intäkt_Posit" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Händelse_Intäkt_Posit" unique (
        "EV_REV_EV_ID",
        "EV_REV_Händelse_Intäkt"
    )
) ORDER BY "EV_REV_EV_ID" SEGMENTED BY MODULARHASH("EV_REV_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Annex" (
    "EV_REV_ID" integer not null,
    "EV_REV_PositedAt" timestamp not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Händelse_Intäkt_Annex" foreign key (
        "EV_REV_ID"
    ) references attributes."EV_REV_Händelse_Intäkt_Posit"("EV_REV_ID"),
    constraint "pkEV_REV_Händelse_Intäkt_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_PositedAt"
    )
) ORDER BY "EV_REV_ID", "EV_REV_PositedAt" SEGMENTED BY MODULARHASH("EV_REV_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Posit" (
    "EV_STA_ID" integer default nextval('attributes."EV_STA_Händelse_Status_Posit_ID_SEQ"') not null, 
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    constraint "fkEV_STA_Händelse_Status_Posit" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_STA_Händelse_Status_Posit" primary key (
        "EV_STA_ID"
    ),
    constraint "uqEV_STA_Händelse_Status_Posit" unique (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_Händelse_Status"
    )
) ORDER BY "EV_STA_EV_ID", "EV_STA_ChangedAt" SEGMENTED BY MODULARHASH("EV_STA_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Annex" (
    "EV_STA_ID" integer not null,
    "EV_STA_PositedAt" timestamp not null,
    "EV_STA_Reliability" decimal(5,2) not null,
    "Metadata_EV_STA" integer not null,
    constraint "fkEV_STA_Händelse_Status_Annex" foreign key (
        "EV_STA_ID"
    ) references attributes."EV_STA_Händelse_Status_Posit"("EV_STA_ID"),
    constraint "pkEV_STA_Händelse_Status_Annex" primary key (
        "EV_STA_ID",
        "EV_STA_PositedAt"
    )
) ORDER BY "EV_STA_ID", "EV_STA_PositedAt" SEGMENTED BY MODULARHASH("EV_STA_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Posit" (
    "EV_UTL_ID" integer default nextval('attributes."EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ"') not null, 
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
    constraint "fk_A_EV_UTL_Händelse_Utnyttjande_Posit" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_UTL_Händelse_Utnyttjande_Posit" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkEV_UTL_Händelse_Utnyttjande_Posit" primary key (
        "EV_UTL_ID"
    ),
    constraint "uqEV_UTL_Händelse_Utnyttjande_Posit" unique (
        "EV_UTL_EV_ID",
        "EV_UTL_UTL_ID"
    )
) ORDER BY "EV_UTL_EV_ID" SEGMENTED BY MODULARHASH("EV_UTL_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
    "EV_UTL_ID" integer not null,
    "EV_UTL_PositedAt" timestamp not null,
    "EV_UTL_Reliability" decimal(5,2) not null,
    "Metadata_EV_UTL" integer not null,
    constraint "fkEV_UTL_Händelse_Utnyttjande_Annex" foreign key (
        "EV_UTL_ID"
    ) references attributes."EV_UTL_Händelse_Utnyttjande_Posit"("EV_UTL_ID"),
    constraint "pkEV_UTL_Händelse_Utnyttjande_Annex" primary key (
        "EV_UTL_ID",
        "EV_UTL_PositedAt"
    )
) ORDER BY "EV_UTL_ID", "EV_UTL_PositedAt" SEGMENTED BY MODULARHASH("EV_UTL_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Posit" (
    "EV_LVL_ID" integer default nextval('attributes."EV_LVL_Händelse_Level_Posit_ID_SEQ"') not null, 
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    constraint "fk_A_EV_LVL_Händelse_Level_Posit" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_LVL_Händelse_Level_Posit" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID"),
    constraint "pkEV_LVL_Händelse_Level_Posit" primary key (
        "EV_LVL_ID"
    ),
    constraint "uqEV_LVL_Händelse_Level_Posit" unique (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt",
        "EV_LVL_PLV_ID"
    )
) ORDER BY "EV_LVL_EV_ID", "EV_LVL_ChangedAt" SEGMENTED BY MODULARHASH("EV_LVL_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Annex" (
    "EV_LVL_ID" integer not null,
    "EV_LVL_PositedAt" timestamp not null,
    "EV_LVL_Reliability" decimal(5,2) not null,
    "Metadata_EV_LVL" integer not null,
    constraint "fkEV_LVL_Händelse_Level_Annex" foreign key (
        "EV_LVL_ID"
    ) references attributes."EV_LVL_Händelse_Level_Posit"("EV_LVL_ID"),
    constraint "pkEV_LVL_Händelse_Level_Annex" primary key (
        "EV_LVL_ID",
        "EV_LVL_PositedAt"
    )
) ORDER BY "EV_LVL_ID", "EV_LVL_PositedAt" SEGMENTED BY MODULARHASH("EV_LVL_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Posit" (
    "ST_NAM_ID" integer default nextval('attributes."ST_NAM_Scen_Namn_Posit_ID_SEQ"') not null, 
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Scen_Namn_Posit" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_NAM_Scen_Namn_Posit" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Scen_Namn_Posit" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Scen_Namn"
    )
) ORDER BY "ST_NAM_ST_ID", "ST_NAM_ChangedAt" SEGMENTED BY MODULARHASH("ST_NAM_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Annex" (
    "ST_NAM_ID" integer not null,
    "ST_NAM_PositedAt" timestamp not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Scen_Namn_Annex" foreign key (
        "ST_NAM_ID"
    ) references attributes."ST_NAM_Scen_Namn_Posit"("ST_NAM_ID"),
    constraint "pkST_NAM_Scen_Namn_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_PositedAt"
    )
) ORDER BY "ST_NAM_ID", "ST_NAM_PositedAt" SEGMENTED BY MODULARHASH("ST_NAM_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Posit" (
    "ST_LOC_ID" integer default nextval('attributes."ST_LOC_Scen_Plats_Posit_ID_SEQ"') not null, 
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Scen_Plats" geography not null,
    "ST_LOC_Checksum" int default hash("ST_LOC_Scen_Plats"),
    constraint "fkST_LOC_Scen_Plats_Posit" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_LOC_Scen_Plats_Posit" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Scen_Plats_Posit" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    )
) ORDER BY "ST_LOC_ST_ID" SEGMENTED BY MODULARHASH("ST_LOC_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Annex" (
    "ST_LOC_ID" integer not null,
    "ST_LOC_PositedAt" timestamp not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Scen_Plats_Annex" foreign key (
        "ST_LOC_ID"
    ) references attributes."ST_LOC_Scen_Plats_Posit"("ST_LOC_ID"),
    constraint "pkST_LOC_Scen_Plats_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_PositedAt"
    )
) ORDER BY "ST_LOC_ID", "ST_LOC_PositedAt" SEGMENTED BY MODULARHASH("ST_LOC_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Posit" (
    "ST_AVG_ID" integer default nextval('attributes."ST_AVG_Scen_Medel_Posit_ID_SEQ"') not null, 
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Scen_Medel_Posit" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "fk_K_ST_AVG_Scen_Medel_Posit" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkST_AVG_Scen_Medel_Posit" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Scen_Medel_Posit" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    )
) ORDER BY "ST_AVG_ST_ID", "ST_AVG_ChangedAt" SEGMENTED BY MODULARHASH("ST_AVG_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Annex" (
    "ST_AVG_ID" integer not null,
    "ST_AVG_PositedAt" timestamp not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fkST_AVG_Scen_Medel_Annex" foreign key (
        "ST_AVG_ID"
    ) references attributes."ST_AVG_Scen_Medel_Posit"("ST_AVG_ID"),
    constraint "pkST_AVG_Scen_Medel_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_PositedAt"
    )
) ORDER BY "ST_AVG_ID", "ST_AVG_PositedAt" SEGMENTED BY MODULARHASH("ST_AVG_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Posit" (
    "ST_MIN_ID" integer default nextval('attributes."ST_MIN_Scen_Minimum_Posit_ID_SEQ"') not null, 
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" tinyint not null,
    constraint "fk_A_ST_MIN_Scen_Minimum_Posit" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "fk_K_ST_MIN_Scen_Minimum_Posit" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkST_MIN_Scen_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Scen_Minimum_Posit" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    )
) ORDER BY "ST_MIN_ST_ID" SEGMENTED BY MODULARHASH("ST_MIN_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Annex" (
    "ST_MIN_ID" integer not null,
    "ST_MIN_PositedAt" timestamp not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fkST_MIN_Scen_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references attributes."ST_MIN_Scen_Minimum_Posit"("ST_MIN_ID"),
    constraint "pkST_MIN_Scen_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_PositedAt"
    )
) ORDER BY "ST_MIN_ID", "ST_MIN_PositedAt" SEGMENTED BY MODULARHASH("ST_MIN_ID") ALL NODES;
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
CREATE SEQUENCE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Posit" (
    "AC_NAM_ID" integer default nextval('attributes."AC_NAM_Skådespelare_Namn_Posit_ID_SEQ"') not null, 
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Skådespelare_Namn" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Skådespelare_Namn_Posit" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "pkAC_NAM_Skådespelare_Namn_Posit" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Skådespelare_Namn_Posit" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Skådespelare_Namn"
    )
) ORDER BY "AC_NAM_AC_ID", "AC_NAM_ChangedAt" SEGMENTED BY MODULARHASH("AC_NAM_AC_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Annex" (
    "AC_NAM_ID" integer not null,
    "AC_NAM_PositedAt" timestamp not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Skådespelare_Namn_Annex" foreign key (
        "AC_NAM_ID"
    ) references attributes."AC_NAM_Skådespelare_Namn_Posit"("AC_NAM_ID"),
    constraint "pkAC_NAM_Skådespelare_Namn_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_PositedAt"
    )
) ORDER BY "AC_NAM_ID", "AC_NAM_PositedAt" SEGMENTED BY MODULARHASH("AC_NAM_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Posit" (
    "AC_GEN_ID" integer default nextval('attributes."AC_GEN_Skådespelare_Kön_Posit_ID_SEQ"') not null, 
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" tinyint not null,
    constraint "fk_A_AC_GEN_Skådespelare_Kön_Posit" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_GEN_Skådespelare_Kön_Posit" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Kön"("GEN_ID"),
    constraint "pkAC_GEN_Skådespelare_Kön_Posit" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Skådespelare_Kön_Posit" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    )
) ORDER BY "AC_GEN_AC_ID" SEGMENTED BY MODULARHASH("AC_GEN_AC_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Annex" (
    "AC_GEN_ID" integer not null,
    "AC_GEN_PositedAt" timestamp not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fkAC_GEN_Skådespelare_Kön_Annex" foreign key (
        "AC_GEN_ID"
    ) references attributes."AC_GEN_Skådespelare_Kön_Posit"("AC_GEN_ID"),
    constraint "pkAC_GEN_Skådespelare_Kön_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_PositedAt"
    )
) ORDER BY "AC_GEN_ID", "AC_GEN_PositedAt" SEGMENTED BY MODULARHASH("AC_GEN_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" (
    "AC_PLV_ID" integer default nextval('attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ"') not null, 
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå_Posit" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå_Posit" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID"),
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå_Posit" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Skådespelare_Yrkesnivå_Posit" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    )
) ORDER BY "AC_PLV_AC_ID", "AC_PLV_ChangedAt" SEGMENTED BY MODULARHASH("AC_PLV_AC_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
    "AC_PLV_ID" integer not null,
    "AC_PLV_PositedAt" timestamp not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fkAC_PLV_Skådespelare_Yrkesnivå_Annex" foreign key (
        "AC_PLV_ID"
    ) references attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"("AC_PLV_ID"),
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_PositedAt"
    )
) ORDER BY "AC_PLV_ID", "AC_PLV_PositedAt" SEGMENTED BY MODULARHASH("AC_PLV_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Posit" (
    "PR_NAM_ID" integer default nextval('attributes."PR_NAM_Föreställning_Namn_Posit_ID_SEQ"') not null, 
    "PR_NAM_PR_ID" bigint not null,
    "PR_NAM_Föreställning_Namn" varchar(42) not null,
    constraint "fkPR_NAM_Föreställning_Namn_Posit" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_NAM_Föreställning_Namn_Posit" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Föreställning_Namn_Posit" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Föreställning_Namn"
    )
) ORDER BY "PR_NAM_PR_ID" SEGMENTED BY MODULARHASH("PR_NAM_PR_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Annex" (
    "PR_NAM_ID" integer not null,
    "PR_NAM_PositedAt" timestamp not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Föreställning_Namn_Annex" foreign key (
        "PR_NAM_ID"
    ) references attributes."PR_NAM_Föreställning_Namn_Posit"("PR_NAM_ID"),
    constraint "pkPR_NAM_Föreställning_Namn_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_PositedAt"
    )
) ORDER BY "PR_NAM_ID", "PR_NAM_PositedAt" SEGMENTED BY MODULARHASH("PR_NAM_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Posit" (
    "PR_LEN_ID" integer default nextval('attributes."PR_LEN_Föreställning_Längd_Posit_ID_SEQ"') not null, 
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Föreställning_Längd_Posit" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_LEN_Föreställning_Längd_Posit" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Föreställning_Längd_Posit" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Föreställning_Längd"
    )
) ORDER BY "PR_LEN_PR_ID", "PR_LEN_ChangedAt" SEGMENTED BY MODULARHASH("PR_LEN_PR_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Annex" (
    "PR_LEN_ID" integer not null,
    "PR_LEN_PositedAt" timestamp not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Föreställning_Längd_Annex" foreign key (
        "PR_LEN_ID"
    ) references attributes."PR_LEN_Föreställning_Längd_Posit"("PR_LEN_ID"),
    constraint "pkPR_LEN_Föreställning_Längd_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_PositedAt"
    )
) ORDER BY "PR_LEN_ID", "PR_LEN_PositedAt" SEGMENTED BY MODULARHASH("PR_LEN_ID") ALL NODES;
