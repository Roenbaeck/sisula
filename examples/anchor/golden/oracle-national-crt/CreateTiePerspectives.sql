-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- The time traveling, point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or
-- later): a function that returns the text of a query, in which its parameters stand for the values given. They are called
-- in the FROM clause of a query, like a table: SELECT * FROM pAC_part_PR_wasPlayed(TIMESTAMP '2020-01-01 00:00:00').
--
-- The rewinder of a tie is not called in the macros, what it does is written out in them: the posit and annex of the
-- tie joined, the annex with the latest positing time picked for each posit and positor.
--
-- The latest and now perspectives are views over the point-in-time macro. A macro cannot be given a column of another
-- table to work for each positor, so the point-in-time macro works out the views of all positors itself, as does the
-- difference macro. The time traveling macro shows one positor, given by its first argument.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
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
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Positor,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Assertion <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Positor,
                            r.AC_ID_partner,
                            r.AC_ID_with,
                            r.ONG_ID_currently
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_partner_AC_with_ONG_currently,
                        po.AC_partner_AC_with_ONG_currently_ID,
                        po.AC_ID_partner,
                        po.AC_ID_with,
                        po.ONG_ID_currently,
                        po.AC_partner_AC_with_ONG_currently_ChangedAt,
                        an.AC_partner_AC_with_ONG_currently_PositedAt,
                        an.AC_partner_AC_with_ONG_currently_Positor,
                        an.AC_partner_AC_with_ONG_currently_Reliability,
                        an.AC_partner_AC_with_ONG_currently_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Positor
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
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Assertion = COALESCE(assertion, s.AC_partner_AC_with_ONG_currently_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.AC_partner_AC_with_ONG_currently_Positor = forPositor
        AND
            t.latestPositAC_ID_partner = 1
        AND
            t.latestPositAC_ID_with = 1
    ]';
END tAC_partner_AC_with_ONG_currently;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Positor,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Positor, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Reliability DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Assertion <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Positor,
                            r.AC_ID_partner,
                            r.AC_ID_with,
                            r.ONG_ID_currently
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_partner_AC_with_ONG_currently,
                        po.AC_partner_AC_with_ONG_currently_ID,
                        po.AC_ID_partner,
                        po.AC_ID_with,
                        po.ONG_ID_currently,
                        po.AC_partner_AC_with_ONG_currently_ChangedAt,
                        an.AC_partner_AC_with_ONG_currently_PositedAt,
                        an.AC_partner_AC_with_ONG_currently_Positor,
                        an.AC_partner_AC_with_ONG_currently_Reliability,
                        an.AC_partner_AC_with_ONG_currently_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Positor
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
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Assertion = '+'
            AND
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_partner_AC_with_ONG_currently_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            q.Positor,
            q.inspectedTimepoint,
            q.Metadata_AC_partner_AC_with_ONG_currently,
            q.AC_ID_partner,
            q.AC_ID_with,
            q.currently_ONG_Pågående,
            q.currently_Metadata_ONG,
            q.ONG_ID_currently,
            q.AC_partner_AC_with_ONG_currently_ChangedAt,
            q.AC_partner_AC_with_ONG_currently_PositedAt,
            q.AC_partner_AC_with_ONG_currently_Positor,
            q.AC_partner_AC_with_ONG_currently_Reliability,
            q.AC_partner_AC_with_ONG_currently_Assertion
        FROM (
        SELECT
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Positor,
            t.AC_partner_AC_with_ONG_currently_Reliability,
            t.AC_partner_AC_with_ONG_currently_Assertion,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_partner
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Reliability DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_partner,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_with
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Reliability DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_with
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_partner_AC_with_ONG_currently_Positor AS inspectedPositor,
                CAST(h.AC_partner_AC_with_ONG_currently_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_partner_AC_with_ONG_currently h
            WHERE
                h.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_partner_AC_with_ONG_currently_Positor,
                        y.AC_ID_partner,
                        y.AC_ID_with,
                        y.ONG_ID_currently
                    ORDER BY y.AC_partner_AC_with_ONG_currently_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_partner_AC_with_ONG_currently_Positor,
                                r.AC_ID_partner,
                                r.AC_ID_with,
                                r.ONG_ID_currently,
                                r.AC_partner_AC_with_ONG_currently_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_partner_AC_with_ONG_currently_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                                r.AC_partner_AC_with_ONG_currently_Reliability DESC,
                                r.AC_partner_AC_with_ONG_currently_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_partner_AC_with_ONG_currently,
                            po.AC_partner_AC_with_ONG_currently_ID,
                            po.AC_ID_partner,
                            po.AC_ID_with,
                            po.ONG_ID_currently,
                            po.AC_partner_AC_with_ONG_currently_ChangedAt,
                            an.AC_partner_AC_with_ONG_currently_PositedAt,
                            an.AC_partner_AC_with_ONG_currently_Positor,
                            an.AC_partner_AC_with_ONG_currently_Reliability,
                            an.AC_partner_AC_with_ONG_currently_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Positor
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
                        r.AC_partner_AC_with_ONG_currently_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_partner_AC_with_ONG_currently_Positor = tp.inspectedPositor
        AND
            t.AC_partner_AC_with_ONG_currently_Assertion = '+'
        AND
            t.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.ONG_Pågående "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        ) q
        WHERE
            q.latestPositAC_ID_partner = 1
        AND
            q.latestPositAC_ID_with = 1
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
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
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Positor,
            t.AC_subset_PN_of_Reliability,
            t.AC_subset_PN_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_subset_PN_of,
                        po.AC_subset_PN_of_ID,
                        po.AC_ID_subset,
                        po.PN_ID_of,
                        an.AC_subset_PN_of_PositedAt,
                        an.AC_subset_PN_of_Positor,
                        an.AC_subset_PN_of_Reliability,
                        an.AC_subset_PN_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Positor
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
            ) s
            WHERE
                s.AC_subset_PN_of_Assertion = COALESCE(assertion, s.AC_subset_PN_of_Assertion)
        ) t
        WHERE
            t.AC_subset_PN_of_Positor = forPositor
        AND
            t.latestPositAC_ID_subset = 1
        AND
            t.latestPositPN_ID_of = 1
    ]';
