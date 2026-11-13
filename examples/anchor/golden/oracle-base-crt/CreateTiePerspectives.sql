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
CREATE OR REPLACE FUNCTION tAC_partner_AC_with_ONG_currently (
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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
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
            ONG_Ongoing "kONG_currently"
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
CREATE OR REPLACE FUNCTION pAC_partner_AC_with_ONG_currently (
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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
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
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Assertion = '+'
            AND
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.AC_partner_AC_with_ONG_currently_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            q.Positor,
            q.inspectedTimepoint,
            q.Metadata_AC_partner_AC_with_ONG_currently,
            q.AC_ID_partner,
            q.AC_ID_with,
            q.currently_ONG_Ongoing,
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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
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
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_partner_AC_with_ONG_currently_Positor AS inspectedPositor,
                CAST(h.AC_partner_AC_with_ONG_currently_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                AC_partner_AC_with_ONG_currently h
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
                            AC_partner_AC_with_ONG_currently_Posit po
                        JOIN
                            AC_partner_AC_with_ONG_currently_Annex an
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
            ONG_Ongoing "kONG_currently"
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
CREATE OR REPLACE FUNCTION tAC_subset_PN_of (
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
CREATE OR REPLACE FUNCTION pAC_subset_PN_of (
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
            ) s
            WHERE
                s.AC_subset_PN_of_Assertion = '+'
        ) t
        JOIN
            Positor_ positorTable
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tEV_in_AC_wasCast (
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
            t.Metadata_EV_in_AC_wasCast,
            t.EV_ID_in,
            t.AC_ID_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Positor,
            t.EV_in_AC_wasCast_Reliability,
            t.EV_in_AC_wasCast_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_wasCast_Positor,
                        s.EV_ID_in,
                        s.AC_ID_wasCast
                    ORDER BY
                        s.EV_in_AC_wasCast_PositedAt DESC,
                        s.EV_in_AC_wasCast_Reliability DESC,
                        s.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_wasCast,
                        po.EV_in_AC_wasCast_ID,
                        po.EV_ID_in,
                        po.AC_ID_wasCast,
                        an.EV_in_AC_wasCast_PositedAt,
                        an.EV_in_AC_wasCast_Positor,
                        an.EV_in_AC_wasCast_Reliability,
                        an.EV_in_AC_wasCast_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_wasCast_ID, an.EV_in_AC_wasCast_Positor
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
            ) s
            WHERE
                s.EV_in_AC_wasCast_Assertion = COALESCE(assertion, s.EV_in_AC_wasCast_Assertion)
        ) t
        WHERE
            t.EV_in_AC_wasCast_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tEV_in_AC_wasCast;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_ID_in,
            t.AC_ID_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Positor,
            t.EV_in_AC_wasCast_Reliability,
            t.EV_in_AC_wasCast_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_wasCast_Positor,
                        s.EV_ID_in,
                        s.AC_ID_wasCast
                    ORDER BY
                        s.EV_in_AC_wasCast_PositedAt DESC,
                        s.EV_in_AC_wasCast_Reliability DESC,
                        s.EV_in_AC_wasCast_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_EV_in_AC_wasCast,
                        po.EV_in_AC_wasCast_ID,
                        po.EV_ID_in,
                        po.AC_ID_wasCast,
                        an.EV_in_AC_wasCast_PositedAt,
                        an.EV_in_AC_wasCast_Positor,
                        an.EV_in_AC_wasCast_Reliability,
                        an.EV_in_AC_wasCast_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_wasCast_ID, an.EV_in_AC_wasCast_Positor
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
            ) s
            WHERE
                s.EV_in_AC_wasCast_Assertion = '+'
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.EV_in_AC_wasCast_Positor
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_part_PR_in_RAT_got (
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
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Positor,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_part_PR_in_RAT_got_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_part_PR_in_RAT_got_Positor,
                        s.AC_ID_part,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        s.AC_part_PR_in_RAT_got_PositedAt DESC,
                        s.AC_part_PR_in_RAT_got_Reliability DESC,
                        s.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_part_PR_in_RAT_got_Assertion <> '?' THEN r.AC_part_PR_in_RAT_got_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_part_PR_in_RAT_got_Positor,
                            r.AC_ID_part,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_part_PR_in_RAT_got,
                        po.AC_part_PR_in_RAT_got_ID,
                        po.AC_ID_part,
                        po.PR_ID_in,
                        po.RAT_ID_got,
                        po.AC_part_PR_in_RAT_got_ChangedAt,
                        an.AC_part_PR_in_RAT_got_PositedAt,
                        an.AC_part_PR_in_RAT_got_Positor,
                        an.AC_part_PR_in_RAT_got_Reliability,
                        an.AC_part_PR_in_RAT_got_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Positor
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
            ) s
            WHERE
                s.AC_part_PR_in_RAT_got_Assertion = COALESCE(assertion, s.AC_part_PR_in_RAT_got_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_part_PR_in_RAT_got_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.AC_part_PR_in_RAT_got_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_part_PR_in_RAT_got;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Positor,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_part_PR_in_RAT_got_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_part_PR_in_RAT_got_Positor,
                        s.AC_ID_part,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        s.AC_part_PR_in_RAT_got_PositedAt DESC,
                        s.AC_part_PR_in_RAT_got_Reliability DESC,
                        s.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_part_PR_in_RAT_got_Assertion <> '?' THEN r.AC_part_PR_in_RAT_got_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_part_PR_in_RAT_got_Positor,
                            r.AC_ID_part,
                            r.PR_ID_in
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_AC_part_PR_in_RAT_got,
                        po.AC_part_PR_in_RAT_got_ID,
                        po.AC_ID_part,
                        po.PR_ID_in,
                        po.RAT_ID_got,
                        po.AC_part_PR_in_RAT_got_ChangedAt,
                        an.AC_part_PR_in_RAT_got_PositedAt,
                        an.AC_part_PR_in_RAT_got_Positor,
                        an.AC_part_PR_in_RAT_got_Reliability,
                        an.AC_part_PR_in_RAT_got_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Positor
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
            ) s
            WHERE
                s.AC_part_PR_in_RAT_got_Assertion = '+'
            AND
                s.AC_part_PR_in_RAT_got_ChangedAt = s.inEffect
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.AC_part_PR_in_RAT_got_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Positor,
            t.AC_part_PR_in_RAT_got_Reliability,
            t.AC_part_PR_in_RAT_got_Assertion
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_part_PR_in_RAT_got_Positor AS inspectedPositor,
                CAST(h.AC_part_PR_in_RAT_got_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                AC_part_PR_in_RAT_got h
            WHERE
                h.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_part_PR_in_RAT_got_Positor,
                        y.AC_ID_part,
                        y.PR_ID_in
                    ORDER BY y.AC_part_PR_in_RAT_got_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.AC_part_PR_in_RAT_got_Positor,
                                r.AC_ID_part,
                                r.PR_ID_in,
                                r.AC_part_PR_in_RAT_got_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_part_PR_in_RAT_got_Assertion = '+' THEN 0 ELSE 1 END,
                                r.AC_part_PR_in_RAT_got_PositedAt DESC,
                                r.AC_part_PR_in_RAT_got_Reliability DESC,
                                r.AC_part_PR_in_RAT_got_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_AC_part_PR_in_RAT_got,
                            po.AC_part_PR_in_RAT_got_ID,
                            po.AC_ID_part,
                            po.PR_ID_in,
                            po.RAT_ID_got,
                            po.AC_part_PR_in_RAT_got_ChangedAt,
                            an.AC_part_PR_in_RAT_got_PositedAt,
                            an.AC_part_PR_in_RAT_got_Positor,
                            an.AC_part_PR_in_RAT_got_Reliability,
                            an.AC_part_PR_in_RAT_got_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Positor
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
                        r.AC_part_PR_in_RAT_got_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_part_PR_in_RAT_got_Positor = tp.inspectedPositor
        AND
            t.AC_part_PR_in_RAT_got_Assertion = '+'
        AND
            t.AC_part_PR_in_RAT_got_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tST_at_PR_isPlaying (
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
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Positor,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_at_PR_isPlaying_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_isPlaying_Positor,
                        s.ST_ID_at,
                        s.PR_ID_isPlaying
                    ORDER BY
                        s.ST_at_PR_isPlaying_ChangedAt DESC,
                        s.ST_at_PR_isPlaying_PositedAt DESC,
                        s.ST_at_PR_isPlaying_Reliability DESC,
                        s.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_isPlaying_Assertion <> '?' THEN r.ST_at_PR_isPlaying_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_isPlaying_Positor,
                            r.ST_ID_at,
                            r.PR_ID_isPlaying
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_isPlaying,
                        po.ST_at_PR_isPlaying_ID,
                        po.ST_ID_at,
                        po.PR_ID_isPlaying,
                        po.ST_at_PR_isPlaying_ChangedAt,
                        an.ST_at_PR_isPlaying_PositedAt,
                        an.ST_at_PR_isPlaying_Positor,
                        an.ST_at_PR_isPlaying_Reliability,
                        an.ST_at_PR_isPlaying_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Positor
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
            ) s
            WHERE
                s.ST_at_PR_isPlaying_Assertion = COALESCE(assertion, s.ST_at_PR_isPlaying_Assertion)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.ST_at_PR_isPlaying_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.ST_at_PR_isPlaying_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tST_at_PR_isPlaying;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Positor,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_at_PR_isPlaying_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_isPlaying_Positor,
                        s.ST_ID_at,
                        s.PR_ID_isPlaying
                    ORDER BY
                        s.ST_at_PR_isPlaying_ChangedAt DESC,
                        s.ST_at_PR_isPlaying_PositedAt DESC,
                        s.ST_at_PR_isPlaying_Reliability DESC,
                        s.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_isPlaying_Assertion <> '?' THEN r.ST_at_PR_isPlaying_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_isPlaying_Positor,
                            r.ST_ID_at,
                            r.PR_ID_isPlaying
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_ST_at_PR_isPlaying,
                        po.ST_at_PR_isPlaying_ID,
                        po.ST_ID_at,
                        po.PR_ID_isPlaying,
                        po.ST_at_PR_isPlaying_ChangedAt,
                        an.ST_at_PR_isPlaying_PositedAt,
                        an.ST_at_PR_isPlaying_Positor,
                        an.ST_at_PR_isPlaying_Reliability,
                        an.ST_at_PR_isPlaying_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Positor
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
            ) s
            WHERE
                s.ST_at_PR_isPlaying_Assertion = '+'
            AND
                s.ST_at_PR_isPlaying_ChangedAt = s.inEffect
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.ST_at_PR_isPlaying_Positor
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
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
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
            positorTable.Positor,
            tp.inspectedTimepoint,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Positor,
            t.ST_at_PR_isPlaying_Reliability,
            t.ST_at_PR_isPlaying_Assertion
        FROM
            Positor_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_at_PR_isPlaying_Positor AS inspectedPositor,
                CAST(h.ST_at_PR_isPlaying_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ST_at_PR_isPlaying h
            WHERE
                h.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Positor
        JOIN (
            SELECT
                y.*,
                LEAD(y.ST_at_PR_isPlaying_ChangedAt) OVER (
                    PARTITION BY
                        y.ST_at_PR_isPlaying_Positor,
                        y.ST_ID_at,
                        y.PR_ID_isPlaying
                    ORDER BY y.ST_at_PR_isPlaying_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.ST_at_PR_isPlaying_Positor,
                                r.ST_ID_at,
                                r.PR_ID_isPlaying,
                                r.ST_at_PR_isPlaying_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_at_PR_isPlaying_Assertion = '+' THEN 0 ELSE 1 END,
                                r.ST_at_PR_isPlaying_PositedAt DESC,
                                r.ST_at_PR_isPlaying_Reliability DESC,
                                r.ST_at_PR_isPlaying_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_ST_at_PR_isPlaying,
                            po.ST_at_PR_isPlaying_ID,
                            po.ST_ID_at,
                            po.PR_ID_isPlaying,
                            po.ST_at_PR_isPlaying_ChangedAt,
                            an.ST_at_PR_isPlaying_PositedAt,
                            an.ST_at_PR_isPlaying_Positor,
                            an.ST_at_PR_isPlaying_Reliability,
                            an.ST_at_PR_isPlaying_Assertion,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Positor
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
                        r.ST_at_PR_isPlaying_Assertion <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.ST_at_PR_isPlaying_Positor = tp.inspectedPositor
        AND
            t.ST_at_PR_isPlaying_Assertion = '+'
        AND
            t.ST_at_PR_isPlaying_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
    ]';
END dST_at_PR_isPlaying;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tAC_parent_AC_child_PAT_having (
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
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Positor,
            t.AC_parent_AC_child_PAT_having_Reliability,
            t.AC_parent_AC_child_PAT_having_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_parent_AC_child_PAT_having_Positor,
                        s.AC_ID_parent,
                        s.AC_ID_child,
                        s.PAT_ID_having
                    ORDER BY
                        s.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        s.AC_parent_AC_child_PAT_having_Reliability DESC,
                        s.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_parent_AC_child_PAT_having,
                        po.AC_parent_AC_child_PAT_having_ID,
                        po.AC_ID_parent,
                        po.AC_ID_child,
                        po.PAT_ID_having,
                        an.AC_parent_AC_child_PAT_having_PositedAt,
                        an.AC_parent_AC_child_PAT_having_Positor,
                        an.AC_parent_AC_child_PAT_having_Reliability,
                        an.AC_parent_AC_child_PAT_having_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_parent_AC_child_PAT_having_ID, an.AC_parent_AC_child_PAT_having_Positor
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
            ) s
            WHERE
                s.AC_parent_AC_child_PAT_having_Assertion = COALESCE(assertion, s.AC_parent_AC_child_PAT_having_Assertion)
        ) t
        LEFT JOIN
            PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.AC_parent_AC_child_PAT_having_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_parent_AC_child_PAT_having;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Positor,
            t.AC_parent_AC_child_PAT_having_Reliability,
            t.AC_parent_AC_child_PAT_having_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_parent_AC_child_PAT_having_Positor,
                        s.AC_ID_parent,
                        s.AC_ID_child,
                        s.PAT_ID_having
                    ORDER BY
                        s.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        s.AC_parent_AC_child_PAT_having_Reliability DESC,
                        s.AC_parent_AC_child_PAT_having_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_AC_parent_AC_child_PAT_having,
                        po.AC_parent_AC_child_PAT_having_ID,
                        po.AC_ID_parent,
                        po.AC_ID_child,
                        po.PAT_ID_having,
                        an.AC_parent_AC_child_PAT_having_PositedAt,
                        an.AC_parent_AC_child_PAT_having_Positor,
                        an.AC_parent_AC_child_PAT_having_Reliability,
                        an.AC_parent_AC_child_PAT_having_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_parent_AC_child_PAT_having_ID, an.AC_parent_AC_child_PAT_having_Positor
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
            ) s
            WHERE
                s.AC_parent_AC_child_PAT_having_Assertion = '+'
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.AC_parent_AC_child_PAT_having_Positor
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
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tPR_content_ST_location_EV_of (
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
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Positor,
            t.PR_content_ST_location_EV_of_Reliability,
            t.PR_content_ST_location_EV_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.PR_content_ST_location_EV_of_Positor,
                        s.EV_ID_of
                    ORDER BY
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Reliability DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_PR_content_ST_location_EV_of,
                        po.PR_content_ST_location_EV_of_ID,
                        po.PR_ID_content,
                        po.ST_ID_location,
                        po.EV_ID_of,
                        an.PR_content_ST_location_EV_of_PositedAt,
                        an.PR_content_ST_location_EV_of_Positor,
                        an.PR_content_ST_location_EV_of_Reliability,
                        an.PR_content_ST_location_EV_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Positor
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
            ) s
            WHERE
                s.PR_content_ST_location_EV_of_Assertion = COALESCE(assertion, s.PR_content_ST_location_EV_of_Assertion)
        ) t
        WHERE
            t.PR_content_ST_location_EV_of_Positor = forPositor
        AND
            t.latestPosit = 1
    ]';
END tPR_content_ST_location_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Positor,
            CAST(NULL AS number(5,2)) AS Reliability,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Positor,
            t.PR_content_ST_location_EV_of_Reliability,
            t.PR_content_ST_location_EV_of_Assertion
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.PR_content_ST_location_EV_of_Positor,
                        s.EV_ID_of
                    ORDER BY
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Reliability DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*
                FROM (
                    SELECT
                        an.Metadata_PR_content_ST_location_EV_of,
                        po.PR_content_ST_location_EV_of_ID,
                        po.PR_ID_content,
                        po.ST_ID_location,
                        po.EV_ID_of,
                        an.PR_content_ST_location_EV_of_PositedAt,
                        an.PR_content_ST_location_EV_of_Positor,
                        an.PR_content_ST_location_EV_of_Reliability,
                        an.PR_content_ST_location_EV_of_Assertion,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Positor
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
            ) s
            WHERE
                s.PR_content_ST_location_EV_of_Assertion = '+'
        ) t
        JOIN
            Positor_ positorTable
        ON
            positorTable.Positor = t.PR_content_ST_location_EV_of_Positor
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
