-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_Subject (
    SU_ID,
    Metadata_SU,
    SU_NAM_SU_ID,
    Metadata_SU_NAM,
    Deletable_SU_NAM,
    SU_NAM_Subject_Name,
    SU_COD_SU_ID,
    Metadata_SU_COD,
    SU_COD_Subject_Code,
    SU_GRD_SU_ID,
    Metadata_SU_GRD,
    SU_GRD_GRD_Grade,
    SU_GRD_Metadata_GRD,
    SU_GRD_GRD_ID,
    SU_NOT_SU_ID,
    Metadata_SU_NOT,
    SU_NOT_Subject_Note,
    SU_TTL_SU_ID,
    Metadata_SU_TTL,
    SU_TTL_ChangedAt,
    SU_TTL_Subject_Title,
    SU_STA_SU_ID,
    Metadata_SU_STA,
    SU_STA_ChangedAt,
    SU_STA_Subject_State,
    SU_LBL_SU_ID,
    Metadata_SU_LBL,
    SU_LBL_ChangedAt,
    SU_LBL_Subject_Label,
    SU_TAG_SU_ID,
    Metadata_SU_TAG,
    SU_TAG_ChangedAt,
    SU_TAG_Subject_Tag,
    SU_LVL_SU_ID,
    Metadata_SU_LVL,
    Deletable_SU_LVL,
    SU_LVL_ChangedAt,
    SU_LVL_GRD_Grade,
    SU_LVL_Metadata_GRD,
    SU_LVL_GRD_ID,
    SU_TXT_SU_ID,
    Metadata_SU_TXT,
    SU_TXT_ChangedAt,
    SU_TXT_Subject_Text,
    SU_ASR_SU_ID,
    Metadata_SU_ASR,
    SU_ASR_ChangedAt,
    SU_ASR_Subject_Assessment,
    SU_ERS_SU_ID,
    Metadata_SU_ERS,
    Deletable_SU_ERS,
    SU_ERS_ChangedAt,
    SU_ERS_Subject_Erasable
)
AS
SELECT
    "SU".SU_ID,
    "SU".Metadata_SU,
    "NAM".SU_NAM_SU_ID,
    "NAM".Metadata_SU_NAM,
    CAST(NULL AS number(1)),
    "NAM".SU_NAM_Subject_Name,
    "COD".SU_COD_SU_ID,
    "COD".Metadata_SU_COD,
    "COD".SU_COD_Subject_Code,
    "GRD".SU_GRD_SU_ID,
    "GRD".Metadata_SU_GRD,
    "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
    "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
    "GRD".SU_GRD_GRD_ID,
    "NOT".SU_NOT_SU_ID,
    "NOT".Metadata_SU_NOT,
    "NOT".SU_NOT_Subject_Note,
    "TTL".SU_TTL_SU_ID,
    "TTL".Metadata_SU_TTL,
    "TTL".SU_TTL_ChangedAt,
    "TTL".SU_TTL_Subject_Title,
    "STA".SU_STA_SU_ID,
    "STA".Metadata_SU_STA,
    "STA".SU_STA_ChangedAt,
    "STA".SU_STA_Subject_State,
    "LBL".SU_LBL_SU_ID,
    "LBL".Metadata_SU_LBL,
    "LBL".SU_LBL_ChangedAt,
    "LBL".SU_LBL_Subject_Label,
    "TAG".SU_TAG_SU_ID,
    "TAG".Metadata_SU_TAG,
    "TAG".SU_TAG_ChangedAt,
    "TAG".SU_TAG_Subject_Tag,
    "LVL".SU_LVL_SU_ID,
    "LVL".Metadata_SU_LVL,
    CAST(NULL AS number(1)),
    "LVL".SU_LVL_ChangedAt,
    "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
    "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
    "LVL".SU_LVL_GRD_ID,
    "TXT".SU_TXT_SU_ID,
    "TXT".Metadata_SU_TXT,
    "TXT".SU_TXT_ChangedAt,
    "TXT".SU_TXT_Subject_Text,
    "ASR".SU_ASR_SU_ID,
    "ASR".Metadata_SU_ASR,
    "ASR".SU_ASR_ChangedAt,
    "ASR".SU_ASR_Subject_Assessment,
    "ERS".SU_ERS_SU_ID,
    "ERS".Metadata_SU_ERS,
    CAST(NULL AS number(1)),
    "ERS".SU_ERS_ChangedAt,
    "ERS".SU_ERS_Subject_Erasable
