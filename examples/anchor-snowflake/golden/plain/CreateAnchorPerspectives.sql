-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lST_Stage (
    ST_ID,
    ST_NAM_ChangedAt,
    ST_NAM_Stage_Name COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    ST_LOC_Checksum,
    ST_LOC_Stage_Location COMMENT 'Geographic location of the stage as a geography point.',
    ST_AVG_ChangedAt,
    UTL_Utilization COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    UTL_ID COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    UTL_Utilization COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    UTL_ID COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_Checksum,
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
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            public.ST_NAM_Stage_Name sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_ID = ST.ST_ID
LEFT JOIN
    public.ST_AVG_Stage_Average AVG
ON
    AVG.ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            public.ST_AVG_Stage_Average sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
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
    kMIN.UTL_ID = MIN.UTL_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ChangedAt datetime,
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ChangedAt,
    kAVG.UTL_Utilization AS UTL_Utilization,
    AVG.UTL_ID,
    kMIN.UTL_Utilization AS UTL_Utilization,
    MIN.UTL_ID
FROM
    public.ST_Stage ST
LEFT JOIN
    TABLE(public.rST_NAM_Stage_Name(changingTimepoint::datetime)) NAM
ON
    NAM.ST_ID = ST.ST_ID
AND
    NAM.ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            TABLE(public.rST_NAM_Stage_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
LEFT JOIN
    public.ST_LOC_Stage_Location LOC
ON
    LOC.ST_ID = ST.ST_ID
LEFT JOIN
    TABLE(public.rST_AVG_Stage_Average(changingTimepoint::datetime)) AVG
ON
    AVG.ST_ID = ST.ST_ID
AND
    AVG.ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            TABLE(public.rST_AVG_Stage_Average(changingTimepoint::datetime)) sub
        WHERE
            sub.ST_ID = ST.ST_ID
   )
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
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nST_Stage
AS
SELECT
    *
FROM
    TABLE(public.pST_Stage(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    ST_ID int,
    ST_NAM_ChangedAt datetime,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ChangedAt datetime,
    UTL_Utilization tinyint,
    UTL_ID tinyint,
    UTL_Utilization tinyint,
    UTL_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pST.ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ChangedAt,
    pST.UTL_Utilization,
    pST.UTL_ID,
    pST.UTL_Utilization,
    pST.UTL_ID
FROM
    public.ST_NAM_Stage_Name hNAM,
    TABLE(public.pST_Stage(hNAM.ST_NAM_ChangedAt::timestamp_ntz(9))) pST
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    hNAM.ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pST.ST_ID = hNAM.ST_ID
UNION
SELECT DISTINCT
    hAVG.ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    pST.ST_ID,
    pST.ST_NAM_ChangedAt,
    pST.ST_NAM_Stage_Name,
    pST.ST_LOC_Checksum,
    pST.ST_LOC_Stage_Location,
    pST.ST_AVG_ChangedAt,
    pST.UTL_Utilization,
    pST.UTL_ID,
    pST.UTL_Utilization,
    pST.UTL_ID
FROM
    public.ST_AVG_Stage_Average hAVG,
    TABLE(public.pST_Stage(hAVG.ST_AVG_ChangedAt::timestamp_ntz(9))) pST
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    hAVG.ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pST.ST_ID = hAVG.ST_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lAC_Actor (
    AC_ID,
    AC_NAM_ChangedAt,
    AC_NAM_Actor_Name COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    GEN_Gender COMMENT 'Gender of the actor.',
    GEN_ID COMMENT 'Gender of the actor.',
    AC_PLV_ChangedAt,
    ,
    PLV_ProfessionalLevel COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    PLV_ID COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
AS
SELECT
    AC.AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    kGEN.GEN_Gender AS GEN_Gender,
    GEN.GEN_ID,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS ,
    kPLV.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    PLV.PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    public.AC_NAM_Actor_Name NAM
ON
    NAM.AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            public.AC_NAM_Actor_Name sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
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
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            public.AC_PLV_Actor_ProfessionalLevel sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.PLV_ID;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ChangedAt datetime,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_Actor_Name,
    kGEN.GEN_Gender AS GEN_Gender,
    GEN.GEN_ID,
    PLV.AC_PLV_ChangedAt,
    kPLV.PLV_Checksum AS ,
    kPLV.PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    PLV.PLV_ID
FROM
    public.AC_Actor AC
LEFT JOIN
    TABLE(public.rAC_NAM_Actor_Name(changingTimepoint::datetime)) NAM
ON
    NAM.AC_ID = AC.AC_ID
AND
    NAM.AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            TABLE(public.rAC_NAM_Actor_Name(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.AC_GEN_Actor_Gender GEN
ON
    GEN.AC_ID = AC.AC_ID
LEFT JOIN
    public.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.GEN_ID
LEFT JOIN
    TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) PLV
ON
    PLV.AC_ID = AC.AC_ID
AND
    PLV.AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            TABLE(public.rAC_PLV_Actor_ProfessionalLevel(changingTimepoint::datetime)) sub
        WHERE
            sub.AC_ID = AC.AC_ID
   )
LEFT JOIN
    public.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.PLV_ID
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nAC_Actor
AS
SELECT
    *
FROM
    TABLE(public.pAC_Actor(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    AC_ID int,
    AC_NAM_ChangedAt datetime,
    AC_NAM_Actor_Name varchar(42),
    GEN_Gender varchar(42),
    GEN_ID number(1,0),
    AC_PLV_ChangedAt datetime,
     numeric(19,0),
    PLV_ProfessionalLevel string,
    PLV_ID tinyint
)
AS
$$
SELECT DISTINCT
    hNAM.AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    pAC.AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_Actor_Name,
    pAC.GEN_Gender,
    pAC.GEN_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.,
    pAC.PLV_ProfessionalLevel,
    pAC.PLV_ID
FROM
    public.AC_NAM_Actor_Name hNAM,
    TABLE(public.pAC_Actor(hNAM.AC_NAM_ChangedAt::timestamp_ntz(9))) pAC
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    hNAM.AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pAC.AC_ID = hNAM.AC_ID
UNION
SELECT DISTINCT
    hPLV.AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    pAC.AC_ID,
    pAC.AC_NAM_ChangedAt,
    pAC.AC_NAM_Actor_Name,
    pAC.GEN_Gender,
    pAC.GEN_ID,
    pAC.AC_PLV_ChangedAt,
    pAC.,
    pAC.PLV_ProfessionalLevel,
    pAC.PLV_ID
FROM
    public.AC_PLV_Actor_ProfessionalLevel hPLV,
    TABLE(public.pAC_Actor(hPLV.AC_PLV_ChangedAt::timestamp_ntz(9))) pAC
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    hPLV.AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pAC.AC_ID = hPLV.AC_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.lPR_Program (
    PR_ID,
    PR_NAM_Program_Name COMMENT 'Name or title of the program.',
    PR_LEN_ChangedAt,
    PR_LEN_Program_Length COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) COMMENT = 'A program, such as a play, show or concert, that can be played on stages.'
AS
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
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            public.PR_LEN_Program_Length sub
        WHERE
            sub.PR_ID = PR.PR_ID
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
RETURNS TABLE (
    PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
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
    TABLE(public.rPR_LEN_Program_Length(changingTimepoint::date)) LEN
ON
    LEN.PR_ID = PR.PR_ID
AND
    LEN.PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            TABLE(public.rPR_LEN_Program_Length(changingTimepoint::date)) sub
        WHERE
            sub.PR_ID = PR.PR_ID
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.nPR_Program
AS
SELECT
    *
FROM
    TABLE(public.pPR_Program(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    PR_ID int,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_ChangedAt date,
    PR_LEN_Program_Length time
)
AS
$$
SELECT DISTINCT
    hLEN.PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    pPR.PR_ID,
    pPR.PR_NAM_Program_Name,
    pPR.PR_LEN_ChangedAt,
    pPR.PR_LEN_Program_Length
FROM
    public.PR_LEN_Program_Length hLEN,
    TABLE(public.pPR_Program(hLEN.PR_LEN_ChangedAt::timestamp_ntz(9))) pPR
WHERE
    (selection IS NULL OR selection LIKE '%LEN%')
AND
    hLEN.PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
AND
    pPR.PR_ID = hLEN.PR_ID
$$
;
