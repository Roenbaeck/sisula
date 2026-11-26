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
CREATE OR REPLACE FUNCTION tAC_partner_AC_with_ONG_currently (
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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
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
                    AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    AC_partner_AC_with_ONG_currently_Annex an
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
            ONG_Ongoing "kONG_currently"
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
CREATE OR REPLACE FUNCTION pAC_partner_AC_with_ONG_currently (
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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
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
                    AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    AC_partner_AC_with_ONG_currently_Annex an
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
            ONG_Ongoing "kONG_currently"
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
CREATE OR REPLACE VIEW lAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    pAC_partner_AC_with_ONG_currently(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_partner_AC_with_ONG_currently (
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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
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
                    AC_partner_AC_with_ONG_currently_Posit po
                JOIN
                    AC_partner_AC_with_ONG_currently_Annex an
                ON
                    an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_partner_AC_with_ONG_currently_Reliability = 1
        ) t
        LEFT JOIN
            ONG_Ongoing "kONG_currently"
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
CREATE OR REPLACE FUNCTION tAC_subset_PN_of (
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
                    AC_subset_PN_of_Posit po
                JOIN
                    AC_subset_PN_of_Annex an
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
CREATE OR REPLACE FUNCTION pAC_subset_PN_of (
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
                    AC_subset_PN_of_Posit po
                JOIN
                    AC_subset_PN_of_Annex an
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
CREATE OR REPLACE VIEW lAC_subset_PN_of
AS
SELECT
    *
FROM
    pAC_subset_PN_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_subset_PN_of
AS
SELECT
    *
FROM
    pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tEV_in_AC_wasCast (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.EV_in_AC_wasCast_ID,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Reliability,
            t.EV_ID_in,
            t.AC_ID_wasCast
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_in,
                        r.AC_ID_wasCast
                    ORDER BY
                        r.EV_in_AC_wasCast_PositedAt DESC,
                        r.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_EV_in_AC_wasCast,
                    po.EV_in_AC_wasCast_ID,
                    po.EV_ID_in,
                    po.AC_ID_wasCast,
                    an.EV_in_AC_wasCast_PositedAt,
                    an.EV_in_AC_wasCast_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.EV_in_AC_wasCast_ID
                        ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                    ) AS rewindRank
                FROM
                    EV_in_AC_wasCast_Posit po
                JOIN
                    EV_in_AC_wasCast_Annex an
                ON
                    an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                WHERE
                    an.EV_in_AC_wasCast_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.EV_in_AC_wasCast_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tEV_in_AC_wasCast;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.EV_in_AC_wasCast_ID,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Reliability,
            t.EV_ID_in,
            t.AC_ID_wasCast
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_in,
                        r.AC_ID_wasCast
                    ORDER BY
                        r.EV_in_AC_wasCast_PositedAt DESC,
                        r.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_EV_in_AC_wasCast,
                    po.EV_in_AC_wasCast_ID,
                    po.EV_ID_in,
                    po.AC_ID_wasCast,
                    an.EV_in_AC_wasCast_PositedAt,
                    an.EV_in_AC_wasCast_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.EV_in_AC_wasCast_ID
                        ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                    ) AS rewindRank
                FROM
                    EV_in_AC_wasCast_Posit po
                JOIN
                    EV_in_AC_wasCast_Annex an
                ON
                    an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                WHERE
                    an.EV_in_AC_wasCast_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.EV_in_AC_wasCast_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pEV_in_AC_wasCast;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_in_AC_wasCast
AS
SELECT
    *
FROM
    pEV_in_AC_wasCast(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_part_PR_in_RAT_got_ID,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_part,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        r.AC_part_PR_in_RAT_got_PositedAt DESC,
                        r.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_part_PR_in_RAT_got,
                    po.AC_part_PR_in_RAT_got_ID,
                    po.AC_ID_part,
                    po.PR_ID_in,
                    po.RAT_ID_got,
                    po.AC_part_PR_in_RAT_got_ChangedAt,
                    an.AC_part_PR_in_RAT_got_PositedAt,
                    an.AC_part_PR_in_RAT_got_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_part_PR_in_RAT_got_ID
                        ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_part_PR_in_RAT_got_Posit po
                JOIN
                    AC_part_PR_in_RAT_got_Annex an
                ON
                    an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                WHERE
                    po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_part_PR_in_RAT_got_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_part_PR_in_RAT_got_Reliability = 1
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
    ]';
END tAC_part_PR_in_RAT_got;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_part_PR_in_RAT_got_ID,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_part,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        r.AC_part_PR_in_RAT_got_PositedAt DESC,
                        r.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_part_PR_in_RAT_got,
                    po.AC_part_PR_in_RAT_got_ID,
                    po.AC_ID_part,
                    po.PR_ID_in,
                    po.RAT_ID_got,
                    po.AC_part_PR_in_RAT_got_ChangedAt,
                    an.AC_part_PR_in_RAT_got_PositedAt,
                    an.AC_part_PR_in_RAT_got_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_part_PR_in_RAT_got_ID
                        ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_part_PR_in_RAT_got_Posit po
                JOIN
                    AC_part_PR_in_RAT_got_Annex an
                ON
                    an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                WHERE
                    po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.AC_part_PR_in_RAT_got_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_part_PR_in_RAT_got_Reliability = 1
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
    ]';
END pAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    pAC_part_PR_in_RAT_got(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    pAC_part_PR_in_RAT_got(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_part_PR_in_RAT_got (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_part_PR_in_RAT_got_ID,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_part,
                        r.PR_ID_in
                    ORDER BY
                        r.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        r.AC_part_PR_in_RAT_got_PositedAt DESC,
                        r.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_part_PR_in_RAT_got,
                    po.AC_part_PR_in_RAT_got_ID,
                    po.AC_ID_part,
                    po.PR_ID_in,
                    po.RAT_ID_got,
                    po.AC_part_PR_in_RAT_got_ChangedAt,
                    an.AC_part_PR_in_RAT_got_PositedAt,
                    an.AC_part_PR_in_RAT_got_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_part_PR_in_RAT_got_ID
                        ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_part_PR_in_RAT_got_Posit po
                JOIN
                    AC_part_PR_in_RAT_got_Annex an
                ON
                    an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_part_PR_in_RAT_got_Reliability = 1
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
        AND
            t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tST_at_PR_isPlaying (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_isPlaying_ID,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_ID_at,
            t.PR_ID_isPlaying
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_isPlaying
                    ORDER BY
                        r.ST_at_PR_isPlaying_ChangedAt DESC,
                        r.ST_at_PR_isPlaying_PositedAt DESC,
                        r.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_isPlaying,
                    po.ST_at_PR_isPlaying_ID,
                    po.ST_ID_at,
                    po.PR_ID_isPlaying,
                    po.ST_at_PR_isPlaying_ChangedAt,
                    an.ST_at_PR_isPlaying_PositedAt,
                    an.ST_at_PR_isPlaying_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_isPlaying_ID
                        ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ST_at_PR_isPlaying_Posit po
                JOIN
                    ST_at_PR_isPlaying_Annex an
                ON
                    an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                WHERE
                    po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.ST_at_PR_isPlaying_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_isPlaying_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tST_at_PR_isPlaying;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_isPlaying_ID,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_ID_at,
            t.PR_ID_isPlaying
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_isPlaying
                    ORDER BY
                        r.ST_at_PR_isPlaying_ChangedAt DESC,
                        r.ST_at_PR_isPlaying_PositedAt DESC,
                        r.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_isPlaying,
                    po.ST_at_PR_isPlaying_ID,
                    po.ST_ID_at,
                    po.PR_ID_isPlaying,
                    po.ST_at_PR_isPlaying_ChangedAt,
                    an.ST_at_PR_isPlaying_PositedAt,
                    an.ST_at_PR_isPlaying_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_isPlaying_ID
                        ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ST_at_PR_isPlaying_Posit po
                JOIN
                    ST_at_PR_isPlaying_Annex an
                ON
                    an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                WHERE
                    po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                AND
                    an.ST_at_PR_isPlaying_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_isPlaying_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lST_at_PR_isPlaying
AS
SELECT
    *
FROM
    pST_at_PR_isPlaying(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nST_at_PR_isPlaying
AS
SELECT
    *
FROM
    pST_at_PR_isPlaying(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- The posits that the latest perspective shows (as known now) whose changing time is in the interval.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dST_at_PR_isPlaying (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.ST_at_PR_isPlaying_ID,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_ID_at,
            t.PR_ID_isPlaying
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.ST_ID_at,
                        r.PR_ID_isPlaying
                    ORDER BY
                        r.ST_at_PR_isPlaying_ChangedAt DESC,
                        r.ST_at_PR_isPlaying_PositedAt DESC,
                        r.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_ST_at_PR_isPlaying,
                    po.ST_at_PR_isPlaying_ID,
                    po.ST_ID_at,
                    po.PR_ID_isPlaying,
                    po.ST_at_PR_isPlaying_ChangedAt,
                    an.ST_at_PR_isPlaying_PositedAt,
                    an.ST_at_PR_isPlaying_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.ST_at_PR_isPlaying_ID
                        ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                    ) AS rewindRank
                FROM
                    ST_at_PR_isPlaying_Posit po
                JOIN
                    ST_at_PR_isPlaying_Annex an
                ON
                    an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.ST_at_PR_isPlaying_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
        AND
            t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_isPlaying;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_parent_AC_child_PAT_having_ID,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Reliability,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_parent,
                        r.AC_ID_child,
                        r.PAT_ID_having
                    ORDER BY
                        r.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        r.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_parent_AC_child_PAT_having,
                    po.AC_parent_AC_child_PAT_having_ID,
                    po.AC_ID_parent,
                    po.AC_ID_child,
                    po.PAT_ID_having,
                    an.AC_parent_AC_child_PAT_having_PositedAt,
                    an.AC_parent_AC_child_PAT_having_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_parent_AC_child_PAT_having_ID
                        ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_parent_AC_child_PAT_having_Posit po
                JOIN
                    AC_parent_AC_child_PAT_having_Annex an
                ON
                    an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                WHERE
                    an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_parent_AC_child_PAT_having_Reliability = 1
        ) t
        LEFT JOIN
            PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.latestPosit = 1
    ]';
END tAC_parent_AC_child_PAT_having;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.AC_parent_AC_child_PAT_having_ID,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Reliability,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.AC_ID_parent,
                        r.AC_ID_child,
                        r.PAT_ID_having
                    ORDER BY
                        r.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        r.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_AC_parent_AC_child_PAT_having,
                    po.AC_parent_AC_child_PAT_having_ID,
                    po.AC_ID_parent,
                    po.AC_ID_child,
                    po.PAT_ID_having,
                    an.AC_parent_AC_child_PAT_having_PositedAt,
                    an.AC_parent_AC_child_PAT_having_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.AC_parent_AC_child_PAT_having_ID
                        ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                    ) AS rewindRank
                FROM
                    AC_parent_AC_child_PAT_having_Posit po
                JOIN
                    AC_parent_AC_child_PAT_having_Annex an
                ON
                    an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                WHERE
                    an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.AC_parent_AC_child_PAT_having_Reliability = 1
        ) t
        LEFT JOIN
            PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.latestPosit = 1
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    pAC_parent_AC_child_PAT_having(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The latest reliable posit for the identifiers (for each anchor, in a tie without identifiers), as known at the positing
-- time, in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_content_ST_location_EV_of_ID,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Reliability,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_of
                    ORDER BY
                        r.PR_content_ST_location_EV_of_PositedAt DESC,
                        r.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_PR_content_ST_location_EV_of,
                    po.PR_content_ST_location_EV_of_ID,
                    po.PR_ID_content,
                    po.ST_ID_location,
                    po.EV_ID_of,
                    an.PR_content_ST_location_EV_of_PositedAt,
                    an.PR_content_ST_location_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_content_ST_location_EV_of_ID
                        ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    PR_content_ST_location_EV_of_Posit po
                JOIN
                    PR_content_ST_location_EV_of_Annex an
                ON
                    an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                WHERE
                    an.PR_content_ST_location_EV_of_PositedAt <= CAST(positingTimepoint AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_content_ST_location_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END tPR_content_ST_location_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What the time traveling perspective shows as known now (positing time end of time) and in effect at the changing time.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            t.PR_content_ST_location_EV_of_ID,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Reliability,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of
        FROM (
            SELECT
                r.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        r.EV_ID_of
                    ORDER BY
                        r.PR_content_ST_location_EV_of_PositedAt DESC,
                        r.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    an.Metadata_PR_content_ST_location_EV_of,
                    po.PR_content_ST_location_EV_of_ID,
                    po.PR_ID_content,
                    po.ST_ID_location,
                    po.EV_ID_of,
                    an.PR_content_ST_location_EV_of_PositedAt,
                    an.PR_content_ST_location_EV_of_Reliability,
                    ROW_NUMBER() OVER (
                        PARTITION BY po.PR_content_ST_location_EV_of_ID
                        ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                    ) AS rewindRank
                FROM
                    PR_content_ST_location_EV_of_Posit po
                JOIN
                    PR_content_ST_location_EV_of_Annex an
                ON
                    an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                WHERE
                    an.PR_content_ST_location_EV_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp)
            ) r
            WHERE
                r.rewindRank = 1
            AND
                r.PR_content_ST_location_EV_of_Reliability = 1
        ) t
        WHERE
            t.latestPosit = 1
    ]';
END pPR_content_ST_location_EV_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    pPR_content_ST_location_EV_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    pPR_content_ST_location_EV_of(CAST(current_timestamp AS timestamp(9)))
;
