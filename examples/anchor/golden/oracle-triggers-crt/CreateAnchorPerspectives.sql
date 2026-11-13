-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_Actor(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinders of the attributes are not called in the macros, what they do is written out in them: the posit and annex
-- of an attribute joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes: a mnemonic can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tSU_Subject (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
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
            "NAM".SU_NAM_Positor,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Assertion,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Positor,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Assertion,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Positor,
            "GRD".SU_GRD_Reliability,
            "GRD".SU_GRD_Assertion,
            "GRD".SU_GRD_GRD_Grade,
            "GRD".SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Positor,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Assertion,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Positor,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Assertion,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Positor,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Assertion,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Positor,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Assertion,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Positor,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Assertion,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Positor,
            "LVL".SU_LVL_Reliability,
            "LVL".SU_LVL_Assertion,
            "LVL".SU_LVL_GRD_Grade,
            "LVL".SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Positor,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Assertion,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Positor,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Assertion,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Positor,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Assertion,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        CROSS JOIN
            Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_NAM_Positor, x.SU_NAM_SU_ID
                        ORDER BY
                            x.SU_NAM_PositedAt DESC,
                            x.SU_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_NAM,
                            po.SU_NAM_ID,
                            an.SU_NAM_PositedAt,
                            an.SU_NAM_Positor,
                            an.SU_NAM_Reliability,
                            an.SU_NAM_Assertion,
                            po.SU_NAM_SU_ID,
                            po.SU_NAM_Subject_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NAM_ID, an.SU_NAM_Positor
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
                ) x
                WHERE
                    x.SU_NAM_Assertion = COALESCE(assertion, x.SU_NAM_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        AND
            "NAM".SU_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_COD_Positor, x.SU_COD_SU_ID
                        ORDER BY
                            x.SU_COD_PositedAt DESC,
                            x.SU_COD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_COD,
                            po.SU_COD_ID,
                            an.SU_COD_PositedAt,
                            an.SU_COD_Positor,
                            an.SU_COD_Reliability,
                            an.SU_COD_Assertion,
                            po.SU_COD_SU_ID,
                            po.SU_COD_Subject_Code,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_COD_ID, an.SU_COD_Positor
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
                ) x
                WHERE
                    x.SU_COD_Assertion = COALESCE(assertion, x.SU_COD_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        AND
            "COD".SU_COD_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_GRD AS SU_GRD_Metadata_GRD,
                k.GRD_Grade AS SU_GRD_GRD_Grade
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_GRD_Positor, x.SU_GRD_SU_ID
                        ORDER BY
                            x.SU_GRD_PositedAt DESC,
                            x.SU_GRD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_GRD,
                            po.SU_GRD_ID,
                            an.SU_GRD_PositedAt,
                            an.SU_GRD_Positor,
                            an.SU_GRD_Reliability,
                            an.SU_GRD_Assertion,
                            po.SU_GRD_SU_ID,
                            po.SU_GRD_GRD_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_GRD_ID, an.SU_GRD_Positor
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
                ) x
                WHERE
                    x.SU_GRD_Assertion = COALESCE(assertion, x.SU_GRD_Assertion)
            ) y
            LEFT JOIN
                GRD_Grade k
            ON
                k.GRD_ID = y.SU_GRD_GRD_ID
            WHERE
                y.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        AND
            "GRD".SU_GRD_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_NOT_Positor, x.SU_NOT_SU_ID
                        ORDER BY
                            x.SU_NOT_PositedAt DESC,
                            x.SU_NOT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_NOT,
                            po.SU_NOT_ID,
                            an.SU_NOT_PositedAt,
                            an.SU_NOT_Positor,
                            an.SU_NOT_Reliability,
                            an.SU_NOT_Assertion,
                            po.SU_NOT_SU_ID,
                            po.SU_NOT_Subject_Note,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NOT_ID, an.SU_NOT_Positor
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
                ) x
                WHERE
                    x.SU_NOT_Assertion = COALESCE(assertion, x.SU_NOT_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        AND
            "NOT".SU_NOT_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_TTL_Positor, x.SU_TTL_SU_ID
                        ORDER BY
                            x.SU_TTL_ChangedAt DESC,
                            x.SU_TTL_PositedAt DESC,
                            x.SU_TTL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_TTL_Assertion <> '?' THEN r.SU_TTL_ChangedAt END) OVER (
                            PARTITION BY r.SU_TTL_Positor, r.SU_TTL_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_TTL,
                            po.SU_TTL_ID,
                            an.SU_TTL_PositedAt,
                            an.SU_TTL_Positor,
                            an.SU_TTL_Reliability,
                            an.SU_TTL_Assertion,
                            po.SU_TTL_SU_ID,
                            po.SU_TTL_Subject_Title,
                            po.SU_TTL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TTL_ID, an.SU_TTL_Positor
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
                ) x
                WHERE
                    x.SU_TTL_Assertion = COALESCE(assertion, x.SU_TTL_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_TTL_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        AND
            "TTL".SU_TTL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_STA_Positor, x.SU_STA_SU_ID
                        ORDER BY
                            x.SU_STA_ChangedAt DESC,
                            x.SU_STA_PositedAt DESC,
                            x.SU_STA_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_STA_Assertion <> '?' THEN r.SU_STA_ChangedAt END) OVER (
                            PARTITION BY r.SU_STA_Positor, r.SU_STA_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_STA,
                            po.SU_STA_ID,
                            an.SU_STA_PositedAt,
                            an.SU_STA_Positor,
                            an.SU_STA_Reliability,
                            an.SU_STA_Assertion,
                            po.SU_STA_SU_ID,
                            po.SU_STA_Subject_State,
                            po.SU_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_STA_ID, an.SU_STA_Positor
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
                ) x
                WHERE
                    x.SU_STA_Assertion = COALESCE(assertion, x.SU_STA_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_STA_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        AND
            "STA".SU_STA_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_LBL_Positor, x.SU_LBL_SU_ID
                        ORDER BY
                            x.SU_LBL_ChangedAt DESC,
                            x.SU_LBL_PositedAt DESC,
                            x.SU_LBL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_LBL_Assertion <> '?' THEN r.SU_LBL_ChangedAt END) OVER (
                            PARTITION BY r.SU_LBL_Positor, r.SU_LBL_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_LBL,
                            po.SU_LBL_ID,
                            an.SU_LBL_PositedAt,
                            an.SU_LBL_Positor,
                            an.SU_LBL_Reliability,
                            an.SU_LBL_Assertion,
                            po.SU_LBL_SU_ID,
                            po.SU_LBL_Subject_Label,
                            po.SU_LBL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LBL_ID, an.SU_LBL_Positor
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
                ) x
                WHERE
                    x.SU_LBL_Assertion = COALESCE(assertion, x.SU_LBL_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_LBL_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        AND
            "LBL".SU_LBL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_TAG_Positor, x.SU_TAG_SU_ID
                        ORDER BY
                            x.SU_TAG_ChangedAt DESC,
                            x.SU_TAG_PositedAt DESC,
                            x.SU_TAG_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_TAG_Assertion <> '?' THEN r.SU_TAG_ChangedAt END) OVER (
                            PARTITION BY r.SU_TAG_Positor, r.SU_TAG_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_TAG,
                            po.SU_TAG_ID,
                            an.SU_TAG_PositedAt,
                            an.SU_TAG_Positor,
                            an.SU_TAG_Reliability,
                            an.SU_TAG_Assertion,
                            po.SU_TAG_SU_ID,
                            po.SU_TAG_Subject_Tag,
                            po.SU_TAG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TAG_ID, an.SU_TAG_Positor
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
                ) x
                WHERE
                    x.SU_TAG_Assertion = COALESCE(assertion, x.SU_TAG_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_TAG_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        AND
            "TAG".SU_TAG_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_GRD AS SU_LVL_Metadata_GRD,
                k.GRD_Grade AS SU_LVL_GRD_Grade
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_LVL_Positor, x.SU_LVL_SU_ID
                        ORDER BY
                            x.SU_LVL_ChangedAt DESC,
                            x.SU_LVL_PositedAt DESC,
                            x.SU_LVL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_LVL_Assertion <> '?' THEN r.SU_LVL_ChangedAt END) OVER (
                            PARTITION BY r.SU_LVL_Positor, r.SU_LVL_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_LVL,
                            po.SU_LVL_ID,
                            an.SU_LVL_PositedAt,
                            an.SU_LVL_Positor,
                            an.SU_LVL_Reliability,
                            an.SU_LVL_Assertion,
                            po.SU_LVL_SU_ID,
                            po.SU_LVL_GRD_ID,
                            po.SU_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LVL_ID, an.SU_LVL_Positor
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
                ) x
                WHERE
                    x.SU_LVL_Assertion = COALESCE(assertion, x.SU_LVL_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_LVL_ChangedAt = x.inEffect
                )
            ) y
            LEFT JOIN
                GRD_Grade k
            ON
                k.GRD_ID = y.SU_LVL_GRD_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        AND
            "LVL".SU_LVL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_TXT_Positor, x.SU_TXT_SU_ID
                        ORDER BY
                            x.SU_TXT_ChangedAt DESC,
                            x.SU_TXT_PositedAt DESC,
                            x.SU_TXT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_TXT_Assertion <> '?' THEN r.SU_TXT_ChangedAt END) OVER (
                            PARTITION BY r.SU_TXT_Positor, r.SU_TXT_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_TXT,
                            po.SU_TXT_ID,
                            an.SU_TXT_PositedAt,
                            an.SU_TXT_Positor,
                            an.SU_TXT_Reliability,
                            an.SU_TXT_Assertion,
                            po.SU_TXT_SU_ID,
                            po.SU_TXT_Subject_Text,
                            po.SU_TXT_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TXT_ID, an.SU_TXT_Positor
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
                ) x
                WHERE
                    x.SU_TXT_Assertion = COALESCE(assertion, x.SU_TXT_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_TXT_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        AND
            "TXT".SU_TXT_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_ASR_Positor, x.SU_ASR_SU_ID
                        ORDER BY
                            x.SU_ASR_ChangedAt DESC,
                            x.SU_ASR_PositedAt DESC,
                            x.SU_ASR_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_ASR_Assertion <> '?' THEN r.SU_ASR_ChangedAt END) OVER (
                            PARTITION BY r.SU_ASR_Positor, r.SU_ASR_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_ASR,
                            po.SU_ASR_ID,
                            an.SU_ASR_PositedAt,
                            an.SU_ASR_Positor,
                            an.SU_ASR_Reliability,
                            an.SU_ASR_Assertion,
                            po.SU_ASR_SU_ID,
                            po.SU_ASR_Subject_Assessment,
                            po.SU_ASR_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ASR_ID, an.SU_ASR_Positor
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
                ) x
                WHERE
                    x.SU_ASR_Assertion = COALESCE(assertion, x.SU_ASR_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_ASR_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        AND
            "ASR".SU_ASR_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_ERS_Positor, x.SU_ERS_SU_ID
                        ORDER BY
                            x.SU_ERS_ChangedAt DESC,
                            x.SU_ERS_PositedAt DESC,
                            x.SU_ERS_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_ERS_Assertion <> '?' THEN r.SU_ERS_ChangedAt END) OVER (
                            PARTITION BY r.SU_ERS_Positor, r.SU_ERS_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_ERS,
                            po.SU_ERS_ID,
                            an.SU_ERS_PositedAt,
                            an.SU_ERS_Positor,
                            an.SU_ERS_Reliability,
                            an.SU_ERS_Assertion,
                            po.SU_ERS_SU_ID,
                            po.SU_ERS_Subject_Erasable,
                            po.SU_ERS_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ERS_ID, an.SU_ERS_Positor
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
                ) x
                WHERE
                    x.SU_ERS_Assertion = COALESCE(assertion, x.SU_ERS_Assertion)
                AND (
                    COALESCE(assertion, '?') = '?'
                OR
                    x.SU_ERS_ChangedAt = x.inEffect
                )
            ) y
            WHERE
                y.pickRank = 1
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
        AND
            "ERS".SU_ERS_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tSU_Subject;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pSU_Subject (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Positor,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Assertion,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Positor,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Assertion,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Positor,
            "GRD".SU_GRD_Reliability,
            "GRD".SU_GRD_Assertion,
            "GRD".SU_GRD_GRD_Grade,
            "GRD".SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Positor,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Assertion,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Positor,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Assertion,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Positor,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Assertion,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Positor,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Assertion,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Positor,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Assertion,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Positor,
            "LVL".SU_LVL_Reliability,
            "LVL".SU_LVL_Assertion,
            "LVL".SU_LVL_GRD_Grade,
            "LVL".SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Positor,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Assertion,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Positor,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Assertion,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Positor,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Assertion,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            SU_Subject "SU"
        CROSS JOIN
            Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_NAM_Positor, x.SU_NAM_SU_ID
                        ORDER BY
                            x.SU_NAM_PositedAt DESC,
                            x.SU_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_NAM,
                            po.SU_NAM_ID,
                            an.SU_NAM_PositedAt,
                            an.SU_NAM_Positor,
                            an.SU_NAM_Reliability,
                            an.SU_NAM_Assertion,
                            po.SU_NAM_SU_ID,
                            po.SU_NAM_Subject_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NAM_ID, an.SU_NAM_Positor
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
                ) x
                WHERE
                    x.SU_NAM_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        AND
            "NAM".SU_NAM_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_COD_Positor, x.SU_COD_SU_ID
                        ORDER BY
                            x.SU_COD_PositedAt DESC,
                            x.SU_COD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_COD,
                            po.SU_COD_ID,
                            an.SU_COD_PositedAt,
                            an.SU_COD_Positor,
                            an.SU_COD_Reliability,
                            an.SU_COD_Assertion,
                            po.SU_COD_SU_ID,
                            po.SU_COD_Subject_Code,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_COD_ID, an.SU_COD_Positor
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
                ) x
                WHERE
                    x.SU_COD_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        AND
            "COD".SU_COD_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_GRD AS SU_GRD_Metadata_GRD,
                k.GRD_Grade AS SU_GRD_GRD_Grade
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_GRD_Positor, x.SU_GRD_SU_ID
                        ORDER BY
                            x.SU_GRD_PositedAt DESC,
                            x.SU_GRD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_GRD,
                            po.SU_GRD_ID,
                            an.SU_GRD_PositedAt,
                            an.SU_GRD_Positor,
                            an.SU_GRD_Reliability,
                            an.SU_GRD_Assertion,
                            po.SU_GRD_SU_ID,
                            po.SU_GRD_GRD_ID,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_GRD_ID, an.SU_GRD_Positor
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
                ) x
                WHERE
                    x.SU_GRD_Assertion = '+'
            ) y
            LEFT JOIN
                GRD_Grade k
            ON
                k.GRD_ID = y.SU_GRD_GRD_ID
            WHERE
                y.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        AND
            "GRD".SU_GRD_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_NOT_Positor, x.SU_NOT_SU_ID
                        ORDER BY
                            x.SU_NOT_PositedAt DESC,
                            x.SU_NOT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_SU_NOT,
                            po.SU_NOT_ID,
                            an.SU_NOT_PositedAt,
                            an.SU_NOT_Positor,
                            an.SU_NOT_Reliability,
                            an.SU_NOT_Assertion,
                            po.SU_NOT_SU_ID,
                            po.SU_NOT_Subject_Note,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_NOT_ID, an.SU_NOT_Positor
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
                ) x
                WHERE
                    x.SU_NOT_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        AND
            "NOT".SU_NOT_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_TTL_Positor, x.SU_TTL_SU_ID
                        ORDER BY
                            x.SU_TTL_ChangedAt DESC,
                            x.SU_TTL_PositedAt DESC,
                            x.SU_TTL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_TTL_Assertion <> '?' THEN r.SU_TTL_ChangedAt END) OVER (
                            PARTITION BY r.SU_TTL_Positor, r.SU_TTL_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_TTL,
                            po.SU_TTL_ID,
                            an.SU_TTL_PositedAt,
                            an.SU_TTL_Positor,
                            an.SU_TTL_Reliability,
                            an.SU_TTL_Assertion,
                            po.SU_TTL_SU_ID,
                            po.SU_TTL_Subject_Title,
                            po.SU_TTL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TTL_ID, an.SU_TTL_Positor
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
                ) x
                WHERE
                    x.SU_TTL_Assertion = '+'
                AND
                    x.SU_TTL_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        AND
            "TTL".SU_TTL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_STA_Positor, x.SU_STA_SU_ID
                        ORDER BY
                            x.SU_STA_ChangedAt DESC,
                            x.SU_STA_PositedAt DESC,
                            x.SU_STA_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_STA_Assertion <> '?' THEN r.SU_STA_ChangedAt END) OVER (
                            PARTITION BY r.SU_STA_Positor, r.SU_STA_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_STA,
                            po.SU_STA_ID,
                            an.SU_STA_PositedAt,
                            an.SU_STA_Positor,
                            an.SU_STA_Reliability,
                            an.SU_STA_Assertion,
                            po.SU_STA_SU_ID,
                            po.SU_STA_Subject_State,
                            po.SU_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_STA_ID, an.SU_STA_Positor
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
                ) x
                WHERE
                    x.SU_STA_Assertion = '+'
                AND
                    x.SU_STA_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        AND
            "STA".SU_STA_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_LBL_Positor, x.SU_LBL_SU_ID
                        ORDER BY
                            x.SU_LBL_ChangedAt DESC,
                            x.SU_LBL_PositedAt DESC,
                            x.SU_LBL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_LBL_Assertion <> '?' THEN r.SU_LBL_ChangedAt END) OVER (
                            PARTITION BY r.SU_LBL_Positor, r.SU_LBL_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_LBL,
                            po.SU_LBL_ID,
                            an.SU_LBL_PositedAt,
                            an.SU_LBL_Positor,
                            an.SU_LBL_Reliability,
                            an.SU_LBL_Assertion,
                            po.SU_LBL_SU_ID,
                            po.SU_LBL_Subject_Label,
                            po.SU_LBL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LBL_ID, an.SU_LBL_Positor
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
                ) x
                WHERE
                    x.SU_LBL_Assertion = '+'
                AND
                    x.SU_LBL_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        AND
            "LBL".SU_LBL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_TAG_Positor, x.SU_TAG_SU_ID
                        ORDER BY
                            x.SU_TAG_ChangedAt DESC,
                            x.SU_TAG_PositedAt DESC,
                            x.SU_TAG_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_TAG_Assertion <> '?' THEN r.SU_TAG_ChangedAt END) OVER (
                            PARTITION BY r.SU_TAG_Positor, r.SU_TAG_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_TAG,
                            po.SU_TAG_ID,
                            an.SU_TAG_PositedAt,
                            an.SU_TAG_Positor,
                            an.SU_TAG_Reliability,
                            an.SU_TAG_Assertion,
                            po.SU_TAG_SU_ID,
                            po.SU_TAG_Subject_Tag,
                            po.SU_TAG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TAG_ID, an.SU_TAG_Positor
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
                ) x
                WHERE
                    x.SU_TAG_Assertion = '+'
                AND
                    x.SU_TAG_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        AND
            "TAG".SU_TAG_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*,
                k.Metadata_GRD AS SU_LVL_Metadata_GRD,
                k.GRD_Grade AS SU_LVL_GRD_Grade
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_LVL_Positor, x.SU_LVL_SU_ID
                        ORDER BY
                            x.SU_LVL_ChangedAt DESC,
                            x.SU_LVL_PositedAt DESC,
                            x.SU_LVL_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_LVL_Assertion <> '?' THEN r.SU_LVL_ChangedAt END) OVER (
                            PARTITION BY r.SU_LVL_Positor, r.SU_LVL_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_LVL,
                            po.SU_LVL_ID,
                            an.SU_LVL_PositedAt,
                            an.SU_LVL_Positor,
                            an.SU_LVL_Reliability,
                            an.SU_LVL_Assertion,
                            po.SU_LVL_SU_ID,
                            po.SU_LVL_GRD_ID,
                            po.SU_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LVL_ID, an.SU_LVL_Positor
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
                ) x
                WHERE
                    x.SU_LVL_Assertion = '+'
                AND
                    x.SU_LVL_ChangedAt = x.inEffect
            ) y
            LEFT JOIN
                GRD_Grade k
            ON
                k.GRD_ID = y.SU_LVL_GRD_ID
            WHERE
                y.pickRank = 1
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        AND
            "LVL".SU_LVL_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_TXT_Positor, x.SU_TXT_SU_ID
                        ORDER BY
                            x.SU_TXT_ChangedAt DESC,
                            x.SU_TXT_PositedAt DESC,
                            x.SU_TXT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_TXT_Assertion <> '?' THEN r.SU_TXT_ChangedAt END) OVER (
                            PARTITION BY r.SU_TXT_Positor, r.SU_TXT_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_TXT,
                            po.SU_TXT_ID,
                            an.SU_TXT_PositedAt,
                            an.SU_TXT_Positor,
                            an.SU_TXT_Reliability,
                            an.SU_TXT_Assertion,
                            po.SU_TXT_SU_ID,
                            po.SU_TXT_Subject_Text,
                            po.SU_TXT_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TXT_ID, an.SU_TXT_Positor
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
                ) x
                WHERE
                    x.SU_TXT_Assertion = '+'
                AND
                    x.SU_TXT_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        AND
            "TXT".SU_TXT_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_ASR_Positor, x.SU_ASR_SU_ID
                        ORDER BY
                            x.SU_ASR_ChangedAt DESC,
                            x.SU_ASR_PositedAt DESC,
                            x.SU_ASR_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_ASR_Assertion <> '?' THEN r.SU_ASR_ChangedAt END) OVER (
                            PARTITION BY r.SU_ASR_Positor, r.SU_ASR_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_ASR,
                            po.SU_ASR_ID,
                            an.SU_ASR_PositedAt,
                            an.SU_ASR_Positor,
                            an.SU_ASR_Reliability,
                            an.SU_ASR_Assertion,
                            po.SU_ASR_SU_ID,
                            po.SU_ASR_Subject_Assessment,
                            po.SU_ASR_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ASR_ID, an.SU_ASR_Positor
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
                ) x
                WHERE
                    x.SU_ASR_Assertion = '+'
                AND
                    x.SU_ASR_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        AND
            "ASR".SU_ASR_Positor = positorTable.Positor
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.SU_ERS_Positor, x.SU_ERS_SU_ID
                        ORDER BY
                            x.SU_ERS_ChangedAt DESC,
                            x.SU_ERS_PositedAt DESC,
                            x.SU_ERS_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*,
                        MAX(CASE WHEN r.SU_ERS_Assertion <> '?' THEN r.SU_ERS_ChangedAt END) OVER (
                            PARTITION BY r.SU_ERS_Positor, r.SU_ERS_SU_ID
                        ) AS inEffect
                    FROM (
                        SELECT
                            an.Metadata_SU_ERS,
                            po.SU_ERS_ID,
                            an.SU_ERS_PositedAt,
                            an.SU_ERS_Positor,
                            an.SU_ERS_Reliability,
                            an.SU_ERS_Assertion,
                            po.SU_ERS_SU_ID,
                            po.SU_ERS_Subject_Erasable,
                            po.SU_ERS_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ERS_ID, an.SU_ERS_Positor
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
                ) x
                WHERE
                    x.SU_ERS_Assertion = '+'
                AND
                    x.SU_ERS_ChangedAt = x.inEffect
            ) y
            WHERE
                y.pickRank = 1
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
        AND
            "ERS".SU_ERS_Positor = positorTable.Positor
    ]';
