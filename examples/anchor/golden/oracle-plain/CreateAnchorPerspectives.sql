-- ANCHOR PERSPECTIVES ------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW public.lPN_Person AS
SELECT
    *
FROM
    public.PN_Person PN
;

CREATE OR REPLACE VIEW public.nPN_Person AS
SELECT
    *
FROM
    public.lPN_Person
;
CREATE OR REPLACE VIEW public.lST_Stage AS
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS UTL_Utilization,
    AVG.UTL_ID,
    kMIN.UTL_Utilization AS UTL_Utilization,
    MIN.UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    public.ST_NAM_Stage_Name NAM
ON
    NAM.ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_AVG_Stage_Average AVG
ON
    AVG.ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.UTL_ID
LEFT JOIN
    public.ST_MIN_Stage_Minimum MIN
ON
    MIN.ST_ID = ST.ST_ID
LEFT JOIN
    public.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.UTL_ID
WHERE
    1 = 1
AND (
    NAM.ST_NAM_ChangedAt = (
        SELECT
            MAX(sub.ST_NAM_ChangedAt)
        FROM
            public.ST_NAM_Stage_Name sub
        WHERE
            sub.ST_ID = ST.ST_ID
    )
    OR NAM.ST_NAM_ChangedAt IS NULL
)
AND (
    AVG.ST_AVG_ChangedAt = (
        SELECT
            MAX(sub.ST_AVG_ChangedAt)
        FROM
            public.ST_AVG_Stage_Average sub
        WHERE
            sub.ST_ID = ST.ST_ID
    )
    OR AVG.ST_AVG_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nST_Stage AS
SELECT
    *
FROM
    public.lST_Stage
;
CREATE OR REPLACE VIEW public.lAC_Actor AS
SELECT
    AC.AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    kGEN.GEN_Gender AS GEN_Gender,
    GEN.GEN_ID,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    PLV.PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    public.AC_NAM_Actor_Name NAM
ON
    NAM.AC_ID = AC.AC_ID
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.GEN_ID
LEFT JOIN
    public.AC_PLV_Actor_ProfessionalLevel PLV
ON
    PLV.AC_ID = AC.AC_ID
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.PLV_ID
WHERE
    1 = 1
AND (
    NAM.AC_NAM_ChangedAt = (
        SELECT
            MAX(sub.AC_NAM_ChangedAt)
        FROM
            public.AC_NAM_Actor_Name sub
        WHERE
            sub.AC_ID = AC.AC_ID
    )
    OR NAM.AC_NAM_ChangedAt IS NULL
)
AND (
    PLV.AC_PLV_ChangedAt = (
        SELECT
            MAX(sub.AC_PLV_ChangedAt)
        FROM
            public.AC_PLV_Actor_ProfessionalLevel sub
        WHERE
            sub.AC_ID = AC.AC_ID
    )
    OR PLV.AC_PLV_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nAC_Actor AS
SELECT
    *
FROM
    public.lAC_Actor
;
CREATE OR REPLACE VIEW public.lPR_Program AS
SELECT
    PR.PR_ID,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_Program_Length
FROM
    public.PR_Program PR
LEFT JOIN
    public.PR_NAM_Program_Name NAM
ON
    NAM.PR_ID = PR.PR_ID
LEFT JOIN
    public.PR_LEN_Program_Length LEN
ON
    LEN.PR_ID = PR.PR_ID
WHERE
    1 = 1
AND (
    LEN.PR_LEN_ChangedAt = (
        SELECT
            MAX(sub.PR_LEN_ChangedAt)
        FROM
            public.PR_LEN_Program_Length sub
        WHERE
            sub.PR_ID = PR.PR_ID
    )
    OR LEN.PR_LEN_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nPR_Program AS
SELECT
    *
FROM
    public.lPR_Program
;
