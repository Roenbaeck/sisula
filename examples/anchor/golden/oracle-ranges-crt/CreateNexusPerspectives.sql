-- NEXUS CRT PERSPECTIVES ---------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT nexuses.
--
CREATE OR REPLACE VIEW nexuses.lEV_Event AS
SELECT
    n.EV_ID,
    n.Metadata_EV,
    n.ST_ID_wasHeldAt,
    n.PR_ID_wasPlayed,
    n.ETY_ID_of,
    rDAT.EV_DAT_Event_Date,
    rDAT.EV_DAT_PositedAt,
    rDAT.EV_DAT_Who,
    rDAT.EV_DAT_Confidence,
    rDAT.EV_DAT_Stance,
    rDAT.,
    rAUD.EV_AUD_Event_Audience,
    rAUD.EV_AUD_PositedAt,
    rAUD.EV_AUD_Who,
    rAUD.EV_AUD_Confidence,
    rAUD.EV_AUD_Stance,
    rAUD.,
    rREV.EV_REV_Event_Revenue,
    rREV.EV_REV_PositedAt,
    rREV.EV_REV_Who,
    rREV.EV_REV_Confidence,
    rREV.EV_REV_Stance,
    rREV.,
    rSTA.EV_STA_Event_Status,
    rSTA.EV_STA_ChangedAt,
    rSTA.EV_STA_PositedAt,
    rSTA.EV_STA_Who,
    rSTA.EV_STA_Confidence,
    rSTA.EV_STA_Stance,
    rSTA.,
    rUTL.EV_UTL_UTL_ID,
    rUTL.EV_UTL_PositedAt,
    rUTL.EV_UTL_Who,
    rUTL.EV_UTL_Confidence,
    rUTL.EV_UTL_Stance,
    rUTL.,
    rLVL.EV_LVL_PLV_ID,
    rLVL.EV_LVL_ChangedAt,
    rLVL.EV_LVL_PositedAt,
    rLVL.EV_LVL_Who,
    rLVL.EV_LVL_Confidence,
    rLVL.EV_LVL_Stance,
    rLVL.
FROM
    nexuses.EV_Event n
LEFT JOIN
    attributes.rEV_DAT_Event_Date rDAT
ON
    rDAT.EV_DAT_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_AUD_Event_Audience rAUD
ON
    rAUD.EV_AUD_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_REV_Event_Revenue rREV
ON
    rREV.EV_REV_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_STA_Event_Status rSTA
ON
    rSTA.EV_STA_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_UTL_Event_Utilization rUTL
ON
    rUTL.EV_UTL_EV_ID = n.EV_ID
LEFT JOIN
    attributes.rEV_LVL_Event_Level rLVL
ON
    rLVL.EV_LVL_EV_ID = n.EV_ID
;

CREATE OR REPLACE VIEW nexuses.nEV_Event AS
SELECT
    *
FROM
    nexuses.lEV_Event
;

CREATE OR REPLACE FUNCTION nexuses.tEV_Event (
    positor number(5),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp(3),
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Event t
        WHERE
            (
                positor IS NULL
                OR (
                    t.EV_DAT_Who = positor OR
                    t.EV_AUD_Who = positor OR
                    t.EV_REV_Who = positor OR
                    t.EV_STA_Who = positor OR
                    t.EV_UTL_Who = positor OR
                    t.EV_LVL_Who = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.EV_DAT_Stance = assertion OR
                    t.EV_AUD_Stance = assertion OR
                    t.EV_REV_Stance = assertion OR
                    t.EV_STA_Stance = assertion OR
                    t.EV_UTL_Stance = assertion OR
                    t.EV_LVL_Stance = assertion 
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

CREATE OR REPLACE FUNCTION nexuses.pEV_Event (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            nexuses.lEV_Event t
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

CREATE OR REPLACE FUNCTION nexuses.dEV_Event (
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
            nexuses.lEV_Event t
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