END pSU_Subject;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The attributes whose mnemonics the selection holds are
-- the ones that are looked at (all of them if it is null).
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
            positorTable.Positor,
            timepoints.inspectedTimepoint,
            "SU".SU_ID,
            "SU".Metadata_SU,
            "NAM".SU_NAM_SU_ID,
            "NAM".Metadata_SU_NAM,
            "NAM".SU_NAM_ID,
            "NAM".SU_NAM_PositedAt,
            "NAM".SU_NAM_Positor,
            "NAM".SU_NAM_Reliability,
            "NAM".SU_NAM_Assertion,
            "NAM".SU_NAM_Subject_Name,
            "COD".SU_COD_SU_ID,
            "COD".Metadata_SU_COD,
            "COD".SU_COD_ID,
            "COD".SU_COD_PositedAt,
            "COD".SU_COD_Positor,
            "COD".SU_COD_Reliability,
            "COD".SU_COD_Assertion,
            "COD".SU_COD_Subject_Code,
            "GRD".SU_GRD_SU_ID,
            "GRD".Metadata_SU_GRD,
            "GRD".SU_GRD_ID,
            "GRD".SU_GRD_PositedAt,
            "GRD".SU_GRD_Positor,
            "GRD".SU_GRD_Reliability,
            "GRD".SU_GRD_Assertion,
            "kGRD".GRD_Grade AS SU_GRD_GRD_Grade,
            "kGRD".Metadata_GRD AS SU_GRD_Metadata_GRD,
            "GRD".SU_GRD_GRD_ID,
            "NOT".SU_NOT_SU_ID,
            "NOT".Metadata_SU_NOT,
            "NOT".SU_NOT_ID,
            "NOT".SU_NOT_PositedAt,
            "NOT".SU_NOT_Positor,
            "NOT".SU_NOT_Reliability,
            "NOT".SU_NOT_Assertion,
            "NOT".SU_NOT_Subject_Note,
            "TTL".SU_TTL_SU_ID,
            "TTL".Metadata_SU_TTL,
            "TTL".SU_TTL_ID,
            "TTL".SU_TTL_ChangedAt,
            "TTL".SU_TTL_PositedAt,
            "TTL".SU_TTL_Positor,
            "TTL".SU_TTL_Reliability,
            "TTL".SU_TTL_Assertion,
            "TTL".SU_TTL_Subject_Title,
            "STA".SU_STA_SU_ID,
            "STA".Metadata_SU_STA,
            "STA".SU_STA_ID,
            "STA".SU_STA_ChangedAt,
            "STA".SU_STA_PositedAt,
            "STA".SU_STA_Positor,
            "STA".SU_STA_Reliability,
            "STA".SU_STA_Assertion,
            "STA".SU_STA_Subject_State,
            "LBL".SU_LBL_SU_ID,
            "LBL".Metadata_SU_LBL,
            "LBL".SU_LBL_ID,
            "LBL".SU_LBL_ChangedAt,
            "LBL".SU_LBL_PositedAt,
            "LBL".SU_LBL_Positor,
            "LBL".SU_LBL_Reliability,
            "LBL".SU_LBL_Assertion,
            "LBL".SU_LBL_Subject_Label,
            "TAG".SU_TAG_SU_ID,
            "TAG".Metadata_SU_TAG,
            "TAG".SU_TAG_ID,
            "TAG".SU_TAG_ChangedAt,
            "TAG".SU_TAG_PositedAt,
            "TAG".SU_TAG_Positor,
            "TAG".SU_TAG_Reliability,
            "TAG".SU_TAG_Assertion,
            "TAG".SU_TAG_Subject_Tag,
            "LVL".SU_LVL_SU_ID,
            "LVL".Metadata_SU_LVL,
            "LVL".SU_LVL_ID,
            "LVL".SU_LVL_ChangedAt,
            "LVL".SU_LVL_PositedAt,
            "LVL".SU_LVL_Positor,
            "LVL".SU_LVL_Reliability,
            "LVL".SU_LVL_Assertion,
            "kLVL".GRD_Grade AS SU_LVL_GRD_Grade,
            "kLVL".Metadata_GRD AS SU_LVL_Metadata_GRD,
            "LVL".SU_LVL_GRD_ID,
            "TXT".SU_TXT_SU_ID,
            "TXT".Metadata_SU_TXT,
            "TXT".SU_TXT_ID,
            "TXT".SU_TXT_ChangedAt,
            "TXT".SU_TXT_PositedAt,
            "TXT".SU_TXT_Positor,
            "TXT".SU_TXT_Reliability,
            "TXT".SU_TXT_Assertion,
            "TXT".SU_TXT_Subject_Text,
            "ASR".SU_ASR_SU_ID,
            "ASR".Metadata_SU_ASR,
            "ASR".SU_ASR_ID,
            "ASR".SU_ASR_ChangedAt,
            "ASR".SU_ASR_PositedAt,
            "ASR".SU_ASR_Positor,
            "ASR".SU_ASR_Reliability,
            "ASR".SU_ASR_Assertion,
            "ASR".SU_ASR_Subject_Assessment,
            "ERS".SU_ERS_SU_ID,
            "ERS".Metadata_SU_ERS,
            "ERS".SU_ERS_ID,
            "ERS".SU_ERS_ChangedAt,
            "ERS".SU_ERS_PositedAt,
            "ERS".SU_ERS_Positor,
            "ERS".SU_ERS_Reliability,
            "ERS".SU_ERS_Assertion,
            "ERS".SU_ERS_Subject_Erasable
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.SU_TTL_Positor AS inspectedPositor,
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
                h.SU_STA_Positor AS inspectedPositor,
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
                h.SU_LBL_Positor AS inspectedPositor,
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
                h.SU_TAG_Positor AS inspectedPositor,
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
                h.SU_LVL_Positor AS inspectedPositor,
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
                h.SU_TXT_Positor AS inspectedPositor,
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
                h.SU_ASR_Positor AS inspectedPositor,
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
                h.SU_ERS_Positor AS inspectedPositor,
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
        ON
            timepoints.inspectedPositor = positorTable.Positor
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
                        PARTITION BY r.SU_NAM_Positor, r.SU_NAM_SU_ID
                        ORDER BY
                            r.SU_NAM_PositedAt DESC,
                            r.SU_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NAM,
                        po.SU_NAM_ID,
                        an.SU_NAM_PositedAt,
                        an.SU_NAM_Positor,
                        an.SU_NAM_Reliability,
                        an.SU_NAM_Assertion,
                        po.SU_NAM_SU_ID,
                        po.SU_NAM_Subject_Name,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NAM_ID, an.SU_NAM_Positor
                            ORDER BY an.SU_NAM_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NAM_Subject_Name_Posit po
                    JOIN
                        SU_NAM_Subject_Name_Annex an
                    ON
                        an.SU_NAM_ID = po.SU_NAM_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NAM_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "NAM"
        ON
            "NAM".SU_NAM_SU_ID = "SU".SU_ID
        AND
            "NAM".SU_NAM_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_COD_Positor, r.SU_COD_SU_ID
                        ORDER BY
                            r.SU_COD_PositedAt DESC,
                            r.SU_COD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_COD,
                        po.SU_COD_ID,
                        an.SU_COD_PositedAt,
                        an.SU_COD_Positor,
                        an.SU_COD_Reliability,
                        an.SU_COD_Assertion,
                        po.SU_COD_SU_ID,
                        po.SU_COD_Subject_Code,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_COD_ID, an.SU_COD_Positor
                            ORDER BY an.SU_COD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_COD_Subject_Code_Posit po
                    JOIN
                        SU_COD_Subject_Code_Annex an
                    ON
                        an.SU_COD_ID = po.SU_COD_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_COD_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "COD"
        ON
            "COD".SU_COD_SU_ID = "SU".SU_ID
        AND
            "COD".SU_COD_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                z.*
            FROM (
                SELECT
                    r.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY r.SU_GRD_Positor, r.SU_GRD_SU_ID
                        ORDER BY
                            r.SU_GRD_PositedAt DESC,
                            r.SU_GRD_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_GRD,
                        po.SU_GRD_ID,
                        an.SU_GRD_PositedAt,
                        an.SU_GRD_Positor,
                        an.SU_GRD_Reliability,
                        an.SU_GRD_Assertion,
                        po.SU_GRD_SU_ID,
                        po.SU_GRD_GRD_ID,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_GRD_ID, an.SU_GRD_Positor
                            ORDER BY an.SU_GRD_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_GRD_Subject_Grade_Posit po
                    JOIN
                        SU_GRD_Subject_Grade_Annex an
                    ON
                        an.SU_GRD_ID = po.SU_GRD_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_GRD_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "GRD"
        ON
            "GRD".SU_GRD_SU_ID = "SU".SU_ID
        AND
            "GRD".SU_GRD_Positor = timepoints.inspectedPositor
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
                        PARTITION BY r.SU_NOT_Positor, r.SU_NOT_SU_ID
                        ORDER BY
                            r.SU_NOT_PositedAt DESC,
                            r.SU_NOT_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        an.Metadata_SU_NOT,
                        po.SU_NOT_ID,
                        an.SU_NOT_PositedAt,
                        an.SU_NOT_Positor,
                        an.SU_NOT_Reliability,
                        an.SU_NOT_Assertion,
                        po.SU_NOT_SU_ID,
                        po.SU_NOT_Subject_Note,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.SU_NOT_ID, an.SU_NOT_Positor
                            ORDER BY an.SU_NOT_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        SU_NOT_Subject_Note_Posit po
                    JOIN
                        SU_NOT_Subject_Note_Annex an
                    ON
                        an.SU_NOT_ID = po.SU_NOT_ID
                ) r
                WHERE
                    r.rewindRank = 1
                AND
                    r.SU_NOT_Assertion = '+'
            ) z
            WHERE
                z.pickRank = 1
        ) "NOT"
        ON
            "NOT".SU_NOT_SU_ID = "SU".SU_ID
        AND
            "NOT".SU_NOT_Positor = timepoints.inspectedPositor
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_TTL_ChangedAt) OVER (
                    PARTITION BY y.SU_TTL_Positor, y.SU_TTL_SU_ID
                    ORDER BY y.SU_TTL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TTL_Positor, r.SU_TTL_SU_ID, r.SU_TTL_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_TTL_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_TTL_PositedAt DESC,
                                r.SU_TTL_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TTL,
                            po.SU_TTL_ID,
                            an.SU_TTL_PositedAt,
                            an.SU_TTL_Positor,
                            an.SU_TTL_Reliability,
                            an.SU_TTL_Assertion,
                            po.SU_TTL_SU_ID,
                            po.SU_TTL_Subject_Title,
                            po.SU_TTL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TTL_ID, an.SU_TTL_Positor
                                ORDER BY an.SU_TTL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TTL_Subject_Title_Posit po
                        JOIN
                            SU_TTL_Subject_Title_Annex an
                        ON
                            an.SU_TTL_ID = po.SU_TTL_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TTL_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "TTL"
        ON
            "TTL".SU_TTL_SU_ID = "SU".SU_ID
        AND
            "TTL".SU_TTL_Positor = timepoints.inspectedPositor
        AND
            "TTL".SU_TTL_Assertion = '+'
        AND
            "TTL".SU_TTL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TTL".untilTime IS NULL
        OR
            "TTL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_STA_ChangedAt) OVER (
                    PARTITION BY y.SU_STA_Positor, y.SU_STA_SU_ID
                    ORDER BY y.SU_STA_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_STA_Positor, r.SU_STA_SU_ID, r.SU_STA_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_STA_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_STA_PositedAt DESC,
                                r.SU_STA_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_STA,
                            po.SU_STA_ID,
                            an.SU_STA_PositedAt,
                            an.SU_STA_Positor,
                            an.SU_STA_Reliability,
                            an.SU_STA_Assertion,
                            po.SU_STA_SU_ID,
                            po.SU_STA_Subject_State,
                            po.SU_STA_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_STA_ID, an.SU_STA_Positor
                                ORDER BY an.SU_STA_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_STA_Subject_State_Posit po
                        JOIN
                            SU_STA_Subject_State_Annex an
                        ON
                            an.SU_STA_ID = po.SU_STA_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_STA_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "STA"
        ON
            "STA".SU_STA_SU_ID = "SU".SU_ID
        AND
            "STA".SU_STA_Positor = timepoints.inspectedPositor
        AND
            "STA".SU_STA_Assertion = '+'
        AND
            "STA".SU_STA_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "STA".untilTime IS NULL
        OR
            "STA".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_LBL_ChangedAt) OVER (
                    PARTITION BY y.SU_LBL_Positor, y.SU_LBL_SU_ID
                    ORDER BY y.SU_LBL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_LBL_Positor, r.SU_LBL_SU_ID, r.SU_LBL_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_LBL_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_LBL_PositedAt DESC,
                                r.SU_LBL_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_LBL,
                            po.SU_LBL_ID,
                            an.SU_LBL_PositedAt,
                            an.SU_LBL_Positor,
                            an.SU_LBL_Reliability,
                            an.SU_LBL_Assertion,
                            po.SU_LBL_SU_ID,
                            po.SU_LBL_Subject_Label,
                            po.SU_LBL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LBL_ID, an.SU_LBL_Positor
                                ORDER BY an.SU_LBL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_LBL_Subject_Label_Posit po
                        JOIN
                            SU_LBL_Subject_Label_Annex an
                        ON
                            an.SU_LBL_ID = po.SU_LBL_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_LBL_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LBL"
        ON
            "LBL".SU_LBL_SU_ID = "SU".SU_ID
        AND
            "LBL".SU_LBL_Positor = timepoints.inspectedPositor
        AND
            "LBL".SU_LBL_Assertion = '+'
        AND
            "LBL".SU_LBL_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "LBL".untilTime IS NULL
        OR
            "LBL".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_TAG_ChangedAt) OVER (
                    PARTITION BY y.SU_TAG_Positor, y.SU_TAG_SU_ID
                    ORDER BY y.SU_TAG_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TAG_Positor, r.SU_TAG_SU_ID, r.SU_TAG_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_TAG_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_TAG_PositedAt DESC,
                                r.SU_TAG_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TAG,
                            po.SU_TAG_ID,
                            an.SU_TAG_PositedAt,
                            an.SU_TAG_Positor,
                            an.SU_TAG_Reliability,
                            an.SU_TAG_Assertion,
                            po.SU_TAG_SU_ID,
                            po.SU_TAG_Subject_Tag,
                            po.SU_TAG_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TAG_ID, an.SU_TAG_Positor
                                ORDER BY an.SU_TAG_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TAG_Subject_Tag_Posit po
                        JOIN
                            SU_TAG_Subject_Tag_Annex an
                        ON
                            an.SU_TAG_ID = po.SU_TAG_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TAG_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "TAG"
        ON
            "TAG".SU_TAG_SU_ID = "SU".SU_ID
        AND
            "TAG".SU_TAG_Positor = timepoints.inspectedPositor
        AND
            "TAG".SU_TAG_Assertion = '+'
        AND
            "TAG".SU_TAG_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TAG".untilTime IS NULL
        OR
            "TAG".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_LVL_ChangedAt) OVER (
                    PARTITION BY y.SU_LVL_Positor, y.SU_LVL_SU_ID
                    ORDER BY y.SU_LVL_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_LVL_Positor, r.SU_LVL_SU_ID, r.SU_LVL_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_LVL_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_LVL_PositedAt DESC,
                                r.SU_LVL_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_LVL,
                            po.SU_LVL_ID,
                            an.SU_LVL_PositedAt,
                            an.SU_LVL_Positor,
                            an.SU_LVL_Reliability,
                            an.SU_LVL_Assertion,
                            po.SU_LVL_SU_ID,
                            po.SU_LVL_GRD_ID,
                            po.SU_LVL_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_LVL_ID, an.SU_LVL_Positor
                                ORDER BY an.SU_LVL_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_LVL_Subject_Level_Posit po
                        JOIN
                            SU_LVL_Subject_Level_Annex an
                        ON
                            an.SU_LVL_ID = po.SU_LVL_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_LVL_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "LVL"
        ON
            "LVL".SU_LVL_SU_ID = "SU".SU_ID
        AND
            "LVL".SU_LVL_Positor = timepoints.inspectedPositor
        AND
            "LVL".SU_LVL_Assertion = '+'
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
                y.*,
                LEAD(y.SU_TXT_ChangedAt) OVER (
                    PARTITION BY y.SU_TXT_Positor, y.SU_TXT_SU_ID
                    ORDER BY y.SU_TXT_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_TXT_Positor, r.SU_TXT_SU_ID, r.SU_TXT_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_TXT_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_TXT_PositedAt DESC,
                                r.SU_TXT_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_TXT,
                            po.SU_TXT_ID,
                            an.SU_TXT_PositedAt,
                            an.SU_TXT_Positor,
                            an.SU_TXT_Reliability,
                            an.SU_TXT_Assertion,
                            po.SU_TXT_SU_ID,
                            po.SU_TXT_Subject_Text,
                            po.SU_TXT_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_TXT_ID, an.SU_TXT_Positor
                                ORDER BY an.SU_TXT_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_TXT_Subject_Text_Posit po
                        JOIN
                            SU_TXT_Subject_Text_Annex an
                        ON
                            an.SU_TXT_ID = po.SU_TXT_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_TXT_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "TXT"
        ON
            "TXT".SU_TXT_SU_ID = "SU".SU_ID
        AND
            "TXT".SU_TXT_Positor = timepoints.inspectedPositor
        AND
            "TXT".SU_TXT_Assertion = '+'
        AND
            "TXT".SU_TXT_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "TXT".untilTime IS NULL
        OR
            "TXT".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_ASR_ChangedAt) OVER (
                    PARTITION BY y.SU_ASR_Positor, y.SU_ASR_SU_ID
                    ORDER BY y.SU_ASR_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_ASR_Positor, r.SU_ASR_SU_ID, r.SU_ASR_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_ASR_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_ASR_PositedAt DESC,
                                r.SU_ASR_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_ASR,
                            po.SU_ASR_ID,
                            an.SU_ASR_PositedAt,
                            an.SU_ASR_Positor,
                            an.SU_ASR_Reliability,
                            an.SU_ASR_Assertion,
                            po.SU_ASR_SU_ID,
                            po.SU_ASR_Subject_Assessment,
                            po.SU_ASR_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ASR_ID, an.SU_ASR_Positor
                                ORDER BY an.SU_ASR_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_ASR_Subject_Assessment_Posit po
                        JOIN
                            SU_ASR_Subject_Assessment_Annex an
                        ON
                            an.SU_ASR_ID = po.SU_ASR_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_ASR_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "ASR"
        ON
            "ASR".SU_ASR_SU_ID = "SU".SU_ID
        AND
            "ASR".SU_ASR_Positor = timepoints.inspectedPositor
        AND
            "ASR".SU_ASR_Assertion = '+'
        AND
            "ASR".SU_ASR_ChangedAt <= CAST(timepoints.inspectedTimepoint AS timestamp)
        AND (
            "ASR".untilTime IS NULL
        OR
            "ASR".untilTime > CAST(timepoints.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN (
            SELECT
                y.*,
                LEAD(y.SU_ERS_ChangedAt) OVER (
                    PARTITION BY y.SU_ERS_Positor, y.SU_ERS_SU_ID
                    ORDER BY y.SU_ERS_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY r.SU_ERS_Positor, r.SU_ERS_SU_ID, r.SU_ERS_ChangedAt
                            ORDER BY
                                CASE WHEN r.SU_ERS_Assertion = '+' THEN 0 ELSE 1 END,
                                r.SU_ERS_PositedAt DESC,
                                r.SU_ERS_Reliability DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_SU_ERS,
                            po.SU_ERS_ID,
                            an.SU_ERS_PositedAt,
                            an.SU_ERS_Positor,
                            an.SU_ERS_Reliability,
                            an.SU_ERS_Assertion,
                            po.SU_ERS_SU_ID,
                            po.SU_ERS_Subject_Erasable,
                            po.SU_ERS_ChangedAt,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.SU_ERS_ID, an.SU_ERS_Positor
                                ORDER BY an.SU_ERS_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            SU_ERS_Subject_Erasable_Posit po
                        JOIN
                            SU_ERS_Subject_Erasable_Annex an
                        ON
                            an.SU_ERS_ID = po.SU_ERS_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.SU_ERS_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) "ERS"
        ON
            "ERS".SU_ERS_SU_ID = "SU".SU_ID
        AND
            "ERS".SU_ERS_Positor = timepoints.inspectedPositor
        AND
            "ERS".SU_ERS_Assertion = '+'
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tOB_Object (
    forPositor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp,
    assertion IN VARCHAR2
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
            "NAM".OB_NAM_Positor,
            "NAM".OB_NAM_Reliability,
            "NAM".OB_NAM_Assertion,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        CROSS JOIN
            Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.OB_NAM_Positor, x.OB_NAM_OB_ID
                        ORDER BY
                            x.OB_NAM_PositedAt DESC,
                            x.OB_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_OB_NAM,
                            po.OB_NAM_ID,
                            an.OB_NAM_PositedAt,
                            an.OB_NAM_Positor,
                            an.OB_NAM_Reliability,
                            an.OB_NAM_Assertion,
                            po.OB_NAM_OB_ID,
                            po.OB_NAM_Object_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.OB_NAM_ID, an.OB_NAM_Positor
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
                ) x
                WHERE
                    x.OB_NAM_Assertion = COALESCE(assertion, x.OB_NAM_Assertion)
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
        AND
            "NAM".OB_NAM_Positor = positorTable.Positor
        WHERE
            positorTable.Positor = forPositor
    ]';
END tOB_Object;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pOB_Object (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            "OB".OB_ID,
            "OB".Metadata_OB,
            "NAM".OB_NAM_OB_ID,
            "NAM".Metadata_OB_NAM,
            "NAM".OB_NAM_ID,
            "NAM".OB_NAM_PositedAt,
            "NAM".OB_NAM_Positor,
            "NAM".OB_NAM_Reliability,
            "NAM".OB_NAM_Assertion,
            "NAM".OB_NAM_Object_Name
        FROM
            OB_Object "OB"
        CROSS JOIN
            Positor_ positorTable
        LEFT JOIN (
            SELECT
                y.*
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY x.OB_NAM_Positor, x.OB_NAM_OB_ID
                        ORDER BY
                            x.OB_NAM_PositedAt DESC,
                            x.OB_NAM_Reliability DESC
                    ) AS pickRank
                FROM (
                    SELECT
                        r.*
                    FROM (
                        SELECT
                            an.Metadata_OB_NAM,
                            po.OB_NAM_ID,
                            an.OB_NAM_PositedAt,
                            an.OB_NAM_Positor,
                            an.OB_NAM_Reliability,
                            an.OB_NAM_Assertion,
                            po.OB_NAM_OB_ID,
                            po.OB_NAM_Object_Name,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.OB_NAM_ID, an.OB_NAM_Positor
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
                ) x
                WHERE
                    x.OB_NAM_Assertion = '+'
            ) y
            WHERE
                y.pickRank = 1
        ) "NAM"
        ON
            "NAM".OB_NAM_OB_ID = "OB".OB_ID
        AND
            "NAM".OB_NAM_Positor = positorTable.Positor
    ]';
END pOB_Object;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
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