FROM
    SU_Subject "SU"
LEFT JOIN
    SU_NAM_Subject_Name "NAM"
ON
    "NAM".SU_NAM_SU_ID = "SU".SU_ID
LEFT JOIN
    SU_COD_Subject_Code "COD"
ON
    "COD".SU_COD_SU_ID = "SU".SU_ID
LEFT JOIN
    SU_GRD_Subject_Grade "GRD"
ON
    "GRD".SU_GRD_SU_ID = "SU".SU_ID
LEFT JOIN
    GRD_Grade "kGRD"
ON
    "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
LEFT JOIN
    SU_NOT_Subject_Note "NOT"
ON
    "NOT".SU_NOT_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_TTL_Subject_Title a
        WHERE
            a.SU_TTL_ChangedAt = (
                SELECT
                    MAX(sub.SU_TTL_ChangedAt)
                FROM
                    SU_TTL_Subject_Title sub
                WHERE
                    sub.SU_TTL_SU_ID = a.SU_TTL_SU_ID
            )
    ) "TTL"
ON
    "TTL".SU_TTL_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_STA_Subject_State a
        WHERE
            a.SU_STA_ChangedAt = (
                SELECT
                    MAX(sub.SU_STA_ChangedAt)
                FROM
                    SU_STA_Subject_State sub
                WHERE
                    sub.SU_STA_SU_ID = a.SU_STA_SU_ID
            )
    ) "STA"
ON
    "STA".SU_STA_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_LBL_Subject_Label a
        WHERE
            a.SU_LBL_ChangedAt = (
                SELECT
                    MAX(sub.SU_LBL_ChangedAt)
                FROM
                    SU_LBL_Subject_Label sub
                WHERE
                    sub.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            )
    ) "LBL"
ON
    "LBL".SU_LBL_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_TAG_Subject_Tag a
        WHERE
            a.SU_TAG_ChangedAt = (
                SELECT
                    MAX(sub.SU_TAG_ChangedAt)
                FROM
                    SU_TAG_Subject_Tag sub
                WHERE
                    sub.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            )
    ) "TAG"
ON
    "TAG".SU_TAG_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_LVL_Subject_Level a
        WHERE
            a.SU_LVL_ChangedAt = (
                SELECT
                    MAX(sub.SU_LVL_ChangedAt)
                FROM
                    SU_LVL_Subject_Level sub
                WHERE
                    sub.SU_LVL_SU_ID = a.SU_LVL_SU_ID
            )
    ) "LVL"
ON
    "LVL".SU_LVL_SU_ID = "SU".SU_ID
LEFT JOIN
    GRD_Grade "kLVL"
ON
    "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_TXT_Subject_Text a
        WHERE
            a.SU_TXT_ChangedAt = (
                SELECT
                    MAX(sub.SU_TXT_ChangedAt)
                FROM
                    SU_TXT_Subject_Text sub
                WHERE
                    sub.SU_TXT_SU_ID = a.SU_TXT_SU_ID
            )
    ) "TXT"
ON
    "TXT".SU_TXT_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_ASR_Subject_Assessment a
        WHERE
            a.SU_ASR_ChangedAt = (
                SELECT
                    MAX(sub.SU_ASR_ChangedAt)
                FROM
                    SU_ASR_Subject_Assessment sub
                WHERE
                    sub.SU_ASR_SU_ID = a.SU_ASR_SU_ID
            )
    ) "ASR"
ON
    "ASR".SU_ASR_SU_ID = "SU".SU_ID
