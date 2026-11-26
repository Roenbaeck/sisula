-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_in_RAT_got(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the tie
-- joined, the annex row with the latest positing time picked for each posit, the posits that are not reliable left out.
--
-- The latest and now perspectives are views over the point-in-time macro.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_partner_AC_with_ONG_currently_ID,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_partner
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_with
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    an.Metadata_AC_partner_AC_with_ONG_currently,
                    po.AC_partner_AC_with_ONG_currently_ID,
                    po.AC_ID_partner,
                    po.AC_ID_with,
                    po.ONG_ID_currently,
                    po.AC_partner_AC_with_ONG_currently_ChangedAt,
                    an.AC_partner_AC_with_ONG_currently_PositedAt,
                    an.AC_partner_AC_with_ONG_currently_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_partner_AC_with_ONG_currently_ID
                        ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    ties.AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                WHERE
                    po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END tAC_partner_AC_with_ONG_currently;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_partner_AC_with_ONG_currently_ID,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_partner
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_with
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    an.Metadata_AC_partner_AC_with_ONG_currently,
                    po.AC_partner_AC_with_ONG_currently_ID,
                    po.AC_ID_partner,
                    po.AC_ID_with,
                    po.ONG_ID_currently,
                    po.AC_partner_AC_with_ONG_currently_ChangedAt,
                    an.AC_partner_AC_with_ONG_currently_PositedAt,
                    an.AC_partner_AC_with_ONG_currently_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_partner_AC_with_ONG_currently_ID
                        ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    ties.AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                WHERE
                    po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END pAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_partner_AC_with_ONG_currently_ID,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_partner
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_with
                    ORDER BY
                        r.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        r.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    an.Metadata_AC_partner_AC_with_ONG_currently,
                    po.AC_partner_AC_with_ONG_currently_ID,
                    po.AC_ID_partner,
                    po.AC_ID_with,
                    po.ONG_ID_currently,
                    po.AC_partner_AC_with_ONG_currently_ChangedAt,
                    an.AC_partner_AC_with_ONG_currently_PositedAt,
                    an.AC_partner_AC_with_ONG_currently_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_partner_AC_with_ONG_currently_ID
                        ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    ties.AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
        AND
            t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_subset_PN_of_ID,
            t.Metadata_AC_subset_PN_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Reliability,
            t.AC_ID_subset,
            t.PN_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_subset
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PN_ID_of
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    an.Metadata_AC_subset_PN_of,
                    po.AC_subset_PN_of_ID,
                    po.AC_ID_subset,
                    po.PN_ID_of,
                    an.AC_subset_PN_of_PositedAt,
                    an.AC_subset_PN_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_subset_PN_of_ID
                        ORDER BY an.AC_subset_PN_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_subset_PN_of_Posit po
                JOIN
                    ties.AC_subset_PN_of_Annex an
                ON
                    an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                WHERE
                    an.AC_subset_PN_of_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_subset_PN_of_Reliability = 1
        ) t
        WHERE
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END tAC_subset_PN_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_subset_PN_of_ID,
            t.Metadata_AC_subset_PN_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Reliability,
            t.AC_ID_subset,
            t.PN_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.AC_ID_subset
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PN_ID_of
                    ORDER BY
                        r.AC_subset_PN_of_PositedAt DESC,
                        r.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    an.Metadata_AC_subset_PN_of,
                    po.AC_subset_PN_of_ID,
                    po.AC_ID_subset,
                    po.PN_ID_of,
                    an.AC_subset_PN_of_PositedAt,
                    an.AC_subset_PN_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_subset_PN_of_ID
                        ORDER BY an.AC_subset_PN_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_subset_PN_of_Posit po
                JOIN
                    ties.AC_subset_PN_of_Annex an
                ON
                    an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                WHERE
                    an.AC_subset_PN_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_subset_PN_of_Reliability = 1
        ) t
        WHERE
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END pAC_subset_PN_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_rollsattes (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.EV_in_AC_rollsattes_ID,
            t.Metadata_EV_in_AC_rollsattes,
            t.EV_in_AC_rollsattes_PositedAt,
            t.EV_in_AC_rollsattes_Reliability,
            t.EV_ID_in,
            t.AC_ID_rollsattes
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_in,
                        r.AC_ID_rollsattes
                    ORDER BY
                        r.EV_in_AC_rollsattes_PositedAt DESC,
                        r.EV_in_AC_rollsattes_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_EV_in_AC_rollsattes,
                    po.EV_in_AC_rollsattes_ID,
                    po.EV_ID_in,
                    po.AC_ID_rollsattes,
                    an.EV_in_AC_rollsattes_PositedAt,
                    an.EV_in_AC_rollsattes_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.EV_in_AC_rollsattes_ID
                        ORDER BY an.EV_in_AC_rollsattes_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.EV_in_AC_rollsattes_Posit po
                JOIN
                    ties.EV_in_AC_rollsattes_Annex an
                ON
                    an.EV_in_AC_rollsattes_ID = po.EV_in_AC_rollsattes_ID
                WHERE
                    an.EV_in_AC_rollsattes_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.EV_in_AC_rollsattes_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tEV_in_AC_rollsattes;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.EV_in_AC_rollsattes_ID,
            t.Metadata_EV_in_AC_rollsattes,
            t.EV_in_AC_rollsattes_PositedAt,
            t.EV_in_AC_rollsattes_Reliability,
            t.EV_ID_in,
            t.AC_ID_rollsattes
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_in,
                        r.AC_ID_rollsattes
                    ORDER BY
                        r.EV_in_AC_rollsattes_PositedAt DESC,
                        r.EV_in_AC_rollsattes_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_EV_in_AC_rollsattes,
                    po.EV_in_AC_rollsattes_ID,
                    po.EV_ID_in,
                    po.AC_ID_rollsattes,
                    an.EV_in_AC_rollsattes_PositedAt,
                    an.EV_in_AC_rollsattes_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.EV_in_AC_rollsattes_ID
                        ORDER BY an.EV_in_AC_rollsattes_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.EV_in_AC_rollsattes_Posit po
                JOIN
                    ties.EV_in_AC_rollsattes_Annex an
                ON
                    an.EV_in_AC_rollsattes_ID = po.EV_in_AC_rollsattes_ID
                WHERE
                    an.EV_in_AC_rollsattes_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.EV_in_AC_rollsattes_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pEV_in_AC_rollsattes;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes
AS
SELECT
    *
FROM
    ties.pEV_in_AC_rollsattes(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes
AS
SELECT
    *
FROM
    ties.pEV_in_AC_rollsattes(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_deltar_PR_in_RAT_fick (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_deltar_PR_in_RAT_fick_ID,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_deltar,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        r.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        r.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_deltar_PR_in_RAT_fick,
                    po.AC_deltar_PR_in_RAT_fick_ID,
                    po.AC_ID_deltar,
                    po.PR_ID_in,
                    po.RAT_ID_fick,
                    po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                    an.AC_deltar_PR_in_RAT_fick_PositedAt,
                    an.AC_deltar_PR_in_RAT_fick_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID
                        ORDER BY an.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Posit po
                JOIN
                    ties.AC_deltar_PR_in_RAT_fick_Annex an
                ON
                    an.AC_deltar_PR_in_RAT_fick_ID = po.AC_deltar_PR_in_RAT_fick_ID
                WHERE
                    po.AC_deltar_PR_in_RAT_fick_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_deltar_PR_in_RAT_fick_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_deltar_PR_in_RAT_fick_Reliability = 1
        ) t
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
        WHERE
            t.latestPosit = 1
    ]';
END tAC_deltar_PR_in_RAT_fick;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_deltar_PR_in_RAT_fick_ID,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_deltar,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        r.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        r.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_deltar_PR_in_RAT_fick,
                    po.AC_deltar_PR_in_RAT_fick_ID,
                    po.AC_ID_deltar,
                    po.PR_ID_in,
                    po.RAT_ID_fick,
                    po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                    an.AC_deltar_PR_in_RAT_fick_PositedAt,
                    an.AC_deltar_PR_in_RAT_fick_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID
                        ORDER BY an.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Posit po
                JOIN
                    ties.AC_deltar_PR_in_RAT_fick_Annex an
                ON
                    an.AC_deltar_PR_in_RAT_fick_ID = po.AC_deltar_PR_in_RAT_fick_ID
                WHERE
                    po.AC_deltar_PR_in_RAT_fick_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_deltar_PR_in_RAT_fick_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_deltar_PR_in_RAT_fick_Reliability = 1
        ) t
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
        WHERE
            t.latestPosit = 1
    ]';
