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
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Who,
            t.AC_partner_AC_with_ONG_currently_Confidence,
            t.AC_partner_AC_with_ONG_currently_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Stance <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Who,
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
                        an.AC_partner_AC_with_ONG_currently_Who,
                        an.AC_partner_AC_with_ONG_currently_Confidence,
                        an.AC_partner_AC_with_ONG_currently_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Who
                            ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_partner_AC_with_ONG_currently_Fact po
                    JOIN
                        ties.AC_partner_AC_with_ONG_currently_Meta an
                    ON
                        an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    WHERE
                        po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Stance = COALESCE(assertion, s.AC_partner_AC_with_ONG_currently_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.ONG_Ongoing "kONG_currently"
        ON
            "kONG_currently".ONG_ID = t.ONG_ID_currently
        WHERE
            t.AC_partner_AC_with_ONG_currently_Who = forPositor
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
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Who,
            t.AC_partner_AC_with_ONG_currently_Confidence,
            t.AC_partner_AC_with_ONG_currently_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_partner
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_partner,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_partner_AC_with_ONG_currently_Who, s.AC_ID_with
                    ORDER BY
                        s.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                        s.AC_partner_AC_with_ONG_currently_Confidence DESC,
                        s.AC_partner_AC_with_ONG_currently_ID DESC
                ) AS latestPositAC_ID_with
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_partner_AC_with_ONG_currently_Stance <> '?' THEN r.AC_partner_AC_with_ONG_currently_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_partner_AC_with_ONG_currently_Who,
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
                        an.AC_partner_AC_with_ONG_currently_Who,
                        an.AC_partner_AC_with_ONG_currently_Confidence,
                        an.AC_partner_AC_with_ONG_currently_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Who
                            ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_partner_AC_with_ONG_currently_Fact po
                    JOIN
                        ties.AC_partner_AC_with_ONG_currently_Meta an
                    ON
                        an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    WHERE
                        po.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_partner_AC_with_ONG_currently_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_partner_AC_with_ONG_currently_Stance = '+'
            AND
                s.AC_partner_AC_with_ONG_currently_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_partner_AC_with_ONG_currently_Who
        LEFT JOIN
            knots.ONG_Ongoing "kONG_currently"
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
            q.Who,
            q.inspectedTimepoint,
            q.Metadata_AC_partner_AC_with_ONG_currently,
            q.AC_ID_partner,
            q.AC_ID_with,
            q.currently_ONG_Ongoing,
            q.currently_Metadata_ONG,
            q.ONG_ID_currently,
            q.AC_partner_AC_with_ONG_currently_ChangedAt,
            q.AC_partner_AC_with_ONG_currently_PositedAt,
            q.AC_partner_AC_with_ONG_currently_Who,
            q.AC_partner_AC_with_ONG_currently_Confidence,
            q.AC_partner_AC_with_ONG_currently_Stance
        FROM (
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_AC_partner_AC_with_ONG_currently,
            t.AC_ID_partner,
            t.AC_ID_with,
            "kONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "kONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            t.ONG_ID_currently,
            t.AC_partner_AC_with_ONG_currently_ChangedAt,
            t.AC_partner_AC_with_ONG_currently_PositedAt,
            t.AC_partner_AC_with_ONG_currently_Who,
            t.AC_partner_AC_with_ONG_currently_Confidence,
            t.AC_partner_AC_with_ONG_currently_Stance,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_partner
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Confidence DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_partner,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.AC_ID_with
                ORDER BY
                    t.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                    t.AC_partner_AC_with_ONG_currently_Confidence DESC,
                    t.AC_partner_AC_with_ONG_currently_ID DESC
            ) AS latestPositAC_ID_with
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_partner_AC_with_ONG_currently_Who AS inspectedPositor,
                CAST(h.AC_partner_AC_with_ONG_currently_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_partner_AC_with_ONG_currently h
            WHERE
                h.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_partner_AC_with_ONG_currently_Who,
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
                                r.AC_partner_AC_with_ONG_currently_Who,
                                r.AC_ID_partner,
                                r.AC_ID_with,
                                r.ONG_ID_currently,
                                r.AC_partner_AC_with_ONG_currently_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_partner_AC_with_ONG_currently_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_partner_AC_with_ONG_currently_PositedAt DESC,
                                r.AC_partner_AC_with_ONG_currently_Confidence DESC,
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
                            an.AC_partner_AC_with_ONG_currently_Who,
                            an.AC_partner_AC_with_ONG_currently_Confidence,
                            an.AC_partner_AC_with_ONG_currently_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_partner_AC_with_ONG_currently_ID, an.AC_partner_AC_with_ONG_currently_Who
                                ORDER BY an.AC_partner_AC_with_ONG_currently_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.AC_partner_AC_with_ONG_currently_Fact po
                        JOIN
                            ties.AC_partner_AC_with_ONG_currently_Meta an
                        ON
                            an.AC_partner_AC_with_ONG_currently_ID = po.AC_partner_AC_with_ONG_currently_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_partner_AC_with_ONG_currently_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_partner_AC_with_ONG_currently_Who = tp.inspectedPositor
        AND
            t.AC_partner_AC_with_ONG_currently_Stance = '+'
        AND
            t.AC_partner_AC_with_ONG_currently_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.ONG_Ongoing "kONG_currently"
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
            t.AC_subset_PN_of_Who,
            t.AC_subset_PN_of_Confidence,
            t.AC_subset_PN_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
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
                        an.AC_subset_PN_of_Who,
                        an.AC_subset_PN_of_Confidence,
                        an.AC_subset_PN_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Who
                            ORDER BY an.AC_subset_PN_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_subset_PN_of_Fact po
                    JOIN
                        ties.AC_subset_PN_of_Meta an
                    ON
                        an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                    WHERE
                        an.AC_subset_PN_of_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_subset_PN_of_Stance = COALESCE(assertion, s.AC_subset_PN_of_Stance)
        ) t
        WHERE
            t.AC_subset_PN_of_Who = forPositor
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
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_subset_PN_of,
            t.AC_ID_subset,
            t.PN_ID_of,
            t.AC_subset_PN_of_PositedAt,
            t.AC_subset_PN_of_Who,
            t.AC_subset_PN_of_Confidence,
            t.AC_subset_PN_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.AC_ID_subset
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
                        s.AC_subset_PN_of_ID DESC
                ) AS latestPositAC_ID_subset,
                ROW_NUMBER() OVER (
                    PARTITION BY s.AC_subset_PN_of_Who, s.PN_ID_of
                    ORDER BY
                        s.AC_subset_PN_of_PositedAt DESC,
                        s.AC_subset_PN_of_Confidence DESC,
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
                        an.AC_subset_PN_of_Who,
                        an.AC_subset_PN_of_Confidence,
                        an.AC_subset_PN_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_subset_PN_of_ID, an.AC_subset_PN_of_Who
                            ORDER BY an.AC_subset_PN_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_subset_PN_of_Fact po
                    JOIN
                        ties.AC_subset_PN_of_Meta an
                    ON
                        an.AC_subset_PN_of_ID = po.AC_subset_PN_of_ID
                    WHERE
                        an.AC_subset_PN_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_subset_PN_of_Stance = '+'
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_subset_PN_of_Who
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
CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
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
            t.EV_in_AC_wasCast_Who,
            t.EV_in_AC_wasCast_Confidence,
            t.EV_in_AC_wasCast_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_wasCast_Who,
                        s.EV_ID_in,
                        s.AC_ID_wasCast
                    ORDER BY
                        s.EV_in_AC_wasCast_PositedAt DESC,
                        s.EV_in_AC_wasCast_Confidence DESC,
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
                        an.EV_in_AC_wasCast_Who,
                        an.EV_in_AC_wasCast_Confidence,
                        an.EV_in_AC_wasCast_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_wasCast_ID, an.EV_in_AC_wasCast_Who
                            ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.EV_in_AC_wasCast_Fact po
                    JOIN
                        ties.EV_in_AC_wasCast_Meta an
                    ON
                        an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                    WHERE
                        an.EV_in_AC_wasCast_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.EV_in_AC_wasCast_Stance = COALESCE(assertion, s.EV_in_AC_wasCast_Stance)
        ) t
        WHERE
            t.EV_in_AC_wasCast_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tEV_in_AC_wasCast;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_EV_in_AC_wasCast,
            t.EV_ID_in,
            t.AC_ID_wasCast,
            t.EV_in_AC_wasCast_PositedAt,
            t.EV_in_AC_wasCast_Who,
            t.EV_in_AC_wasCast_Confidence,
            t.EV_in_AC_wasCast_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.EV_in_AC_wasCast_Who,
                        s.EV_ID_in,
                        s.AC_ID_wasCast
                    ORDER BY
                        s.EV_in_AC_wasCast_PositedAt DESC,
                        s.EV_in_AC_wasCast_Confidence DESC,
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
                        an.EV_in_AC_wasCast_Who,
                        an.EV_in_AC_wasCast_Confidence,
                        an.EV_in_AC_wasCast_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.EV_in_AC_wasCast_ID, an.EV_in_AC_wasCast_Who
                            ORDER BY an.EV_in_AC_wasCast_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.EV_in_AC_wasCast_Fact po
                    JOIN
                        ties.EV_in_AC_wasCast_Meta an
                    ON
                        an.EV_in_AC_wasCast_ID = po.EV_in_AC_wasCast_ID
                    WHERE
                        an.EV_in_AC_wasCast_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.EV_in_AC_wasCast_Stance = '+'
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.EV_in_AC_wasCast_Who
        WHERE
            t.latestPosit = 1
    ]';
