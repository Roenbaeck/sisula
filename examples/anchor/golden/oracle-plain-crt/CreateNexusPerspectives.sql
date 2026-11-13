-- NEXUS CRT PERSPECTIVES ---------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT nexuses.
--
CREATE OR REPLACE VIEW public.lEV_Event AS
SELECT
    n.EV_ID,
    n.ST_ID_wasHeldAt,
    n.PR_ID_wasPlayed,
    n.ETY_ID_of,
    rDAT.EV_DAT_Event_Date,
    rDAT.EV_DAT_PositedAt,
    rDAT.EV_DAT_Positor,
    rDAT.EV_DAT_Reliability,
    rDAT.EV_DAT_Assertion,
    rDAT.,
    rAUD.EV_AUD_Event_Audience,
    rAUD.EV_AUD_PositedAt,
    rAUD.EV_AUD_Positor,
    rAUD.EV_AUD_Reliability,
    rAUD.EV_AUD_Assertion,
    rAUD.,
    rREV.EV_REV_Event_Revenue,
    rREV.EV_REV_PositedAt,
    rREV.EV_REV_Positor,
    rREV.EV_REV_Reliability,
    rREV.EV_REV_Assertion,
    rREV.
FROM
    public.EV_Event n
LEFT JOIN
    public.rEV_DAT_Event_Date rDAT
ON
    rDAT.EV_ID = n.EV_ID
LEFT JOIN
    public.rEV_AUD_Event_Audience rAUD
ON
    rAUD.EV_ID = n.EV_ID
LEFT JOIN
    public.rEV_REV_Event_Revenue rREV
ON
    rREV.EV_ID = n.EV_ID
;

CREATE OR REPLACE VIEW public.nEV_Event AS
SELECT
    *
FROM
    public.lEV_Event
;

CREATE OR REPLACE FUNCTION public.tEV_Event (
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
            public.lEV_Event t
        WHERE
            (
                positor IS NULL
                OR (
                    t.EV_DAT_Positor = positor OR
                    t.EV_AUD_Positor = positor OR
                    t.EV_REV_Positor = positor 
                )
            )
        AND
            (
                assertion IS NULL
                OR (
                    t.EV_DAT_Assertion = assertion OR
                    t.EV_AUD_Assertion = assertion OR
                    t.EV_REV_Assertion = assertion 
                )
            )
        AND
            (
                changingTimepoint IS NULL
                OR 1 = 1
            )
        AND
            (
                positingTimepoint IS NULL
                OR (
                    t.EV_DAT_PositedAt <= positingTimepoint OR
                    t.EV_AUD_PositedAt <= positingTimepoint OR
                    t.EV_REV_PositedAt <= positingTimepoint 
                )
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.pEV_Event (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            public.lEV_Event t
        WHERE
            (
                changingTimepoint IS NULL
                OR 1 = 1
            )
    ]';
END;
/

CREATE OR REPLACE FUNCTION public.dEV_Event (
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
            public.lEV_Event t
        WHERE
            (
                intervalStart IS NULL
                OR intervalEnd IS NULL
                OR 1 = 1
            )
    ]';
END;
/
