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