END pEV_in_AC_wasCast;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast
AS
SELECT
    *
FROM
    ties.pEV_in_AC_wasCast(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    ties.pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
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
            "kRAT_got".RAT_Checksum AS got_RAT_Checksum,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Who,
            t.AC_part_PR_in_RAT_got_Confidence,
            t.AC_part_PR_in_RAT_got_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_part_PR_in_RAT_got_Who,
                        s.AC_ID_part,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        s.AC_part_PR_in_RAT_got_PositedAt DESC,
                        s.AC_part_PR_in_RAT_got_Confidence DESC,
                        s.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_part_PR_in_RAT_got_Stance <> '?' THEN r.AC_part_PR_in_RAT_got_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_part_PR_in_RAT_got_Who,
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
                        an.AC_part_PR_in_RAT_got_Who,
                        an.AC_part_PR_in_RAT_got_Confidence,
                        an.AC_part_PR_in_RAT_got_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Who
                            ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_part_PR_in_RAT_got_Fact po
                    JOIN
                        ties.AC_part_PR_in_RAT_got_Meta an
                    ON
                        an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                    WHERE
                        po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_part_PR_in_RAT_got_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_part_PR_in_RAT_got_Stance = COALESCE(assertion, s.AC_part_PR_in_RAT_got_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.AC_part_PR_in_RAT_got_ChangedAt = s.inEffect
            )
        ) t
        LEFT JOIN
            knots.RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.AC_part_PR_in_RAT_got_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_part_PR_in_RAT_got;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Checksum AS got_RAT_Checksum,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Who,
            t.AC_part_PR_in_RAT_got_Confidence,
            t.AC_part_PR_in_RAT_got_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_part_PR_in_RAT_got_Who,
                        s.AC_ID_part,
                        s.PR_ID_in
                    ORDER BY
                        s.AC_part_PR_in_RAT_got_ChangedAt DESC,
                        s.AC_part_PR_in_RAT_got_PositedAt DESC,
                        s.AC_part_PR_in_RAT_got_Confidence DESC,
                        s.AC_part_PR_in_RAT_got_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.AC_part_PR_in_RAT_got_Stance <> '?' THEN r.AC_part_PR_in_RAT_got_ChangedAt END) OVER (
                        PARTITION BY
                            r.AC_part_PR_in_RAT_got_Who,
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
                        an.AC_part_PR_in_RAT_got_Who,
                        an.AC_part_PR_in_RAT_got_Confidence,
                        an.AC_part_PR_in_RAT_got_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Who
                            ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_part_PR_in_RAT_got_Fact po
                    JOIN
                        ties.AC_part_PR_in_RAT_got_Meta an
                    ON
                        an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                    WHERE
                        po.AC_part_PR_in_RAT_got_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.AC_part_PR_in_RAT_got_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_part_PR_in_RAT_got_Stance = '+'
            AND
                s.AC_part_PR_in_RAT_got_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_part_PR_in_RAT_got_Who
        LEFT JOIN
            knots.RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
        WHERE
            t.latestPosit = 1
    ]';
END pAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    ties.pAC_part_PR_in_RAT_got(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    ties.pAC_part_PR_in_RAT_got(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_AC_part_PR_in_RAT_got,
            t.AC_ID_part,
            t.PR_ID_in,
            "kRAT_got".RAT_Checksum AS got_RAT_Checksum,
            "kRAT_got".RAT_Rating AS got_RAT_Rating,
            "kRAT_got".Metadata_RAT AS got_Metadata_RAT,
            t.RAT_ID_got,
            t.AC_part_PR_in_RAT_got_ChangedAt,
            t.AC_part_PR_in_RAT_got_PositedAt,
            t.AC_part_PR_in_RAT_got_Who,
            t.AC_part_PR_in_RAT_got_Confidence,
            t.AC_part_PR_in_RAT_got_Stance
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.AC_part_PR_in_RAT_got_Who AS inspectedPositor,
                CAST(h.AC_part_PR_in_RAT_got_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.AC_part_PR_in_RAT_got h
            WHERE
                h.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                    PARTITION BY
                        y.AC_part_PR_in_RAT_got_Who,
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
                                r.AC_part_PR_in_RAT_got_Who,
                                r.AC_ID_part,
                                r.PR_ID_in,
                                r.AC_part_PR_in_RAT_got_ChangedAt
                            ORDER BY
                                CASE WHEN r.AC_part_PR_in_RAT_got_Stance = '+' THEN 0 ELSE 1 END,
                                r.AC_part_PR_in_RAT_got_PositedAt DESC,
                                r.AC_part_PR_in_RAT_got_Confidence DESC,
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
                            an.AC_part_PR_in_RAT_got_Who,
                            an.AC_part_PR_in_RAT_got_Confidence,
                            an.AC_part_PR_in_RAT_got_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.AC_part_PR_in_RAT_got_ID, an.AC_part_PR_in_RAT_got_Who
                                ORDER BY an.AC_part_PR_in_RAT_got_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.AC_part_PR_in_RAT_got_Fact po
                        JOIN
                            ties.AC_part_PR_in_RAT_got_Meta an
                        ON
                            an.AC_part_PR_in_RAT_got_ID = po.AC_part_PR_in_RAT_got_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.AC_part_PR_in_RAT_got_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.AC_part_PR_in_RAT_got_Who = tp.inspectedPositor
        AND
            t.AC_part_PR_in_RAT_got_Stance = '+'
        AND
            t.AC_part_PR_in_RAT_got_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        LEFT JOIN
            knots.RAT_Rating "kRAT_got"
        ON
            "kRAT_got".RAT_ID = t.RAT_ID_got
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
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
            t.ST_at_PR_isPlaying_Who,
            t.ST_at_PR_isPlaying_Confidence,
            t.ST_at_PR_isPlaying_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_isPlaying_Who,
                        s.ST_ID_at,
                        s.PR_ID_isPlaying
                    ORDER BY
                        s.ST_at_PR_isPlaying_ChangedAt DESC,
                        s.ST_at_PR_isPlaying_PositedAt DESC,
                        s.ST_at_PR_isPlaying_Confidence DESC,
                        s.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_isPlaying_Stance <> '?' THEN r.ST_at_PR_isPlaying_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_isPlaying_Who,
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
                        an.ST_at_PR_isPlaying_Who,
                        an.ST_at_PR_isPlaying_Confidence,
                        an.ST_at_PR_isPlaying_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Who
                            ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.ST_at_PR_isPlaying_Fact po
                    JOIN
                        ties.ST_at_PR_isPlaying_Meta an
                    ON
                        an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                    WHERE
                        po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_at_PR_isPlaying_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.ST_at_PR_isPlaying_Stance = COALESCE(assertion, s.ST_at_PR_isPlaying_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.ST_at_PR_isPlaying_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.ST_at_PR_isPlaying_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tST_at_PR_isPlaying;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Who,
            t.ST_at_PR_isPlaying_Confidence,
            t.ST_at_PR_isPlaying_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.ST_at_PR_isPlaying_Who,
                        s.ST_ID_at,
                        s.PR_ID_isPlaying
                    ORDER BY
                        s.ST_at_PR_isPlaying_ChangedAt DESC,
                        s.ST_at_PR_isPlaying_PositedAt DESC,
                        s.ST_at_PR_isPlaying_Confidence DESC,
                        s.ST_at_PR_isPlaying_ID DESC
                ) AS latestPosit
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.ST_at_PR_isPlaying_Stance <> '?' THEN r.ST_at_PR_isPlaying_ChangedAt END) OVER (
                        PARTITION BY
                            r.ST_at_PR_isPlaying_Who,
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
                        an.ST_at_PR_isPlaying_Who,
                        an.ST_at_PR_isPlaying_Confidence,
                        an.ST_at_PR_isPlaying_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Who
                            ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.ST_at_PR_isPlaying_Fact po
                    JOIN
                        ties.ST_at_PR_isPlaying_Meta an
                    ON
                        an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                    WHERE
                        po.ST_at_PR_isPlaying_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.ST_at_PR_isPlaying_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.ST_at_PR_isPlaying_Stance = '+'
            AND
                s.ST_at_PR_isPlaying_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.ST_at_PR_isPlaying_Who
        WHERE
            t.latestPosit = 1
    ]';
END pST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying
AS
SELECT
    *
FROM
    ties.pST_at_PR_isPlaying(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying
AS
SELECT
    *
FROM
    ties.pST_at_PR_isPlaying(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_ST_at_PR_isPlaying,
            t.ST_ID_at,
            t.PR_ID_isPlaying,
            t.ST_at_PR_isPlaying_ChangedAt,
            t.ST_at_PR_isPlaying_PositedAt,
            t.ST_at_PR_isPlaying_Who,
            t.ST_at_PR_isPlaying_Confidence,
            t.ST_at_PR_isPlaying_Stance
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.ST_at_PR_isPlaying_Who AS inspectedPositor,
                CAST(h.ST_at_PR_isPlaying_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.ST_at_PR_isPlaying h
            WHERE
                h.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.ST_at_PR_isPlaying_ChangedAt) OVER (
                    PARTITION BY
                        y.ST_at_PR_isPlaying_Who,
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
                                r.ST_at_PR_isPlaying_Who,
                                r.ST_ID_at,
                                r.PR_ID_isPlaying,
                                r.ST_at_PR_isPlaying_ChangedAt
                            ORDER BY
                                CASE WHEN r.ST_at_PR_isPlaying_Stance = '+' THEN 0 ELSE 1 END,
                                r.ST_at_PR_isPlaying_PositedAt DESC,
                                r.ST_at_PR_isPlaying_Confidence DESC,
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
                            an.ST_at_PR_isPlaying_Who,
                            an.ST_at_PR_isPlaying_Confidence,
                            an.ST_at_PR_isPlaying_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.ST_at_PR_isPlaying_ID, an.ST_at_PR_isPlaying_Who
                                ORDER BY an.ST_at_PR_isPlaying_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.ST_at_PR_isPlaying_Fact po
                        JOIN
                            ties.ST_at_PR_isPlaying_Meta an
                        ON
                            an.ST_at_PR_isPlaying_ID = po.ST_at_PR_isPlaying_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.ST_at_PR_isPlaying_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.ST_at_PR_isPlaying_Who = tp.inspectedPositor
        AND
            t.ST_at_PR_isPlaying_Stance = '+'
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
CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
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
            t.AC_parent_AC_child_PAT_having_Who,
            t.AC_parent_AC_child_PAT_having_Confidence,
            t.AC_parent_AC_child_PAT_having_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_parent_AC_child_PAT_having_Who,
                        s.AC_ID_parent,
                        s.AC_ID_child,
                        s.PAT_ID_having
                    ORDER BY
                        s.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        s.AC_parent_AC_child_PAT_having_Confidence DESC,
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
                        an.AC_parent_AC_child_PAT_having_Who,
                        an.AC_parent_AC_child_PAT_having_Confidence,
                        an.AC_parent_AC_child_PAT_having_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_parent_AC_child_PAT_having_ID, an.AC_parent_AC_child_PAT_having_Who
                            ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_parent_AC_child_PAT_having_Fact po
                    JOIN
                        ties.AC_parent_AC_child_PAT_having_Meta an
                    ON
                        an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                    WHERE
                        an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_parent_AC_child_PAT_having_Stance = COALESCE(assertion, s.AC_parent_AC_child_PAT_having_Stance)
        ) t
        LEFT JOIN
            knots.PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.AC_parent_AC_child_PAT_having_Who = forPositor
        AND
            t.latestPosit = 1
    ]';
END tAC_parent_AC_child_PAT_having;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_AC_parent_AC_child_PAT_having,
            t.AC_ID_parent,
            t.AC_ID_child,
            "kPAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "kPAT_having".Metadata_PAT AS having_Metadata_PAT,
            t.PAT_ID_having,
            t.AC_parent_AC_child_PAT_having_PositedAt,
            t.AC_parent_AC_child_PAT_having_Who,
            t.AC_parent_AC_child_PAT_having_Confidence,
            t.AC_parent_AC_child_PAT_having_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        s.AC_parent_AC_child_PAT_having_Who,
                        s.AC_ID_parent,
                        s.AC_ID_child,
                        s.PAT_ID_having
                    ORDER BY
                        s.AC_parent_AC_child_PAT_having_PositedAt DESC,
                        s.AC_parent_AC_child_PAT_having_Confidence DESC,
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
                        an.AC_parent_AC_child_PAT_having_Who,
                        an.AC_parent_AC_child_PAT_having_Confidence,
                        an.AC_parent_AC_child_PAT_having_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.AC_parent_AC_child_PAT_having_ID, an.AC_parent_AC_child_PAT_having_Who
                            ORDER BY an.AC_parent_AC_child_PAT_having_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.AC_parent_AC_child_PAT_having_Fact po
                    JOIN
                        ties.AC_parent_AC_child_PAT_having_Meta an
                    ON
                        an.AC_parent_AC_child_PAT_having_ID = po.AC_parent_AC_child_PAT_having_ID
                    WHERE
                        an.AC_parent_AC_child_PAT_having_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.AC_parent_AC_child_PAT_having_Stance = '+'
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.AC_parent_AC_child_PAT_having_Who
        LEFT JOIN
            knots.PAT_ParentalType "kPAT_having"
        ON
            "kPAT_having".PAT_ID = t.PAT_ID_having
        WHERE
            t.latestPosit = 1
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    ties.pAC_parent_AC_child_PAT_having(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    ties.pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp(9)))
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- The posits that the positor holds, as known at the positing time, in effect at the changing time, for the assertion
-- given ('+', '-', '?', or null for the positive and negative ones that are in effect).
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
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
            t.PR_content_ST_location_EV_of_ChangedAt,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Who,
            t.PR_content_ST_location_EV_of_Confidence,
            t.PR_content_ST_location_EV_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.PR_ID_content
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositPR_ID_content,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.ST_ID_location
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositST_ID_location
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_content_ST_location_EV_of_Stance <> '?' THEN r.PR_content_ST_location_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_content_ST_location_EV_of_Who,
                            r.PR_ID_content,
                            r.ST_ID_location,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_content_ST_location_EV_of,
                        po.PR_content_ST_location_EV_of_ID,
                        po.PR_ID_content,
                        po.ST_ID_location,
                        po.EV_ID_of,
                        po.PR_content_ST_location_EV_of_ChangedAt,
                        an.PR_content_ST_location_EV_of_PositedAt,
                        an.PR_content_ST_location_EV_of_Who,
                        an.PR_content_ST_location_EV_of_Confidence,
                        an.PR_content_ST_location_EV_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Who
                            ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.PR_content_ST_location_EV_of_Fact po
                    JOIN
                        ties.PR_content_ST_location_EV_of_Meta an
                    ON
                        an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                    WHERE
                        po.PR_content_ST_location_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.PR_content_ST_location_EV_of_PositedAt <= CAST(positingTimepoint AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.PR_content_ST_location_EV_of_Stance = COALESCE(assertion, s.PR_content_ST_location_EV_of_Stance)
            AND (
                COALESCE(assertion, '?') = '?'
            OR
                s.PR_content_ST_location_EV_of_ChangedAt = s.inEffect
            )
        ) t
        WHERE
            t.PR_content_ST_location_EV_of_Who = forPositor
        AND
            t.latestPositPR_ID_content = 1
        AND
            t.latestPositST_ID_location = 1
    ]';
END tPR_content_ST_location_EV_of;
/
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- What each positor holds as known now (positing time end of time) and in effect at the changing time, with the positor
-- and a reliability that is null since a perspective does not combine the reliabilities of the posits.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            positorTable.Who,
            CAST(NULL AS number(7,3)) AS Confidence,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_ChangedAt,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Who,
            t.PR_content_ST_location_EV_of_Confidence,
            t.PR_content_ST_location_EV_of_Stance
        FROM (
            SELECT
                s.*,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.PR_ID_content
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositPR_ID_content,
                ROW_NUMBER() OVER (
                    PARTITION BY s.PR_content_ST_location_EV_of_Who, s.ST_ID_location
                    ORDER BY
                        s.PR_content_ST_location_EV_of_ChangedAt DESC,
                        s.PR_content_ST_location_EV_of_PositedAt DESC,
                        s.PR_content_ST_location_EV_of_Confidence DESC,
                        s.PR_content_ST_location_EV_of_ID DESC
                ) AS latestPositST_ID_location
            FROM (
                SELECT
                    r.*,
                    MAX(CASE WHEN r.PR_content_ST_location_EV_of_Stance <> '?' THEN r.PR_content_ST_location_EV_of_ChangedAt END) OVER (
                        PARTITION BY
                            r.PR_content_ST_location_EV_of_Who,
                            r.PR_ID_content,
                            r.ST_ID_location,
                            r.EV_ID_of
                    ) AS inEffect
                FROM (
                    SELECT
                        an.Metadata_PR_content_ST_location_EV_of,
                        po.PR_content_ST_location_EV_of_ID,
                        po.PR_ID_content,
                        po.ST_ID_location,
                        po.EV_ID_of,
                        po.PR_content_ST_location_EV_of_ChangedAt,
                        an.PR_content_ST_location_EV_of_PositedAt,
                        an.PR_content_ST_location_EV_of_Who,
                        an.PR_content_ST_location_EV_of_Confidence,
                        an.PR_content_ST_location_EV_of_Stance,
                        ROW_NUMBER() OVER (
                            PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Who
                            ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                        ) AS rewindRank
                    FROM
                        ties.PR_content_ST_location_EV_of_Fact po
                    JOIN
                        ties.PR_content_ST_location_EV_of_Meta an
                    ON
                        an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                    WHERE
                        po.PR_content_ST_location_EV_of_ChangedAt <= CAST(changingTimepoint AS timestamp)
                    AND
                        an.PR_content_ST_location_EV_of_PositedAt <= CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(3))
                ) r
                WHERE
                    r.rewindRank = 1
            ) s
            WHERE
                s.PR_content_ST_location_EV_of_Stance = '+'
            AND
                s.PR_content_ST_location_EV_of_ChangedAt = s.inEffect
        ) t
        JOIN
            dw.Who_ positorTable
        ON
            positorTable.Who = t.PR_content_ST_location_EV_of_Who
        WHERE
            t.latestPositPR_ID_content = 1
        AND
            t.latestPositST_ID_location = 1
    ]';
