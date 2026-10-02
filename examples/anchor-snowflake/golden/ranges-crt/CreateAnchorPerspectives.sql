-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tST_Stage (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    ST_ID int,
    Metadata_ST bigint,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Who smallint,
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_Stance string,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Who smallint,
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_Stance string,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Who smallint,
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_Stance string,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL bigint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Who smallint,
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_Stance string,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL bigint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    ST.ST_ID,
    ST.Metadata_ST,
    NAM.ST_NAM_ST_ID,
    NAM.Metadata_ST_NAM,
    NAM.ST_NAM_ID,
    NAM.ST_NAM_ChangedAt,
    NAM.ST_NAM_PositedAt,
    NAM.ST_NAM_Who,
    NAM.ST_NAM_Confidence,
    NAM.ST_NAM_Stance,
    NAM.ST_NAM_Stage_Name,
    LOC.ST_LOC_ST_ID,
    LOC.Metadata_ST_LOC,
    LOC.ST_LOC_ID,
    LOC.ST_LOC_PositedAt,
    LOC.ST_LOC_Who,
    LOC.ST_LOC_Confidence,
    LOC.ST_LOC_Stance,
    LOC.ST_LOC_Checksum,
    LOC.ST_LOC_Stage_Location,
    AVG.ST_AVG_ST_ID,
    AVG.Metadata_ST_AVG,
    AVG.ST_AVG_ID,
    AVG.ST_AVG_ChangedAt,
    AVG.ST_AVG_PositedAt,
    AVG.ST_AVG_Who,
    AVG.ST_AVG_Confidence,
    AVG.ST_AVG_Stance,
    kAVG.UTL_Utilization AS ST_AVG_UTL_Utilization,
    kAVG.Metadata_UTL AS ST_AVG_Metadata_UTL,
    AVG.ST_AVG_UTL_ID,
    MIN.ST_MIN_ST_ID,
    MIN.Metadata_ST_MIN,
    MIN.ST_MIN_ID,
    MIN.ST_MIN_PositedAt,
    MIN.ST_MIN_Who,
    MIN.ST_MIN_Confidence,
    MIN.ST_MIN_Stance,
    kMIN.UTL_Utilization AS ST_MIN_UTL_Utilization,
    kMIN.Metadata_UTL AS ST_MIN_Metadata_UTL,
    MIN.ST_MIN_UTL_ID
FROM
    anchors.ST_Stage ST
LEFT JOIN
    TABLE(attributes.rST_NAM_Stage_Name(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) NAM
ON
    NAM.ST_NAM_ID = (
        SELECT
            sub.ST_NAM_ID
        FROM
            TABLE(attributes.rST_NAM_Stage_Name(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_NAM_ST_ID = ST.ST_ID
        AND
            sub.ST_NAM_Stance = coalesce(assertion, sub.ST_NAM_Stance)
        ORDER BY
            sub.ST_NAM_ChangedAt DESC,
            sub.ST_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rST_LOC_Stage_Location(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) LOC
ON
    LOC.ST_LOC_ID = (
        SELECT
            sub.ST_LOC_ID
        FROM
            TABLE(attributes.rST_LOC_Stage_Location(
                positor,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_LOC_ST_ID = ST.ST_ID
        AND
            sub.ST_LOC_Stance = coalesce(assertion, sub.ST_LOC_Stance)
        ORDER BY
            sub.ST_LOC_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rST_AVG_Stage_Average(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) AVG
ON
    AVG.ST_AVG_ID = (
        SELECT
            sub.ST_AVG_ID
        FROM
            TABLE(attributes.rST_AVG_Stage_Average(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_AVG_ST_ID = ST.ST_ID
        AND
            sub.ST_AVG_Stance = coalesce(assertion, sub.ST_AVG_Stance)
        ORDER BY
            sub.ST_AVG_ChangedAt DESC,
            sub.ST_AVG_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.UTL_Utilization kAVG
ON
    kAVG.UTL_ID = AVG.ST_AVG_UTL_ID
LEFT JOIN
    TABLE(attributes.rST_MIN_Stage_Minimum(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) MIN
ON
    MIN.ST_MIN_ID = (
        SELECT
            sub.ST_MIN_ID
        FROM
            TABLE(attributes.rST_MIN_Stage_Minimum(
                positor,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.ST_MIN_ST_ID = ST.ST_ID
        AND
            sub.ST_MIN_Stance = coalesce(assertion, sub.ST_MIN_Stance)
        ORDER BY
            sub.ST_MIN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.UTL_Utilization kMIN
ON
    kMIN.UTL_ID = MIN.ST_MIN_UTL_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lST_Stage COPY GRANTS AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    ST.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tST_Stage(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) ST
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pST_Stage (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    ST_ID int,
    Metadata_ST bigint,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Who smallint,
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_Stance string,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Who smallint,
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_Stance string,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Who smallint,
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_Stance string,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL bigint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Who smallint,
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_Stance string,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL bigint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    ST.ST_ID,
    ST.Metadata_ST,
    ST.ST_NAM_ST_ID,
    ST.Metadata_ST_NAM,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Who,
    ST.ST_NAM_Confidence,
    ST.ST_NAM_Stance,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ST_ID,
    ST.Metadata_ST_LOC,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Who,
    ST.ST_LOC_Confidence,
    ST.ST_LOC_Stance,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ST_ID,
    ST.Metadata_ST_AVG,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Who,
    ST.ST_AVG_Confidence,
    ST.ST_AVG_Stance,
    ST.ST_AVG_UTL_Utilization,
    ST.ST_AVG_Metadata_UTL,
    ST.ST_AVG_UTL_ID,
    ST.ST_MIN_ST_ID,
    ST.Metadata_ST_MIN,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Who,
    ST.ST_MIN_Confidence,
    ST.ST_MIN_Stance,
    ST.ST_MIN_UTL_Utilization,
    ST.ST_MIN_Metadata_UTL,
    ST.ST_MIN_UTL_ID
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tST_Stage(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) ST
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nST_Stage COPY GRANTS AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    ST.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tST_Stage(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) ST
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dST_Stage (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    ST_ID int,
    Metadata_ST bigint,
    ST_NAM_ST_ID int,
    Metadata_ST_NAM bigint,
    ST_NAM_ID bigint,
    ST_NAM_ChangedAt datetime,
    ST_NAM_PositedAt timestamp_ntz(3),
    ST_NAM_Who smallint,
    ST_NAM_Confidence decimal(7,3),
    ST_NAM_Stance string,
    ST_NAM_Stage_Name varchar(42),
    ST_LOC_ST_ID int,
    Metadata_ST_LOC bigint,
    ST_LOC_ID bigint,
    ST_LOC_PositedAt timestamp_ntz(3),
    ST_LOC_Who smallint,
    ST_LOC_Confidence decimal(7,3),
    ST_LOC_Stance string,
    ST_LOC_Checksum numeric(19,0),
    ST_LOC_Stage_Location geography,
    ST_AVG_ST_ID int,
    Metadata_ST_AVG bigint,
    ST_AVG_ID bigint,
    ST_AVG_ChangedAt datetime,
    ST_AVG_PositedAt timestamp_ntz(3),
    ST_AVG_Who smallint,
    ST_AVG_Confidence decimal(7,3),
    ST_AVG_Stance string,
    ST_AVG_UTL_Utilization tinyint,
    ST_AVG_Metadata_UTL bigint,
    ST_AVG_UTL_ID tinyint,
    ST_MIN_ST_ID int,
    Metadata_ST_MIN bigint,
    ST_MIN_ID bigint,
    ST_MIN_PositedAt timestamp_ntz(3),
    ST_MIN_Who smallint,
    ST_MIN_Confidence decimal(7,3),
    ST_MIN_Stance string,
    ST_MIN_UTL_Utilization tinyint,
    ST_MIN_Metadata_UTL bigint,
    ST_MIN_UTL_ID tinyint
)
AS
$$
SELECT
    p.Who,
    timepoints.inspectedTimepoint,
    ST.ST_ID,
    ST.Metadata_ST,
    ST.ST_NAM_ST_ID,
    ST.Metadata_ST_NAM,
    ST.ST_NAM_ID,
    ST.ST_NAM_ChangedAt,
    ST.ST_NAM_PositedAt,
    ST.ST_NAM_Who,
    ST.ST_NAM_Confidence,
    ST.ST_NAM_Stance,
    ST.ST_NAM_Stage_Name,
    ST.ST_LOC_ST_ID,
    ST.Metadata_ST_LOC,
    ST.ST_LOC_ID,
    ST.ST_LOC_PositedAt,
    ST.ST_LOC_Who,
    ST.ST_LOC_Confidence,
    ST.ST_LOC_Stance,
    ST.ST_LOC_Checksum,
    ST.ST_LOC_Stage_Location,
    ST.ST_AVG_ST_ID,
    ST.Metadata_ST_AVG,
    ST.ST_AVG_ID,
    ST.ST_AVG_ChangedAt,
    ST.ST_AVG_PositedAt,
    ST.ST_AVG_Who,
    ST.ST_AVG_Confidence,
    ST.ST_AVG_Stance,
    ST.ST_AVG_UTL_Utilization,
    ST.ST_AVG_Metadata_UTL,
    ST.ST_AVG_UTL_ID,
    ST.ST_MIN_ST_ID,
    ST.Metadata_ST_MIN,
    ST.ST_MIN_ID,
    ST.ST_MIN_PositedAt,
    ST.ST_MIN_Who,
    ST.ST_MIN_Confidence,
    ST.ST_MIN_Stance,
    ST.ST_MIN_UTL_Utilization,
    ST.ST_MIN_Metadata_UTL,
    ST.ST_MIN_UTL_ID
FROM
    dw._Who p
JOIN
(
    SELECT DISTINCT
        ST_NAM_Who AS positor,
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.ST_NAM_Stage_Name
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_Who AS positor,
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes.ST_AVG_Stage_Average
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.Who
CROSS JOIN LATERAL
    TABLE(anchors.tST_Stage(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) ST
WHERE
    ST.ST_ID = timepoints.ST_ID
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tAC_Actor (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    AC_ID smallint,
    Metadata_AC bigint,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Who smallint,
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_Stance string,
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Who smallint,
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_Stance string,
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN bigint,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Who smallint,
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_Stance string,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV bigint,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    AC.AC_ID,
    AC.Metadata_AC,
    NAM.AC_NAM_AC_ID,
    NAM.Metadata_AC_NAM,
    NAM.AC_NAM_ID,
    NAM.AC_NAM_ChangedAt,
    NAM.AC_NAM_PositedAt,
    NAM.AC_NAM_Who,
    NAM.AC_NAM_Confidence,
    NAM.AC_NAM_Stance,
    NAM.AC_NAM_Actor_Name,
    GEN.AC_GEN_AC_ID,
    GEN.Metadata_AC_GEN,
    GEN.AC_GEN_ID,
    GEN.AC_GEN_PositedAt,
    GEN.AC_GEN_Who,
    GEN.AC_GEN_Confidence,
    GEN.AC_GEN_Stance,
    kGEN.GEN_Checksum AS AC_GEN_GEN_Checksum,
    kGEN.GEN_Gender AS AC_GEN_GEN_Gender,
    kGEN.Metadata_GEN AS AC_GEN_Metadata_GEN,
    GEN.AC_GEN_GEN_ID,
    PLV.AC_PLV_AC_ID,
    PLV.Metadata_AC_PLV,
    PLV.AC_PLV_ID,
    PLV.AC_PLV_ChangedAt,
    PLV.AC_PLV_PositedAt,
    PLV.AC_PLV_Who,
    PLV.AC_PLV_Confidence,
    PLV.AC_PLV_Stance,
    kPLV.PLV_Checksum AS AC_PLV_PLV_Checksum,
    kPLV.PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    kPLV.Metadata_PLV AS AC_PLV_Metadata_PLV,
    PLV.AC_PLV_PLV_ID
FROM
    anchors.AC_Actor AC
LEFT JOIN
    TABLE(attributes.rAC_NAM_Actor_Name(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) NAM
ON
    NAM.AC_NAM_ID = (
        SELECT
            sub.AC_NAM_ID
        FROM
            TABLE(attributes.rAC_NAM_Actor_Name(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_NAM_AC_ID = AC.AC_ID
        AND
            sub.AC_NAM_Stance = coalesce(assertion, sub.AC_NAM_Stance)
        ORDER BY
            sub.AC_NAM_ChangedAt DESC,
            sub.AC_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rAC_GEN_Actor_Gender(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) GEN
ON
    GEN.AC_GEN_ID = (
        SELECT
            sub.AC_GEN_ID
        FROM
            TABLE(attributes.rAC_GEN_Actor_Gender(
                positor,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_GEN_AC_ID = AC.AC_ID
        AND
            sub.AC_GEN_Stance = coalesce(assertion, sub.AC_GEN_Stance)
        ORDER BY
            sub.AC_GEN_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.GEN_Gender kGEN
ON
    kGEN.GEN_ID = GEN.AC_GEN_GEN_ID
LEFT JOIN
    TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::timestamp_ntz(3)
    )) PLV
ON
    PLV.AC_PLV_ID = (
        SELECT
            sub.AC_PLV_ID
        FROM
            TABLE(attributes.rAC_PLV_Actor_ProfessionalLevel(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.AC_PLV_AC_ID = AC.AC_ID
        AND
            sub.AC_PLV_Stance = coalesce(assertion, sub.AC_PLV_Stance)
        ORDER BY
            sub.AC_PLV_ChangedAt DESC,
            sub.AC_PLV_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    knots.PLV_ProfessionalLevel kPLV
ON
    kPLV.PLV_ID = PLV.AC_PLV_PLV_ID
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lAC_Actor COPY GRANTS AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    AC.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tAC_Actor(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) AC
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pAC_Actor (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    AC_ID smallint,
    Metadata_AC bigint,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Who smallint,
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_Stance string,
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Who smallint,
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_Stance string,
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN bigint,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Who smallint,
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_Stance string,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV bigint,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    AC.AC_ID,
    AC.Metadata_AC,
    AC.AC_NAM_AC_ID,
    AC.Metadata_AC_NAM,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Who,
    AC.AC_NAM_Confidence,
    AC.AC_NAM_Stance,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_AC_ID,
    AC.Metadata_AC_GEN,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Who,
    AC.AC_GEN_Confidence,
    AC.AC_GEN_Stance,
    AC.AC_GEN_GEN_Checksum,
    AC.AC_GEN_GEN_Gender,
    AC.AC_GEN_Metadata_GEN,
    AC.AC_GEN_GEN_ID,
    AC.AC_PLV_AC_ID,
    AC.Metadata_AC_PLV,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Who,
    AC.AC_PLV_Confidence,
    AC.AC_PLV_Stance,
    AC.AC_PLV_PLV_Checksum,
    AC.AC_PLV_PLV_ProfessionalLevel,
    AC.AC_PLV_Metadata_PLV,
    AC.AC_PLV_PLV_ID
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tAC_Actor(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) AC
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nAC_Actor COPY GRANTS AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    AC.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tAC_Actor(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) AC
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dAC_Actor (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    AC_ID smallint,
    Metadata_AC bigint,
    AC_NAM_AC_ID smallint,
    Metadata_AC_NAM bigint,
    AC_NAM_ID bigint,
    AC_NAM_ChangedAt datetime,
    AC_NAM_PositedAt timestamp_ntz(3),
    AC_NAM_Who smallint,
    AC_NAM_Confidence decimal(7,3),
    AC_NAM_Stance string,
    AC_NAM_Actor_Name varbinary(max),
    AC_GEN_AC_ID smallint,
    Metadata_AC_GEN bigint,
    AC_GEN_ID bigint,
    AC_GEN_PositedAt timestamp_ntz(3),
    AC_GEN_Who smallint,
    AC_GEN_Confidence decimal(7,3),
    AC_GEN_Stance string,
    AC_GEN_GEN_Checksum numeric(19,0),
    AC_GEN_GEN_Gender varchar(42),
    AC_GEN_Metadata_GEN bigint,
    AC_GEN_GEN_ID number(1,0),
    AC_PLV_AC_ID smallint,
    Metadata_AC_PLV bigint,
    AC_PLV_ID bigint,
    AC_PLV_ChangedAt datetime,
    AC_PLV_PositedAt timestamp_ntz(3),
    AC_PLV_Who smallint,
    AC_PLV_Confidence decimal(7,3),
    AC_PLV_Stance string,
    AC_PLV_PLV_Checksum numeric(19,0),
    AC_PLV_PLV_ProfessionalLevel string,
    AC_PLV_Metadata_PLV bigint,
    AC_PLV_PLV_ID tinyint
)
AS
$$
SELECT
    p.Who,
    timepoints.inspectedTimepoint,
    AC.AC_ID,
    AC.Metadata_AC,
    AC.AC_NAM_AC_ID,
    AC.Metadata_AC_NAM,
    AC.AC_NAM_ID,
    AC.AC_NAM_ChangedAt,
    AC.AC_NAM_PositedAt,
    AC.AC_NAM_Who,
    AC.AC_NAM_Confidence,
    AC.AC_NAM_Stance,
    AC.AC_NAM_Actor_Name,
    AC.AC_GEN_AC_ID,
    AC.Metadata_AC_GEN,
    AC.AC_GEN_ID,
    AC.AC_GEN_PositedAt,
    AC.AC_GEN_Who,
    AC.AC_GEN_Confidence,
    AC.AC_GEN_Stance,
    AC.AC_GEN_GEN_Checksum,
    AC.AC_GEN_GEN_Gender,
    AC.AC_GEN_Metadata_GEN,
    AC.AC_GEN_GEN_ID,
    AC.AC_PLV_AC_ID,
    AC.Metadata_AC_PLV,
    AC.AC_PLV_ID,
    AC.AC_PLV_ChangedAt,
    AC.AC_PLV_PositedAt,
    AC.AC_PLV_Who,
    AC.AC_PLV_Confidence,
    AC.AC_PLV_Stance,
    AC.AC_PLV_PLV_Checksum,
    AC.AC_PLV_PLV_ProfessionalLevel,
    AC.AC_PLV_Metadata_PLV,
    AC.AC_PLV_PLV_ID
FROM
    dw._Who p
JOIN
(
    SELECT DISTINCT
        AC_NAM_Who AS positor,
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.AC_NAM_Actor_Name
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_Who AS positor,
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes.AC_PLV_Actor_ProfessionalLevel
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.Who
CROSS JOIN LATERAL
    TABLE(anchors.tAC_Actor(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) AC
WHERE
    AC.AC_ID = timepoints.AC_ID
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.tPR_Program (
    positor smallint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint timestamp_ntz(3),
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    PR_ID number(10,0),
    Metadata_PR bigint,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Who smallint,
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_Stance string,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Who smallint,
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_Stance string,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    PR.PR_ID,
    PR.Metadata_PR,
    NAM.PR_NAM_PR_ID,
    NAM.Metadata_PR_NAM,
    NAM.PR_NAM_ID,
    NAM.PR_NAM_PositedAt,
    NAM.PR_NAM_Who,
    NAM.PR_NAM_Confidence,
    NAM.PR_NAM_Stance,
    NAM.PR_NAM_Program_Name,
    LEN.PR_LEN_PR_ID,
    LEN.Metadata_PR_LEN,
    LEN.PR_LEN_ID,
    LEN.PR_LEN_ChangedAt,
    LEN.PR_LEN_PositedAt,
    LEN.PR_LEN_Who,
    LEN.PR_LEN_Confidence,
    LEN.PR_LEN_Stance,
    LEN.PR_LEN_Program_Length
FROM
    anchors.PR_Program PR
LEFT JOIN
    TABLE(attributes.rPR_NAM_Program_Name(
        positor,
        positingTimepoint::timestamp_ntz(3)
    )) NAM
ON
    NAM.PR_NAM_ID = (
        SELECT
            sub.PR_NAM_ID
        FROM
            TABLE(attributes.rPR_NAM_Program_Name(
                positor,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.PR_NAM_PR_ID = PR.PR_ID
        AND
            sub.PR_NAM_Stance = coalesce(assertion, sub.PR_NAM_Stance)
        ORDER BY
            sub.PR_NAM_PositedAt DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes.rPR_LEN_Program_Length(
        positor,
        changingTimepoint::date,
        positingTimepoint::timestamp_ntz(3)
    )) LEN
ON
    LEN.PR_LEN_ID = (
        SELECT
            sub.PR_LEN_ID
        FROM
            TABLE(attributes.rPR_LEN_Program_Length(
                positor,
                changingTimepoint::date,
                positingTimepoint::timestamp_ntz(3)
            )) sub
        WHERE
            sub.PR_LEN_PR_ID = PR.PR_ID
        AND
            sub.PR_LEN_Stance = coalesce(assertion, sub.PR_LEN_Stance)
        ORDER BY
            sub.PR_LEN_ChangedAt DESC,
            sub.PR_LEN_PositedAt DESC
        LIMIT 1
    )
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.lPR_Program COPY GRANTS AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    PR.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tPR_Program(
        p.Who,
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) PR
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.pPR_Program (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    Who smallint,
    Confidence decimal(7,3),
    PR_ID number(10,0),
    Metadata_PR bigint,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Who smallint,
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_Stance string,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Who smallint,
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_Stance string,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    PR.PR_ID,
    PR.Metadata_PR,
    PR.PR_NAM_PR_ID,
    PR.Metadata_PR_NAM,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Who,
    PR.PR_NAM_Confidence,
    PR.PR_NAM_Stance,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_PR_ID,
    PR.Metadata_PR_LEN,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Who,
    PR.PR_LEN_Confidence,
    PR.PR_LEN_Stance,
    PR.PR_LEN_Program_Length
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tPR_Program(
        p.Who,
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) PR
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.nPR_Program COPY GRANTS AS
SELECT
    p.Who,
    cast(null as decimal(7,3)) as Confidence,
    PR.*
FROM
    dw._Who p
CROSS JOIN LATERAL
    TABLE(anchors.tPR_Program(
        p.Who,
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) PR
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors.dPR_Program (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    Who smallint,
    inspectedTimepoint timestamp_ntz(9),
    PR_ID number(10,0),
    Metadata_PR bigint,
    PR_NAM_PR_ID number(10,0),
    Metadata_PR_NAM bigint,
    PR_NAM_ID bigint,
    PR_NAM_PositedAt timestamp_ntz(3),
    PR_NAM_Who smallint,
    PR_NAM_Confidence decimal(7,3),
    PR_NAM_Stance string,
    PR_NAM_Program_Name varchar(42),
    PR_LEN_PR_ID number(10,0),
    Metadata_PR_LEN bigint,
    PR_LEN_ID bigint,
    PR_LEN_ChangedAt date,
    PR_LEN_PositedAt timestamp_ntz(3),
    PR_LEN_Who smallint,
    PR_LEN_Confidence decimal(7,3),
    PR_LEN_Stance string,
    PR_LEN_Program_Length time
)
AS
$$
SELECT
    p.Who,
    timepoints.inspectedTimepoint,
    PR.PR_ID,
    PR.Metadata_PR,
    PR.PR_NAM_PR_ID,
    PR.Metadata_PR_NAM,
    PR.PR_NAM_ID,
    PR.PR_NAM_PositedAt,
    PR.PR_NAM_Who,
    PR.PR_NAM_Confidence,
    PR.PR_NAM_Stance,
    PR.PR_NAM_Program_Name,
    PR.PR_LEN_PR_ID,
    PR.Metadata_PR_LEN,
    PR.PR_LEN_ID,
    PR.PR_LEN_ChangedAt,
    PR.PR_LEN_PositedAt,
    PR.PR_LEN_Who,
    PR.PR_LEN_Confidence,
    PR.PR_LEN_Stance,
    PR.PR_LEN_Program_Length
FROM
    dw._Who p
JOIN
(
    SELECT DISTINCT
        PR_LEN_Who AS positor,
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.PR_LEN_Program_Length
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.Who
CROSS JOIN LATERAL
    TABLE(anchors.tPR_Program(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::timestamp_ntz(3),
        '+'
    )) PR
WHERE
    PR.PR_ID = timepoints.PR_ID
$$
;
