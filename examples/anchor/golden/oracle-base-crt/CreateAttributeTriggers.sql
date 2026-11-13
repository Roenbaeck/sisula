-- ATTRIBUTE INSERT PROCEDURES ----------------------------------------------------------------------------------------
--
-- The procedures here state one posit of an attribute and what a positor asserts of it, in the way that the model says,
-- like the triggers on the assembled views do in PostgreSQL: the positor is 0, the positing time is now and the
-- reliability is 1 where they are not given. They are procedures and not triggers on the assembled views (which are views
-- that Oracle would need an INSTEAD OF trigger on) or on the posit and annex tables, since Oracle does not let a row
-- trigger read the table it is on (ORA-04091), which these rules do. The INSTEAD OF triggers on the latest views of the
-- anchors, and those of the nexuses, call them, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_value => 'Ann', p_changing => SYSTIMESTAMP, p_positor => 0, p_reliability => 1, p_metadata => 1); END;
--
-- ip_<attribute.name> (one for every attribute of an anchor or a nexus, named as the attribute is in the model, written in
-- front of its schema if it has one). Its parameters are named, and all except the owner and the value may be left out (or
-- be null), when the default of the one left out is used:
--
--     p_owner        the entity that has the attribute, a column of the posit table: the entity reference of the attribute
--     p_value        the value that is posited, as it is in the posit table: for a knotted attribute the identity of the value in the
--                    knot, for an attribute with a checksum the value (the checksum is made by the table)
--     p_changing     only for a historized attribute: from when the value is valid. Default: now (current_timestamp)
--     p_positor      the positor that asserts the posit. Default: 0
--     p_positing     when the positor asserts it. Default: now
--     p_reliability  how reliable the positor says that it is: positive asserts the posit, negative asserts that it is not so, and
--                    0 retracts the assertion of it. Default: 1
--     p_metadata     only when the model has metadata: the metadata of the annex row. Default: 0
--
-- A posit that is not there is created. A retraction of what the positor does not hold states nothing. An error is raised
-- (RAISE_APPLICATION_ERROR) for a contradiction (-20001: the positor asserts another reliability of the same posit at the
-- same positing time, or in the model where positors are decisive another value for the same entity and changing time, or
-- in the model where positors are indecisive, alternatives with reliabilities that sum up to more than one) and for a
-- restatement (-20002: the value is the same as that of the version before or after it, where the attribute may not be
-- restated). A call that raises an error is undone, as is the statement that made it.
--
-- Two functions help the procedures and may be used in a query as well:
--
--     eq_<attribute.name>(p_left, p_right)         1 if two values of the attribute are the same, else 0
--     he_<attribute.name>(p_id, p_positor, p_positing)   the reliability that the positor holds for the posit with the identity
--                                                  at the positing time (that of its latest annex row up to then), null if it holds nothing
--
-- Positors are decisive: a positor holds one assertion at a time for an entity (and a changing time), so an assertion that
-- is not a retraction, positive or negative, of another value retracts, at its own positing time, the posit that the
-- positor holds, which is a correction.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_DAT_Event_Date tells whether two values of EV_DAT_Event_Date are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_DAT_Event_Date (
    p_left IN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date%TYPE,
    p_right IN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_DAT_Event_Date;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_DAT_Event_Date is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_DAT_Event_Date (
    p_id IN EV_DAT_Event_Date_Annex.EV_DAT_ID%TYPE,
    p_positor IN EV_DAT_Event_Date_Annex.EV_DAT_Positor%TYPE,
    p_positing IN EV_DAT_Event_Date_Annex.EV_DAT_PositedAt%TYPE
) RETURN EV_DAT_Event_Date_Annex.EV_DAT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_DAT_Reliability
        FROM
            EV_DAT_Event_Date_Annex a
        WHERE
            a.EV_DAT_ID = p_id
        AND
            a.EV_DAT_Positor = p_positor
        AND
            a.EV_DAT_PositedAt <= p_positing
        ORDER BY
            a.EV_DAT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_DAT_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_DAT_Event_Date (
    p_owner IN EV_DAT_Event_Date_Posit.EV_DAT_EV_ID%TYPE,
    p_value IN EV_DAT_Event_Date_Posit.EV_DAT_Event_Date%TYPE,
    p_positor IN EV_DAT_Event_Date_Annex.EV_DAT_Positor%TYPE DEFAULT NULL,
    p_positing IN EV_DAT_Event_Date_Annex.EV_DAT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_DAT_Event_Date_Annex.EV_DAT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_DAT_Event_Date_Annex.Metadata_EV_DAT%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit EV_DAT_Event_Date_Posit.EV_DAT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_DAT_Event_Date_Posit.EV_DAT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_DAT_Event_Date_Annex (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Positor,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_DAT_Event_Date_Annex x
                WHERE
                    x.EV_DAT_ID = p_id
                AND
                    x.EV_DAT_Positor = v_positor
                AND
                    x.EV_DAT_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            EV_DAT_Event_Date_Posit p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_DAT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_DAT_Event_Date_Annex a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Positor = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_DAT_Event_Date_Posit p
        JOIN
            EV_DAT_Event_Date_Annex a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            a.EV_DAT_Positor = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_DAT_Event_Date_Annex a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Positor = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_EV_DAT_Event_Date(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO EV_DAT_Event_Date_Annex (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Positor,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            EV_DAT_Event_Date_Posit p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            COALESCE(he_EV_DAT_Event_Date(p.EV_DAT_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_DAT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_DAT_Event_Date_Posit (
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_DAT_ID INTO v_posit;
    END IF;
    INSERT INTO EV_DAT_Event_Date_Annex (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Positor,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_DAT_Event_Date;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Event_Audience tells whether two values of EV_AUD_Event_Audience are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_AUD_Event_Audience (
    p_left IN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience%TYPE,
    p_right IN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_AUD_Event_Audience;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_AUD_Event_Audience is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_AUD_Event_Audience (
    p_id IN EV_AUD_Event_Audience_Annex.EV_AUD_ID%TYPE,
    p_positor IN EV_AUD_Event_Audience_Annex.EV_AUD_Positor%TYPE,
    p_positing IN EV_AUD_Event_Audience_Annex.EV_AUD_PositedAt%TYPE
) RETURN EV_AUD_Event_Audience_Annex.EV_AUD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_AUD_Reliability
        FROM
            EV_AUD_Event_Audience_Annex a
        WHERE
            a.EV_AUD_ID = p_id
        AND
            a.EV_AUD_Positor = p_positor
        AND
            a.EV_AUD_PositedAt <= p_positing
        ORDER BY
            a.EV_AUD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_AUD_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_AUD_Event_Audience (
    p_owner IN EV_AUD_Event_Audience_Posit.EV_AUD_EV_ID%TYPE,
    p_value IN EV_AUD_Event_Audience_Posit.EV_AUD_Event_Audience%TYPE,
    p_positor IN EV_AUD_Event_Audience_Annex.EV_AUD_Positor%TYPE DEFAULT NULL,
    p_positing IN EV_AUD_Event_Audience_Annex.EV_AUD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_AUD_Event_Audience_Annex.EV_AUD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_AUD_Event_Audience_Annex.Metadata_EV_AUD%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit EV_AUD_Event_Audience_Posit.EV_AUD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_AUD_Event_Audience_Posit.EV_AUD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_AUD_Event_Audience_Annex (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Positor,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_AUD_Event_Audience_Annex x
                WHERE
                    x.EV_AUD_ID = p_id
                AND
                    x.EV_AUD_Positor = v_positor
                AND
                    x.EV_AUD_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            EV_AUD_Event_Audience_Posit p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_AUD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_AUD_Event_Audience_Annex a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Positor = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_AUD_Event_Audience_Posit p
        JOIN
            EV_AUD_Event_Audience_Annex a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            a.EV_AUD_Positor = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_AUD_Event_Audience_Annex a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Positor = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_EV_AUD_Event_Audience(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO EV_AUD_Event_Audience_Annex (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Positor,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            EV_AUD_Event_Audience_Posit p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            COALESCE(he_EV_AUD_Event_Audience(p.EV_AUD_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_AUD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_AUD_Event_Audience_Posit (
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_AUD_ID INTO v_posit;
    END IF;
    INSERT INTO EV_AUD_Event_Audience_Annex (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_AUD_Event_Audience;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Event_Revenue tells whether two values of EV_REV_Event_Revenue are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_REV_Event_Revenue (
    p_left IN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue%TYPE,
    p_right IN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_REV_Event_Revenue;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_REV_Event_Revenue is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_REV_Event_Revenue (
    p_id IN EV_REV_Event_Revenue_Annex.EV_REV_ID%TYPE,
    p_positor IN EV_REV_Event_Revenue_Annex.EV_REV_Positor%TYPE,
    p_positing IN EV_REV_Event_Revenue_Annex.EV_REV_PositedAt%TYPE
) RETURN EV_REV_Event_Revenue_Annex.EV_REV_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_REV_Reliability
        FROM
            EV_REV_Event_Revenue_Annex a
        WHERE
            a.EV_REV_ID = p_id
        AND
            a.EV_REV_Positor = p_positor
        AND
            a.EV_REV_PositedAt <= p_positing
        ORDER BY
            a.EV_REV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_REV_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_REV_Event_Revenue (
    p_owner IN EV_REV_Event_Revenue_Posit.EV_REV_EV_ID%TYPE,
    p_value IN EV_REV_Event_Revenue_Posit.EV_REV_Event_Revenue%TYPE,
    p_positor IN EV_REV_Event_Revenue_Annex.EV_REV_Positor%TYPE DEFAULT NULL,
    p_positing IN EV_REV_Event_Revenue_Annex.EV_REV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_REV_Event_Revenue_Annex.EV_REV_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_REV_Event_Revenue_Annex.Metadata_EV_REV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit EV_REV_Event_Revenue_Posit.EV_REV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_REV_Event_Revenue_Posit.EV_REV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_REV_Event_Revenue_Annex (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Positor,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    EV_REV_Event_Revenue_Annex x
                WHERE
                    x.EV_REV_ID = p_id
                AND
                    x.EV_REV_Positor = v_positor
                AND
                    x.EV_REV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            EV_REV_Event_Revenue_Posit p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_REV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_REV_Event_Revenue_Annex a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Positor = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_REV_Event_Revenue_Posit p
        JOIN
            EV_REV_Event_Revenue_Annex a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            a.EV_REV_Positor = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_REV_Event_Revenue_Annex a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Positor = v_positor
        AND
            a.EV_REV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_EV_REV_Event_Revenue(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO EV_REV_Event_Revenue_Annex (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Positor,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            EV_REV_Event_Revenue_Posit p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            COALESCE(he_EV_REV_Event_Revenue(p.EV_REV_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_REV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_REV_Event_Revenue_Posit (
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_REV_ID INTO v_posit;
    END IF;
    INSERT INTO EV_REV_Event_Revenue_Annex (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_REV_Event_Revenue;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_NAM_Stage_Name (
    p_left IN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name%TYPE,
    p_right IN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_NAM_Stage_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_NAM_Stage_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_NAM_Stage_Name (
    p_id IN ST_NAM_Stage_Name_Annex.ST_NAM_ID%TYPE,
    p_positor IN ST_NAM_Stage_Name_Annex.ST_NAM_Positor%TYPE,
    p_positing IN ST_NAM_Stage_Name_Annex.ST_NAM_PositedAt%TYPE
) RETURN ST_NAM_Stage_Name_Annex.ST_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_NAM_Reliability
        FROM
            ST_NAM_Stage_Name_Annex a
        WHERE
            a.ST_NAM_ID = p_id
        AND
            a.ST_NAM_Positor = p_positor
        AND
            a.ST_NAM_PositedAt <= p_positing
        ORDER BY
            a.ST_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_NAM_Stage_Name (
    p_owner IN ST_NAM_Stage_Name_Posit.ST_NAM_ST_ID%TYPE,
    p_value IN ST_NAM_Stage_Name_Posit.ST_NAM_Stage_Name%TYPE,
    p_changing IN ST_NAM_Stage_Name_Posit.ST_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ST_NAM_Stage_Name_Annex.ST_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN ST_NAM_Stage_Name_Annex.ST_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_NAM_Stage_Name_Annex.ST_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_NAM_Stage_Name_Annex.Metadata_ST_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit ST_NAM_Stage_Name_Posit.ST_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_NAM_Stage_Name_Posit.ST_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_NAM_Stage_Name_Annex (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Positor,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_NAM_Stage_Name_Annex x
                WHERE
                    x.ST_NAM_ID = p_id
                AND
                    x.ST_NAM_Positor = v_positor
                AND
                    x.ST_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            ST_NAM_Stage_Name_Posit p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_NAM_Stage_Name_Annex a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Positor = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_NAM_Stage_Name_Posit p
        JOIN
            ST_NAM_Stage_Name_Annex a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            a.ST_NAM_Positor = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_NAM_Stage_Name_Annex a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Positor = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_ST_NAM_Stage_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ST_NAM_Stage_Name_Annex (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Positor,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_NAM_ID
        FROM
            ST_NAM_Stage_Name_Posit p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            COALESCE(he_ST_NAM_Stage_Name(p.ST_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_NAM_Stage_Name_Posit (
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO ST_NAM_Stage_Name_Annex (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_NAM_Stage_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Stage_Location tells whether two values of ST_LOC_Stage_Location are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_LOC_Stage_Location (
    p_left IN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location%TYPE,
    p_right IN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location%TYPE
) RETURN NUMBER
IS
    v_same NUMBER;
BEGIN
    SELECT CASE WHEN STANDARD_HASH(p_left, 'MD5') = STANDARD_HASH(p_right, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
    RETURN v_same;
END eq_ST_LOC_Stage_Location;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_LOC_Stage_Location is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_LOC_Stage_Location (
    p_id IN ST_LOC_Stage_Location_Annex.ST_LOC_ID%TYPE,
    p_positor IN ST_LOC_Stage_Location_Annex.ST_LOC_Positor%TYPE,
    p_positing IN ST_LOC_Stage_Location_Annex.ST_LOC_PositedAt%TYPE
) RETURN ST_LOC_Stage_Location_Annex.ST_LOC_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_LOC_Reliability
        FROM
            ST_LOC_Stage_Location_Annex a
        WHERE
            a.ST_LOC_ID = p_id
        AND
            a.ST_LOC_Positor = p_positor
        AND
            a.ST_LOC_PositedAt <= p_positing
        ORDER BY
            a.ST_LOC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_LOC_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_LOC_Stage_Location (
    p_owner IN ST_LOC_Stage_Location_Posit.ST_LOC_ST_ID%TYPE,
    p_value IN ST_LOC_Stage_Location_Posit.ST_LOC_Stage_Location%TYPE,
    p_positor IN ST_LOC_Stage_Location_Annex.ST_LOC_Positor%TYPE DEFAULT NULL,
    p_positing IN ST_LOC_Stage_Location_Annex.ST_LOC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_LOC_Stage_Location_Annex.ST_LOC_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_LOC_Stage_Location_Annex.Metadata_ST_LOC%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit ST_LOC_Stage_Location_Posit.ST_LOC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_LOC_Stage_Location_Posit.ST_LOC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_LOC_Stage_Location_Annex (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Positor,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_LOC_Stage_Location_Annex x
                WHERE
                    x.ST_LOC_ID = p_id
                AND
                    x.ST_LOC_Positor = v_positor
                AND
                    x.ST_LOC_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            ST_LOC_Stage_Location_Posit p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_LOC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_LOC_Stage_Location_Annex a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Positor = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_LOC_Stage_Location_Posit p
        JOIN
            ST_LOC_Stage_Location_Annex a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            a.ST_LOC_Positor = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_LOC_Stage_Location_Annex a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Positor = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_ST_LOC_Stage_Location(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ST_LOC_Stage_Location_Annex (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Positor,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            ST_LOC_Stage_Location_Posit p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            COALESCE(he_ST_LOC_Stage_Location(p.ST_LOC_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_LOC_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_LOC_Stage_Location_Posit (
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_LOC_ID INTO v_posit;
    END IF;
    INSERT INTO ST_LOC_Stage_Location_Annex (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_LOC_Stage_Location;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Stage_Average tells whether two values of ST_AVG_Stage_Average are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_AVG_Stage_Average (
    p_left IN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID%TYPE,
    p_right IN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_AVG_Stage_Average;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_AVG_Stage_Average is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_AVG_Stage_Average (
    p_id IN ST_AVG_Stage_Average_Annex.ST_AVG_ID%TYPE,
    p_positor IN ST_AVG_Stage_Average_Annex.ST_AVG_Positor%TYPE,
    p_positing IN ST_AVG_Stage_Average_Annex.ST_AVG_PositedAt%TYPE
) RETURN ST_AVG_Stage_Average_Annex.ST_AVG_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_AVG_Reliability
        FROM
            ST_AVG_Stage_Average_Annex a
        WHERE
            a.ST_AVG_ID = p_id
        AND
            a.ST_AVG_Positor = p_positor
        AND
            a.ST_AVG_PositedAt <= p_positing
        ORDER BY
            a.ST_AVG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_AVG_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_AVG_Stage_Average (
    p_owner IN ST_AVG_Stage_Average_Posit.ST_AVG_ST_ID%TYPE,
    p_value IN ST_AVG_Stage_Average_Posit.ST_AVG_UTL_ID%TYPE,
    p_changing IN ST_AVG_Stage_Average_Posit.ST_AVG_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ST_AVG_Stage_Average_Annex.ST_AVG_Positor%TYPE DEFAULT NULL,
    p_positing IN ST_AVG_Stage_Average_Annex.ST_AVG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_AVG_Stage_Average_Annex.ST_AVG_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_AVG_Stage_Average_Annex.Metadata_ST_AVG%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit ST_AVG_Stage_Average_Posit.ST_AVG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_AVG_Stage_Average_Posit.ST_AVG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_AVG_Stage_Average_Annex (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_AVG_Stage_Average_Annex x
                WHERE
                    x.ST_AVG_ID = p_id
                AND
                    x.ST_AVG_Positor = v_positor
                AND
                    x.ST_AVG_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            ST_AVG_Stage_Average_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_AVG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_AVG_Stage_Average_Annex a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Positor = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_AVG_Stage_Average_Posit p
        JOIN
            ST_AVG_Stage_Average_Annex a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            a.ST_AVG_Positor = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_AVG_Stage_Average_Annex a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Positor = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_ST_AVG_Stage_Average(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ST_AVG_Stage_Average_Annex (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_AVG_ID
        FROM
            ST_AVG_Stage_Average_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            COALESCE(he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_AVG_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            ST_AVG_Stage_Average_Posit p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < v_changing
        AND
            COALESCE(he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.ST_AVG_ID,
            f.ST_AVG_UTL_ID
        FROM
            ST_AVG_Stage_Average_Posit f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > v_changing
        AND
            COALESCE(he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.ST_AVG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_AVG_Stage_Average_Posit (
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING ST_AVG_ID INTO v_posit;
    END IF;
    INSERT INTO ST_AVG_Stage_Average_Annex (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_AVG_Stage_Average;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Stage_Minimum tells whether two values of ST_MIN_Stage_Minimum are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_ST_MIN_Stage_Minimum (
    p_left IN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID%TYPE,
    p_right IN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_ST_MIN_Stage_Minimum;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_MIN_Stage_Minimum is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_ST_MIN_Stage_Minimum (
    p_id IN ST_MIN_Stage_Minimum_Annex.ST_MIN_ID%TYPE,
    p_positor IN ST_MIN_Stage_Minimum_Annex.ST_MIN_Positor%TYPE,
    p_positing IN ST_MIN_Stage_Minimum_Annex.ST_MIN_PositedAt%TYPE
) RETURN ST_MIN_Stage_Minimum_Annex.ST_MIN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_MIN_Reliability
        FROM
            ST_MIN_Stage_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = p_id
        AND
            a.ST_MIN_Positor = p_positor
        AND
            a.ST_MIN_PositedAt <= p_positing
        ORDER BY
            a.ST_MIN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_MIN_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_MIN_Stage_Minimum (
    p_owner IN ST_MIN_Stage_Minimum_Posit.ST_MIN_ST_ID%TYPE,
    p_value IN ST_MIN_Stage_Minimum_Posit.ST_MIN_UTL_ID%TYPE,
    p_positor IN ST_MIN_Stage_Minimum_Annex.ST_MIN_Positor%TYPE DEFAULT NULL,
    p_positing IN ST_MIN_Stage_Minimum_Annex.ST_MIN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ST_MIN_Stage_Minimum_Annex.ST_MIN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ST_MIN_Stage_Minimum_Annex.Metadata_ST_MIN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit ST_MIN_Stage_Minimum_Posit.ST_MIN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN ST_MIN_Stage_Minimum_Posit.ST_MIN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ST_MIN_Stage_Minimum_Annex (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Positor,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ST_MIN_Stage_Minimum_Annex x
                WHERE
                    x.ST_MIN_ID = p_id
                AND
                    x.ST_MIN_Positor = v_positor
                AND
                    x.ST_MIN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            ST_MIN_Stage_Minimum_Posit p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_MIN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_MIN_Stage_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Positor = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_MIN_Stage_Minimum_Posit p
        JOIN
            ST_MIN_Stage_Minimum_Annex a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            a.ST_MIN_Positor = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            ST_MIN_Stage_Minimum_Annex a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Positor = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_ST_MIN_Stage_Minimum(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ST_MIN_Stage_Minimum_Annex (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Positor,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            ST_MIN_Stage_Minimum_Posit p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            COALESCE(he_ST_MIN_Stage_Minimum(p.ST_MIN_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.ST_MIN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ST_MIN_Stage_Minimum_Posit (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_MIN_ID INTO v_posit;
    END IF;
    INSERT INTO ST_MIN_Stage_Minimum_Annex (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Actor_Name tells whether two values of AC_NAM_Actor_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_AC_NAM_Actor_Name (
    p_left IN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name%TYPE,
    p_right IN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_NAM_Actor_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_NAM_Actor_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_AC_NAM_Actor_Name (
    p_id IN AC_NAM_Actor_Name_Annex.AC_NAM_ID%TYPE,
    p_positor IN AC_NAM_Actor_Name_Annex.AC_NAM_Positor%TYPE,
    p_positing IN AC_NAM_Actor_Name_Annex.AC_NAM_PositedAt%TYPE
) RETURN AC_NAM_Actor_Name_Annex.AC_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_NAM_Reliability
        FROM
            AC_NAM_Actor_Name_Annex a
        WHERE
            a.AC_NAM_ID = p_id
        AND
            a.AC_NAM_Positor = p_positor
        AND
            a.AC_NAM_PositedAt <= p_positing
        ORDER BY
            a.AC_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_NAM_Actor_Name (
    p_owner IN AC_NAM_Actor_Name_Posit.AC_NAM_AC_ID%TYPE,
    p_value IN AC_NAM_Actor_Name_Posit.AC_NAM_Actor_Name%TYPE,
    p_changing IN AC_NAM_Actor_Name_Posit.AC_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN AC_NAM_Actor_Name_Annex.AC_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN AC_NAM_Actor_Name_Annex.AC_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_NAM_Actor_Name_Annex.AC_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_NAM_Actor_Name_Annex.Metadata_AC_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit AC_NAM_Actor_Name_Posit.AC_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN AC_NAM_Actor_Name_Posit.AC_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_NAM_Actor_Name_Annex (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Positor,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_NAM_Actor_Name_Annex x
                WHERE
                    x.AC_NAM_ID = p_id
                AND
                    x.AC_NAM_Positor = v_positor
                AND
                    x.AC_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            AC_NAM_Actor_Name_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_NAM_Actor_Name_Annex a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Positor = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_NAM_Actor_Name_Posit p
        JOIN
            AC_NAM_Actor_Name_Annex a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            a.AC_NAM_Positor = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_NAM_Actor_Name_Annex a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Positor = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_AC_NAM_Actor_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_NAM_Actor_Name_Annex (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Positor,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_NAM_ID
        FROM
            AC_NAM_Actor_Name_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            COALESCE(he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.AC_NAM_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name_Posit p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < v_changing
        AND
            COALESCE(he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.AC_NAM_ID,
            f.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name_Posit f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > v_changing
        AND
            COALESCE(he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_NAM_Actor_Name_Posit (
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO AC_NAM_Actor_Name_Annex (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_NAM_Actor_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Actor_Gender tells whether two values of AC_GEN_Actor_Gender are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_AC_GEN_Actor_Gender (
    p_left IN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID%TYPE,
    p_right IN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_GEN_Actor_Gender;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_GEN_Actor_Gender is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_AC_GEN_Actor_Gender (
    p_id IN AC_GEN_Actor_Gender_Annex.AC_GEN_ID%TYPE,
    p_positor IN AC_GEN_Actor_Gender_Annex.AC_GEN_Positor%TYPE,
    p_positing IN AC_GEN_Actor_Gender_Annex.AC_GEN_PositedAt%TYPE
) RETURN AC_GEN_Actor_Gender_Annex.AC_GEN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_GEN_Reliability
        FROM
            AC_GEN_Actor_Gender_Annex a
        WHERE
            a.AC_GEN_ID = p_id
        AND
            a.AC_GEN_Positor = p_positor
        AND
            a.AC_GEN_PositedAt <= p_positing
        ORDER BY
            a.AC_GEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_GEN_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_GEN_Actor_Gender (
    p_owner IN AC_GEN_Actor_Gender_Posit.AC_GEN_AC_ID%TYPE,
    p_value IN AC_GEN_Actor_Gender_Posit.AC_GEN_GEN_ID%TYPE,
    p_positor IN AC_GEN_Actor_Gender_Annex.AC_GEN_Positor%TYPE DEFAULT NULL,
    p_positing IN AC_GEN_Actor_Gender_Annex.AC_GEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_GEN_Actor_Gender_Annex.AC_GEN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_GEN_Actor_Gender_Annex.Metadata_AC_GEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit AC_GEN_Actor_Gender_Posit.AC_GEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN AC_GEN_Actor_Gender_Posit.AC_GEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_GEN_Actor_Gender_Annex (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Positor,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_GEN_Actor_Gender_Annex x
                WHERE
                    x.AC_GEN_ID = p_id
                AND
                    x.AC_GEN_Positor = v_positor
                AND
                    x.AC_GEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            AC_GEN_Actor_Gender_Posit p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_GEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_GEN_Actor_Gender_Annex a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Positor = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_GEN_Actor_Gender_Posit p
        JOIN
            AC_GEN_Actor_Gender_Annex a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            a.AC_GEN_Positor = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_GEN_Actor_Gender_Annex a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Positor = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_AC_GEN_Actor_Gender(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_GEN_Actor_Gender_Annex (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Positor,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            AC_GEN_Actor_Gender_Posit p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            COALESCE(he_AC_GEN_Actor_Gender(p.AC_GEN_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.AC_GEN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_GEN_Actor_Gender_Posit (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING AC_GEN_ID INTO v_posit;
    END IF;
    INSERT INTO AC_GEN_Actor_Gender_Annex (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_GEN_Actor_Gender;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Actor_ProfessionalLevel tells whether two values of AC_PLV_Actor_ProfessionalLevel are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_AC_PLV_Actor_ProfessionalLevel (
    p_left IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID%TYPE,
    p_right IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_AC_PLV_Actor_ProfessionalLevel;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_PLV_Actor_ProfessionalLevel is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_AC_PLV_Actor_ProfessionalLevel (
    p_id IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_ID%TYPE,
    p_positor IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_Positor%TYPE,
    p_positing IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_PositedAt%TYPE
) RETURN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_PLV_Reliability
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex a
        WHERE
            a.AC_PLV_ID = p_id
        AND
            a.AC_PLV_Positor = p_positor
        AND
            a.AC_PLV_PositedAt <= p_positing
        ORDER BY
            a.AC_PLV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_PLV_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_AC_ID%TYPE,
    p_value IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_PLV_ID%TYPE,
    p_changing IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_Positor%TYPE DEFAULT NULL,
    p_positing IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN AC_PLV_Actor_ProfessionalLevel_Annex.AC_PLV_Reliability%TYPE DEFAULT NULL,
    p_metadata IN AC_PLV_Actor_ProfessionalLevel_Annex.Metadata_AC_PLV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN AC_PLV_Actor_ProfessionalLevel_Posit.AC_PLV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Positor,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    AC_PLV_Actor_ProfessionalLevel_Annex x
                WHERE
                    x.AC_PLV_ID = p_id
                AND
                    x.AC_PLV_Positor = v_positor
                AND
                    x.AC_PLV_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_PLV_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Positor = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit p
        JOIN
            AC_PLV_Actor_ProfessionalLevel_Annex a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            a.AC_PLV_Positor = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Positor = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_AC_PLV_Actor_ProfessionalLevel(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Positor,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_PLV_ID
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            COALESCE(he_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.AC_PLV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO AC_PLV_Actor_ProfessionalLevel_Posit (
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING AC_PLV_ID INTO v_posit;
    END IF;
    INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Program_Name tells whether two values of PR_NAM_Program_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_PR_NAM_Program_Name (
    p_left IN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name%TYPE,
    p_right IN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_NAM_Program_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_NAM_Program_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_PR_NAM_Program_Name (
    p_id IN PR_NAM_Program_Name_Annex.PR_NAM_ID%TYPE,
    p_positor IN PR_NAM_Program_Name_Annex.PR_NAM_Positor%TYPE,
    p_positing IN PR_NAM_Program_Name_Annex.PR_NAM_PositedAt%TYPE
) RETURN PR_NAM_Program_Name_Annex.PR_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_NAM_Reliability
        FROM
            PR_NAM_Program_Name_Annex a
        WHERE
            a.PR_NAM_ID = p_id
        AND
            a.PR_NAM_Positor = p_positor
        AND
            a.PR_NAM_PositedAt <= p_positing
        ORDER BY
            a.PR_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_NAM_Program_Name (
    p_owner IN PR_NAM_Program_Name_Posit.PR_NAM_PR_ID%TYPE,
    p_value IN PR_NAM_Program_Name_Posit.PR_NAM_Program_Name%TYPE,
    p_positor IN PR_NAM_Program_Name_Annex.PR_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN PR_NAM_Program_Name_Annex.PR_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN PR_NAM_Program_Name_Annex.PR_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN PR_NAM_Program_Name_Annex.Metadata_PR_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit PR_NAM_Program_Name_Posit.PR_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN PR_NAM_Program_Name_Posit.PR_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO PR_NAM_Program_Name_Annex (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Positor,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    PR_NAM_Program_Name_Annex x
                WHERE
                    x.PR_NAM_ID = p_id
                AND
                    x.PR_NAM_Positor = v_positor
                AND
                    x.PR_NAM_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            PR_NAM_Program_Name_Posit p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_NAM_Program_Name_Annex a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Positor = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_NAM_Program_Name_Posit p
        JOIN
            PR_NAM_Program_Name_Annex a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            a.PR_NAM_Positor = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_NAM_Program_Name_Annex a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Positor = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_PR_NAM_Program_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO PR_NAM_Program_Name_Annex (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Positor,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            PR_NAM_Program_Name_Posit p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            COALESCE(he_PR_NAM_Program_Name(p.PR_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.PR_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO PR_NAM_Program_Name_Posit (
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING PR_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO PR_NAM_Program_Name_Annex (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_NAM_Program_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Program_Length tells whether two values of PR_LEN_Program_Length are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_PR_LEN_Program_Length (
    p_left IN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length%TYPE,
    p_right IN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_PR_LEN_Program_Length;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_LEN_Program_Length is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_PR_LEN_Program_Length (
    p_id IN PR_LEN_Program_Length_Annex.PR_LEN_ID%TYPE,
    p_positor IN PR_LEN_Program_Length_Annex.PR_LEN_Positor%TYPE,
    p_positing IN PR_LEN_Program_Length_Annex.PR_LEN_PositedAt%TYPE
) RETURN PR_LEN_Program_Length_Annex.PR_LEN_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_LEN_Reliability
        FROM
            PR_LEN_Program_Length_Annex a
        WHERE
            a.PR_LEN_ID = p_id
        AND
            a.PR_LEN_Positor = p_positor
        AND
            a.PR_LEN_PositedAt <= p_positing
        ORDER BY
            a.PR_LEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_LEN_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_LEN_Program_Length;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_LEN_Program_Length (
    p_owner IN PR_LEN_Program_Length_Posit.PR_LEN_PR_ID%TYPE,
    p_value IN PR_LEN_Program_Length_Posit.PR_LEN_Program_Length%TYPE,
    p_changing IN PR_LEN_Program_Length_Posit.PR_LEN_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN PR_LEN_Program_Length_Annex.PR_LEN_Positor%TYPE DEFAULT NULL,
    p_positing IN PR_LEN_Program_Length_Annex.PR_LEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN PR_LEN_Program_Length_Annex.PR_LEN_Reliability%TYPE DEFAULT NULL,
    p_metadata IN PR_LEN_Program_Length_Annex.Metadata_PR_LEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing date;
    v_posit PR_LEN_Program_Length_Posit.PR_LEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN PR_LEN_Program_Length_Posit.PR_LEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO PR_LEN_Program_Length_Annex (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    PR_LEN_Program_Length_Annex x
                WHERE
                    x.PR_LEN_ID = p_id
                AND
                    x.PR_LEN_Positor = v_positor
                AND
                    x.PR_LEN_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            PR_LEN_Program_Length_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_LEN_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_LEN_Program_Length_Annex a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Positor = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_LEN_Program_Length_Posit p
        JOIN
            PR_LEN_Program_Length_Annex a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            a.PR_LEN_Positor = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            PR_LEN_Program_Length_Annex a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Positor = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_PR_LEN_Program_Length(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO PR_LEN_Program_Length_Annex (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.PR_LEN_ID
        FROM
            PR_LEN_Program_Length_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            COALESCE(he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.PR_LEN_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            PR_LEN_Program_Length_Posit p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < v_changing
        AND
            COALESCE(he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.PR_LEN_ID,
            f.PR_LEN_Program_Length
        FROM
            PR_LEN_Program_Length_Posit f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > v_changing
        AND
            COALESCE(he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.PR_LEN_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO PR_LEN_Program_Length_Posit (
            PR_LEN_PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING PR_LEN_ID INTO v_posit;
    END IF;
    INSERT INTO PR_LEN_Program_Length_Annex (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_LEN_Program_Length;
/