END pAC_deltar_PR_in_RAT_fick;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick
AS
SELECT
    *
FROM
    ties.pAC_deltar_PR_in_RAT_fick(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_deltar_PR_in_RAT_fick
AS
SELECT
    *
FROM
    ties.pAC_deltar_PR_in_RAT_fick(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_deltar_PR_in_RAT_fick (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_deltar_PR_in_RAT_fick_ID,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_deltar,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        r.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        r.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_deltar_PR_in_RAT_fick,
                    po.AC_deltar_PR_in_RAT_fick_ID,
                    po.AC_ID_deltar,
                    po.PR_ID_in,
                    po.RAT_ID_fick,
                    po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                    an.AC_deltar_PR_in_RAT_fick_PositedAt,
                    an.AC_deltar_PR_in_RAT_fick_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID
                        ORDER BY an.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Posit po
                JOIN
                    ties.AC_deltar_PR_in_RAT_fick_Annex an
                ON
                    an.AC_deltar_PR_in_RAT_fick_ID = po.AC_deltar_PR_in_RAT_fick_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_deltar_PR_in_RAT_fick_Reliability = 1
        ) t
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
        WHERE
            t.latestPosit = 1
        AND
            t.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_deltar_PR_in_RAT_fick;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_spelas (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_spelas_ID,
            t.Metadata_ST_at_PR_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Reliability,
            t.ST_ID_at,
            t.PR_ID_spelas
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_spelas
                    ORDER BY
                        r.ST_at_PR_spelas_ChangedAt DESC,
                        r.ST_at_PR_spelas_PositedAt DESC,
                        r.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_spelas,
                    po.ST_at_PR_spelas_ID,
                    po.ST_ID_at,
                    po.PR_ID_spelas,
                    po.ST_at_PR_spelas_ChangedAt,
                    an.ST_at_PR_spelas_PositedAt,
                    an.ST_at_PR_spelas_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_spelas_ID
                        ORDER BY an.ST_at_PR_spelas_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.ST_at_PR_spelas_Posit po
                JOIN
                    ties.ST_at_PR_spelas_Annex an
                ON
                    an.ST_at_PR_spelas_ID = po.ST_at_PR_spelas_ID
                WHERE
                    po.ST_at_PR_spelas_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.ST_at_PR_spelas_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_spelas_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tST_at_PR_spelas;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_spelas_ID,
            t.Metadata_ST_at_PR_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Reliability,
            t.ST_ID_at,
            t.PR_ID_spelas
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_spelas
                    ORDER BY
                        r.ST_at_PR_spelas_ChangedAt DESC,
                        r.ST_at_PR_spelas_PositedAt DESC,
                        r.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_spelas,
                    po.ST_at_PR_spelas_ID,
                    po.ST_ID_at,
                    po.PR_ID_spelas,
                    po.ST_at_PR_spelas_ChangedAt,
                    an.ST_at_PR_spelas_PositedAt,
                    an.ST_at_PR_spelas_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_spelas_ID
                        ORDER BY an.ST_at_PR_spelas_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.ST_at_PR_spelas_Posit po
                JOIN
                    ties.ST_at_PR_spelas_Annex an
                ON
                    an.ST_at_PR_spelas_ID = po.ST_at_PR_spelas_ID
                WHERE
                    po.ST_at_PR_spelas_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.ST_at_PR_spelas_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_spelas_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pST_at_PR_spelas;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas
AS
SELECT
    *
FROM
    ties.pST_at_PR_spelas(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_spelas
AS
SELECT
    *
FROM
    ties.pST_at_PR_spelas(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_spelas (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_spelas_ID,
            t.Metadata_ST_at_PR_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Reliability,
            t.ST_ID_at,
            t.PR_ID_spelas
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_spelas
                    ORDER BY
                        r.ST_at_PR_spelas_ChangedAt DESC,
                        r.ST_at_PR_spelas_PositedAt DESC,
                        r.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_spelas,
                    po.ST_at_PR_spelas_ID,
                    po.ST_ID_at,
                    po.PR_ID_spelas,
                    po.ST_at_PR_spelas_ChangedAt,
                    an.ST_at_PR_spelas_PositedAt,
                    an.ST_at_PR_spelas_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_spelas_ID
                        ORDER BY an.ST_at_PR_spelas_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.ST_at_PR_spelas_Posit po
                JOIN
                    ties.ST_at_PR_spelas_Annex an
                ON
                    an.ST_at_PR_spelas_ID = po.ST_at_PR_spelas_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_spelas_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
        AND
            t.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_spelas;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_förälder_AC_barn_PAT_har (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_förälder_AC_barn_PAT_har_ID,
            t.Metadata_AC_förälder_AC_barn_PAT_har,
            t.AC_förälder_AC_barn_PAT_har_PositedAt,
            t.AC_förälder_AC_barn_PAT_har_Reliability,
            t.AC_ID_förälder,
            t.AC_ID_barn,
            "kPAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "kPAT_har".Metadata_PAT AS har_Metadata_PAT,
            t.PAT_ID_har
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_förälder,
                        r.AC_ID_barn,
                        r.PAT_ID_har
                    ORDER BY
                        r.AC_förälder_AC_barn_PAT_har_PositedAt DESC,
                        r.AC_förälder_AC_barn_PAT_har_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_förälder_AC_barn_PAT_har,
                    po.AC_förälder_AC_barn_PAT_har_ID,
                    po.AC_ID_förälder,
                    po.AC_ID_barn,
                    po.PAT_ID_har,
                    an.AC_förälder_AC_barn_PAT_har_PositedAt,
                    an.AC_förälder_AC_barn_PAT_har_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_förälder_AC_barn_PAT_har_ID
                        ORDER BY an.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_förälder_AC_barn_PAT_har_Posit po
                JOIN
                    ties.AC_förälder_AC_barn_PAT_har_Annex an
                ON
                    an.AC_förälder_AC_barn_PAT_har_ID = po.AC_förälder_AC_barn_PAT_har_ID
                WHERE
                    an.AC_förälder_AC_barn_PAT_har_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_förälder_AC_barn_PAT_har_Reliability = 1
        ) t
        LEFT JOIN
            knots.PAT_Föräldratyp "kPAT_har"
        ON
            "kPAT_har".PAT_ID = t.PAT_ID_har
        WHERE
            t.latestPosit = 1
    ]';
END tAC_förälder_AC_barn_PAT_har;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_förälder_AC_barn_PAT_har_ID,
            t.Metadata_AC_förälder_AC_barn_PAT_har,
            t.AC_förälder_AC_barn_PAT_har_PositedAt,
            t.AC_förälder_AC_barn_PAT_har_Reliability,
            t.AC_ID_förälder,
            t.AC_ID_barn,
            "kPAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "kPAT_har".Metadata_PAT AS har_Metadata_PAT,
            t.PAT_ID_har
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_förälder,
                        r.AC_ID_barn,
                        r.PAT_ID_har
                    ORDER BY
                        r.AC_förälder_AC_barn_PAT_har_PositedAt DESC,
                        r.AC_förälder_AC_barn_PAT_har_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_förälder_AC_barn_PAT_har,
                    po.AC_förälder_AC_barn_PAT_har_ID,
                    po.AC_ID_förälder,
                    po.AC_ID_barn,
                    po.PAT_ID_har,
                    an.AC_förälder_AC_barn_PAT_har_PositedAt,
                    an.AC_förälder_AC_barn_PAT_har_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_förälder_AC_barn_PAT_har_ID
                        ORDER BY an.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.AC_förälder_AC_barn_PAT_har_Posit po
                JOIN
                    ties.AC_förälder_AC_barn_PAT_har_Annex an
                ON
                    an.AC_förälder_AC_barn_PAT_har_ID = po.AC_förälder_AC_barn_PAT_har_ID
                WHERE
                    an.AC_förälder_AC_barn_PAT_har_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_förälder_AC_barn_PAT_har_Reliability = 1
        ) t
        LEFT JOIN
            knots.PAT_Föräldratyp "kPAT_har"
        ON
            "kPAT_har".PAT_ID = t.PAT_ID_har
        WHERE
            t.latestPosit = 1
    ]';
END pAC_förälder_AC_barn_PAT_har;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har
AS
SELECT
    *
FROM
    ties.pAC_förälder_AC_barn_PAT_har(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har
AS
SELECT
    *
FROM
    ties.pAC_förälder_AC_barn_PAT_har(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_innehåll_ST_plats_EV_of (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_innehåll_ST_plats_EV_of_ID,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PR_ID_innehåll
                    ORDER BY
                        r.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY r.ST_ID_plats
                    ORDER BY
                        r.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    an.Metadata_PR_innehåll_ST_plats_EV_of,
                    po.PR_innehåll_ST_plats_EV_of_ID,
                    po.PR_ID_innehåll,
                    po.ST_ID_plats,
                    po.EV_ID_of,
                    po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                    an.PR_innehåll_ST_plats_EV_of_PositedAt,
                    an.PR_innehåll_ST_plats_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID
                        ORDER BY an.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Posit po
                JOIN
                    ties.PR_innehåll_ST_plats_EV_of_Annex an
                ON
                    an.PR_innehåll_ST_plats_EV_of_ID = po.PR_innehåll_ST_plats_EV_of_ID
                WHERE
                    po.PR_innehåll_ST_plats_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.PR_innehåll_ST_plats_EV_of_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_innehåll_ST_plats_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPositPR_ID_innehåll = 1
        AND
            t.latestPositST_ID_plats = 1
    ]';
END tPR_innehåll_ST_plats_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_innehåll_ST_plats_EV_of_ID,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PR_ID_innehåll
                    ORDER BY
                        r.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY r.ST_ID_plats
                    ORDER BY
                        r.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    an.Metadata_PR_innehåll_ST_plats_EV_of,
                    po.PR_innehåll_ST_plats_EV_of_ID,
                    po.PR_ID_innehåll,
                    po.ST_ID_plats,
                    po.EV_ID_of,
                    po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                    an.PR_innehåll_ST_plats_EV_of_PositedAt,
                    an.PR_innehåll_ST_plats_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID
                        ORDER BY an.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Posit po
                JOIN
                    ties.PR_innehåll_ST_plats_EV_of_Annex an
                ON
                    an.PR_innehåll_ST_plats_EV_of_ID = po.PR_innehåll_ST_plats_EV_of_ID
                WHERE
                    po.PR_innehåll_ST_plats_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.PR_innehåll_ST_plats_EV_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_innehåll_ST_plats_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPositPR_ID_innehåll = 1
        AND
            t.latestPositST_ID_plats = 1
    ]';
END pPR_innehåll_ST_plats_EV_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of
AS
SELECT
    *
FROM
    ties.pPR_innehåll_ST_plats_EV_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_innehåll_ST_plats_EV_of
AS
SELECT
    *
FROM
    ties.pPR_innehåll_ST_plats_EV_of(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_innehåll_ST_plats_EV_of (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_innehåll_ST_plats_EV_of_ID,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY r.PR_ID_innehåll
                    ORDER BY
                        r.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY r.ST_ID_plats
                    ORDER BY
                        r.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        r.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    an.Metadata_PR_innehåll_ST_plats_EV_of,
                    po.PR_innehåll_ST_plats_EV_of_ID,
                    po.PR_ID_innehåll,
                    po.ST_ID_plats,
                    po.EV_ID_of,
                    po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                    an.PR_innehåll_ST_plats_EV_of_PositedAt,
                    an.PR_innehåll_ST_plats_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID
                        ORDER BY an.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Posit po
                JOIN
                    ties.PR_innehåll_ST_plats_EV_of_Annex an
                ON
                    an.PR_innehåll_ST_plats_EV_of_ID = po.PR_innehåll_ST_plats_EV_of_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_innehåll_ST_plats_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPositPR_ID_innehåll = 1
        AND
            t.latestPositST_ID_plats = 1
        AND
            t.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dPR_innehåll_ST_plats_EV_of;
/
