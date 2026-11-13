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
--                    0.25 retracts the assertion of it. Default: 1
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
CREATE OR REPLACE FUNCTION attributes.eq_EV_DAT_Event_Date (
    p_left IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE,
    p_right IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_EV_DAT_Event_Date (
    p_id IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_ID%TYPE,
    p_positor IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Who%TYPE,
    p_positing IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_PositedAt%TYPE
) RETURN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_DAT_Confidence
        FROM
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = p_id
        AND
            a.EV_DAT_Who = p_positor
        AND
            a.EV_DAT_PositedAt <= p_positing
        ORDER BY
            a.EV_DAT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_DAT_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Event_Date (
    p_owner IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_Event_Date%TYPE,
    p_positor IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_DAT_Event_Date_Meta.EV_DAT_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_DAT_Event_Date_Meta.Metadata_EV_DAT%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_DAT_Event_Date_Fact.EV_DAT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_DAT_Event_Date_Fact.EV_DAT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_DAT_Event_Date_Meta (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Who,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_DAT_Event_Date_Meta x
                WHERE
                    x.EV_DAT_ID = p_id
                AND
                    x.EV_DAT_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_DAT_ID
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 1
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
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Who = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_DAT_Event_Date_Fact p
        JOIN
            attributes.EV_DAT_Event_Date_Meta a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            a.EV_DAT_Who = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing
        AND
            a.EV_DAT_Confidence <> 0.25;
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
            attributes.EV_DAT_Event_Date_Meta a
        WHERE
            a.EV_DAT_ID = v_posit
        AND
            a.EV_DAT_Who = v_positor
        AND
            a.EV_DAT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_DAT_Event_Date(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_DAT_Event_Date_Meta (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Who,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
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
            attributes.EV_DAT_Event_Date_Fact p
        WHERE
            p.EV_DAT_EV_ID = p_owner
        AND
            attributes.eq_EV_DAT_Event_Date(p.EV_DAT_Event_Date, p_value) = 0
        AND
            COALESCE(attributes.he_EV_DAT_Event_Date(p.EV_DAT_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_DAT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_DAT_Event_Date_Fact (
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_DAT_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_DAT_Event_Date_Meta (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_Who,
        EV_DAT_PositedAt,
        EV_DAT_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_EV_AUD_Event_Audience (
    p_left IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE,
    p_right IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_EV_AUD_Event_Audience (
    p_id IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_ID%TYPE,
    p_positor IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Who%TYPE,
    p_positing IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_PositedAt%TYPE
) RETURN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_AUD_Confidence
        FROM
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = p_id
        AND
            a.EV_AUD_Who = p_positor
        AND
            a.EV_AUD_PositedAt <= p_positing
        ORDER BY
            a.EV_AUD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_AUD_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Event_Audience (
    p_owner IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_Event_Audience%TYPE,
    p_positor IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_AUD_Event_Audience_Meta.EV_AUD_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_AUD_Event_Audience_Meta.Metadata_EV_AUD%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_AUD_Event_Audience_Fact.EV_AUD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_AUD_Event_Audience_Fact.EV_AUD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Who,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_AUD_Event_Audience_Meta x
                WHERE
                    x.EV_AUD_ID = p_id
                AND
                    x.EV_AUD_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_AUD_ID
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 1
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
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Who = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_AUD_Event_Audience_Fact p
        JOIN
            attributes.EV_AUD_Event_Audience_Meta a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            a.EV_AUD_Who = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing
        AND
            a.EV_AUD_Confidence <> 0.25;
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
            attributes.EV_AUD_Event_Audience_Meta a
        WHERE
            a.EV_AUD_ID = v_posit
        AND
            a.EV_AUD_Who = v_positor
        AND
            a.EV_AUD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_AUD_Event_Audience(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Who,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
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
            attributes.EV_AUD_Event_Audience_Fact p
        WHERE
            p.EV_AUD_EV_ID = p_owner
        AND
            attributes.eq_EV_AUD_Event_Audience(p.EV_AUD_Event_Audience, p_value) = 0
        AND
            COALESCE(attributes.he_EV_AUD_Event_Audience(p.EV_AUD_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_AUD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_AUD_Event_Audience_Fact (
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_AUD_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_AUD_Event_Audience_Meta (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Who,
        EV_AUD_PositedAt,
        EV_AUD_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_EV_REV_Event_Revenue (
    p_left IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE,
    p_right IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_EV_REV_Event_Revenue (
    p_id IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_ID%TYPE,
    p_positor IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Who%TYPE,
    p_positing IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_PositedAt%TYPE
) RETURN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_REV_Confidence
        FROM
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = p_id
        AND
            a.EV_REV_Who = p_positor
        AND
            a.EV_REV_PositedAt <= p_positing
        ORDER BY
            a.EV_REV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_REV_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Event_Revenue (
    p_owner IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_Event_Revenue%TYPE,
    p_positor IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_REV_Event_Revenue_Meta.EV_REV_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_REV_Event_Revenue_Meta.Metadata_EV_REV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_REV_Event_Revenue_Fact.EV_REV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_REV_Event_Revenue_Fact.EV_REV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Who,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_REV_Event_Revenue_Meta x
                WHERE
                    x.EV_REV_ID = p_id
                AND
                    x.EV_REV_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_REV_ID
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 1
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
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Who = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_REV_Event_Revenue_Fact p
        JOIN
            attributes.EV_REV_Event_Revenue_Meta a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            a.EV_REV_Who = v_positor
        AND
            a.EV_REV_PositedAt = v_positing
        AND
            a.EV_REV_Confidence <> 0.25;
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
            attributes.EV_REV_Event_Revenue_Meta a
        WHERE
            a.EV_REV_ID = v_posit
        AND
            a.EV_REV_Who = v_positor
        AND
            a.EV_REV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_REV_Event_Revenue(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Who,
            EV_REV_PositedAt,
            EV_REV_Confidence
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
            attributes.EV_REV_Event_Revenue_Fact p
        WHERE
            p.EV_REV_EV_ID = p_owner
        AND
            attributes.eq_EV_REV_Event_Revenue(p.EV_REV_Event_Revenue, p_value) = 0
        AND
            COALESCE(attributes.he_EV_REV_Event_Revenue(p.EV_REV_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_REV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_REV_Event_Revenue_Fact (
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_REV_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_REV_Event_Revenue_Meta (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Who,
        EV_REV_PositedAt,
        EV_REV_Confidence
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
-- eq_EV_STA_Event_Status tells whether two values of EV_STA_Event_Status are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_STA_Event_Status (
    p_left IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE,
    p_right IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_STA_Event_Status;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_STA_Event_Status is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_STA_Event_Status (
    p_id IN attributes.EV_STA_Event_Status_Meta.EV_STA_ID%TYPE,
    p_positor IN attributes.EV_STA_Event_Status_Meta.EV_STA_Who%TYPE,
    p_positing IN attributes.EV_STA_Event_Status_Meta.EV_STA_PositedAt%TYPE
) RETURN attributes.EV_STA_Event_Status_Meta.EV_STA_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_STA_Confidence
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = p_id
        AND
            a.EV_STA_Who = p_positor
        AND
            a.EV_STA_PositedAt <= p_positing
        ORDER BY
            a.EV_STA_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_STA_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_STA_Event_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Event_Status states a value of EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Event_Status (
    p_owner IN attributes.EV_STA_Event_Status_Fact.EV_STA_EV_ID%TYPE,
    p_value IN attributes.EV_STA_Event_Status_Fact.EV_STA_Event_Status%TYPE,
    p_changing IN attributes.EV_STA_Event_Status_Fact.EV_STA_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.EV_STA_Event_Status_Meta.EV_STA_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_STA_Event_Status_Meta.EV_STA_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_STA_Event_Status_Meta.EV_STA_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_STA_Event_Status_Meta.Metadata_EV_STA%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.EV_STA_Event_Status_Fact.EV_STA_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_STA_Event_Status_Fact.EV_STA_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_STA_Event_Status_Meta (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Who,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_STA_Event_Status_Meta x
                WHERE
                    x.EV_STA_ID = p_id
                AND
                    x.EV_STA_Who = v_positor
                AND
                    x.EV_STA_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Event_Status_Fact p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_STA_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_Who = v_positor
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_STA_Event_Status_Fact p
        JOIN
            attributes.EV_STA_Event_Status_Meta a
        ON
            a.EV_STA_ID = p.EV_STA_ID
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 0
        AND
            a.EV_STA_Who = v_positor
        AND
            a.EV_STA_PositedAt = v_positing
        AND
            a.EV_STA_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Event_Status for: ' || p_owner || ', ' ||
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
            attributes.EV_STA_Event_Status_Meta a
        WHERE
            a.EV_STA_ID = v_posit
        AND
            a.EV_STA_Who = v_positor
        AND
            a.EV_STA_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_STA_Event_Status(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_STA_Event_Status_Meta (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Who,
            EV_STA_PositedAt,
            EV_STA_Confidence
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
            p.EV_STA_ID
        FROM
            attributes.EV_STA_Event_Status_Fact p
        WHERE
            p.EV_STA_EV_ID = p_owner
        AND
            p.EV_STA_ChangedAt = v_changing
        AND
            attributes.eq_EV_STA_Event_Status(p.EV_STA_Event_Status, p_value) = 0
        AND
            COALESCE(attributes.he_EV_STA_Event_Status(p.EV_STA_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_STA_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_STA_Event_Status_Fact (
            EV_STA_EV_ID,
            EV_STA_ChangedAt,
            EV_STA_Event_Status
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_STA_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_STA_Event_Status_Meta (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Who,
        EV_STA_PositedAt,
        EV_STA_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_STA_Event_Status;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Event_Utilization tells whether two values of EV_UTL_Event_Utilization are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_UTL_Event_Utilization (
    p_left IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE,
    p_right IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_UTL_Event_Utilization;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_UTL_Event_Utilization is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_UTL_Event_Utilization (
    p_id IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_ID%TYPE,
    p_positor IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Who%TYPE,
    p_positing IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_PositedAt%TYPE
) RETURN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_UTL_Confidence
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = p_id
        AND
            a.EV_UTL_Who = p_positor
        AND
            a.EV_UTL_PositedAt <= p_positing
        ORDER BY
            a.EV_UTL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_UTL_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_UTL_Event_Utilization;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Event_Utilization states a value of EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Event_Utilization (
    p_owner IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_UTL_ID%TYPE,
    p_positor IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_UTL_Event_Utilization_Meta.EV_UTL_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_UTL_Event_Utilization_Meta.Metadata_EV_UTL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_UTL_Event_Utilization_Fact.EV_UTL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Who,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_UTL_Event_Utilization_Meta x
                WHERE
                    x.EV_UTL_ID = p_id
                AND
                    x.EV_UTL_Who = v_positor
                AND
                    x.EV_UTL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_UTL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_Who = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        JOIN
            attributes.EV_UTL_Event_Utilization_Meta a
        ON
            a.EV_UTL_ID = p.EV_UTL_ID
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            a.EV_UTL_Who = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing
        AND
            a.EV_UTL_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Event_Utilization for: ' || p_owner || ', ' ||
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
            attributes.EV_UTL_Event_Utilization_Meta a
        WHERE
            a.EV_UTL_ID = v_posit
        AND
            a.EV_UTL_Who = v_positor
        AND
            a.EV_UTL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_UTL_Event_Utilization(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Who,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
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
            p.EV_UTL_ID
        FROM
            attributes.EV_UTL_Event_Utilization_Fact p
        WHERE
            p.EV_UTL_EV_ID = p_owner
        AND
            attributes.eq_EV_UTL_Event_Utilization(p.EV_UTL_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_UTL_Event_Utilization(p.EV_UTL_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_UTL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_UTL_Event_Utilization_Fact (
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_UTL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_UTL_Event_Utilization_Meta (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Who,
        EV_UTL_PositedAt,
        EV_UTL_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_UTL_Event_Utilization;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Event_Level tells whether two values of EV_LVL_Event_Level are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_EV_LVL_Event_Level (
    p_left IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE,
    p_right IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_LVL_Event_Level;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_LVL_Event_Level is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.he_EV_LVL_Event_Level (
    p_id IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_ID%TYPE,
    p_positor IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Who%TYPE,
    p_positing IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_PositedAt%TYPE
) RETURN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_LVL_Confidence
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = p_id
        AND
            a.EV_LVL_Who = p_positor
        AND
            a.EV_LVL_PositedAt <= p_positing
        ORDER BY
            a.EV_LVL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_LVL_Confidence;
    END LOOP;
    RETURN NULL;
END he_EV_LVL_Event_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Event_Level states a value of EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Event_Level (
    p_owner IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_EV_ID%TYPE,
    p_value IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_PLV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.EV_LVL_Event_Level_Meta.EV_LVL_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.EV_LVL_Event_Level_Meta.Metadata_EV_LVL%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing date;
    v_posit attributes.EV_LVL_Event_Level_Fact.EV_LVL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.EV_LVL_Event_Level_Fact.EV_LVL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.EV_LVL_Event_Level_Meta (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Who,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.EV_LVL_Event_Level_Meta x
                WHERE
                    x.EV_LVL_ID = p_id
                AND
                    x.EV_LVL_Who = v_positor
                AND
                    x.EV_LVL_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := p_positing;
    IF v_positing IS NULL THEN
        v_positing := v_now;
    END IF;
    v_reliability := COALESCE(p_reliability, 1);
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    v_changing := p_changing;
    IF v_changing IS NULL THEN
        v_changing := v_now;
    END IF;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_LVL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_Who = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        JOIN
            attributes.EV_LVL_Event_Level_Meta a
        ON
            a.EV_LVL_ID = p.EV_LVL_ID
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            a.EV_LVL_Who = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing
        AND
            a.EV_LVL_Confidence <> 0.25;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Event_Level for: ' || p_owner || ', ' ||
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
            attributes.EV_LVL_Event_Level_Meta a
        WHERE
            a.EV_LVL_ID = v_posit
        AND
            a.EV_LVL_Who = v_positor
        AND
            a.EV_LVL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_EV_LVL_Event_Level(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.EV_LVL_Event_Level_Meta (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Who,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
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
            p.EV_LVL_ID
        FROM
            attributes.EV_LVL_Event_Level_Fact p
        WHERE
            p.EV_LVL_EV_ID = p_owner
        AND
            p.EV_LVL_ChangedAt = v_changing
        AND
            attributes.eq_EV_LVL_Event_Level(p.EV_LVL_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_EV_LVL_Event_Level(p.EV_LVL_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.EV_LVL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.EV_LVL_Event_Level_Fact (
            EV_LVL_EV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_LVL_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.EV_LVL_Event_Level_Meta (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Who,
        EV_LVL_PositedAt,
        EV_LVL_Confidence
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_LVL_Event_Level;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Stage_Name tells whether two values of ST_NAM_Stage_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.eq_ST_NAM_Stage_Name (
    p_left IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE,
    p_right IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_ST_NAM_Stage_Name (
    p_id IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_ID%TYPE,
    p_positor IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Who%TYPE,
    p_positing IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_PositedAt%TYPE
) RETURN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_NAM_Confidence
        FROM
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = p_id
        AND
            a.ST_NAM_Who = p_positor
        AND
            a.ST_NAM_PositedAt <= p_positing
        ORDER BY
            a.ST_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Stage_Name (
    p_owner IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ST_ID%TYPE,
    p_value IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_Stage_Name%TYPE,
    p_changing IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_NAM_Stage_Name_Meta.ST_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_NAM_Stage_Name_Meta.Metadata_ST_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_NAM_Stage_Name_Fact.ST_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Who,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_NAM_Stage_Name_Meta x
                WHERE
                    x.ST_NAM_ID = p_id
                AND
                    x.ST_NAM_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
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
            attributes.ST_NAM_Stage_Name_Fact p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 1
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
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Who = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_NAM_Stage_Name_Fact p
        JOIN
            attributes.ST_NAM_Stage_Name_Meta a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            a.ST_NAM_Who = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing
        AND
            a.ST_NAM_Confidence <> 0.25;
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
            attributes.ST_NAM_Stage_Name_Meta a
        WHERE
            a.ST_NAM_ID = v_posit
        AND
            a.ST_NAM_Who = v_positor
        AND
            a.ST_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_NAM_Stage_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Who,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
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
            attributes.ST_NAM_Stage_Name_Fact p
        WHERE
            p.ST_NAM_ST_ID = p_owner
        AND
            p.ST_NAM_ChangedAt = v_changing
        AND
            attributes.eq_ST_NAM_Stage_Name(p.ST_NAM_Stage_Name, p_value) = 0
        AND
            COALESCE(attributes.he_ST_NAM_Stage_Name(p.ST_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_NAM_Stage_Name_Fact (
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
    INSERT INTO attributes.ST_NAM_Stage_Name_Meta (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Who,
        ST_NAM_PositedAt,
        ST_NAM_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_ST_LOC_Stage_Location (
    p_left IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE,
    p_right IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_ST_LOC_Stage_Location (
    p_id IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_ID%TYPE,
    p_positor IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Who%TYPE,
    p_positing IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_PositedAt%TYPE
) RETURN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_LOC_Confidence
        FROM
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = p_id
        AND
            a.ST_LOC_Who = p_positor
        AND
            a.ST_LOC_PositedAt <= p_positing
        ORDER BY
            a.ST_LOC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_LOC_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Stage_Location (
    p_owner IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_Stage_Location%TYPE,
    p_positor IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_LOC_Stage_Location_Meta.ST_LOC_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_LOC_Stage_Location_Meta.Metadata_ST_LOC%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_LOC_Stage_Location_Fact.ST_LOC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Who,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_LOC_Stage_Location_Meta x
                WHERE
                    x.ST_LOC_ID = p_id
                AND
                    x.ST_LOC_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_LOC_ID
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 1
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
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Who = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_LOC_Stage_Location_Fact p
        JOIN
            attributes.ST_LOC_Stage_Location_Meta a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            a.ST_LOC_Who = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing
        AND
            a.ST_LOC_Confidence <> 0.25;
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
            attributes.ST_LOC_Stage_Location_Meta a
        WHERE
            a.ST_LOC_ID = v_posit
        AND
            a.ST_LOC_Who = v_positor
        AND
            a.ST_LOC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_LOC_Stage_Location(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Who,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
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
            attributes.ST_LOC_Stage_Location_Fact p
        WHERE
            p.ST_LOC_ST_ID = p_owner
        AND
            attributes.eq_ST_LOC_Stage_Location(p.ST_LOC_Stage_Location, p_value) = 0
        AND
            COALESCE(attributes.he_ST_LOC_Stage_Location(p.ST_LOC_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_LOC_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_LOC_Stage_Location_Fact (
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_LOC_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_LOC_Stage_Location_Meta (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Who,
        ST_LOC_PositedAt,
        ST_LOC_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_ST_AVG_Stage_Average (
    p_left IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE,
    p_right IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_ST_AVG_Stage_Average (
    p_id IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_ID%TYPE,
    p_positor IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Who%TYPE,
    p_positing IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_PositedAt%TYPE
) RETURN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_AVG_Confidence
        FROM
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = p_id
        AND
            a.ST_AVG_Who = p_positor
        AND
            a.ST_AVG_PositedAt <= p_positing
        ORDER BY
            a.ST_AVG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_AVG_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Stage_Average (
    p_owner IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ST_ID%TYPE,
    p_value IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_UTL_ID%TYPE,
    p_changing IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_AVG_Stage_Average_Meta.ST_AVG_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_AVG_Stage_Average_Meta.Metadata_ST_AVG%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_AVG_Stage_Average_Fact.ST_AVG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_AVG_Stage_Average_Meta x
                WHERE
                    x.ST_AVG_ID = p_id
                AND
                    x.ST_AVG_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
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
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 1
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
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Who = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        JOIN
            attributes.ST_AVG_Stage_Average_Meta a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            a.ST_AVG_Who = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing
        AND
            a.ST_AVG_Confidence <> 0.25;
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
            attributes.ST_AVG_Stage_Average_Meta a
        WHERE
            a.ST_AVG_ID = v_posit
        AND
            a.ST_AVG_Who = v_positor
        AND
            a.ST_AVG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_AVG_Stage_Average(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
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
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt = v_changing
        AND
            attributes.eq_ST_AVG_Stage_Average(p.ST_AVG_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_AVG_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Stage_Average_Fact p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_ST_AVG_Stage_Average(p.ST_AVG_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
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
            attributes.ST_AVG_Stage_Average_Fact f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_ST_AVG_Stage_Average(f.ST_AVG_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_ST_AVG_Stage_Average(r.ST_AVG_UTL_ID, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.ST_AVG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_AVG_Stage_Average_Fact (
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
    INSERT INTO attributes.ST_AVG_Stage_Average_Meta (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Who,
        ST_AVG_PositedAt,
        ST_AVG_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_ST_MIN_Stage_Minimum (
    p_left IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE,
    p_right IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_ST_MIN_Stage_Minimum (
    p_id IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_ID%TYPE,
    p_positor IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Who%TYPE,
    p_positing IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_PositedAt%TYPE
) RETURN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_MIN_Confidence
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = p_id
        AND
            a.ST_MIN_Who = p_positor
        AND
            a.ST_MIN_PositedAt <= p_positing
        ORDER BY
            a.ST_MIN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_MIN_Confidence;
    END LOOP;
    RETURN NULL;
END he_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Stage_Minimum (
    p_owner IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_UTL_ID%TYPE,
    p_positor IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.ST_MIN_Stage_Minimum_Meta.ST_MIN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.ST_MIN_Stage_Minimum_Meta.Metadata_ST_MIN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.ST_MIN_Stage_Minimum_Fact.ST_MIN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Who,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.ST_MIN_Stage_Minimum_Meta x
                WHERE
                    x.ST_MIN_ID = p_id
                AND
                    x.ST_MIN_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.ST_MIN_ID
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 1
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
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Who = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.ST_MIN_Stage_Minimum_Fact p
        JOIN
            attributes.ST_MIN_Stage_Minimum_Meta a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            a.ST_MIN_Who = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing
        AND
            a.ST_MIN_Confidence <> 0.25;
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
            attributes.ST_MIN_Stage_Minimum_Meta a
        WHERE
            a.ST_MIN_ID = v_posit
        AND
            a.ST_MIN_Who = v_positor
        AND
            a.ST_MIN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_ST_MIN_Stage_Minimum(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Who,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
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
            attributes.ST_MIN_Stage_Minimum_Fact p
        WHERE
            p.ST_MIN_ST_ID = p_owner
        AND
            attributes.eq_ST_MIN_Stage_Minimum(p.ST_MIN_UTL_ID, p_value) = 0
        AND
            COALESCE(attributes.he_ST_MIN_Stage_Minimum(p.ST_MIN_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.ST_MIN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.ST_MIN_Stage_Minimum_Fact (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING ST_MIN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.ST_MIN_Stage_Minimum_Meta (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Who,
        ST_MIN_PositedAt,
        ST_MIN_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_AC_NAM_Actor_Name (
    p_left IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE,
    p_right IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_AC_NAM_Actor_Name (
    p_id IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_ID%TYPE,
    p_positor IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Who%TYPE,
    p_positing IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_PositedAt%TYPE
) RETURN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_NAM_Confidence
        FROM
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = p_id
        AND
            a.AC_NAM_Who = p_positor
        AND
            a.AC_NAM_PositedAt <= p_positing
        ORDER BY
            a.AC_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Actor_Name (
    p_owner IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_AC_ID%TYPE,
    p_value IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_Actor_Name%TYPE,
    p_changing IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_NAM_Actor_Name_Meta.AC_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_NAM_Actor_Name_Meta.Metadata_AC_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_NAM_Actor_Name_Fact.AC_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Who,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_NAM_Actor_Name_Meta x
                WHERE
                    x.AC_NAM_ID = p_id
                AND
                    x.AC_NAM_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
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
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 1
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
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Who = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        JOIN
            attributes.AC_NAM_Actor_Name_Meta a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            a.AC_NAM_Who = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing
        AND
            a.AC_NAM_Confidence <> 0.25;
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
            attributes.AC_NAM_Actor_Name_Meta a
        WHERE
            a.AC_NAM_ID = v_posit
        AND
            a.AC_NAM_Who = v_positor
        AND
            a.AC_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_NAM_Actor_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Who,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
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
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt = v_changing
        AND
            attributes.eq_AC_NAM_Actor_Name(p.AC_NAM_Actor_Name, p_value) = 0
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.AC_NAM_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name_Fact p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_AC_NAM_Actor_Name(p.AC_NAM_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.AC_NAM_ID,
            f.AC_NAM_Actor_Name
        FROM
            attributes.AC_NAM_Actor_Name_Fact f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_AC_NAM_Actor_Name(f.AC_NAM_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_AC_NAM_Actor_Name(r.AC_NAM_Actor_Name, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_NAM_Actor_Name_Fact (
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
    INSERT INTO attributes.AC_NAM_Actor_Name_Meta (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Who,
        AC_NAM_PositedAt,
        AC_NAM_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_AC_GEN_Actor_Gender (
    p_left IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE,
    p_right IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_AC_GEN_Actor_Gender (
    p_id IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_ID%TYPE,
    p_positor IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Who%TYPE,
    p_positing IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_PositedAt%TYPE
) RETURN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_GEN_Confidence
        FROM
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = p_id
        AND
            a.AC_GEN_Who = p_positor
        AND
            a.AC_GEN_PositedAt <= p_positing
        ORDER BY
            a.AC_GEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_GEN_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Actor_Gender (
    p_owner IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_GEN_ID%TYPE,
    p_positor IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_GEN_Actor_Gender_Meta.AC_GEN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_GEN_Actor_Gender_Meta.Metadata_AC_GEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_GEN_Actor_Gender_Fact.AC_GEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Who,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_GEN_Actor_Gender_Meta x
                WHERE
                    x.AC_GEN_ID = p_id
                AND
                    x.AC_GEN_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.AC_GEN_ID
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 1
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
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Who = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_GEN_Actor_Gender_Fact p
        JOIN
            attributes.AC_GEN_Actor_Gender_Meta a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            a.AC_GEN_Who = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing
        AND
            a.AC_GEN_Confidence <> 0.25;
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
            attributes.AC_GEN_Actor_Gender_Meta a
        WHERE
            a.AC_GEN_ID = v_posit
        AND
            a.AC_GEN_Who = v_positor
        AND
            a.AC_GEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_GEN_Actor_Gender(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Who,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
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
            attributes.AC_GEN_Actor_Gender_Fact p
        WHERE
            p.AC_GEN_AC_ID = p_owner
        AND
            attributes.eq_AC_GEN_Actor_Gender(p.AC_GEN_GEN_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_GEN_Actor_Gender(p.AC_GEN_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.AC_GEN_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_GEN_Actor_Gender_Fact (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING AC_GEN_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.AC_GEN_Actor_Gender_Meta (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Who,
        AC_GEN_PositedAt,
        AC_GEN_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_AC_PLV_Actor_ProfessionalLevel (
    p_left IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE,
    p_right IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_AC_PLV_Actor_ProfessionalLevel (
    p_id IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_ID%TYPE,
    p_positor IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Who%TYPE,
    p_positing IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_PositedAt%TYPE
) RETURN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_PLV_Confidence
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = p_id
        AND
            a.AC_PLV_Who = p_positor
        AND
            a.AC_PLV_PositedAt <= p_positing
        ORDER BY
            a.AC_PLV_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_PLV_Confidence;
    END LOOP;
    RETURN NULL;
END he_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_AC_ID%TYPE,
    p_value IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_PLV_ID%TYPE,
    p_changing IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.AC_PLV_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.AC_PLV_Actor_ProfessionalLevel_Meta.Metadata_AC_PLV%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing timestamp;
    v_posit attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.AC_PLV_Actor_ProfessionalLevel_Fact.AC_PLV_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Who,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.AC_PLV_Actor_ProfessionalLevel_Meta x
                WHERE
                    x.AC_PLV_ID = p_id
                AND
                    x.AC_PLV_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
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
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 1
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
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Who = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        JOIN
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            a.AC_PLV_Who = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing
        AND
            a.AC_PLV_Confidence <> 0.25;
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
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
        WHERE
            a.AC_PLV_ID = v_posit
        AND
            a.AC_PLV_Who = v_positor
        AND
            a.AC_PLV_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_AC_PLV_Actor_ProfessionalLevel(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Who,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
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
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
        WHERE
            p.AC_PLV_AC_ID = p_owner
        AND
            p.AC_PLV_ChangedAt = v_changing
        AND
            attributes.eq_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_PLV_ID, p_value) = 0
        AND
            COALESCE(attributes.he_AC_PLV_Actor_ProfessionalLevel(p.AC_PLV_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.AC_PLV_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Fact (
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
    INSERT INTO attributes.AC_PLV_Actor_ProfessionalLevel_Meta (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Who,
        AC_PLV_PositedAt,
        AC_PLV_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_PR_NAM_Program_Name (
    p_left IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE,
    p_right IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_PR_NAM_Program_Name (
    p_id IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_ID%TYPE,
    p_positor IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Who%TYPE,
    p_positing IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_PositedAt%TYPE
) RETURN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_NAM_Confidence
        FROM
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = p_id
        AND
            a.PR_NAM_Who = p_positor
        AND
            a.PR_NAM_PositedAt <= p_positing
        ORDER BY
            a.PR_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_NAM_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Program_Name (
    p_owner IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_Program_Name%TYPE,
    p_positor IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_NAM_Program_Name_Meta.PR_NAM_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_NAM_Program_Name_Meta.Metadata_PR_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_posit attributes.PR_NAM_Program_Name_Fact.PR_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_NAM_Program_Name_Fact.PR_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_NAM_Program_Name_Meta (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Who,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_NAM_Program_Name_Meta x
                WHERE
                    x.PR_NAM_ID = p_id
                AND
                    x.PR_NAM_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
    -- the posit, if there is one
    v_posit := NULL;
    FOR r IN (
        SELECT
            p.PR_NAM_ID
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 1
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
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Who = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_NAM_Program_Name_Fact p
        JOIN
            attributes.PR_NAM_Program_Name_Meta a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            a.PR_NAM_Who = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing
        AND
            a.PR_NAM_Confidence <> 0.25;
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
            attributes.PR_NAM_Program_Name_Meta a
        WHERE
            a.PR_NAM_ID = v_posit
        AND
            a.PR_NAM_Who = v_positor
        AND
            a.PR_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_PR_NAM_Program_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_NAM_Program_Name_Meta (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Who,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
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
            attributes.PR_NAM_Program_Name_Fact p
        WHERE
            p.PR_NAM_PR_ID = p_owner
        AND
            attributes.eq_PR_NAM_Program_Name(p.PR_NAM_Program_Name, p_value) = 0
        AND
            COALESCE(attributes.he_PR_NAM_Program_Name(p.PR_NAM_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.PR_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_NAM_Program_Name_Fact (
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING PR_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO attributes.PR_NAM_Program_Name_Meta (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Who,
        PR_NAM_PositedAt,
        PR_NAM_Confidence
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
CREATE OR REPLACE FUNCTION attributes.eq_PR_LEN_Program_Length (
    p_left IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE,
    p_right IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE
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
CREATE OR REPLACE FUNCTION attributes.he_PR_LEN_Program_Length (
    p_id IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_ID%TYPE,
    p_positor IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Who%TYPE,
    p_positing IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_PositedAt%TYPE
) RETURN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Confidence%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_LEN_Confidence
        FROM
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = p_id
        AND
            a.PR_LEN_Who = p_positor
        AND
            a.PR_LEN_PositedAt <= p_positing
        ORDER BY
            a.PR_LEN_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_LEN_Confidence;
    END LOOP;
    RETURN NULL;
END he_PR_LEN_Program_Length;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Program_Length (
    p_owner IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_PR_ID%TYPE,
    p_value IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_Program_Length%TYPE,
    p_changing IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Who%TYPE DEFAULT NULL,
    p_positing IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN attributes.PR_LEN_Program_Length_Meta.PR_LEN_Confidence%TYPE DEFAULT NULL,
    p_metadata IN attributes.PR_LEN_Program_Length_Meta.Metadata_PR_LEN%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(5);
    v_positing timestamp(3);
    v_reliability number(7,3);
    v_positive NUMBER(1);
    v_held number(7,3);
    v_changing date;
    v_posit attributes.PR_LEN_Program_Length_Fact.PR_LEN_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN attributes.PR_LEN_Program_Length_Fact.PR_LEN_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO attributes.PR_LEN_Program_Length_Meta (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0.25
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    attributes.PR_LEN_Program_Length_Meta x
                WHERE
                    x.PR_LEN_ID = p_id
                AND
                    x.PR_LEN_Who = v_positor
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
    v_positive := CASE WHEN v_reliability > 0.25 THEN 1 ELSE 0 END;
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
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 1
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
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Who = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Confidence <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, is an assertion of another value at that time
    IF v_reliability <> 0.25 THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        JOIN
            attributes.PR_LEN_Program_Length_Meta a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            a.PR_LEN_Who = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing
        AND
            a.PR_LEN_Confidence <> 0.25;
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
            attributes.PR_LEN_Program_Length_Meta a
        WHERE
            a.PR_LEN_ID = v_posit
        AND
            a.PR_LEN_Who = v_positor
        AND
            a.PR_LEN_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := attributes.he_PR_LEN_Program_Length(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0.25 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0.25) = 0.25 THEN
            RETURN;
        END IF;
        INSERT INTO attributes.PR_LEN_Program_Length_Meta (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
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
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt = v_changing
        AND
            attributes.eq_PR_LEN_Program_Length(p.PR_LEN_Program_Length, p_value) = 0
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing), 0.25) <> 0.25
    ) LOOP
        retract(r.PR_LEN_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            attributes.PR_LEN_Program_Length_Fact p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_PR_LEN_Program_Length(p.PR_LEN_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
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
            attributes.PR_LEN_Program_Length_Fact f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > v_changing
        AND
            COALESCE(attributes.he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positor, v_positing), 0.25) <> 0.25
        AND
            CASE WHEN attributes.he_PR_LEN_Program_Length(f.PR_LEN_ID, v_positor, v_positing) > 0.25 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF attributes.eq_PR_LEN_Program_Length(r.PR_LEN_Program_Length, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.PR_LEN_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO attributes.PR_LEN_Program_Length_Fact (
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
    INSERT INTO attributes.PR_LEN_Program_Length_Meta (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Who,
        PR_LEN_PositedAt,
        PR_LEN_Confidence
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
