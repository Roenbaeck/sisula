-- ANCHOR PERSPECTIVES ------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW anchors.lPN_Person AS
SELECT
    *
FROM
    anchors.PN_Person PN
;

CREATE OR REPLACE VIEW anchors.nPN_Person AS
SELECT
    *
FROM
    anchors.lPN_Person
;
CREATE OR REPLACE VIEW anchors.lST_Scen AS
SELECT
    ST.ST_ID,
    ST.Metadata_ST,
    NAM.ST_NAM_ST_ID,
    NAM.Metadata_ST_NAM,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Scen_Namn,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_Scen_Plats,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utnyttjande AS ST_AVG_UTL_Utnyttjande,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    kMIN.UTL_Utnyttjande AS ST_MIN_UTL_Utnyttjande,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    anchors.ST_Scen ST
LEFT JOIN
    attributes.ST_NAM_Scen_Namn NAM
ON
    NAM.ST_NAM_ST_ID = ST.ST_ID
LEFT JOIN
    attributes.ST_LOC_Scen_Plats LOC
ON
    LOC.ST_LOC_ST_ID = ST.ST_ID
LEFT JOIN
    attributes.ST_AVG_Scen_Medel AVG
ON
    AVG.ST_AVG_ST_ID = ST.ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    attributes.ST_MIN_Scen_Minimum MIN
ON
    MIN.ST_MIN_ST_ID = ST.ST_ID
LEFT JOIN
    knots.UTL_Utnyttjande kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
WHERE
    1 = 1
AND (
    NAM.ST_NAM_ChangedAt = (
        SELECT
            MAX(sub.ST_NAM_ChangedAt)
        FROM
            attributes.ST_NAM_Scen_Namn sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
    )
    OR NAM.ST_NAM_ChangedAt IS NULL
)
AND (
    AVG.ST_AVG_ChangedAt = (
        SELECT
            MAX(sub.ST_AVG_ChangedAt)
        FROM
            attributes.ST_AVG_Scen_Medel sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
    )
    OR AVG.ST_AVG_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW anchors.nST_Scen AS
SELECT
    *
FROM
    anchors.lST_Scen
;
CREATE OR REPLACE VIEW anchors.lAC_Skådespelare AS
SELECT
    AC.AC_ID,
    AC.Metadata_AC,
    NAM.AC_NAM_AC_ID,
    NAM.Metadata_AC_NAM,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Skådespelare_Namn,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    kGEN.GEN_Kön AS AC_GEN_GEN_Kön,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Yrkesnivå AS AC_PLV_PLV_Yrkesnivå,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    anchors.AC_Skådespelare AC
LEFT JOIN
    attributes.AC_NAM_Skådespelare_Namn NAM
ON
    NAM.AC_NAM_AC_ID = AC.AC_ID
LEFT JOIN
    attributes.AC_GEN_Skådespelare_Kön GEN
ON
    GEN.AC_GEN_AC_ID = AC.AC_ID
LEFT JOIN
    knots.GEN_Kön kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    attributes.AC_PLV_Skådespelare_Yrkesnivå PLV
ON
    PLV.AC_PLV_AC_ID = AC.AC_ID
LEFT JOIN
    knots.PLV_Yrkesnivå kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
WHERE
    1 = 1
AND (
    NAM.AC_NAM_ChangedAt = (
        SELECT
            MAX(sub.AC_NAM_ChangedAt)
        FROM
            attributes.AC_NAM_Skådespelare_Namn sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
    )
    OR NAM.AC_NAM_ChangedAt IS NULL
)
AND (
    PLV.AC_PLV_ChangedAt = (
        SELECT
            MAX(sub.AC_PLV_ChangedAt)
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
    )
    OR PLV.AC_PLV_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW anchors.nAC_Skådespelare AS
SELECT
    *
FROM
    anchors.lAC_Skådespelare
;
CREATE OR REPLACE VIEW anchors.lPR_Föreställning AS
SELECT
    PR.PR_ID,
    PR.Metadata_PR,
    NAM.PR_NAM_PR_ID,
    NAM.Metadata_PR_NAM,
    NAM.PR_NAM_Föreställning_Namn,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Föreställning_Längd
FROM
    anchors.PR_Föreställning PR
LEFT JOIN
    attributes.PR_NAM_Föreställning_Namn NAM
ON
    NAM.PR_NAM_PR_ID = PR.PR_ID
LEFT JOIN
    attributes.PR_LEN_Föreställning_Längd LEN
ON
    LEN.PR_LEN_PR_ID = PR.PR_ID
WHERE
    1 = 1
AND (
    LEN.PR_LEN_ChangedAt = (
        SELECT
            MAX(sub.PR_LEN_ChangedAt)
        FROM
            attributes.PR_LEN_Föreställning_Längd sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
    )
    OR LEN.PR_LEN_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW anchors.nPR_Föreställning AS
SELECT
    *
FROM
    anchors.lPR_Föreställning
;
