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
-- eq_EV_QTY_Event_Quantity tells whether two values of EV_QTY_Event_Quantity are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_QTY_Event_Quantity (
    p_left IN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity%TYPE,
    p_right IN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_QTY_Event_Quantity;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_QTY_Event_Quantity is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_QTY_Event_Quantity (
    p_id IN EV_QTY_Event_Quantity_Annex.EV_QTY_ID%TYPE,
    p_positor IN EV_QTY_Event_Quantity_Annex.EV_QTY_Positor%TYPE,
    p_positing IN EV_QTY_Event_Quantity_Annex.EV_QTY_PositedAt%TYPE
) RETURN EV_QTY_Event_Quantity_Annex.EV_QTY_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_QTY_Reliability
        FROM
            EV_QTY_Event_Quantity_Annex a
        WHERE
            a.EV_QTY_ID = p_id
        AND
            a.EV_QTY_Positor = p_positor
        AND
            a.EV_QTY_PositedAt <= p_positing
        ORDER BY
            a.EV_QTY_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_QTY_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_QTY_Event_Quantity;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_QTY_Event_Quantity states a value of EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_QTY_Event_Quantity (
    p_owner IN EV_QTY_Event_Quantity_Posit.EV_QTY_EV_ID%TYPE,
    p_value IN EV_QTY_Event_Quantity_Posit.EV_QTY_Event_Quantity%TYPE,
    p_positor IN EV_QTY_Event_Quantity_Annex.EV_QTY_Positor%TYPE DEFAULT NULL,
    p_positing IN EV_QTY_Event_Quantity_Annex.EV_QTY_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_QTY_Event_Quantity_Annex.EV_QTY_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_QTY_Event_Quantity_Annex.Metadata_EV_QTY%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit EV_QTY_Event_Quantity_Posit.EV_QTY_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_QTY_Event_Quantity_Posit.EV_QTY_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_QTY_Event_Quantity_Annex (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_Positor,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
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
                    EV_QTY_Event_Quantity_Annex x
                WHERE
                    x.EV_QTY_ID = p_id
                AND
                    x.EV_QTY_Positor = v_positor
                AND
                    x.EV_QTY_PositedAt = v_positing
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
            p.EV_QTY_ID
        FROM
            EV_QTY_Event_Quantity_Posit p
        WHERE
            p.EV_QTY_EV_ID = p_owner
        AND
            eq_EV_QTY_Event_Quantity(p.EV_QTY_Event_Quantity, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_QTY_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_QTY_Event_Quantity_Annex a
        WHERE
            a.EV_QTY_ID = v_posit
        AND
            a.EV_QTY_Positor = v_positor
        AND
            a.EV_QTY_PositedAt = v_positing
        AND
            a.EV_QTY_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_QTY_Event_Quantity for: ' || p_owner || ', ' ||
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
            EV_QTY_Event_Quantity_Posit p
        JOIN
            EV_QTY_Event_Quantity_Annex a
        ON
            a.EV_QTY_ID = p.EV_QTY_ID
        WHERE
            p.EV_QTY_EV_ID = p_owner
        AND
            eq_EV_QTY_Event_Quantity(p.EV_QTY_Event_Quantity, p_value) = 0
        AND
            a.EV_QTY_Positor = v_positor
        AND
            a.EV_QTY_PositedAt = v_positing
        AND
            a.EV_QTY_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_QTY_Event_Quantity for: ' || p_owner || ', ' ||
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
            EV_QTY_Event_Quantity_Annex a
        WHERE
            a.EV_QTY_ID = v_posit
        AND
            a.EV_QTY_Positor = v_positor
        AND
            a.EV_QTY_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_EV_QTY_Event_Quantity(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO EV_QTY_Event_Quantity_Annex (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_Positor,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
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
            p.EV_QTY_ID
        FROM
            EV_QTY_Event_Quantity_Posit p
        WHERE
            p.EV_QTY_EV_ID = p_owner
        AND
            eq_EV_QTY_Event_Quantity(p.EV_QTY_Event_Quantity, p_value) = 0
        AND
            COALESCE(he_EV_QTY_Event_Quantity(p.EV_QTY_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_QTY_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_QTY_Event_Quantity_Posit (
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING EV_QTY_ID INTO v_posit;
    END IF;
    INSERT INTO EV_QTY_Event_Quantity_Annex (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_Positor,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_QTY_Event_Quantity;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_PLC_Event_Place tells whether two values of EV_PLC_Event_Place are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_EV_PLC_Event_Place (
    p_left IN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place%TYPE,
    p_right IN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_EV_PLC_Event_Place;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_PLC_Event_Place is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_EV_PLC_Event_Place (
    p_id IN EV_PLC_Event_Place_Annex.EV_PLC_ID%TYPE,
    p_positor IN EV_PLC_Event_Place_Annex.EV_PLC_Positor%TYPE,
    p_positing IN EV_PLC_Event_Place_Annex.EV_PLC_PositedAt%TYPE
) RETURN EV_PLC_Event_Place_Annex.EV_PLC_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_PLC_Reliability
        FROM
            EV_PLC_Event_Place_Annex a
        WHERE
            a.EV_PLC_ID = p_id
        AND
            a.EV_PLC_Positor = p_positor
        AND
            a.EV_PLC_PositedAt <= p_positing
        ORDER BY
            a.EV_PLC_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_PLC_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_PLC_Event_Place;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_PLC_Event_Place states a value of EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_PLC_Event_Place (
    p_owner IN EV_PLC_Event_Place_Posit.EV_PLC_EV_ID%TYPE,
    p_value IN EV_PLC_Event_Place_Posit.EV_PLC_Event_Place%TYPE,
    p_changing IN EV_PLC_Event_Place_Posit.EV_PLC_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN EV_PLC_Event_Place_Annex.EV_PLC_Positor%TYPE DEFAULT NULL,
    p_positing IN EV_PLC_Event_Place_Annex.EV_PLC_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN EV_PLC_Event_Place_Annex.EV_PLC_Reliability%TYPE DEFAULT NULL,
    p_metadata IN EV_PLC_Event_Place_Annex.Metadata_EV_PLC%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit EV_PLC_Event_Place_Posit.EV_PLC_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN EV_PLC_Event_Place_Posit.EV_PLC_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO EV_PLC_Event_Place_Annex (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_Positor,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
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
                    EV_PLC_Event_Place_Annex x
                WHERE
                    x.EV_PLC_ID = p_id
                AND
                    x.EV_PLC_Positor = v_positor
                AND
                    x.EV_PLC_PositedAt = v_positing
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
            p.EV_PLC_ID
        FROM
            EV_PLC_Event_Place_Posit p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt = v_changing
        AND
            eq_EV_PLC_Event_Place(p.EV_PLC_Event_Place, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_PLC_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            EV_PLC_Event_Place_Annex a
        WHERE
            a.EV_PLC_ID = v_posit
        AND
            a.EV_PLC_Positor = v_positor
        AND
            a.EV_PLC_PositedAt = v_positing
        AND
            a.EV_PLC_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_PLC_Event_Place for: ' || p_owner || ', ' ||
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
            EV_PLC_Event_Place_Posit p
        JOIN
            EV_PLC_Event_Place_Annex a
        ON
            a.EV_PLC_ID = p.EV_PLC_ID
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt = v_changing
        AND
            eq_EV_PLC_Event_Place(p.EV_PLC_Event_Place, p_value) = 0
        AND
            a.EV_PLC_Positor = v_positor
        AND
            a.EV_PLC_PositedAt = v_positing
        AND
            a.EV_PLC_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_PLC_Event_Place for: ' || p_owner || ', ' ||
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
            EV_PLC_Event_Place_Annex a
        WHERE
            a.EV_PLC_ID = v_posit
        AND
            a.EV_PLC_Positor = v_positor
        AND
            a.EV_PLC_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_EV_PLC_Event_Place(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO EV_PLC_Event_Place_Annex (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_Positor,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
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
            p.EV_PLC_ID
        FROM
            EV_PLC_Event_Place_Posit p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt = v_changing
        AND
            eq_EV_PLC_Event_Place(p.EV_PLC_Event_Place, p_value) = 0
        AND
            COALESCE(he_EV_PLC_Event_Place(p.EV_PLC_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.EV_PLC_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place_Posit p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt < v_changing
        AND
            COALESCE(he_EV_PLC_Event_Place(p.EV_PLC_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_EV_PLC_Event_Place(p.EV_PLC_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.EV_PLC_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_EV_PLC_Event_Place(r.EV_PLC_Event_Place, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.EV_PLC_ID,
            f.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place_Posit f
        WHERE
            f.EV_PLC_EV_ID = p_owner
        AND
            f.EV_PLC_ChangedAt > v_changing
        AND
            COALESCE(he_EV_PLC_Event_Place(f.EV_PLC_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_EV_PLC_Event_Place(f.EV_PLC_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.EV_PLC_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_EV_PLC_Event_Place(r.EV_PLC_Event_Place, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO EV_PLC_Event_Place_Posit (
            EV_PLC_EV_ID,
            EV_PLC_ChangedAt,
            EV_PLC_Event_Place
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING EV_PLC_ID INTO v_posit;
    END IF;
    INSERT INTO EV_PLC_Event_Place_Annex (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_Positor,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_PLC_Event_Place;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NAM_Subject_Name tells whether two values of SU_NAM_Subject_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_NAM_Subject_Name (
    p_left IN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name%TYPE,
    p_right IN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_NAM_Subject_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_NAM_Subject_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_NAM_Subject_Name (
    p_id IN SU_NAM_Subject_Name_Annex.SU_NAM_ID%TYPE,
    p_positor IN SU_NAM_Subject_Name_Annex.SU_NAM_Positor%TYPE,
    p_positing IN SU_NAM_Subject_Name_Annex.SU_NAM_PositedAt%TYPE
) RETURN SU_NAM_Subject_Name_Annex.SU_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_NAM_Reliability
        FROM
            SU_NAM_Subject_Name_Annex a
        WHERE
            a.SU_NAM_ID = p_id
        AND
            a.SU_NAM_Positor = p_positor
        AND
            a.SU_NAM_PositedAt <= p_positing
        ORDER BY
            a.SU_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_NAM_Subject_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NAM_Subject_Name states a value of SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NAM_Subject_Name (
    p_owner IN SU_NAM_Subject_Name_Posit.SU_NAM_SU_ID%TYPE,
    p_value IN SU_NAM_Subject_Name_Posit.SU_NAM_Subject_Name%TYPE,
    p_positor IN SU_NAM_Subject_Name_Annex.SU_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_NAM_Subject_Name_Annex.SU_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_NAM_Subject_Name_Annex.SU_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_NAM_Subject_Name_Annex.Metadata_SU_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit SU_NAM_Subject_Name_Posit.SU_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_NAM_Subject_Name_Posit.SU_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_NAM_Subject_Name_Annex (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
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
                    SU_NAM_Subject_Name_Annex x
                WHERE
                    x.SU_NAM_ID = p_id
                AND
                    x.SU_NAM_Positor = v_positor
                AND
                    x.SU_NAM_PositedAt = v_positing
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
            p.SU_NAM_ID
        FROM
            SU_NAM_Subject_Name_Posit p
        WHERE
            p.SU_NAM_SU_ID = p_owner
        AND
            eq_SU_NAM_Subject_Name(p.SU_NAM_Subject_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_NAM_Subject_Name_Annex a
        WHERE
            a.SU_NAM_ID = v_posit
        AND
            a.SU_NAM_Positor = v_positor
        AND
            a.SU_NAM_PositedAt = v_positing
        AND
            a.SU_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NAM_Subject_Name for: ' || p_owner || ', ' ||
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
            SU_NAM_Subject_Name_Posit p
        JOIN
            SU_NAM_Subject_Name_Annex a
        ON
            a.SU_NAM_ID = p.SU_NAM_ID
        WHERE
            p.SU_NAM_SU_ID = p_owner
        AND
            eq_SU_NAM_Subject_Name(p.SU_NAM_Subject_Name, p_value) = 0
        AND
            a.SU_NAM_Positor = v_positor
        AND
            a.SU_NAM_PositedAt = v_positing
        AND
            a.SU_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NAM_Subject_Name for: ' || p_owner || ', ' ||
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
            SU_NAM_Subject_Name_Annex a
        WHERE
            a.SU_NAM_ID = v_posit
        AND
            a.SU_NAM_Positor = v_positor
        AND
            a.SU_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_NAM_Subject_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_NAM_Subject_Name_Annex (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
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
            p.SU_NAM_ID
        FROM
            SU_NAM_Subject_Name_Posit p
        WHERE
            p.SU_NAM_SU_ID = p_owner
        AND
            eq_SU_NAM_Subject_Name(p.SU_NAM_Subject_Name, p_value) = 0
        AND
            COALESCE(he_SU_NAM_Subject_Name(p.SU_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_NAM_Subject_Name_Posit (
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO SU_NAM_Subject_Name_Annex (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_Positor,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_NAM_Subject_Name;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_COD_Subject_Code tells whether two values of SU_COD_Subject_Code are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_COD_Subject_Code (
    p_left IN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code%TYPE,
    p_right IN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_COD_Subject_Code;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_COD_Subject_Code is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_COD_Subject_Code (
    p_id IN SU_COD_Subject_Code_Annex.SU_COD_ID%TYPE,
    p_positor IN SU_COD_Subject_Code_Annex.SU_COD_Positor%TYPE,
    p_positing IN SU_COD_Subject_Code_Annex.SU_COD_PositedAt%TYPE
) RETURN SU_COD_Subject_Code_Annex.SU_COD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_COD_Reliability
        FROM
            SU_COD_Subject_Code_Annex a
        WHERE
            a.SU_COD_ID = p_id
        AND
            a.SU_COD_Positor = p_positor
        AND
            a.SU_COD_PositedAt <= p_positing
        ORDER BY
            a.SU_COD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_COD_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_COD_Subject_Code;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_COD_Subject_Code states a value of SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_COD_Subject_Code (
    p_owner IN SU_COD_Subject_Code_Posit.SU_COD_SU_ID%TYPE,
    p_value IN SU_COD_Subject_Code_Posit.SU_COD_Subject_Code%TYPE,
    p_positor IN SU_COD_Subject_Code_Annex.SU_COD_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_COD_Subject_Code_Annex.SU_COD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_COD_Subject_Code_Annex.SU_COD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_COD_Subject_Code_Annex.Metadata_SU_COD%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit SU_COD_Subject_Code_Posit.SU_COD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_COD_Subject_Code_Posit.SU_COD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_COD_Subject_Code_Annex (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability
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
                    SU_COD_Subject_Code_Annex x
                WHERE
                    x.SU_COD_ID = p_id
                AND
                    x.SU_COD_Positor = v_positor
                AND
                    x.SU_COD_PositedAt = v_positing
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
            p.SU_COD_ID
        FROM
            SU_COD_Subject_Code_Posit p
        WHERE
            p.SU_COD_SU_ID = p_owner
        AND
            eq_SU_COD_Subject_Code(p.SU_COD_Subject_Code, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_COD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_COD_Subject_Code_Annex a
        WHERE
            a.SU_COD_ID = v_posit
        AND
            a.SU_COD_Positor = v_positor
        AND
            a.SU_COD_PositedAt = v_positing
        AND
            a.SU_COD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_COD_Subject_Code for: ' || p_owner || ', ' ||
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
            SU_COD_Subject_Code_Posit p
        JOIN
            SU_COD_Subject_Code_Annex a
        ON
            a.SU_COD_ID = p.SU_COD_ID
        WHERE
            p.SU_COD_SU_ID = p_owner
        AND
            eq_SU_COD_Subject_Code(p.SU_COD_Subject_Code, p_value) = 0
        AND
            a.SU_COD_Positor = v_positor
        AND
            a.SU_COD_PositedAt = v_positing
        AND
            a.SU_COD_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_COD_Subject_Code for: ' || p_owner || ', ' ||
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
            SU_COD_Subject_Code_Annex a
        WHERE
            a.SU_COD_ID = v_posit
        AND
            a.SU_COD_Positor = v_positor
        AND
            a.SU_COD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_COD_Subject_Code(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_COD_Subject_Code_Annex (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability
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
            p.SU_COD_ID
        FROM
            SU_COD_Subject_Code_Posit p
        WHERE
            p.SU_COD_SU_ID = p_owner
        AND
            eq_SU_COD_Subject_Code(p.SU_COD_Subject_Code, p_value) = 0
        AND
            COALESCE(he_SU_COD_Subject_Code(p.SU_COD_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_COD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_COD_Subject_Code_Posit (
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_COD_ID INTO v_posit;
    END IF;
    INSERT INTO SU_COD_Subject_Code_Annex (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_Positor,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_COD_Subject_Code;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_GRD_Subject_Grade tells whether two values of SU_GRD_Subject_Grade are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_GRD_Subject_Grade (
    p_left IN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID%TYPE,
    p_right IN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_GRD_Subject_Grade;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_GRD_Subject_Grade is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_GRD_Subject_Grade (
    p_id IN SU_GRD_Subject_Grade_Annex.SU_GRD_ID%TYPE,
    p_positor IN SU_GRD_Subject_Grade_Annex.SU_GRD_Positor%TYPE,
    p_positing IN SU_GRD_Subject_Grade_Annex.SU_GRD_PositedAt%TYPE
) RETURN SU_GRD_Subject_Grade_Annex.SU_GRD_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_GRD_Reliability
        FROM
            SU_GRD_Subject_Grade_Annex a
        WHERE
            a.SU_GRD_ID = p_id
        AND
            a.SU_GRD_Positor = p_positor
        AND
            a.SU_GRD_PositedAt <= p_positing
        ORDER BY
            a.SU_GRD_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_GRD_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_GRD_Subject_Grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_GRD_Subject_Grade states a value of SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_GRD_Subject_Grade (
    p_owner IN SU_GRD_Subject_Grade_Posit.SU_GRD_SU_ID%TYPE,
    p_value IN SU_GRD_Subject_Grade_Posit.SU_GRD_GRD_ID%TYPE,
    p_positor IN SU_GRD_Subject_Grade_Annex.SU_GRD_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_GRD_Subject_Grade_Annex.SU_GRD_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_GRD_Subject_Grade_Annex.SU_GRD_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_GRD_Subject_Grade_Annex.Metadata_SU_GRD%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit SU_GRD_Subject_Grade_Posit.SU_GRD_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_GRD_Subject_Grade_Posit.SU_GRD_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_GRD_Subject_Grade_Annex (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
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
                    SU_GRD_Subject_Grade_Annex x
                WHERE
                    x.SU_GRD_ID = p_id
                AND
                    x.SU_GRD_Positor = v_positor
                AND
                    x.SU_GRD_PositedAt = v_positing
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
            p.SU_GRD_ID
        FROM
            SU_GRD_Subject_Grade_Posit p
        WHERE
            p.SU_GRD_SU_ID = p_owner
        AND
            eq_SU_GRD_Subject_Grade(p.SU_GRD_GRD_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_GRD_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_GRD_Subject_Grade_Annex a
        WHERE
            a.SU_GRD_ID = v_posit
        AND
            a.SU_GRD_Positor = v_positor
        AND
            a.SU_GRD_PositedAt = v_positing
        AND
            a.SU_GRD_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_GRD_Subject_Grade for: ' || p_owner || ', ' ||
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
            SU_GRD_Subject_Grade_Posit p
        JOIN
            SU_GRD_Subject_Grade_Annex a
        ON
            a.SU_GRD_ID = p.SU_GRD_ID
        WHERE
            p.SU_GRD_SU_ID = p_owner
        AND
            eq_SU_GRD_Subject_Grade(p.SU_GRD_GRD_ID, p_value) = 0
        AND
            a.SU_GRD_Positor = v_positor
        AND
            a.SU_GRD_PositedAt = v_positing
        AND
            a.SU_GRD_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_GRD_Subject_Grade for: ' || p_owner || ', ' ||
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
            SU_GRD_Subject_Grade_Annex a
        WHERE
            a.SU_GRD_ID = v_posit
        AND
            a.SU_GRD_Positor = v_positor
        AND
            a.SU_GRD_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_GRD_Subject_Grade(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_GRD_Subject_Grade_Annex (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
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
            p.SU_GRD_ID
        FROM
            SU_GRD_Subject_Grade_Posit p
        WHERE
            p.SU_GRD_SU_ID = p_owner
        AND
            eq_SU_GRD_Subject_Grade(p.SU_GRD_GRD_ID, p_value) = 0
        AND
            COALESCE(he_SU_GRD_Subject_Grade(p.SU_GRD_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_GRD_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_GRD_Subject_Grade_Posit (
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_GRD_ID INTO v_posit;
    END IF;
    INSERT INTO SU_GRD_Subject_Grade_Annex (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_Positor,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_GRD_Subject_Grade;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NOT_Subject_Note tells whether two values of SU_NOT_Subject_Note are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_NOT_Subject_Note (
    p_left IN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note%TYPE,
    p_right IN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note%TYPE
) RETURN NUMBER
IS
BEGIN
    IF p_left IS NULL OR p_right IS NULL THEN
        RETURN 0;
    END IF;
    RETURN CASE WHEN DBMS_LOB.COMPARE(p_left, p_right) = 0 THEN 1 ELSE 0 END;
END eq_SU_NOT_Subject_Note;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_NOT_Subject_Note is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_NOT_Subject_Note (
    p_id IN SU_NOT_Subject_Note_Annex.SU_NOT_ID%TYPE,
    p_positor IN SU_NOT_Subject_Note_Annex.SU_NOT_Positor%TYPE,
    p_positing IN SU_NOT_Subject_Note_Annex.SU_NOT_PositedAt%TYPE
) RETURN SU_NOT_Subject_Note_Annex.SU_NOT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_NOT_Reliability
        FROM
            SU_NOT_Subject_Note_Annex a
        WHERE
            a.SU_NOT_ID = p_id
        AND
            a.SU_NOT_Positor = p_positor
        AND
            a.SU_NOT_PositedAt <= p_positing
        ORDER BY
            a.SU_NOT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_NOT_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_NOT_Subject_Note;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NOT_Subject_Note states a value of SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NOT_Subject_Note (
    p_owner IN SU_NOT_Subject_Note_Posit.SU_NOT_SU_ID%TYPE,
    p_value IN SU_NOT_Subject_Note_Posit.SU_NOT_Subject_Note%TYPE,
    p_positor IN SU_NOT_Subject_Note_Annex.SU_NOT_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_NOT_Subject_Note_Annex.SU_NOT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_NOT_Subject_Note_Annex.SU_NOT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_NOT_Subject_Note_Annex.Metadata_SU_NOT%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit SU_NOT_Subject_Note_Posit.SU_NOT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_NOT_Subject_Note_Posit.SU_NOT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_NOT_Subject_Note_Annex (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
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
                    SU_NOT_Subject_Note_Annex x
                WHERE
                    x.SU_NOT_ID = p_id
                AND
                    x.SU_NOT_Positor = v_positor
                AND
                    x.SU_NOT_PositedAt = v_positing
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
            p.SU_NOT_ID
        FROM
            SU_NOT_Subject_Note_Posit p
        WHERE
            p.SU_NOT_SU_ID = p_owner
        AND
            eq_SU_NOT_Subject_Note(p.SU_NOT_Subject_Note, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_NOT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_NOT_Subject_Note_Annex a
        WHERE
            a.SU_NOT_ID = v_posit
        AND
            a.SU_NOT_Positor = v_positor
        AND
            a.SU_NOT_PositedAt = v_positing
        AND
            a.SU_NOT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NOT_Subject_Note for: ' || p_owner || ', ' ||
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
            SU_NOT_Subject_Note_Posit p
        JOIN
            SU_NOT_Subject_Note_Annex a
        ON
            a.SU_NOT_ID = p.SU_NOT_ID
        WHERE
            p.SU_NOT_SU_ID = p_owner
        AND
            eq_SU_NOT_Subject_Note(p.SU_NOT_Subject_Note, p_value) = 0
        AND
            a.SU_NOT_Positor = v_positor
        AND
            a.SU_NOT_PositedAt = v_positing
        AND
            a.SU_NOT_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NOT_Subject_Note for: ' || p_owner || ', ' ||
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
            SU_NOT_Subject_Note_Annex a
        WHERE
            a.SU_NOT_ID = v_posit
        AND
            a.SU_NOT_Positor = v_positor
        AND
            a.SU_NOT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_NOT_Subject_Note(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_NOT_Subject_Note_Annex (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
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
            p.SU_NOT_ID
        FROM
            SU_NOT_Subject_Note_Posit p
        WHERE
            p.SU_NOT_SU_ID = p_owner
        AND
            eq_SU_NOT_Subject_Note(p.SU_NOT_Subject_Note, p_value) = 0
        AND
            COALESCE(he_SU_NOT_Subject_Note(p.SU_NOT_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_NOT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_NOT_Subject_Note_Posit (
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING SU_NOT_ID INTO v_posit;
    END IF;
    INSERT INTO SU_NOT_Subject_Note_Annex (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_Positor,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_NOT_Subject_Note;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TTL_Subject_Title tells whether two values of SU_TTL_Subject_Title are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_TTL_Subject_Title (
    p_left IN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title%TYPE,
    p_right IN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_TTL_Subject_Title;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_TTL_Subject_Title is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_TTL_Subject_Title (
    p_id IN SU_TTL_Subject_Title_Annex.SU_TTL_ID%TYPE,
    p_positor IN SU_TTL_Subject_Title_Annex.SU_TTL_Positor%TYPE,
    p_positing IN SU_TTL_Subject_Title_Annex.SU_TTL_PositedAt%TYPE
) RETURN SU_TTL_Subject_Title_Annex.SU_TTL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_TTL_Reliability
        FROM
            SU_TTL_Subject_Title_Annex a
        WHERE
            a.SU_TTL_ID = p_id
        AND
            a.SU_TTL_Positor = p_positor
        AND
            a.SU_TTL_PositedAt <= p_positing
        ORDER BY
            a.SU_TTL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_TTL_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_TTL_Subject_Title;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TTL_Subject_Title states a value of SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TTL_Subject_Title (
    p_owner IN SU_TTL_Subject_Title_Posit.SU_TTL_SU_ID%TYPE,
    p_value IN SU_TTL_Subject_Title_Posit.SU_TTL_Subject_Title%TYPE,
    p_changing IN SU_TTL_Subject_Title_Posit.SU_TTL_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_TTL_Subject_Title_Annex.SU_TTL_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_TTL_Subject_Title_Annex.SU_TTL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_TTL_Subject_Title_Annex.SU_TTL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_TTL_Subject_Title_Annex.Metadata_SU_TTL%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_TTL_Subject_Title_Posit.SU_TTL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_TTL_Subject_Title_Posit.SU_TTL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_TTL_Subject_Title_Annex (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
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
                    SU_TTL_Subject_Title_Annex x
                WHERE
                    x.SU_TTL_ID = p_id
                AND
                    x.SU_TTL_Positor = v_positor
                AND
                    x.SU_TTL_PositedAt = v_positing
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
            p.SU_TTL_ID
        FROM
            SU_TTL_Subject_Title_Posit p
        WHERE
            p.SU_TTL_SU_ID = p_owner
        AND
            p.SU_TTL_ChangedAt = v_changing
        AND
            eq_SU_TTL_Subject_Title(p.SU_TTL_Subject_Title, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_TTL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_TTL_Subject_Title_Annex a
        WHERE
            a.SU_TTL_ID = v_posit
        AND
            a.SU_TTL_Positor = v_positor
        AND
            a.SU_TTL_PositedAt = v_positing
        AND
            a.SU_TTL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TTL_Subject_Title for: ' || p_owner || ', ' ||
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
            SU_TTL_Subject_Title_Posit p
        JOIN
            SU_TTL_Subject_Title_Annex a
        ON
            a.SU_TTL_ID = p.SU_TTL_ID
        WHERE
            p.SU_TTL_SU_ID = p_owner
        AND
            p.SU_TTL_ChangedAt = v_changing
        AND
            eq_SU_TTL_Subject_Title(p.SU_TTL_Subject_Title, p_value) = 0
        AND
            a.SU_TTL_Positor = v_positor
        AND
            a.SU_TTL_PositedAt = v_positing
        AND
            a.SU_TTL_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TTL_Subject_Title for: ' || p_owner || ', ' ||
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
            SU_TTL_Subject_Title_Annex a
        WHERE
            a.SU_TTL_ID = v_posit
        AND
            a.SU_TTL_Positor = v_positor
        AND
            a.SU_TTL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_TTL_Subject_Title(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_TTL_Subject_Title_Annex (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
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
            p.SU_TTL_ID
        FROM
            SU_TTL_Subject_Title_Posit p
        WHERE
            p.SU_TTL_SU_ID = p_owner
        AND
            p.SU_TTL_ChangedAt = v_changing
        AND
            eq_SU_TTL_Subject_Title(p.SU_TTL_Subject_Title, p_value) = 0
        AND
            COALESCE(he_SU_TTL_Subject_Title(p.SU_TTL_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_TTL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_TTL_Subject_Title_Posit (
            SU_TTL_SU_ID,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_TTL_ID INTO v_posit;
    END IF;
    INSERT INTO SU_TTL_Subject_Title_Annex (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_Positor,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_TTL_Subject_Title;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_STA_Subject_State tells whether two values of SU_STA_Subject_State are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_STA_Subject_State (
    p_left IN SU_STA_Subject_State_Posit.SU_STA_Subject_State%TYPE,
    p_right IN SU_STA_Subject_State_Posit.SU_STA_Subject_State%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_STA_Subject_State;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_STA_Subject_State is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_STA_Subject_State (
    p_id IN SU_STA_Subject_State_Annex.SU_STA_ID%TYPE,
    p_positor IN SU_STA_Subject_State_Annex.SU_STA_Positor%TYPE,
    p_positing IN SU_STA_Subject_State_Annex.SU_STA_PositedAt%TYPE
) RETURN SU_STA_Subject_State_Annex.SU_STA_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_STA_Reliability
        FROM
            SU_STA_Subject_State_Annex a
        WHERE
            a.SU_STA_ID = p_id
        AND
            a.SU_STA_Positor = p_positor
        AND
            a.SU_STA_PositedAt <= p_positing
        ORDER BY
            a.SU_STA_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_STA_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_STA_Subject_State;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_STA_Subject_State states a value of SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_STA_Subject_State (
    p_owner IN SU_STA_Subject_State_Posit.SU_STA_SU_ID%TYPE,
    p_value IN SU_STA_Subject_State_Posit.SU_STA_Subject_State%TYPE,
    p_changing IN SU_STA_Subject_State_Posit.SU_STA_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_STA_Subject_State_Annex.SU_STA_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_STA_Subject_State_Annex.SU_STA_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_STA_Subject_State_Annex.SU_STA_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_STA_Subject_State_Annex.Metadata_SU_STA%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_STA_Subject_State_Posit.SU_STA_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_STA_Subject_State_Posit.SU_STA_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_STA_Subject_State_Annex (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability
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
                    SU_STA_Subject_State_Annex x
                WHERE
                    x.SU_STA_ID = p_id
                AND
                    x.SU_STA_Positor = v_positor
                AND
                    x.SU_STA_PositedAt = v_positing
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
            p.SU_STA_ID
        FROM
            SU_STA_Subject_State_Posit p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt = v_changing
        AND
            eq_SU_STA_Subject_State(p.SU_STA_Subject_State, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_STA_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_STA_Subject_State_Annex a
        WHERE
            a.SU_STA_ID = v_posit
        AND
            a.SU_STA_Positor = v_positor
        AND
            a.SU_STA_PositedAt = v_positing
        AND
            a.SU_STA_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_STA_Subject_State for: ' || p_owner || ', ' ||
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
            SU_STA_Subject_State_Posit p
        JOIN
            SU_STA_Subject_State_Annex a
        ON
            a.SU_STA_ID = p.SU_STA_ID
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt = v_changing
        AND
            eq_SU_STA_Subject_State(p.SU_STA_Subject_State, p_value) = 0
        AND
            a.SU_STA_Positor = v_positor
        AND
            a.SU_STA_PositedAt = v_positing
        AND
            a.SU_STA_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_STA_Subject_State for: ' || p_owner || ', ' ||
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
            SU_STA_Subject_State_Annex a
        WHERE
            a.SU_STA_ID = v_posit
        AND
            a.SU_STA_Positor = v_positor
        AND
            a.SU_STA_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_STA_Subject_State(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_STA_Subject_State_Annex (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability
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
            p.SU_STA_ID
        FROM
            SU_STA_Subject_State_Posit p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt = v_changing
        AND
            eq_SU_STA_Subject_State(p.SU_STA_Subject_State, p_value) = 0
        AND
            COALESCE(he_SU_STA_Subject_State(p.SU_STA_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_STA_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State_Posit p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt < v_changing
        AND
            COALESCE(he_SU_STA_Subject_State(p.SU_STA_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_SU_STA_Subject_State(p.SU_STA_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.SU_STA_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_STA_Subject_State(r.SU_STA_Subject_State, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.SU_STA_ID,
            f.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State_Posit f
        WHERE
            f.SU_STA_SU_ID = p_owner
        AND
            f.SU_STA_ChangedAt > v_changing
        AND
            COALESCE(he_SU_STA_Subject_State(f.SU_STA_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_SU_STA_Subject_State(f.SU_STA_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.SU_STA_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_STA_Subject_State(r.SU_STA_Subject_State, p_value) = 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || v_changing || ', ' || v_positor || ', ' || v_positing);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_STA_Subject_State_Posit (
            SU_STA_SU_ID,
            SU_STA_ChangedAt,
            SU_STA_Subject_State
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_STA_ID INTO v_posit;
    END IF;
    INSERT INTO SU_STA_Subject_State_Annex (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_Positor,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_STA_Subject_State;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LBL_Subject_Label tells whether two values of SU_LBL_Subject_Label are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_LBL_Subject_Label (
    p_left IN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label%TYPE,
    p_right IN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_LBL_Subject_Label;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_LBL_Subject_Label is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_LBL_Subject_Label (
    p_id IN SU_LBL_Subject_Label_Annex.SU_LBL_ID%TYPE,
    p_positor IN SU_LBL_Subject_Label_Annex.SU_LBL_Positor%TYPE,
    p_positing IN SU_LBL_Subject_Label_Annex.SU_LBL_PositedAt%TYPE
) RETURN SU_LBL_Subject_Label_Annex.SU_LBL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_LBL_Reliability
        FROM
            SU_LBL_Subject_Label_Annex a
        WHERE
            a.SU_LBL_ID = p_id
        AND
            a.SU_LBL_Positor = p_positor
        AND
            a.SU_LBL_PositedAt <= p_positing
        ORDER BY
            a.SU_LBL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_LBL_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_LBL_Subject_Label;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LBL_Subject_Label states a value of SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LBL_Subject_Label (
    p_owner IN SU_LBL_Subject_Label_Posit.SU_LBL_SU_ID%TYPE,
    p_value IN SU_LBL_Subject_Label_Posit.SU_LBL_Subject_Label%TYPE,
    p_changing IN SU_LBL_Subject_Label_Posit.SU_LBL_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_LBL_Subject_Label_Annex.SU_LBL_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_LBL_Subject_Label_Annex.SU_LBL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_LBL_Subject_Label_Annex.SU_LBL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_LBL_Subject_Label_Annex.Metadata_SU_LBL%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_LBL_Subject_Label_Posit.SU_LBL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_LBL_Subject_Label_Posit.SU_LBL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_LBL_Subject_Label_Annex (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
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
                    SU_LBL_Subject_Label_Annex x
                WHERE
                    x.SU_LBL_ID = p_id
                AND
                    x.SU_LBL_Positor = v_positor
                AND
                    x.SU_LBL_PositedAt = v_positing
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
            p.SU_LBL_ID
        FROM
            SU_LBL_Subject_Label_Posit p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt = v_changing
        AND
            eq_SU_LBL_Subject_Label(p.SU_LBL_Subject_Label, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_LBL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_LBL_Subject_Label_Annex a
        WHERE
            a.SU_LBL_ID = v_posit
        AND
            a.SU_LBL_Positor = v_positor
        AND
            a.SU_LBL_PositedAt = v_positing
        AND
            a.SU_LBL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LBL_Subject_Label for: ' || p_owner || ', ' ||
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
            SU_LBL_Subject_Label_Posit p
        JOIN
            SU_LBL_Subject_Label_Annex a
        ON
            a.SU_LBL_ID = p.SU_LBL_ID
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt = v_changing
        AND
            eq_SU_LBL_Subject_Label(p.SU_LBL_Subject_Label, p_value) = 0
        AND
            a.SU_LBL_Positor = v_positor
        AND
            a.SU_LBL_PositedAt = v_positing
        AND
            a.SU_LBL_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LBL_Subject_Label for: ' || p_owner || ', ' ||
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
            SU_LBL_Subject_Label_Annex a
        WHERE
            a.SU_LBL_ID = v_posit
        AND
            a.SU_LBL_Positor = v_positor
        AND
            a.SU_LBL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_LBL_Subject_Label(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_LBL_Subject_Label_Annex (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
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
            p.SU_LBL_ID
        FROM
            SU_LBL_Subject_Label_Posit p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt = v_changing
        AND
            eq_SU_LBL_Subject_Label(p.SU_LBL_Subject_Label, p_value) = 0
        AND
            COALESCE(he_SU_LBL_Subject_Label(p.SU_LBL_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_LBL_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label_Posit p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt < v_changing
        AND
            COALESCE(he_SU_LBL_Subject_Label(p.SU_LBL_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_SU_LBL_Subject_Label(p.SU_LBL_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.SU_LBL_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_LBL_Subject_Label(r.SU_LBL_Subject_Label, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.SU_LBL_ID,
            f.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label_Posit f
        WHERE
            f.SU_LBL_SU_ID = p_owner
        AND
            f.SU_LBL_ChangedAt > v_changing
        AND
            COALESCE(he_SU_LBL_Subject_Label(f.SU_LBL_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_SU_LBL_Subject_Label(f.SU_LBL_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.SU_LBL_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_LBL_Subject_Label(r.SU_LBL_Subject_Label, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.SU_LBL_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_LBL_Subject_Label_Posit (
            SU_LBL_SU_ID,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_LBL_ID INTO v_posit;
    END IF;
    INSERT INTO SU_LBL_Subject_Label_Annex (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_Positor,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_LBL_Subject_Label;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TAG_Subject_Tag tells whether two values of SU_TAG_Subject_Tag are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_TAG_Subject_Tag (
    p_left IN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag%TYPE,
    p_right IN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_TAG_Subject_Tag;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_TAG_Subject_Tag is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_TAG_Subject_Tag (
    p_id IN SU_TAG_Subject_Tag_Annex.SU_TAG_ID%TYPE,
    p_positor IN SU_TAG_Subject_Tag_Annex.SU_TAG_Positor%TYPE,
    p_positing IN SU_TAG_Subject_Tag_Annex.SU_TAG_PositedAt%TYPE
) RETURN SU_TAG_Subject_Tag_Annex.SU_TAG_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_TAG_Reliability
        FROM
            SU_TAG_Subject_Tag_Annex a
        WHERE
            a.SU_TAG_ID = p_id
        AND
            a.SU_TAG_Positor = p_positor
        AND
            a.SU_TAG_PositedAt <= p_positing
        ORDER BY
            a.SU_TAG_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_TAG_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_TAG_Subject_Tag;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TAG_Subject_Tag states a value of SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TAG_Subject_Tag (
    p_owner IN SU_TAG_Subject_Tag_Posit.SU_TAG_SU_ID%TYPE,
    p_value IN SU_TAG_Subject_Tag_Posit.SU_TAG_Subject_Tag%TYPE,
    p_changing IN SU_TAG_Subject_Tag_Posit.SU_TAG_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_TAG_Subject_Tag_Annex.SU_TAG_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_TAG_Subject_Tag_Annex.SU_TAG_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_TAG_Subject_Tag_Annex.SU_TAG_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_TAG_Subject_Tag_Annex.Metadata_SU_TAG%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_TAG_Subject_Tag_Posit.SU_TAG_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_TAG_Subject_Tag_Posit.SU_TAG_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_TAG_Subject_Tag_Annex (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
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
                    SU_TAG_Subject_Tag_Annex x
                WHERE
                    x.SU_TAG_ID = p_id
                AND
                    x.SU_TAG_Positor = v_positor
                AND
                    x.SU_TAG_PositedAt = v_positing
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
            p.SU_TAG_ID
        FROM
            SU_TAG_Subject_Tag_Posit p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt = v_changing
        AND
            eq_SU_TAG_Subject_Tag(p.SU_TAG_Subject_Tag, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_TAG_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_TAG_Subject_Tag_Annex a
        WHERE
            a.SU_TAG_ID = v_posit
        AND
            a.SU_TAG_Positor = v_positor
        AND
            a.SU_TAG_PositedAt = v_positing
        AND
            a.SU_TAG_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TAG_Subject_Tag for: ' || p_owner || ', ' ||
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
            SU_TAG_Subject_Tag_Posit p
        JOIN
            SU_TAG_Subject_Tag_Annex a
        ON
            a.SU_TAG_ID = p.SU_TAG_ID
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt = v_changing
        AND
            eq_SU_TAG_Subject_Tag(p.SU_TAG_Subject_Tag, p_value) = 0
        AND
            a.SU_TAG_Positor = v_positor
        AND
            a.SU_TAG_PositedAt = v_positing
        AND
            a.SU_TAG_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TAG_Subject_Tag for: ' || p_owner || ', ' ||
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
            SU_TAG_Subject_Tag_Annex a
        WHERE
            a.SU_TAG_ID = v_posit
        AND
            a.SU_TAG_Positor = v_positor
        AND
            a.SU_TAG_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_TAG_Subject_Tag(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_TAG_Subject_Tag_Annex (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
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
            p.SU_TAG_ID
        FROM
            SU_TAG_Subject_Tag_Posit p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt = v_changing
        AND
            eq_SU_TAG_Subject_Tag(p.SU_TAG_Subject_Tag, p_value) = 0
        AND
            COALESCE(he_SU_TAG_Subject_Tag(p.SU_TAG_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_TAG_ID);
    END LOOP;
    -- the same value as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    FOR r IN (
        SELECT
            p.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag_Posit p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt < v_changing
        AND
            COALESCE(he_SU_TAG_Subject_Tag(p.SU_TAG_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_SU_TAG_Subject_Tag(p.SU_TAG_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            p.SU_TAG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_TAG_Subject_Tag(r.SU_TAG_Subject_Tag, p_value) = 1 THEN
            -- (an idempotent attribute does not store it)
            RETURN;
        END IF;
    END LOOP;
    -- the same value as the version after it makes that version a restatement
    FOR r IN (
        SELECT
            f.SU_TAG_ID,
            f.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag_Posit f
        WHERE
            f.SU_TAG_SU_ID = p_owner
        AND
            f.SU_TAG_ChangedAt > v_changing
        AND
            COALESCE(he_SU_TAG_Subject_Tag(f.SU_TAG_ID, v_positor, v_positing), 0) <> 0
        AND
            CASE WHEN he_SU_TAG_Subject_Tag(f.SU_TAG_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_positive
        ORDER BY
            f.SU_TAG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF eq_SU_TAG_Subject_Tag(r.SU_TAG_Subject_Tag, p_value) = 1 THEN
            -- (an idempotent attribute retracts it)
            retract(r.SU_TAG_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_TAG_Subject_Tag_Posit (
            SU_TAG_SU_ID,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_TAG_ID INTO v_posit;
    END IF;
    INSERT INTO SU_TAG_Subject_Tag_Annex (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_Positor,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_TAG_Subject_Tag;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LVL_Subject_Level tells whether two values of SU_LVL_Subject_Level are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_LVL_Subject_Level (
    p_left IN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID%TYPE,
    p_right IN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_LVL_Subject_Level;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_LVL_Subject_Level is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_LVL_Subject_Level (
    p_id IN SU_LVL_Subject_Level_Annex.SU_LVL_ID%TYPE,
    p_positor IN SU_LVL_Subject_Level_Annex.SU_LVL_Positor%TYPE,
    p_positing IN SU_LVL_Subject_Level_Annex.SU_LVL_PositedAt%TYPE
) RETURN SU_LVL_Subject_Level_Annex.SU_LVL_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_LVL_Reliability
        FROM
            SU_LVL_Subject_Level_Annex a
        WHERE
            a.SU_LVL_ID = p_id
        AND
            a.SU_LVL_Positor = p_positor
        AND
            a.SU_LVL_PositedAt <= p_positing
        ORDER BY
            a.SU_LVL_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_LVL_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_LVL_Subject_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LVL_Subject_Level states a value of SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LVL_Subject_Level (
    p_owner IN SU_LVL_Subject_Level_Posit.SU_LVL_SU_ID%TYPE,
    p_value IN SU_LVL_Subject_Level_Posit.SU_LVL_GRD_ID%TYPE,
    p_changing IN SU_LVL_Subject_Level_Posit.SU_LVL_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_LVL_Subject_Level_Annex.SU_LVL_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_LVL_Subject_Level_Annex.SU_LVL_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_LVL_Subject_Level_Annex.SU_LVL_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_LVL_Subject_Level_Annex.Metadata_SU_LVL%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_LVL_Subject_Level_Posit.SU_LVL_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_LVL_Subject_Level_Posit.SU_LVL_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_LVL_Subject_Level_Annex (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
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
                    SU_LVL_Subject_Level_Annex x
                WHERE
                    x.SU_LVL_ID = p_id
                AND
                    x.SU_LVL_Positor = v_positor
                AND
                    x.SU_LVL_PositedAt = v_positing
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
            p.SU_LVL_ID
        FROM
            SU_LVL_Subject_Level_Posit p
        WHERE
            p.SU_LVL_SU_ID = p_owner
        AND
            p.SU_LVL_ChangedAt = v_changing
        AND
            eq_SU_LVL_Subject_Level(p.SU_LVL_GRD_ID, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_LVL_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_LVL_Subject_Level_Annex a
        WHERE
            a.SU_LVL_ID = v_posit
        AND
            a.SU_LVL_Positor = v_positor
        AND
            a.SU_LVL_PositedAt = v_positing
        AND
            a.SU_LVL_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LVL_Subject_Level for: ' || p_owner || ', ' ||
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
            SU_LVL_Subject_Level_Posit p
        JOIN
            SU_LVL_Subject_Level_Annex a
        ON
            a.SU_LVL_ID = p.SU_LVL_ID
        WHERE
            p.SU_LVL_SU_ID = p_owner
        AND
            p.SU_LVL_ChangedAt = v_changing
        AND
            eq_SU_LVL_Subject_Level(p.SU_LVL_GRD_ID, p_value) = 0
        AND
            a.SU_LVL_Positor = v_positor
        AND
            a.SU_LVL_PositedAt = v_positing
        AND
            a.SU_LVL_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LVL_Subject_Level for: ' || p_owner || ', ' ||
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
            SU_LVL_Subject_Level_Annex a
        WHERE
            a.SU_LVL_ID = v_posit
        AND
            a.SU_LVL_Positor = v_positor
        AND
            a.SU_LVL_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_LVL_Subject_Level(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_LVL_Subject_Level_Annex (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
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
            p.SU_LVL_ID
        FROM
            SU_LVL_Subject_Level_Posit p
        WHERE
            p.SU_LVL_SU_ID = p_owner
        AND
            p.SU_LVL_ChangedAt = v_changing
        AND
            eq_SU_LVL_Subject_Level(p.SU_LVL_GRD_ID, p_value) = 0
        AND
            COALESCE(he_SU_LVL_Subject_Level(p.SU_LVL_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_LVL_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_LVL_Subject_Level_Posit (
            SU_LVL_SU_ID,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_ID
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_LVL_ID INTO v_posit;
    END IF;
    INSERT INTO SU_LVL_Subject_Level_Annex (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_Positor,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_LVL_Subject_Level;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TXT_Subject_Text tells whether two values of SU_TXT_Subject_Text are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_TXT_Subject_Text (
    p_left IN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text%TYPE,
    p_right IN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text%TYPE
) RETURN NUMBER
IS
BEGIN
    IF p_left IS NULL OR p_right IS NULL THEN
        RETURN 0;
    END IF;
    RETURN CASE WHEN DBMS_LOB.COMPARE(p_left, p_right) = 0 THEN 1 ELSE 0 END;
END eq_SU_TXT_Subject_Text;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_TXT_Subject_Text is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_TXT_Subject_Text (
    p_id IN SU_TXT_Subject_Text_Annex.SU_TXT_ID%TYPE,
    p_positor IN SU_TXT_Subject_Text_Annex.SU_TXT_Positor%TYPE,
    p_positing IN SU_TXT_Subject_Text_Annex.SU_TXT_PositedAt%TYPE
) RETURN SU_TXT_Subject_Text_Annex.SU_TXT_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_TXT_Reliability
        FROM
            SU_TXT_Subject_Text_Annex a
        WHERE
            a.SU_TXT_ID = p_id
        AND
            a.SU_TXT_Positor = p_positor
        AND
            a.SU_TXT_PositedAt <= p_positing
        ORDER BY
            a.SU_TXT_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_TXT_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_TXT_Subject_Text;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TXT_Subject_Text states a value of SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TXT_Subject_Text (
    p_owner IN SU_TXT_Subject_Text_Posit.SU_TXT_SU_ID%TYPE,
    p_value IN SU_TXT_Subject_Text_Posit.SU_TXT_Subject_Text%TYPE,
    p_changing IN SU_TXT_Subject_Text_Posit.SU_TXT_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_TXT_Subject_Text_Annex.SU_TXT_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_TXT_Subject_Text_Annex.SU_TXT_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_TXT_Subject_Text_Annex.SU_TXT_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_TXT_Subject_Text_Annex.Metadata_SU_TXT%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_TXT_Subject_Text_Posit.SU_TXT_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_TXT_Subject_Text_Posit.SU_TXT_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_TXT_Subject_Text_Annex (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
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
                    SU_TXT_Subject_Text_Annex x
                WHERE
                    x.SU_TXT_ID = p_id
                AND
                    x.SU_TXT_Positor = v_positor
                AND
                    x.SU_TXT_PositedAt = v_positing
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
            p.SU_TXT_ID
        FROM
            SU_TXT_Subject_Text_Posit p
        WHERE
            p.SU_TXT_SU_ID = p_owner
        AND
            p.SU_TXT_ChangedAt = v_changing
        AND
            eq_SU_TXT_Subject_Text(p.SU_TXT_Subject_Text, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_TXT_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_TXT_Subject_Text_Annex a
        WHERE
            a.SU_TXT_ID = v_posit
        AND
            a.SU_TXT_Positor = v_positor
        AND
            a.SU_TXT_PositedAt = v_positing
        AND
            a.SU_TXT_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TXT_Subject_Text for: ' || p_owner || ', ' ||
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
            SU_TXT_Subject_Text_Posit p
        JOIN
            SU_TXT_Subject_Text_Annex a
        ON
            a.SU_TXT_ID = p.SU_TXT_ID
        WHERE
            p.SU_TXT_SU_ID = p_owner
        AND
            p.SU_TXT_ChangedAt = v_changing
        AND
            eq_SU_TXT_Subject_Text(p.SU_TXT_Subject_Text, p_value) = 0
        AND
            a.SU_TXT_Positor = v_positor
        AND
            a.SU_TXT_PositedAt = v_positing
        AND
            a.SU_TXT_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TXT_Subject_Text for: ' || p_owner || ', ' ||
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
            SU_TXT_Subject_Text_Annex a
        WHERE
            a.SU_TXT_ID = v_posit
        AND
            a.SU_TXT_Positor = v_positor
        AND
            a.SU_TXT_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_TXT_Subject_Text(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_TXT_Subject_Text_Annex (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
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
            p.SU_TXT_ID
        FROM
            SU_TXT_Subject_Text_Posit p
        WHERE
            p.SU_TXT_SU_ID = p_owner
        AND
            p.SU_TXT_ChangedAt = v_changing
        AND
            eq_SU_TXT_Subject_Text(p.SU_TXT_Subject_Text, p_value) = 0
        AND
            COALESCE(he_SU_TXT_Subject_Text(p.SU_TXT_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_TXT_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_TXT_Subject_Text_Posit (
            SU_TXT_SU_ID,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_TXT_ID INTO v_posit;
    END IF;
    INSERT INTO SU_TXT_Subject_Text_Annex (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_Positor,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_TXT_Subject_Text;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ASR_Subject_Assessment tells whether two values of SU_ASR_Subject_Assessment are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_ASR_Subject_Assessment (
    p_left IN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment%TYPE,
    p_right IN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_ASR_Subject_Assessment;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_ASR_Subject_Assessment is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_ASR_Subject_Assessment (
    p_id IN SU_ASR_Subject_Assessment_Annex.SU_ASR_ID%TYPE,
    p_positor IN SU_ASR_Subject_Assessment_Annex.SU_ASR_Positor%TYPE,
    p_positing IN SU_ASR_Subject_Assessment_Annex.SU_ASR_PositedAt%TYPE
) RETURN SU_ASR_Subject_Assessment_Annex.SU_ASR_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_ASR_Reliability
        FROM
            SU_ASR_Subject_Assessment_Annex a
        WHERE
            a.SU_ASR_ID = p_id
        AND
            a.SU_ASR_Positor = p_positor
        AND
            a.SU_ASR_PositedAt <= p_positing
        ORDER BY
            a.SU_ASR_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_ASR_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_ASR_Subject_Assessment;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ASR_Subject_Assessment states a value of SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ASR_Subject_Assessment (
    p_owner IN SU_ASR_Subject_Assessment_Posit.SU_ASR_SU_ID%TYPE,
    p_value IN SU_ASR_Subject_Assessment_Posit.SU_ASR_Subject_Assessment%TYPE,
    p_changing IN SU_ASR_Subject_Assessment_Posit.SU_ASR_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_ASR_Subject_Assessment_Annex.SU_ASR_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_ASR_Subject_Assessment_Annex.SU_ASR_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_ASR_Subject_Assessment_Annex.SU_ASR_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_ASR_Subject_Assessment_Annex.Metadata_SU_ASR%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_ASR_Subject_Assessment_Posit.SU_ASR_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_ASR_Subject_Assessment_Posit.SU_ASR_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_ASR_Subject_Assessment_Annex (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
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
                    SU_ASR_Subject_Assessment_Annex x
                WHERE
                    x.SU_ASR_ID = p_id
                AND
                    x.SU_ASR_Positor = v_positor
                AND
                    x.SU_ASR_PositedAt = v_positing
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
            p.SU_ASR_ID
        FROM
            SU_ASR_Subject_Assessment_Posit p
        WHERE
            p.SU_ASR_SU_ID = p_owner
        AND
            p.SU_ASR_ChangedAt = v_changing
        AND
            eq_SU_ASR_Subject_Assessment(p.SU_ASR_Subject_Assessment, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_ASR_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_ASR_Subject_Assessment_Annex a
        WHERE
            a.SU_ASR_ID = v_posit
        AND
            a.SU_ASR_Positor = v_positor
        AND
            a.SU_ASR_PositedAt = v_positing
        AND
            a.SU_ASR_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ASR_Subject_Assessment for: ' || p_owner || ', ' ||
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
            SU_ASR_Subject_Assessment_Posit p
        JOIN
            SU_ASR_Subject_Assessment_Annex a
        ON
            a.SU_ASR_ID = p.SU_ASR_ID
        WHERE
            p.SU_ASR_SU_ID = p_owner
        AND
            p.SU_ASR_ChangedAt = v_changing
        AND
            eq_SU_ASR_Subject_Assessment(p.SU_ASR_Subject_Assessment, p_value) = 0
        AND
            a.SU_ASR_Positor = v_positor
        AND
            a.SU_ASR_PositedAt = v_positing
        AND
            a.SU_ASR_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ASR_Subject_Assessment for: ' || p_owner || ', ' ||
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
            SU_ASR_Subject_Assessment_Annex a
        WHERE
            a.SU_ASR_ID = v_posit
        AND
            a.SU_ASR_Positor = v_positor
        AND
            a.SU_ASR_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_ASR_Subject_Assessment(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_ASR_Subject_Assessment_Annex (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
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
    -- the same assertion that the positor holds is not stated again unless the attribute is assertive
    IF v_held IS NOT NULL AND v_held = v_reliability THEN
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same entity (and changing time), when that has another value: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.SU_ASR_ID
        FROM
            SU_ASR_Subject_Assessment_Posit p
        WHERE
            p.SU_ASR_SU_ID = p_owner
        AND
            p.SU_ASR_ChangedAt = v_changing
        AND
            eq_SU_ASR_Subject_Assessment(p.SU_ASR_Subject_Assessment, p_value) = 0
        AND
            COALESCE(he_SU_ASR_Subject_Assessment(p.SU_ASR_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_ASR_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_ASR_Subject_Assessment_Posit (
            SU_ASR_SU_ID,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_ASR_ID INTO v_posit;
    END IF;
    INSERT INTO SU_ASR_Subject_Assessment_Annex (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_Positor,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_ASR_Subject_Assessment;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ERS_Subject_Erasable tells whether two values of SU_ERS_Subject_Erasable are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_SU_ERS_Subject_Erasable (
    p_left IN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable%TYPE,
    p_right IN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_SU_ERS_Subject_Erasable;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_ERS_Subject_Erasable is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_ERS_Subject_Erasable (
    p_id IN SU_ERS_Subject_Erasable_Annex.SU_ERS_ID%TYPE,
    p_positor IN SU_ERS_Subject_Erasable_Annex.SU_ERS_Positor%TYPE,
    p_positing IN SU_ERS_Subject_Erasable_Annex.SU_ERS_PositedAt%TYPE
) RETURN SU_ERS_Subject_Erasable_Annex.SU_ERS_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_ERS_Reliability
        FROM
            SU_ERS_Subject_Erasable_Annex a
        WHERE
            a.SU_ERS_ID = p_id
        AND
            a.SU_ERS_Positor = p_positor
        AND
            a.SU_ERS_PositedAt <= p_positing
        ORDER BY
            a.SU_ERS_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_ERS_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_ERS_Subject_Erasable;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ERS_Subject_Erasable states a value of SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ERS_Subject_Erasable (
    p_owner IN SU_ERS_Subject_Erasable_Posit.SU_ERS_SU_ID%TYPE,
    p_value IN SU_ERS_Subject_Erasable_Posit.SU_ERS_Subject_Erasable%TYPE,
    p_changing IN SU_ERS_Subject_Erasable_Posit.SU_ERS_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_ERS_Subject_Erasable_Annex.SU_ERS_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_ERS_Subject_Erasable_Annex.SU_ERS_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_ERS_Subject_Erasable_Annex.SU_ERS_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_ERS_Subject_Erasable_Annex.Metadata_SU_ERS%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_changing timestamp;
    v_posit SU_ERS_Subject_Erasable_Posit.SU_ERS_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN SU_ERS_Subject_Erasable_Posit.SU_ERS_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_ERS_Subject_Erasable_Annex (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
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
                    SU_ERS_Subject_Erasable_Annex x
                WHERE
                    x.SU_ERS_ID = p_id
                AND
                    x.SU_ERS_Positor = v_positor
                AND
                    x.SU_ERS_PositedAt = v_positing
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
            p.SU_ERS_ID
        FROM
            SU_ERS_Subject_Erasable_Posit p
        WHERE
            p.SU_ERS_SU_ID = p_owner
        AND
            p.SU_ERS_ChangedAt = v_changing
        AND
            eq_SU_ERS_Subject_Erasable(p.SU_ERS_Subject_Erasable, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_ERS_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            SU_ERS_Subject_Erasable_Annex a
        WHERE
            a.SU_ERS_ID = v_posit
        AND
            a.SU_ERS_Positor = v_positor
        AND
            a.SU_ERS_PositedAt = v_positing
        AND
            a.SU_ERS_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ERS_Subject_Erasable for: ' || p_owner || ', ' ||
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
            SU_ERS_Subject_Erasable_Posit p
        JOIN
            SU_ERS_Subject_Erasable_Annex a
        ON
            a.SU_ERS_ID = p.SU_ERS_ID
        WHERE
            p.SU_ERS_SU_ID = p_owner
        AND
            p.SU_ERS_ChangedAt = v_changing
        AND
            eq_SU_ERS_Subject_Erasable(p.SU_ERS_Subject_Erasable, p_value) = 0
        AND
            a.SU_ERS_Positor = v_positor
        AND
            a.SU_ERS_PositedAt = v_positing
        AND
            a.SU_ERS_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ERS_Subject_Erasable for: ' || p_owner || ', ' ||
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
            SU_ERS_Subject_Erasable_Annex a
        WHERE
            a.SU_ERS_ID = v_posit
        AND
            a.SU_ERS_Positor = v_positor
        AND
            a.SU_ERS_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_SU_ERS_Subject_Erasable(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_ERS_Subject_Erasable_Annex (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
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
            p.SU_ERS_ID
        FROM
            SU_ERS_Subject_Erasable_Posit p
        WHERE
            p.SU_ERS_SU_ID = p_owner
        AND
            p.SU_ERS_ChangedAt = v_changing
        AND
            eq_SU_ERS_Subject_Erasable(p.SU_ERS_Subject_Erasable, p_value) = 0
        AND
            COALESCE(he_SU_ERS_Subject_Erasable(p.SU_ERS_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.SU_ERS_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_ERS_Subject_Erasable_Posit (
            SU_ERS_SU_ID,
            SU_ERS_ChangedAt,
            SU_ERS_Subject_Erasable
        )
        VALUES (
            p_owner,
            v_changing,
            p_value
        )
        RETURNING SU_ERS_ID INTO v_posit;
    END IF;
    INSERT INTO SU_ERS_Subject_Erasable_Annex (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_Positor,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_ERS_Subject_Erasable;
/
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_OB_NAM_Object_Name tells whether two values of OB_NAM_Object_Name are the same (1 or 0, as a query cannot use a boolean)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION eq_OB_NAM_Object_Name (
    p_left IN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name%TYPE,
    p_right IN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name%TYPE
) RETURN NUMBER
IS
BEGIN
    RETURN CASE WHEN p_left = p_right THEN 1 ELSE 0 END;
END eq_OB_NAM_Object_Name;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_OB_NAM_Object_Name is the reliability that a positor holds for a posit at a positing time (null if it holds nothing):
-- that of its latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_OB_NAM_Object_Name (
    p_id IN OB_NAM_Object_Name_Annex.OB_NAM_ID%TYPE,
    p_positor IN OB_NAM_Object_Name_Annex.OB_NAM_Positor%TYPE,
    p_positing IN OB_NAM_Object_Name_Annex.OB_NAM_PositedAt%TYPE
) RETURN OB_NAM_Object_Name_Annex.OB_NAM_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.OB_NAM_Reliability
        FROM
            OB_NAM_Object_Name_Annex a
        WHERE
            a.OB_NAM_ID = p_id
        AND
            a.OB_NAM_Positor = p_positor
        AND
            a.OB_NAM_PositedAt <= p_positing
        ORDER BY
            a.OB_NAM_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.OB_NAM_Reliability;
    END LOOP;
    RETURN NULL;
END he_OB_NAM_Object_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_NAM_Object_Name states a value of OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_NAM_Object_Name (
    p_owner IN OB_NAM_Object_Name_Posit.OB_NAM_OB_ID%TYPE,
    p_value IN OB_NAM_Object_Name_Posit.OB_NAM_Object_Name%TYPE,
    p_positor IN OB_NAM_Object_Name_Annex.OB_NAM_Positor%TYPE DEFAULT NULL,
    p_positing IN OB_NAM_Object_Name_Annex.OB_NAM_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN OB_NAM_Object_Name_Annex.OB_NAM_Reliability%TYPE DEFAULT NULL,
    p_metadata IN OB_NAM_Object_Name_Annex.Metadata_OB_NAM%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_positive NUMBER(1);
    v_held number(5,2);
    v_posit OB_NAM_Object_Name_Posit.OB_NAM_ID%TYPE;
    v_count NUMBER;
    -- a retraction of a posit by the positor at the positing time, which is not stated again if it is there already
    PROCEDURE retract (
        p_id IN OB_NAM_Object_Name_Posit.OB_NAM_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO OB_NAM_Object_Name_Annex (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
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
                    OB_NAM_Object_Name_Annex x
                WHERE
                    x.OB_NAM_ID = p_id
                AND
                    x.OB_NAM_Positor = v_positor
                AND
                    x.OB_NAM_PositedAt = v_positing
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
            p.OB_NAM_ID
        FROM
            OB_NAM_Object_Name_Posit p
        WHERE
            p.OB_NAM_OB_ID = p_owner
        AND
            eq_OB_NAM_Object_Name(p.OB_NAM_Object_Name, p_value) = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.OB_NAM_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            OB_NAM_Object_Name_Annex a
        WHERE
            a.OB_NAM_ID = v_posit
        AND
            a.OB_NAM_Positor = v_positor
        AND
            a.OB_NAM_PositedAt = v_positing
        AND
            a.OB_NAM_Reliability <> v_reliability;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_NAM_Object_Name for: ' || p_owner || ', ' ||
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
            OB_NAM_Object_Name_Posit p
        JOIN
            OB_NAM_Object_Name_Annex a
        ON
            a.OB_NAM_ID = p.OB_NAM_ID
        WHERE
            p.OB_NAM_OB_ID = p_owner
        AND
            eq_OB_NAM_Object_Name(p.OB_NAM_Object_Name, p_value) = 0
        AND
            a.OB_NAM_Positor = v_positor
        AND
            a.OB_NAM_PositedAt = v_positing
        AND
            a.OB_NAM_Reliability <> 0;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_NAM_Object_Name for: ' || p_owner || ', ' ||
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
            OB_NAM_Object_Name_Annex a
        WHERE
            a.OB_NAM_ID = v_posit
        AND
            a.OB_NAM_Positor = v_positor
        AND
            a.OB_NAM_PositedAt = v_positing;
        IF v_count > 0 THEN
            RETURN;
        END IF;
    END IF;
    -- what the positor holds of the posit
    IF v_posit IS NOT NULL THEN
        v_held := he_OB_NAM_Object_Name(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO OB_NAM_Object_Name_Annex (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
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
            p.OB_NAM_ID
        FROM
            OB_NAM_Object_Name_Posit p
        WHERE
            p.OB_NAM_OB_ID = p_owner
        AND
            eq_OB_NAM_Object_Name(p.OB_NAM_Object_Name, p_value) = 0
        AND
            COALESCE(he_OB_NAM_Object_Name(p.OB_NAM_ID, v_positor, v_positing), 0) <> 0
    ) LOOP
        retract(r.OB_NAM_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO OB_NAM_Object_Name_Posit (
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        )
        VALUES (
            p_owner,
            p_value
        )
        RETURNING OB_NAM_ID INTO v_posit;
    END IF;
    INSERT INTO OB_NAM_Object_Name_Annex (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_Positor,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_OB_NAM_Object_Name;
/