END tAC_subset_PN_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Positor,
            t.AC_subset_PN_of_Reliability,
            t.AC_subset_PN_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Positor, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Reliability DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositPN_ID_of
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_subset_PN_of,
                        po.AC_subset_PN_of_ID,
                        po.AC_ID_subset,
                        po.PN_ID_of,
                        an.AC_subset_PN_of_PositedAt,
                        an.AC_subset_PN_of_Positor,
                        an.AC_subset_PN_of_Reliability,
                        an.AC_subset_PN_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Positor
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
            ) s
            WHERE
                s.AC_subset_PN_of_Assertion = '+'
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_subset_PN_of_Positor
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_rollsattes (
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
            t.Metadata_EV_in_AC_rollsattes,
            t.EV_ID_in,
            t.AC_ID_rollsattes,
            t.EV_in_AC_rollsattes_PositedAt,
            t.EV_in_AC_rollsattes_Positor,
            t.EV_in_AC_rollsattes_Reliability,
            t.EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_rollsattes_Positor,
                        s.EV_ID_in,
                        s.AC_ID_rollsattes
                    ORDER BY
                        s.EV_in_AC_rollsattes_PositedAt DESC,
                        s.EV_in_AC_rollsattes_Reliability DESC,
                        s.EV_in_AC_rollsattes_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_rollsattes,
                        po.EV_in_AC_rollsattes_ID,
                        po.EV_ID_in,
                        po.AC_ID_rollsattes,
                        an.EV_in_AC_rollsattes_PositedAt,
                        an.EV_in_AC_rollsattes_Positor,
                        an.EV_in_AC_rollsattes_Reliability,
                        an.EV_in_AC_rollsattes_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_rollsattes_ID, an.EV_in_AC_rollsattes_Positor
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
            ) s
            WHERE
                s.EV_in_AC_rollsattes_Assertion = COALESCE(assertion, s.EV_in_AC_rollsattes_Assertion)
        ) t
        WHERE
            t.EV_in_AC_rollsattes_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tEV_in_AC_rollsattes;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_EV_in_AC_rollsattes,
            t.EV_ID_in,
            t.AC_ID_rollsattes,
            t.EV_in_AC_rollsattes_PositedAt,
            t.EV_in_AC_rollsattes_Positor,
            t.EV_in_AC_rollsattes_Reliability,
            t.EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_rollsattes_Positor,
                        s.EV_ID_in,
                        s.AC_ID_rollsattes
                    ORDER BY
                        s.EV_in_AC_rollsattes_PositedAt DESC,
                        s.EV_in_AC_rollsattes_Reliability DESC,
                        s.EV_in_AC_rollsattes_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_rollsattes,
                        po.EV_in_AC_rollsattes_ID,
                        po.EV_ID_in,
                        po.AC_ID_rollsattes,
                        an.EV_in_AC_rollsattes_PositedAt,
                        an.EV_in_AC_rollsattes_Positor,
                        an.EV_in_AC_rollsattes_Reliability,
                        an.EV_in_AC_rollsattes_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_rollsattes_ID, an.EV_in_AC_rollsattes_Positor
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
            ) s
            WHERE
                s.EV_in_AC_rollsattes_Assertion = '+'
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.EV_in_AC_rollsattes_Positor
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_deltar_PR_in_RAT_fick (
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
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Positor,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_deltar_PR_in_RAT_fick_Positor,
                        s.AC_ID_deltar,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_Reliability DESC,
                        s.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_deltar_PR_in_RAT_fick_Assertion <> '?' THEN r.AC_deltar_PR_in_RAT_fick_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_deltar_PR_in_RAT_fick_Positor,
                            r.AC_ID_deltar,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_deltar_PR_in_RAT_fick,
                        po.AC_deltar_PR_in_RAT_fick_ID,
                        po.AC_ID_deltar,
                        po.PR_ID_in,
                        po.RAT_ID_fick,
                        po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                        an.AC_deltar_PR_in_RAT_fick_PositedAt,
                        an.AC_deltar_PR_in_RAT_fick_Positor,
                        an.AC_deltar_PR_in_RAT_fick_Reliability,
                        an.AC_deltar_PR_in_RAT_fick_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID, an.AC_deltar_PR_in_RAT_fick_Positor
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
            ) s
            WHERE
                s.AC_deltar_PR_in_RAT_fick_Assertion = COALESCE(assertion, s.AC_deltar_PR_in_RAT_fick_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_deltar_PR_in_RAT_fick_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
        WHERE
            t.AC_deltar_PR_in_RAT_fick_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_deltar_PR_in_RAT_fick;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Positor,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_deltar_PR_in_RAT_fick_Positor,
                        s.AC_ID_deltar,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_deltar_PR_in_RAT_fick_ChangedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                        s.AC_deltar_PR_in_RAT_fick_Reliability DESC,
                        s.AC_deltar_PR_in_RAT_fick_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_deltar_PR_in_RAT_fick_Assertion <> '?' THEN r.AC_deltar_PR_in_RAT_fick_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_deltar_PR_in_RAT_fick_Positor,
                            r.AC_ID_deltar,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_deltar_PR_in_RAT_fick,
                        po.AC_deltar_PR_in_RAT_fick_ID,
                        po.AC_ID_deltar,
                        po.PR_ID_in,
                        po.RAT_ID_fick,
                        po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                        an.AC_deltar_PR_in_RAT_fick_PositedAt,
                        an.AC_deltar_PR_in_RAT_fick_Positor,
                        an.AC_deltar_PR_in_RAT_fick_Reliability,
                        an.AC_deltar_PR_in_RAT_fick_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID, an.AC_deltar_PR_in_RAT_fick_Positor
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
            ) s
            WHERE
                s.AC_deltar_PR_in_RAT_fick_Assertion = '+'
            AND
                s.AC_deltar_PR_in_RAT_fick_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_deltar_PR_in_RAT_fick_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_AC_deltar_PR_in_RAT_fick,
            t.AC_ID_deltar,
            t.PR_ID_in,
            "kRAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "kRAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "kRAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            t.RAT_ID_fick,
            t.AC_deltar_PR_in_RAT_fick_ChangedAt,
            t.AC_deltar_PR_in_RAT_fick_PositedAt,
            t.AC_deltar_PR_in_RAT_fick_Positor,
            t.AC_deltar_PR_in_RAT_fick_Reliability,
            t.AC_deltar_PR_in_RAT_fick_Assertion
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_deltar_PR_in_RAT_fick_Positor AS inspectedPositor,
                CAST(h.AC_deltar_PR_in_RAT_fick_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_deltar_PR_in_RAT_fick h
            WHERE
                h.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_deltar_PR_in_RAT_fick_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_deltar_PR_in_RAT_fick_Positor,
                        y.AC_ID_deltar,
                        y.PR_ID_in
                    ORDER BY y.AC_deltar_PR_in_RAT_fick_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_deltar_PR_in_RAT_fick_Positor,
                                r.AC_ID_deltar,
                                r.PR_ID_in,
                                r.AC_deltar_PR_in_RAT_fick_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_deltar_PR_in_RAT_fick_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_deltar_PR_in_RAT_fick_PositedAt DESC,
                                r.AC_deltar_PR_in_RAT_fick_Reliability DESC,
                                r.AC_deltar_PR_in_RAT_fick_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_deltar_PR_in_RAT_fick,
                            po.AC_deltar_PR_in_RAT_fick_ID,
                            po.AC_ID_deltar,
                            po.PR_ID_in,
                            po.RAT_ID_fick,
                            po.AC_deltar_PR_in_RAT_fick_ChangedAt,
                            an.AC_deltar_PR_in_RAT_fick_PositedAt,
                            an.AC_deltar_PR_in_RAT_fick_Positor,
                            an.AC_deltar_PR_in_RAT_fick_Reliability,
                            an.AC_deltar_PR_in_RAT_fick_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_deltar_PR_in_RAT_fick_ID, an.AC_deltar_PR_in_RAT_fick_Positor
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
                        r.AC_deltar_PR_in_RAT_fick_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_deltar_PR_in_RAT_fick_Positor = tp.inspectedPositor
        AND
            t.AC_deltar_PR_in_RAT_fick_Assertion = '+'
        AND
            t.AC_deltar_PR_in_RAT_fick_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.RAT_Betyg "kRAT_fick"
        ON
            "kRAT_fick".RAT_ID = t.RAT_ID_fick
    ]';
