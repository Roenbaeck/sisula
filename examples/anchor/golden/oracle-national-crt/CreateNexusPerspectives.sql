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