LEFT JOIN
    (
        SELECT
            a.*
        FROM
            SU_ERS_Subject_Erasable a
        WHERE
            a.SU_ERS_ChangedAt = (
                SELECT
                    MAX(sub.SU_ERS_ChangedAt)
                FROM
                    SU_ERS_Subject_Erasable sub
                WHERE
                    sub.SU_ERS_SU_ID = a.SU_ERS_SU_ID
            )
    ) "ERS"
ON
    "ERS".SU_ERS_SU_ID = "SU".SU_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_Subject (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ChangedAt,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        LEFT JOIN
            SU_NAM_Subject_Name "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_COD_Subject_Code "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_GRD_Subject_Grade "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN
            SU_NOT_Subject_Note "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_TTL_Subject_Title a
                WHERE
                    a.SU_TTL_ChangedAt = (
                        SELECT
                            MAX(sub.SU_TTL_ChangedAt)
                        FROM
                            SU_TTL_Subject_Title sub
                        WHERE
                            sub.SU_TTL_SU_ID = a.SU_TTL_SU_ID
                        AND
                            sub.SU_TTL_ChangedAt <= changingTimepoint
                    )
            ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_STA_Subject_State a
                WHERE
                    a.SU_STA_ChangedAt = (
                        SELECT
                            MAX(sub.SU_STA_ChangedAt)
                        FROM
                            SU_STA_Subject_State sub
                        WHERE
                            sub.SU_STA_SU_ID = a.SU_STA_SU_ID
                        AND
                            sub.SU_STA_ChangedAt <= changingTimepoint
                    )
            ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_LBL_Subject_Label a
                WHERE
                    a.SU_LBL_ChangedAt = (
                        SELECT
                            MAX(sub.SU_LBL_ChangedAt)
                        FROM
                            SU_LBL_Subject_Label sub
                        WHERE
                            sub.SU_LBL_SU_ID = a.SU_LBL_SU_ID
                        AND
                            sub.SU_LBL_ChangedAt <= changingTimepoint
                    )
            ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_TAG_Subject_Tag a
                WHERE
                    a.SU_TAG_ChangedAt = (
                        SELECT
                            MAX(sub.SU_TAG_ChangedAt)
                        FROM
                            SU_TAG_Subject_Tag sub
                        WHERE
                            sub.SU_TAG_SU_ID = a.SU_TAG_SU_ID
                        AND
                            sub.SU_TAG_ChangedAt <= changingTimepoint
                    )
            ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_LVL_Subject_Level a
                WHERE
                    a.SU_LVL_ChangedAt = (
                        SELECT
                            MAX(sub.SU_LVL_ChangedAt)
                        FROM
                            SU_LVL_Subject_Level sub
                        WHERE
                            sub.SU_LVL_SU_ID = a.SU_LVL_SU_ID
                        AND
                            sub.SU_LVL_ChangedAt <= changingTimepoint
                    )
            ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_TXT_Subject_Text a
                WHERE
                    a.SU_TXT_ChangedAt = (
                        SELECT
                            MAX(sub.SU_TXT_ChangedAt)
                        FROM
                            SU_TXT_Subject_Text sub
                        WHERE
                            sub.SU_TXT_SU_ID = a.SU_TXT_SU_ID
                        AND
                            sub.SU_TXT_ChangedAt <= changingTimepoint
                    )
            ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_ASR_Subject_Assessment a
                WHERE
                    a.SU_ASR_ChangedAt = (
                        SELECT
                            MAX(sub.SU_ASR_ChangedAt)
                        FROM
                            SU_ASR_Subject_Assessment sub
                        WHERE
                            sub.SU_ASR_SU_ID = a.SU_ASR_SU_ID
                        AND
                            sub.SU_ASR_ChangedAt <= changingTimepoint
                    )
            ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        LEFT JOIN
            (
                SELECT
                    a.*
                FROM
                    SU_ERS_Subject_Erasable a
                WHERE
                    a.SU_ERS_ChangedAt = (
                        SELECT
                            MAX(sub.SU_ERS_ChangedAt)
                        FROM
                            SU_ERS_Subject_Erasable sub
                        WHERE
                            sub.SU_ERS_SU_ID = a.SU_ERS_SU_ID
                        AND
                            sub.SU_ERS_ChangedAt <= changingTimepoint
                    )
            ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
    ]';
END pSU_Subject;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nSU_Subject
AS
SELECT
    *
FROM
    pSU_Subject(CAST(current_timestamp AS timestamp))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with the values in effect then, for the attributes whose mnemonics the selection holds
-- (all of them if it is null). Every value is joined with the time until which it holds, which is when the next one does.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dSU_Subject (
    intervalStart IN timestamp,
    intervalEnd IN timestamp,
    selection IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            timepoints.inspectedTimepoint,
            timepoints.mnemonic,
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ChangedAt,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_Subject_Erasable
        FROM (
            SELECT DISTINCT
                h.SU_TTL_SU_ID AS SU_ID,
                CAST(h.SU_TTL_ChangedAt AS timestamp) AS inspectedTimepoint,
                'TTL' AS mnemonic
            FROM
                SU_TTL_Subject_Title h
            WHERE
                (selection IS NULL OR selection LIKE '%TTL%')
            AND
                h.SU_TTL_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_STA_SU_ID AS SU_ID,
                CAST(h.SU_STA_ChangedAt AS timestamp) AS inspectedTimepoint,
                'STA' AS mnemonic
            FROM
                SU_STA_Subject_State h
            WHERE
                (selection IS NULL OR selection LIKE '%STA%')
            AND
                h.SU_STA_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_LBL_SU_ID AS SU_ID,
                CAST(h.SU_LBL_ChangedAt AS timestamp) AS inspectedTimepoint,
                'LBL' AS mnemonic
            FROM
                SU_LBL_Subject_Label h
            WHERE
                (selection IS NULL OR selection LIKE '%LBL%')
            AND
                h.SU_LBL_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_TAG_SU_ID AS SU_ID,
                CAST(h.SU_TAG_ChangedAt AS timestamp) AS inspectedTimepoint,
                'TAG' AS mnemonic
            FROM
                SU_TAG_Subject_Tag h
            WHERE
                (selection IS NULL OR selection LIKE '%TAG%')
            AND
                h.SU_TAG_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_LVL_SU_ID AS SU_ID,
                CAST(h.SU_LVL_ChangedAt AS timestamp) AS inspectedTimepoint,
                'LVL' AS mnemonic
            FROM
                SU_LVL_Subject_Level h
            WHERE
                (selection IS NULL OR selection LIKE '%LVL%')
            AND
                h.SU_LVL_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_TXT_SU_ID AS SU_ID,
                CAST(h.SU_TXT_ChangedAt AS timestamp) AS inspectedTimepoint,
                'TXT' AS mnemonic
            FROM
                SU_TXT_Subject_Text h
            WHERE
                (selection IS NULL OR selection LIKE '%TXT%')
            AND
                h.SU_TXT_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_ASR_SU_ID AS SU_ID,
                CAST(h.SU_ASR_ChangedAt AS timestamp) AS inspectedTimepoint,
                'ASR' AS mnemonic
            FROM
                SU_ASR_Subject_Assessment h
            WHERE
                (selection IS NULL OR selection LIKE '%ASR%')
            AND
                h.SU_ASR_ChangedAt BETWEEN intervalStart AND intervalEnd
            UNION
            SELECT DISTINCT
                h.SU_ERS_SU_ID AS SU_ID,
                CAST(h.SU_ERS_ChangedAt AS timestamp) AS inspectedTimepoint,
                'ERS' AS mnemonic
            FROM
                SU_ERS_Subject_Erasable h
            WHERE
                (selection IS NULL OR selection LIKE '%ERS%')
            AND
                h.SU_ERS_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) timepoints
        JOIN
            SU_Subject "SU"
        ON
            "SU".SU_ID = timepoints.SU_ID
        LEFT JOIN
            SU_NAM_Subject_Name "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_COD_Subject_Code "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN
            SU_GRD_Subject_Grade "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN
            SU_NOT_Subject_Note "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_TTL_ChangedAt) OVER (
                    PARTITION BY h.SU_TTL_SU_ID
                    ORDER BY h.SU_TTL_ChangedAt
                ) AS untilTime
            FROM
                SU_TTL_Subject_Title h
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        AND
            "TTL".SU_TTL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TTL".untilTime IS NULL
        OR
            "TTL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_STA_ChangedAt) OVER (
                    PARTITION BY h.SU_STA_SU_ID
                    ORDER BY h.SU_STA_ChangedAt
                ) AS untilTime
            FROM
                SU_STA_Subject_State h
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        AND
            "STA".SU_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_LBL_ChangedAt) OVER (
                    PARTITION BY h.SU_LBL_SU_ID
                    ORDER BY h.SU_LBL_ChangedAt
                ) AS untilTime
            FROM
                SU_LBL_Subject_Label h
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        AND
            "LBL".SU_LBL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "LBL".untilTime IS NULL
        OR
            "LBL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_TAG_ChangedAt) OVER (
                    PARTITION BY h.SU_TAG_SU_ID
                    ORDER BY h.SU_TAG_ChangedAt
                ) AS untilTime
            FROM
                SU_TAG_Subject_Tag h
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        AND
            "TAG".SU_TAG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TAG".untilTime IS NULL
        OR
            "TAG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_LVL_ChangedAt) OVER (
                    PARTITION BY h.SU_LVL_SU_ID
                    ORDER BY h.SU_LVL_ChangedAt
                ) AS untilTime
            FROM
                SU_LVL_Subject_Level h
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        AND
            "LVL".SU_LVL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "LVL".untilTime IS NULL
        OR
            "LVL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_TXT_ChangedAt) OVER (
                    PARTITION BY h.SU_TXT_SU_ID
                    ORDER BY h.SU_TXT_ChangedAt
                ) AS untilTime
            FROM
                SU_TXT_Subject_Text h
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        AND
            "TXT".SU_TXT_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TXT".untilTime IS NULL
        OR
            "TXT".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_ASR_ChangedAt) OVER (
                    PARTITION BY h.SU_ASR_SU_ID
                    ORDER BY h.SU_ASR_ChangedAt
                ) AS untilTime
            FROM
                SU_ASR_Subject_Assessment h
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        AND
            "ASR".SU_ASR_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "ASR".untilTime IS NULL
        OR
            "ASR".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                h.*,
                LEAD(h.SU_ERS_ChangedAt) OVER (
                    PARTITION BY h.SU_ERS_SU_ID
                    ORDER BY h.SU_ERS_ChangedAt
                ) AS untilTime
            FROM
                SU_ERS_Subject_Erasable h
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
        AND
            "ERS".SU_ERS_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "ERS".untilTime IS NULL
        OR
            "ERS".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
    ]';
END dSU_Subject;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_Object (
    OB_ID,
    Metadata_OB,
    OB_NAM_OB_ID,
    Metadata_OB_NAM,
    OB_NAM_Object_Name
)
AS
SELECT
    "OB".OB_ID,
    "OB".Metadata_OB,
    "NAM".OB_NAM_OB_ID,
    "NAM".Metadata_OB_NAM,
    "NAM".OB_NAM_Object_Name
FROM
    OB_Object "OB"
LEFT JOIN
    OB_NAM_Object_Name "NAM"
ON
    "NAM".OB_NAM_OB_ID = "OB".OB_ID
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_Object (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            "OB".OB_ID,
            "OB".Metadata_OB,
            "NAM".OB_NAM_OB_ID,
            "NAM".Metadata_OB_NAM,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        LEFT JOIN
            OB_NAM_Object_Name "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
    ]';
END pOB_Object;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_Object
AS
SELECT
    *
FROM
    pOB_Object(CAST(current_timestamp AS timestamp))
;