END dAC_deltar_PR_in_RAT_fick;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_spelas (
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
            t.Metadata_ST_at_PR_spelas,
            t.ST_ID_at,
            t.PR_ID_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Positor,
            t.ST_at_PR_spelas_Reliability,
            t.ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_spelas_Positor,
                        s.ST_ID_at,
                        s.PR_ID_spelas
                    ORDER BY
                        s.ST_at_PR_spelas_ChangedAt DESC,
                        s.ST_at_PR_spelas_PositedAt DESC,
                        s.ST_at_PR_spelas_Reliability DESC,
                        s.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_spelas_Assertion <> '?' THEN r.ST_at_PR_spelas_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_spelas_Positor,
                            r.ST_ID_at,
                            r.PR_ID_spelas
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_spelas,
                        po.ST_at_PR_spelas_ID,
                        po.ST_ID_at,
                        po.PR_ID_spelas,
                        po.ST_at_PR_spelas_ChangedAt,
                        an.ST_at_PR_spelas_PositedAt,
                        an.ST_at_PR_spelas_Positor,
                        an.ST_at_PR_spelas_Reliability,
                        an.ST_at_PR_spelas_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_spelas_ID, an.ST_at_PR_spelas_Positor
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
            ) s
            WHERE
                s.ST_at_PR_spelas_Assertion = COALESCE(assertion, s.ST_at_PR_spelas_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.ST_at_PR_spelas_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.ST_at_PR_spelas_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tST_at_PR_spelas;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_ST_at_PR_spelas,
            t.ST_ID_at,
            t.PR_ID_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Positor,
            t.ST_at_PR_spelas_Reliability,
            t.ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_spelas_Positor,
                        s.ST_ID_at,
                        s.PR_ID_spelas
                    ORDER BY
                        s.ST_at_PR_spelas_ChangedAt DESC,
                        s.ST_at_PR_spelas_PositedAt DESC,
                        s.ST_at_PR_spelas_Reliability DESC,
                        s.ST_at_PR_spelas_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_spelas_Assertion <> '?' THEN r.ST_at_PR_spelas_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_spelas_Positor,
                            r.ST_ID_at,
                            r.PR_ID_spelas
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_spelas,
                        po.ST_at_PR_spelas_ID,
                        po.ST_ID_at,
                        po.PR_ID_spelas,
                        po.ST_at_PR_spelas_ChangedAt,
                        an.ST_at_PR_spelas_PositedAt,
                        an.ST_at_PR_spelas_Positor,
                        an.ST_at_PR_spelas_Reliability,
                        an.ST_at_PR_spelas_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_spelas_ID, an.ST_at_PR_spelas_Positor
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
            ) s
            WHERE
                s.ST_at_PR_spelas_Assertion = '+'
            AND
                s.ST_at_PR_spelas_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.ST_at_PR_spelas_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_ST_at_PR_spelas,
            t.ST_ID_at,
            t.PR_ID_spelas,
            t.ST_at_PR_spelas_ChangedAt,
            t.ST_at_PR_spelas_PositedAt,
            t.ST_at_PR_spelas_Positor,
            t.ST_at_PR_spelas_Reliability,
            t.ST_at_PR_spelas_Assertion
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_at_PR_spelas_Positor AS inspectedPositor,
                CAST(h.ST_at_PR_spelas_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.ST_at_PR_spelas h
            WHERE
                h.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.ST_at_PR_spelas_ChangedAt) OVER (
                    PARTITION BY
                        y.ST_at_PR_spelas_Positor,
                        y.ST_ID_at,
                        y.PR_ID_spelas
                    ORDER BY y.ST_at_PR_spelas_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.ST_at_PR_spelas_Positor,
                                r.ST_ID_at,
                                r.PR_ID_spelas,
                                r.ST_at_PR_spelas_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_at_PR_spelas_Assertion = '+' THEN 0 ELSE 1 END,
                                r.ST_at_PR_spelas_PositedAt DESC,
                                r.ST_at_PR_spelas_Reliability DESC,
                                r.ST_at_PR_spelas_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_at_PR_spelas,
                            po.ST_at_PR_spelas_ID,
                            po.ST_ID_at,
                            po.PR_ID_spelas,
                            po.ST_at_PR_spelas_ChangedAt,
                            an.ST_at_PR_spelas_PositedAt,
                            an.ST_at_PR_spelas_Positor,
                            an.ST_at_PR_spelas_Reliability,
                            an.ST_at_PR_spelas_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_at_PR_spelas_ID, an.ST_at_PR_spelas_Positor
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
                        r.ST_at_PR_spelas_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.ST_at_PR_spelas_Positor = tp.inspectedPositor
        AND
            t.ST_at_PR_spelas_Assertion = '+'
        AND
            t.ST_at_PR_spelas_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
    ]';