END pPR_content_ST_location_EV_of;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    ties.pPR_content_ST_location_EV_of(CAST(TIMESTAMP '9999-12-31 00:00:00' AS timestamp(9)))
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    ties.pPR_content_ST_location_EV_of(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-- Each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            q.Who,
            q.inspectedTimepoint,
            q.Metadata_PR_content_ST_location_EV_of,
            q.PR_ID_content,
            q.ST_ID_location,
            q.EV_ID_of,
            q.PR_content_ST_location_EV_of_ChangedAt,
            q.PR_content_ST_location_EV_of_PositedAt,
            q.PR_content_ST_location_EV_of_Who,
            q.PR_content_ST_location_EV_of_Confidence,
            q.PR_content_ST_location_EV_of_Stance
        FROM (
        SELECT
            positorTable.Who,
            tp.inspectedTimepoint,
            t.Metadata_PR_content_ST_location_EV_of,
            t.PR_ID_content,
            t.ST_ID_location,
            t.EV_ID_of,
            t.PR_content_ST_location_EV_of_ChangedAt,
            t.PR_content_ST_location_EV_of_PositedAt,
            t.PR_content_ST_location_EV_of_Who,
            t.PR_content_ST_location_EV_of_Confidence,
            t.PR_content_ST_location_EV_of_Stance,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.PR_ID_content
                ORDER BY
                    t.PR_content_ST_location_EV_of_ChangedAt DESC,
                    t.PR_content_ST_location_EV_of_PositedAt DESC,
                    t.PR_content_ST_location_EV_of_Confidence DESC,
                    t.PR_content_ST_location_EV_of_ID DESC
            ) AS latestPositPR_ID_content,
            ROW_NUMBER() OVER (
                PARTITION BY tp.inspectedPositor, tp.inspectedTimepoint, t.ST_ID_location
                ORDER BY
                    t.PR_content_ST_location_EV_of_ChangedAt DESC,
                    t.PR_content_ST_location_EV_of_PositedAt DESC,
                    t.PR_content_ST_location_EV_of_Confidence DESC,
                    t.PR_content_ST_location_EV_of_ID DESC
            ) AS latestPositST_ID_location
        FROM
            dw.Who_ positorTable
        JOIN (
            SELECT DISTINCT
                h.PR_content_ST_location_EV_of_Who AS inspectedPositor,
                CAST(h.PR_content_ST_location_EV_of_ChangedAt AS timestamp(9)) AS inspectedTimepoint
            FROM
                ties.PR_content_ST_location_EV_of h
            WHERE
                h.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
        ) tp
        ON
            tp.inspectedPositor = positorTable.Who
        JOIN (
            SELECT
                y.*,
                LEAD(y.PR_content_ST_location_EV_of_ChangedAt) OVER (
                    PARTITION BY
                        y.PR_content_ST_location_EV_of_Who,
                        y.PR_ID_content,
                        y.ST_ID_location,
                        y.EV_ID_of
                    ORDER BY y.PR_content_ST_location_EV_of_ChangedAt
                ) AS untilTime
            FROM (
                SELECT
                    z.*
                FROM (
                    SELECT
                        r.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY
                                r.PR_content_ST_location_EV_of_Who,
                                r.PR_ID_content,
                                r.ST_ID_location,
                                r.EV_ID_of,
                                r.PR_content_ST_location_EV_of_ChangedAt
                            ORDER BY
                                CASE WHEN r.PR_content_ST_location_EV_of_Stance = '+' THEN 0 ELSE 1 END,
                                r.PR_content_ST_location_EV_of_PositedAt DESC,
                                r.PR_content_ST_location_EV_of_Confidence DESC,
                                r.PR_content_ST_location_EV_of_ID DESC
                        ) AS pickRank
                    FROM (
                        SELECT
                            an.Metadata_PR_content_ST_location_EV_of,
                            po.PR_content_ST_location_EV_of_ID,
                            po.PR_ID_content,
                            po.ST_ID_location,
                            po.EV_ID_of,
                            po.PR_content_ST_location_EV_of_ChangedAt,
                            an.PR_content_ST_location_EV_of_PositedAt,
                            an.PR_content_ST_location_EV_of_Who,
                            an.PR_content_ST_location_EV_of_Confidence,
                            an.PR_content_ST_location_EV_of_Stance,
                            ROW_NUMBER() OVER (
                                PARTITION BY po.PR_content_ST_location_EV_of_ID, an.PR_content_ST_location_EV_of_Who
                                ORDER BY an.PR_content_ST_location_EV_of_PositedAt DESC
                            ) AS rewindRank
                        FROM
                            ties.PR_content_ST_location_EV_of_Fact po
                        JOIN
                            ties.PR_content_ST_location_EV_of_Meta an
                        ON
                            an.PR_content_ST_location_EV_of_ID = po.PR_content_ST_location_EV_of_ID
                    ) r
                    WHERE
                        r.rewindRank = 1
                    AND
                        r.PR_content_ST_location_EV_of_Stance <> '?'
                ) z
                WHERE
                    z.pickRank = 1
            ) y
        ) t
        ON
            t.PR_content_ST_location_EV_of_Who = tp.inspectedPositor
        AND
            t.PR_content_ST_location_EV_of_Stance = '+'
        AND
            t.PR_content_ST_location_EV_of_ChangedAt <= CAST(tp.inspectedTimepoint AS timestamp)
        AND (
            t.untilTime IS NULL
        OR
            t.untilTime > CAST(tp.inspectedTimepoint AS timestamp)
        )
        ) q
        WHERE
            q.latestPositPR_ID_content = 1
        AND
            q.latestPositST_ID_location = 1
    ]';
END dPR_content_ST_location_EV_of;
/
