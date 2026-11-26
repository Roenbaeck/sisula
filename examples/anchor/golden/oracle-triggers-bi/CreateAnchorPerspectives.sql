-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM tAC_Actor(TIMESTAMP '9999-12-31 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time up to the positing timepoint picked for each posit.
-- A posit is shown when that annex says that it is asserted (a reliability of 1), and for each anchor the latest asserted
-- posit at the latest changing time is the one that is shown.
--
-- The latest and now perspectives are views over the point-in-time macro, which is the time traveling perspective with the
-- positing time set to End of Time, and as the macros are not nested the point-in-time macro works out the posits itself.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_Subject (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Reliability,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Reliability,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NAM_SU_ID
                        ORDER BY
                            r.SU_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NAM,
                        po.SU_NAM_ID,
                        an.SU_NAM_PositedAt,
                        an.SU_NAM_Reliability,
                        po.SU_NAM_SU_ID,
                        po.SU_NAM_Subject_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NAM_ID
                            ORDER BY an.SU_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NAM_Subject_Name_Posit po
                    JOIN
                        SU_NAM_Subject_Name_Annex an
                    ON
                        an.SU_NAM_ID = po.SU_NAM_ID
                    WHERE
                        an.SU_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_SU_ID
                        ORDER BY
                            r.SU_COD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_COD,
                        po.SU_COD_ID,
                        an.SU_COD_PositedAt,
                        an.SU_COD_Reliability,
                        po.SU_COD_SU_ID,
                        po.SU_COD_Subject_Code,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_COD_ID
                            ORDER BY an.SU_COD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_COD_Subject_Code_Posit po
                    JOIN
                        SU_COD_Subject_Code_Annex an
                    ON
                        an.SU_COD_ID = po.SU_COD_ID
                    WHERE
                        an.SU_COD_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_SU_ID
                        ORDER BY
                            r.SU_GRD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_GRD,
                        po.SU_GRD_ID,
                        an.SU_GRD_PositedAt,
                        an.SU_GRD_Reliability,
                        po.SU_GRD_SU_ID,
                        po.SU_GRD_GRD_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_GRD_ID
                            ORDER BY an.SU_GRD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_GRD_Subject_Grade_Posit po
                    JOIN
                        SU_GRD_Subject_Grade_Annex an
                    ON
                        an.SU_GRD_ID = po.SU_GRD_ID
                    WHERE
                        an.SU_GRD_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NOT_SU_ID
                        ORDER BY
                            r.SU_NOT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NOT,
                        po.SU_NOT_ID,
                        an.SU_NOT_PositedAt,
                        an.SU_NOT_Reliability,
                        po.SU_NOT_SU_ID,
                        po.SU_NOT_Subject_Note,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NOT_ID
                            ORDER BY an.SU_NOT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NOT_Subject_Note_Posit po
                    JOIN
                        SU_NOT_Subject_Note_Annex an
                    ON
                        an.SU_NOT_ID = po.SU_NOT_ID
                    WHERE
                        an.SU_NOT_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TTL_SU_ID
                        ORDER BY
                            r.SU_TTL_ChangedAt DESC,
                            r.SU_TTL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TTL,
                        po.SU_TTL_ID,
                        an.SU_TTL_PositedAt,
                        an.SU_TTL_Reliability,
                        po.SU_TTL_SU_ID,
                        po.SU_TTL_Subject_Title,
                        po.SU_TTL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TTL_ID
                            ORDER BY an.SU_TTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TTL_Subject_Title_Posit po
                    JOIN
                        SU_TTL_Subject_Title_Annex an
                    ON
                        an.SU_TTL_ID = po.SU_TTL_ID
                    WHERE
                        po.SU_TTL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TTL_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TTL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_STA_SU_ID
                        ORDER BY
                            r.SU_STA_ChangedAt DESC,
                            r.SU_STA_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_STA,
                        po.SU_STA_ID,
                        an.SU_STA_PositedAt,
                        an.SU_STA_Reliability,
                        po.SU_STA_SU_ID,
                        po.SU_STA_Subject_State,
                        po.SU_STA_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_STA_ID
                            ORDER BY an.SU_STA_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_STA_Subject_State_Posit po
                    JOIN
                        SU_STA_Subject_State_Annex an
                    ON
                        an.SU_STA_ID = po.SU_STA_ID
                    WHERE
                        po.SU_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_STA_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_STA_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LBL_SU_ID
                        ORDER BY
                            r.SU_LBL_ChangedAt DESC,
                            r.SU_LBL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LBL,
                        po.SU_LBL_ID,
                        an.SU_LBL_PositedAt,
                        an.SU_LBL_Reliability,
                        po.SU_LBL_SU_ID,
                        po.SU_LBL_Subject_Label,
                        po.SU_LBL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LBL_ID
                            ORDER BY an.SU_LBL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LBL_Subject_Label_Posit po
                    JOIN
                        SU_LBL_Subject_Label_Annex an
                    ON
                        an.SU_LBL_ID = po.SU_LBL_ID
                    WHERE
                        po.SU_LBL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LBL_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LBL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TAG_SU_ID
                        ORDER BY
                            r.SU_TAG_ChangedAt DESC,
                            r.SU_TAG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TAG,
                        po.SU_TAG_ID,
                        an.SU_TAG_PositedAt,
                        an.SU_TAG_Reliability,
                        po.SU_TAG_SU_ID,
                        po.SU_TAG_Subject_Tag,
                        po.SU_TAG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TAG_ID
                            ORDER BY an.SU_TAG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TAG_Subject_Tag_Posit po
                    JOIN
                        SU_TAG_Subject_Tag_Annex an
                    ON
                        an.SU_TAG_ID = po.SU_TAG_ID
                    WHERE
                        po.SU_TAG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TAG_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TAG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LVL_SU_ID
                        ORDER BY
                            r.SU_LVL_ChangedAt DESC,
                            r.SU_LVL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LVL,
                        po.SU_LVL_ID,
                        an.SU_LVL_PositedAt,
                        an.SU_LVL_Reliability,
                        po.SU_LVL_SU_ID,
                        po.SU_LVL_GRD_ID,
                        po.SU_LVL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LVL_ID
                            ORDER BY an.SU_LVL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LVL_Subject_Level_Posit po
                    JOIN
                        SU_LVL_Subject_Level_Annex an
                    ON
                        an.SU_LVL_ID = po.SU_LVL_ID
                    WHERE
                        po.SU_LVL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LVL_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LVL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TXT_SU_ID
                        ORDER BY
                            r.SU_TXT_ChangedAt DESC,
                            r.SU_TXT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TXT,
                        po.SU_TXT_ID,
                        an.SU_TXT_PositedAt,
                        an.SU_TXT_Reliability,
                        po.SU_TXT_SU_ID,
                        po.SU_TXT_Subject_Text,
                        po.SU_TXT_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TXT_ID
                            ORDER BY an.SU_TXT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TXT_Subject_Text_Posit po
                    JOIN
                        SU_TXT_Subject_Text_Annex an
                    ON
                        an.SU_TXT_ID = po.SU_TXT_ID
                    WHERE
                        po.SU_TXT_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TXT_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TXT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ASR_SU_ID
                        ORDER BY
                            r.SU_ASR_ChangedAt DESC,
                            r.SU_ASR_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ASR,
                        po.SU_ASR_ID,
                        an.SU_ASR_PositedAt,
                        an.SU_ASR_Reliability,
                        po.SU_ASR_SU_ID,
                        po.SU_ASR_Subject_Assessment,
                        po.SU_ASR_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ASR_ID
                            ORDER BY an.SU_ASR_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ASR_Subject_Assessment_Posit po
                    JOIN
                        SU_ASR_Subject_Assessment_Annex an
                    ON
                        an.SU_ASR_ID = po.SU_ASR_ID
                    WHERE
                        po.SU_ASR_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ASR_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ASR_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ERS_SU_ID
                        ORDER BY
                            r.SU_ERS_ChangedAt DESC,
                            r.SU_ERS_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ERS,
                        po.SU_ERS_ID,
                        an.SU_ERS_PositedAt,
                        an.SU_ERS_Reliability,
                        po.SU_ERS_SU_ID,
                        po.SU_ERS_Subject_Erasable,
                        po.SU_ERS_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ERS_ID
                            ORDER BY an.SU_ERS_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ERS_Subject_Erasable_Posit po
                    JOIN
                        SU_ERS_Subject_Erasable_Annex an
                    ON
                        an.SU_ERS_ID = po.SU_ERS_ID
                    WHERE
                        po.SU_ERS_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ERS_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ERS_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
    ]';
END tSU_Subject;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_Subject (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Reliability,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Reliability,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NAM_SU_ID
                        ORDER BY
                            r.SU_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NAM,
                        po.SU_NAM_ID,
                        an.SU_NAM_PositedAt,
                        an.SU_NAM_Reliability,
                        po.SU_NAM_SU_ID,
                        po.SU_NAM_Subject_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NAM_ID
                            ORDER BY an.SU_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NAM_Subject_Name_Posit po
                    JOIN
                        SU_NAM_Subject_Name_Annex an
                    ON
                        an.SU_NAM_ID = po.SU_NAM_ID
                    WHERE
                        an.SU_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_SU_ID
                        ORDER BY
                            r.SU_COD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_COD,
                        po.SU_COD_ID,
                        an.SU_COD_PositedAt,
                        an.SU_COD_Reliability,
                        po.SU_COD_SU_ID,
                        po.SU_COD_Subject_Code,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_COD_ID
                            ORDER BY an.SU_COD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_COD_Subject_Code_Posit po
                    JOIN
                        SU_COD_Subject_Code_Annex an
                    ON
                        an.SU_COD_ID = po.SU_COD_ID
                    WHERE
                        an.SU_COD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_SU_ID
                        ORDER BY
                            r.SU_GRD_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_GRD,
                        po.SU_GRD_ID,
                        an.SU_GRD_PositedAt,
                        an.SU_GRD_Reliability,
                        po.SU_GRD_SU_ID,
                        po.SU_GRD_GRD_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_GRD_ID
                            ORDER BY an.SU_GRD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_GRD_Subject_Grade_Posit po
                    JOIN
                        SU_GRD_Subject_Grade_Annex an
                    ON
                        an.SU_GRD_ID = po.SU_GRD_ID
                    WHERE
                        an.SU_GRD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NOT_SU_ID
                        ORDER BY
                            r.SU_NOT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NOT,
                        po.SU_NOT_ID,
                        an.SU_NOT_PositedAt,
                        an.SU_NOT_Reliability,
                        po.SU_NOT_SU_ID,
                        po.SU_NOT_Subject_Note,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NOT_ID
                            ORDER BY an.SU_NOT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NOT_Subject_Note_Posit po
                    JOIN
                        SU_NOT_Subject_Note_Annex an
                    ON
                        an.SU_NOT_ID = po.SU_NOT_ID
                    WHERE
                        an.SU_NOT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TTL_SU_ID
                        ORDER BY
                            r.SU_TTL_ChangedAt DESC,
                            r.SU_TTL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TTL,
                        po.SU_TTL_ID,
                        an.SU_TTL_PositedAt,
                        an.SU_TTL_Reliability,
                        po.SU_TTL_SU_ID,
                        po.SU_TTL_Subject_Title,
                        po.SU_TTL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TTL_ID
                            ORDER BY an.SU_TTL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TTL_Subject_Title_Posit po
                    JOIN
                        SU_TTL_Subject_Title_Annex an
                    ON
                        an.SU_TTL_ID = po.SU_TTL_ID
                    WHERE
                        po.SU_TTL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TTL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_STA_SU_ID
                        ORDER BY
                            r.SU_STA_ChangedAt DESC,
                            r.SU_STA_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_STA,
                        po.SU_STA_ID,
                        an.SU_STA_PositedAt,
                        an.SU_STA_Reliability,
                        po.SU_STA_SU_ID,
                        po.SU_STA_Subject_State,
                        po.SU_STA_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_STA_ID
                            ORDER BY an.SU_STA_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_STA_Subject_State_Posit po
                    JOIN
                        SU_STA_Subject_State_Annex an
                    ON
                        an.SU_STA_ID = po.SU_STA_ID
                    WHERE
                        po.SU_STA_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_STA_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LBL_SU_ID
                        ORDER BY
                            r.SU_LBL_ChangedAt DESC,
                            r.SU_LBL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LBL,
                        po.SU_LBL_ID,
                        an.SU_LBL_PositedAt,
                        an.SU_LBL_Reliability,
                        po.SU_LBL_SU_ID,
                        po.SU_LBL_Subject_Label,
                        po.SU_LBL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LBL_ID
                            ORDER BY an.SU_LBL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LBL_Subject_Label_Posit po
                    JOIN
                        SU_LBL_Subject_Label_Annex an
                    ON
                        an.SU_LBL_ID = po.SU_LBL_ID
                    WHERE
                        po.SU_LBL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LBL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LBL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TAG_SU_ID
                        ORDER BY
                            r.SU_TAG_ChangedAt DESC,
                            r.SU_TAG_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TAG,
                        po.SU_TAG_ID,
                        an.SU_TAG_PositedAt,
                        an.SU_TAG_Reliability,
                        po.SU_TAG_SU_ID,
                        po.SU_TAG_Subject_Tag,
                        po.SU_TAG_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TAG_ID
                            ORDER BY an.SU_TAG_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TAG_Subject_Tag_Posit po
                    JOIN
                        SU_TAG_Subject_Tag_Annex an
                    ON
                        an.SU_TAG_ID = po.SU_TAG_ID
                    WHERE
                        po.SU_TAG_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TAG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TAG_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_LVL_SU_ID
                        ORDER BY
                            r.SU_LVL_ChangedAt DESC,
                            r.SU_LVL_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_LVL,
                        po.SU_LVL_ID,
                        an.SU_LVL_PositedAt,
                        an.SU_LVL_Reliability,
                        po.SU_LVL_SU_ID,
                        po.SU_LVL_GRD_ID,
                        po.SU_LVL_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_LVL_ID
                            ORDER BY an.SU_LVL_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_LVL_Subject_Level_Posit po
                    JOIN
                        SU_LVL_Subject_Level_Annex an
                    ON
                        an.SU_LVL_ID = po.SU_LVL_ID
                    WHERE
                        po.SU_LVL_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_LVL_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kLVL"
        ON
            "kLVL".GRD_ID = "LVL".SU_LVL_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_TXT_SU_ID
                        ORDER BY
                            r.SU_TXT_ChangedAt DESC,
                            r.SU_TXT_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_TXT,
                        po.SU_TXT_ID,
                        an.SU_TXT_PositedAt,
                        an.SU_TXT_Reliability,
                        po.SU_TXT_SU_ID,
                        po.SU_TXT_Subject_Text,
                        po.SU_TXT_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_TXT_ID
                            ORDER BY an.SU_TXT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_TXT_Subject_Text_Posit po
                    JOIN
                        SU_TXT_Subject_Text_Annex an
                    ON
                        an.SU_TXT_ID = po.SU_TXT_ID
                    WHERE
                        po.SU_TXT_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_TXT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_TXT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ASR_SU_ID
                        ORDER BY
                            r.SU_ASR_ChangedAt DESC,
                            r.SU_ASR_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ASR,
                        po.SU_ASR_ID,
                        an.SU_ASR_PositedAt,
                        an.SU_ASR_Reliability,
                        po.SU_ASR_SU_ID,
                        po.SU_ASR_Subject_Assessment,
                        po.SU_ASR_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ASR_ID
                            ORDER BY an.SU_ASR_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ASR_Subject_Assessment_Posit po
                    JOIN
                        SU_ASR_Subject_Assessment_Annex an
                    ON
                        an.SU_ASR_ID = po.SU_ASR_ID
                    WHERE
                        po.SU_ASR_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ASR_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ASR_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_ERS_SU_ID
                        ORDER BY
                            r.SU_ERS_ChangedAt DESC,
                            r.SU_ERS_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_ERS,
                        po.SU_ERS_ID,
                        an.SU_ERS_PositedAt,
                        an.SU_ERS_Reliability,
                        po.SU_ERS_SU_ID,
                        po.SU_ERS_Subject_Erasable,
                        po.SU_ERS_ChangedAt,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_ERS_ID
                            ORDER BY an.SU_ERS_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_ERS_Subject_Erasable_Posit po
                    JOIN
                        SU_ERS_Subject_Erasable_Annex an
                    ON
                        an.SU_ERS_ID = po.SU_ERS_ID
                    WHERE
                        po.SU_ERS_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.SU_ERS_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_ERS_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
    ]';
END pSU_Subject;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lSU_Subject
AS
SELECT
    *
FROM
    pSU_Subject(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The attributes whose
-- mnemonics the selection holds are the ones that are looked at (all of them if it is null).
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
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Reliability,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Reliability,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Reliability,
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
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NAM_SU_ID
                        ORDER BY r.SU_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_NAM,
                            po.SU_NAM_ID,
                            an.SU_NAM_PositedAt,
                            an.SU_NAM_Reliability,
                            po.SU_NAM_SU_ID,
                            po.SU_NAM_Subject_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NAM_ID
                                ORDER BY an.SU_NAM_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_NAM_Subject_Name_Posit po
                        JOIN
                            SU_NAM_Subject_Name_Annex an
                        ON
                            an.SU_NAM_ID = po.SU_NAM_ID
                        WHERE
                            an.SU_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_SU_ID
                        ORDER BY r.SU_COD_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_COD,
                            po.SU_COD_ID,
                            an.SU_COD_PositedAt,
                            an.SU_COD_Reliability,
                            po.SU_COD_SU_ID,
                            po.SU_COD_Subject_Code,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_COD_ID
                                ORDER BY an.SU_COD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_COD_Subject_Code_Posit po
                        JOIN
                            SU_COD_Subject_Code_Annex an
                        ON
                            an.SU_COD_ID = po.SU_COD_ID
                        WHERE
                            an.SU_COD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_SU_ID
                        ORDER BY r.SU_GRD_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_GRD,
                            po.SU_GRD_ID,
                            an.SU_GRD_PositedAt,
                            an.SU_GRD_Reliability,
                            po.SU_GRD_SU_ID,
                            po.SU_GRD_GRD_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_GRD_ID
                                ORDER BY an.SU_GRD_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_GRD_Subject_Grade_Posit po
                        JOIN
                            SU_GRD_Subject_Grade_Annex an
                        ON
                            an.SU_GRD_ID = po.SU_GRD_ID
                        WHERE
                            an.SU_GRD_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        LEFT JOIN
            GRD_Grade "kGRD"
        ON
            "kGRD".GRD_ID = "GRD".SU_GRD_GRD_ID
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_NOT_SU_ID
                        ORDER BY r.SU_NOT_PositedAt DESC
                    ) AS pickRank
                FROM (
                        SELECT
                            an.Metadata_SU_NOT,
                            po.SU_NOT_ID,
                            an.SU_NOT_PositedAt,
                            an.SU_NOT_Reliability,
                            po.SU_NOT_SU_ID,
                            po.SU_NOT_Subject_Note,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NOT_ID
                                ORDER BY an.SU_NOT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_NOT_Subject_Note_Posit po
                        JOIN
                            SU_NOT_Subject_Note_Annex an
                        ON
                            an.SU_NOT_ID = po.SU_NOT_ID
                        WHERE
                            an.SU_NOT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        LEFT JOIN (
            SELECT
                x.*,
                LEAD(x.SU_TTL_ChangedAt) OVER (
                    PARTITION BY x.SU_TTL_SU_ID
                    ORDER BY x.SU_TTL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TTL_SU_ID, r.SU_TTL_ChangedAt
                            ORDER BY r.SU_TTL_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TTL,
                            po.SU_TTL_ID,
                            an.SU_TTL_PositedAt,
                            an.SU_TTL_Reliability,
                            po.SU_TTL_SU_ID,
                            po.SU_TTL_Subject_Title,
                            po.SU_TTL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TTL_ID
                                ORDER BY an.SU_TTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TTL_Subject_Title_Posit po
                        JOIN
                            SU_TTL_Subject_Title_Annex an
                        ON
                            an.SU_TTL_ID = po.SU_TTL_ID
                        WHERE
                            po.SU_TTL_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_TTL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TTL_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_STA_ChangedAt) OVER (
                    PARTITION BY x.SU_STA_SU_ID
                    ORDER BY x.SU_STA_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_STA_SU_ID, r.SU_STA_ChangedAt
                            ORDER BY r.SU_STA_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_STA,
                            po.SU_STA_ID,
                            an.SU_STA_PositedAt,
                            an.SU_STA_Reliability,
                            po.SU_STA_SU_ID,
                            po.SU_STA_Subject_State,
                            po.SU_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_STA_ID
                                ORDER BY an.SU_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_STA_Subject_State_Posit po
                        JOIN
                            SU_STA_Subject_State_Annex an
                        ON
                            an.SU_STA_ID = po.SU_STA_ID
                        WHERE
                            po.SU_STA_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_STA_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_STA_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_LBL_ChangedAt) OVER (
                    PARTITION BY x.SU_LBL_SU_ID
                    ORDER BY x.SU_LBL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_LBL_SU_ID, r.SU_LBL_ChangedAt
                            ORDER BY r.SU_LBL_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_LBL,
                            po.SU_LBL_ID,
                            an.SU_LBL_PositedAt,
                            an.SU_LBL_Reliability,
                            po.SU_LBL_SU_ID,
                            po.SU_LBL_Subject_Label,
                            po.SU_LBL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LBL_ID
                                ORDER BY an.SU_LBL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_LBL_Subject_Label_Posit po
                        JOIN
                            SU_LBL_Subject_Label_Annex an
                        ON
                            an.SU_LBL_ID = po.SU_LBL_ID
                        WHERE
                            po.SU_LBL_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_LBL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_LBL_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_TAG_ChangedAt) OVER (
                    PARTITION BY x.SU_TAG_SU_ID
                    ORDER BY x.SU_TAG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TAG_SU_ID, r.SU_TAG_ChangedAt
                            ORDER BY r.SU_TAG_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TAG,
                            po.SU_TAG_ID,
                            an.SU_TAG_PositedAt,
                            an.SU_TAG_Reliability,
                            po.SU_TAG_SU_ID,
                            po.SU_TAG_Subject_Tag,
                            po.SU_TAG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TAG_ID
                                ORDER BY an.SU_TAG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TAG_Subject_Tag_Posit po
                        JOIN
                            SU_TAG_Subject_Tag_Annex an
                        ON
                            an.SU_TAG_ID = po.SU_TAG_ID
                        WHERE
                            po.SU_TAG_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_TAG_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TAG_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_LVL_ChangedAt) OVER (
                    PARTITION BY x.SU_LVL_SU_ID
                    ORDER BY x.SU_LVL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_LVL_SU_ID, r.SU_LVL_ChangedAt
                            ORDER BY r.SU_LVL_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_LVL,
                            po.SU_LVL_ID,
                            an.SU_LVL_PositedAt,
                            an.SU_LVL_Reliability,
                            po.SU_LVL_SU_ID,
                            po.SU_LVL_GRD_ID,
                            po.SU_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LVL_ID
                                ORDER BY an.SU_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_LVL_Subject_Level_Posit po
                        JOIN
                            SU_LVL_Subject_Level_Annex an
                        ON
                            an.SU_LVL_ID = po.SU_LVL_ID
                        WHERE
                            po.SU_LVL_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_LVL_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_LVL_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_TXT_ChangedAt) OVER (
                    PARTITION BY x.SU_TXT_SU_ID
                    ORDER BY x.SU_TXT_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TXT_SU_ID, r.SU_TXT_ChangedAt
                            ORDER BY r.SU_TXT_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TXT,
                            po.SU_TXT_ID,
                            an.SU_TXT_PositedAt,
                            an.SU_TXT_Reliability,
                            po.SU_TXT_SU_ID,
                            po.SU_TXT_Subject_Text,
                            po.SU_TXT_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TXT_ID
                                ORDER BY an.SU_TXT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TXT_Subject_Text_Posit po
                        JOIN
                            SU_TXT_Subject_Text_Annex an
                        ON
                            an.SU_TXT_ID = po.SU_TXT_ID
                        WHERE
                            po.SU_TXT_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_TXT_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TXT_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_ASR_ChangedAt) OVER (
                    PARTITION BY x.SU_ASR_SU_ID
                    ORDER BY x.SU_ASR_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_ASR_SU_ID, r.SU_ASR_ChangedAt
                            ORDER BY r.SU_ASR_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_ASR,
                            po.SU_ASR_ID,
                            an.SU_ASR_PositedAt,
                            an.SU_ASR_Reliability,
                            po.SU_ASR_SU_ID,
                            po.SU_ASR_Subject_Assessment,
                            po.SU_ASR_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ASR_ID
                                ORDER BY an.SU_ASR_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_ASR_Subject_Assessment_Posit po
                        JOIN
                            SU_ASR_Subject_Assessment_Annex an
                        ON
                            an.SU_ASR_ID = po.SU_ASR_ID
                        WHERE
                            po.SU_ASR_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_ASR_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_ASR_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
                x.*,
                LEAD(x.SU_ERS_ChangedAt) OVER (
                    PARTITION BY x.SU_ERS_SU_ID
                    ORDER BY x.SU_ERS_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_ERS_SU_ID, r.SU_ERS_ChangedAt
                            ORDER BY r.SU_ERS_PositedAt DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_ERS,
                            po.SU_ERS_ID,
                            an.SU_ERS_PositedAt,
                            an.SU_ERS_Reliability,
                            po.SU_ERS_SU_ID,
                            po.SU_ERS_Subject_Erasable,
                            po.SU_ERS_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ERS_ID
                                ORDER BY an.SU_ERS_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_ERS_Subject_Erasable_Posit po
                        JOIN
                            SU_ERS_Subject_Erasable_Annex an
                        ON
                            an.SU_ERS_ID = po.SU_ERS_ID
                        WHERE
                            po.SU_ERS_ChangedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                        AND
                            an.SU_ERS_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_ERS_Reliability = 1
                ) z
                WHERE
                    z.pickRank = 1
            ) x
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
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest asserted posit of each attribute, as known at the positing time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tOB_Object (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            "NAM".OB_NAM_ID,
            "NAM".OB_NAM_PositedAt,
            "NAM".OB_NAM_Reliability,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.OB_NAM_OB_ID
                        ORDER BY
                            r.OB_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_OB_NAM,
                        po.OB_NAM_ID,
                        an.OB_NAM_PositedAt,
                        an.OB_NAM_Reliability,
                        po.OB_NAM_OB_ID,
                        po.OB_NAM_Object_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.OB_NAM_ID
                            ORDER BY an.OB_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        OB_NAM_Object_Name_Posit po
                    JOIN
                        OB_NAM_Object_Name_Annex an
                    ON
                        an.OB_NAM_ID = po.OB_NAM_ID
                    WHERE
                        an.OB_NAM_PositedAt <= CAST(positingTimepoint AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.OB_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
    ]';
END tOB_Object;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What is known now (positing time End of Time) about the changing time, with a reliability that is null since a
-- perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_Object (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            CAST(NULL AS number(5,2)) AS Reliability,
            "OB".OB_ID,
            "OB".Metadata_OB,
            "NAM".OB_NAM_OB_ID,
            "NAM".Metadata_OB_NAM,
            "NAM".OB_NAM_ID,
            "NAM".OB_NAM_PositedAt,
            "NAM".OB_NAM_Reliability,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.OB_NAM_OB_ID
                        ORDER BY
                            r.OB_NAM_PositedAt DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_OB_NAM,
                        po.OB_NAM_ID,
                        an.OB_NAM_PositedAt,
                        an.OB_NAM_Reliability,
                        po.OB_NAM_OB_ID,
                        po.OB_NAM_Object_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.OB_NAM_ID
                            ORDER BY an.OB_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        OB_NAM_Object_Name_Posit po
                    JOIN
                        OB_NAM_Object_Name_Annex an
                    ON
                        an.OB_NAM_ID = po.OB_NAM_ID
                    WHERE
                        an.OB_NAM_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.OB_NAM_Reliability = 1
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
    ]';
END pOB_Object;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-- What is known now, at End of Time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lOB_Object
AS
SELECT
    *
FROM
    pOB_Object(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nOB_Object
AS
SELECT
    *
FROM
    pOB_Object(CAST(current_timestamp AS timestamp))
;