END dST_at_PR_spelas;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_förälder_AC_barn_PAT_har (
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
            t.Metadata_AC_förälder_AC_barn_PAT_har,
            t.AC_ID_förälder,
            t.AC_ID_barn,
            "kPAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "kPAT_har".Metadata_PAT AS har_Metadata_PAT,
            t.PAT_ID_har,
            t.AC_förälder_AC_barn_PAT_har_PositedAt,
            t.AC_förälder_AC_barn_PAT_har_Positor,
            t.AC_förälder_AC_barn_PAT_har_Reliability,
            t.AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_förälder_AC_barn_PAT_har_Positor,
                        s.AC_ID_förälder,
                        s.AC_ID_barn,
                        s.PAT_ID_har
                    ORDER BY
                        s.AC_förälder_AC_barn_PAT_har_PositedAt DESC,
                        s.AC_förälder_AC_barn_PAT_har_Reliability DESC,
                        s.AC_förälder_AC_barn_PAT_har_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_förälder_AC_barn_PAT_har,
                        po.AC_förälder_AC_barn_PAT_har_ID,
                        po.AC_ID_förälder,
                        po.AC_ID_barn,
                        po.PAT_ID_har,
                        an.AC_förälder_AC_barn_PAT_har_PositedAt,
                        an.AC_förälder_AC_barn_PAT_har_Positor,
                        an.AC_förälder_AC_barn_PAT_har_Reliability,
                        an.AC_förälder_AC_barn_PAT_har_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_förälder_AC_barn_PAT_har_ID, an.AC_förälder_AC_barn_PAT_har_Positor
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
            ) s
            WHERE
                s.AC_förälder_AC_barn_PAT_har_Assertion = COALESCE(assertion, s.AC_förälder_AC_barn_PAT_har_Assertion)
        ) t
        LEFT JOIN
            knots.PAT_Föräldratyp "kPAT_har"
        ON
            "kPAT_har".PAT_ID = t.PAT_ID_har
        WHERE
            t.AC_förälder_AC_barn_PAT_har_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_förälder_AC_barn_PAT_har;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_förälder_AC_barn_PAT_har,
            t.AC_ID_förälder,
            t.AC_ID_barn,
            "kPAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "kPAT_har".Metadata_PAT AS har_Metadata_PAT,
            t.PAT_ID_har,
            t.AC_förälder_AC_barn_PAT_har_PositedAt,
            t.AC_förälder_AC_barn_PAT_har_Positor,
            t.AC_förälder_AC_barn_PAT_har_Reliability,
            t.AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_förälder_AC_barn_PAT_har_Positor,
                        s.AC_ID_förälder,
                        s.AC_ID_barn,
                        s.PAT_ID_har
                    ORDER BY
                        s.AC_förälder_AC_barn_PAT_har_PositedAt DESC,
                        s.AC_förälder_AC_barn_PAT_har_Reliability DESC,
                        s.AC_förälder_AC_barn_PAT_har_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_förälder_AC_barn_PAT_har,
                        po.AC_förälder_AC_barn_PAT_har_ID,
                        po.AC_ID_förälder,
                        po.AC_ID_barn,
                        po.PAT_ID_har,
                        an.AC_förälder_AC_barn_PAT_har_PositedAt,
                        an.AC_förälder_AC_barn_PAT_har_Positor,
                        an.AC_förälder_AC_barn_PAT_har_Reliability,
                        an.AC_förälder_AC_barn_PAT_har_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_förälder_AC_barn_PAT_har_ID, an.AC_förälder_AC_barn_PAT_har_Positor
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
            ) s
            WHERE
                s.AC_förälder_AC_barn_PAT_har_Assertion = '+'
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.AC_förälder_AC_barn_PAT_har_Positor
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_innehåll_ST_plats_EV_of (
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
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Positor,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.PR_ID_innehåll
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.ST_ID_plats
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_innehåll_ST_plats_EV_of_Assertion <> '?' THEN r.PR_innehåll_ST_plats_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_innehåll_ST_plats_EV_of_Positor,
                            r.PR_ID_innehåll,
                            r.ST_ID_plats,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_innehåll_ST_plats_EV_of,
                        po.PR_innehåll_ST_plats_EV_of_ID,
                        po.PR_ID_innehåll,
                        po.ST_ID_plats,
                        po.EV_ID_of,
                        po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                        an.PR_innehåll_ST_plats_EV_of_PositedAt,
                        an.PR_innehåll_ST_plats_EV_of_Positor,
                        an.PR_innehåll_ST_plats_EV_of_Reliability,
                        an.PR_innehåll_ST_plats_EV_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID, an.PR_innehåll_ST_plats_EV_of_Positor
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
            ) s
            WHERE
                s.PR_innehåll_ST_plats_EV_of_Assertion = COALESCE(assertion, s.PR_innehåll_ST_plats_EV_of_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.PR_innehåll_ST_plats_EV_of_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.PR_innehåll_ST_plats_EV_of_Positor = forPositor
        AND
            t.latestPositPR_ID_innehåll = 1
        AND
            t.latestPositST_ID_plats = 1
    ]';
END tPR_innehåll_ST_plats_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Positor,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.PR_ID_innehåll
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositPR_ID_innehåll,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_innehåll_ST_plats_EV_of_Positor, s.ST_ID_plats
                    ORDER BY
                        s.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                        s.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                        s.PR_innehåll_ST_plats_EV_of_ID DESC
                ) AS latestPositST_ID_plats
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_innehåll_ST_plats_EV_of_Assertion <> '?' THEN r.PR_innehåll_ST_plats_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_innehåll_ST_plats_EV_of_Positor,
                            r.PR_ID_innehåll,
                            r.ST_ID_plats,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_innehåll_ST_plats_EV_of,
                        po.PR_innehåll_ST_plats_EV_of_ID,
                        po.PR_ID_innehåll,
                        po.ST_ID_plats,
                        po.EV_ID_of,
                        po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                        an.PR_innehåll_ST_plats_EV_of_PositedAt,
                        an.PR_innehåll_ST_plats_EV_of_Positor,
                        an.PR_innehåll_ST_plats_EV_of_Reliability,
                        an.PR_innehåll_ST_plats_EV_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID, an.PR_innehåll_ST_plats_EV_of_Positor
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
            ) s
            WHERE
                s.PR_innehåll_ST_plats_EV_of_Assertion = '+'
            AND
                s.PR_innehåll_ST_plats_EV_of_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Positor_ positorTable
        ON
            positorTable.Positor = t.PR_innehåll_ST_plats_EV_of_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            q.Positor,
            q.inspectedTimepoint,
            q.Metadata_PR_innehåll_ST_plats_EV_of,
            q.PR_ID_innehåll,
            q.ST_ID_plats,
            q.EV_ID_of,
            q.PR_innehåll_ST_plats_EV_of_ChangedAt,
            q.PR_innehåll_ST_plats_EV_of_PositedAt,
            q.PR_innehåll_ST_plats_EV_of_Positor,
            q.PR_innehåll_ST_plats_EV_of_Reliability,
            q.PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
        SELECT
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_PR_innehåll_ST_plats_EV_of,
            t.PR_ID_innehåll,
            t.ST_ID_plats,
            t.EV_ID_of,
            t.PR_innehåll_ST_plats_EV_of_ChangedAt,
            t.PR_innehåll_ST_plats_EV_of_PositedAt,
            t.PR_innehåll_ST_plats_EV_of_Positor,
            t.PR_innehåll_ST_plats_EV_of_Reliability,
            t.PR_innehåll_ST_plats_EV_of_Assertion,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.PR_ID_innehåll
                ORDER BY
                    t.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                    t.PR_innehåll_ST_plats_EV_of_ID DESC
            ) AS latestPositPR_ID_innehåll,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.ST_ID_plats
                ORDER BY
                    t.PR_innehåll_ST_plats_EV_of_ChangedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                    t.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                    t.PR_innehåll_ST_plats_EV_of_ID DESC
            ) AS latestPositST_ID_plats
        FROM
            dw.Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_innehåll_ST_plats_EV_of_Positor AS inspectedPositor,
                CAST(h.PR_innehåll_ST_plats_EV_of_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.PR_innehåll_ST_plats_EV_of h
            WHERE
                h.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (
                    PARTITION BY
                        y.PR_innehåll_ST_plats_EV_of_Positor,
                        y.PR_ID_innehåll,
                        y.ST_ID_plats,
                        y.EV_ID_of
                    ORDER BY y.PR_innehåll_ST_plats_EV_of_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.PR_innehåll_ST_plats_EV_of_Positor,
                                r.PR_ID_innehåll,
                                r.ST_ID_plats,
                                r.EV_ID_of,
                                r.PR_innehåll_ST_plats_EV_of_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_innehåll_ST_plats_EV_of_Assertion = '+' THEN 0 ELSE 1 END,
                                r.PR_innehåll_ST_plats_EV_of_PositedAt DESC,
                                r.PR_innehåll_ST_plats_EV_of_Reliability DESC,
                                r.PR_innehåll_ST_plats_EV_of_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_innehåll_ST_plats_EV_of,
                            po.PR_innehåll_ST_plats_EV_of_ID,
                            po.PR_ID_innehåll,
                            po.ST_ID_plats,
                            po.EV_ID_of,
                            po.PR_innehåll_ST_plats_EV_of_ChangedAt,
                            an.PR_innehåll_ST_plats_EV_of_PositedAt,
                            an.PR_innehåll_ST_plats_EV_of_Positor,
                            an.PR_innehåll_ST_plats_EV_of_Reliability,
                            an.PR_innehåll_ST_plats_EV_of_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_innehåll_ST_plats_EV_of_ID, an.PR_innehåll_ST_plats_EV_of_Positor
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
                        r.PR_innehåll_ST_plats_EV_of_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.PR_innehåll_ST_plats_EV_of_Positor = tp.inspectedPositor
        AND
            t.PR_innehåll_ST_plats_EV_of_Assertion = '+'
        AND
            t.PR_innehåll_ST_plats_EV_of_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        ) q
        WHERE
            q.latestPositPR_ID_innehåll = 1
        AND
            q.latestPositST_ID_plats = 1
    ]';
END dPR_innehåll_ST_plats_EV_of;
/
