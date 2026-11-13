-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the positor is 0, the changing and
-- positing times are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is about the values of the identifiers (at a changing time):
-- a decisive positor holds one assertion at a time for them, so an assertion of other values retracts, at its own positing
-- time, the posit that the positor holds, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures, ip_<tie>, and not in triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The triggers on the views call them, and so can
-- a load, with the roles and what else is to be stated (what is left out gets its default: the positor is 0, the changing
-- and positing times are now, the reliability is 1):
--
--     BEGIN
--         ip_<tie>(
--             p_<role> => ...,                  one for each role, the identity of the entity or knot
--             p_changing => ...,                a historized tie
--             p_positor => ..., p_positing => ..., p_reliability => ...,
--             p_metadata => ...                 when the model has metadata
--         );
--     END;
--
-- A row put straight into a posit or annex table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so the rows of an insert are taken in the order they have. Whether a
-- column is set in an UPDATE is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_holder_OB_item_GRD_grade is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_holder_OB_item_GRD_grade (
    p_id IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_ID%TYPE,
    p_positor IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Positor%TYPE,
    p_positing IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE
) RETURN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_holder_OB_item_GRD_grade_Reliability
        FROM
            SU_holder_OB_item_GRD_grade_Annex a
        WHERE
            a.SU_holder_OB_item_GRD_grade_ID = p_id
        AND
            a.SU_holder_OB_item_GRD_grade_Positor = p_positor
        AND
            a.SU_holder_OB_item_GRD_grade_PositedAt <= p_positing
        ORDER BY
            a.SU_holder_OB_item_GRD_grade_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_holder_OB_item_GRD_grade_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_holder_OB_item_GRD_grade;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_holder_OB_item_GRD_grade tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_SU_holder_OB_item_GRD_grade (
    p_id IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_ID%TYPE,
    p_positor IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Positor%TYPE,
    p_positing IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(he_SU_holder_OB_item_GRD_grade(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_SU_holder_OB_item_GRD_grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_holder_OB_item_GRD_grade states a posit of SU_holder_OB_item_GRD_grade, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_holder_OB_item_GRD_grade (
    p_SU_holder IN SU_holder_OB_item_GRD_grade_Posit.SU_ID_holder%TYPE,
    p_OB_item IN SU_holder_OB_item_GRD_grade_Posit.OB_ID_item%TYPE,
    p_GRD_grade IN SU_holder_OB_item_GRD_grade_Posit.GRD_ID_grade%TYPE,
    p_changing IN SU_holder_OB_item_GRD_grade_Posit.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_holder_OB_item_GRD_grade_Annex.Metadata_SU_holder_OB_item_GRD_grade%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Positor%TYPE;
    v_positing SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_PositedAt%TYPE;
    v_reliability SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Reliability%TYPE;
    v_held SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_Reliability%TYPE;
    v_changing SU_holder_OB_item_GRD_grade_Posit.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE;
    v_posit SU_holder_OB_item_GRD_grade_Posit.SU_holder_OB_item_GRD_grade_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN SU_holder_OB_item_GRD_grade_Annex.SU_holder_OB_item_GRD_grade_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
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
                    SU_holder_OB_item_GRD_grade_Annex a
                WHERE
                    a.SU_holder_OB_item_GRD_grade_ID = p_id
                AND
                    a.SU_holder_OB_item_GRD_grade_Positor = v_positor
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.SU_holder_OB_item_GRD_grade_ID
        FROM
            SU_holder_OB_item_GRD_grade_Posit p
        WHERE
            p.SU_ID_holder = p_SU_holder
        AND
            p.OB_ID_item = p_OB_item
        AND
            p.GRD_ID_grade = p_GRD_grade
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_holder_OB_item_GRD_grade_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_holder_OB_item_GRD_grade_Annex a
                WHERE
                    a.SU_holder_OB_item_GRD_grade_ID = v_posit
                AND
                    a.SU_holder_OB_item_GRD_grade_Positor = v_positor
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
                AND
                    a.SU_holder_OB_item_GRD_grade_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_holder_OB_item_GRD_grade for: ' ||
                p_SU_holder || ', ' ||
                p_OB_item || ', ' ||
                p_GRD_grade || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF v_reliability <> 0 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_holder_OB_item_GRD_grade_Posit p
                JOIN
                    SU_holder_OB_item_GRD_grade_Annex a
                ON
                    a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
                WHERE
                    p.SU_ID_holder = p_SU_holder
                AND
                    p.OB_ID_item = p_OB_item
                AND
                    p.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
                AND
                    NOT (
                        p.GRD_ID_grade = p_GRD_grade
                    )
                AND
                    a.SU_holder_OB_item_GRD_grade_Positor = v_positor
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
                AND
                    a.SU_holder_OB_item_GRD_grade_Reliability <> 0
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_holder_OB_item_GRD_grade for: ' ||
                p_SU_holder || ', ' ||
                p_OB_item || ', ' ||
                p_GRD_grade || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_holder_OB_item_GRD_grade_Annex a
                WHERE
                    a.SU_holder_OB_item_GRD_grade_ID = v_posit
                AND
                    a.SU_holder_OB_item_GRD_grade_Positor = v_positor
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := he_SU_holder_OB_item_GRD_grade(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
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
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.SU_holder_OB_item_GRD_grade_ID
        FROM
            SU_holder_OB_item_GRD_grade_Posit p
        WHERE
            p.SU_ID_holder = p_SU_holder
        AND
            p.OB_ID_item = p_OB_item
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        AND
            NOT (
                p.GRD_ID_grade = p_GRD_grade
            )
        AND
            ie_SU_holder_OB_item_GRD_grade(p.SU_holder_OB_item_GRD_grade_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.SU_holder_OB_item_GRD_grade_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_holder_OB_item_GRD_grade_Posit (
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt
        )
        VALUES (
            p_SU_holder,
            p_OB_item,
            p_GRD_grade,
            v_changing
        )
        RETURNING SU_holder_OB_item_GRD_grade_ID INTO v_posit;
    END IF;
    INSERT INTO SU_holder_OB_item_GRD_grade_Annex (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_holder_OB_item_GRD_grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_holder_OB_item_GRD_grade instead of INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_holder_OB_item_GRD_grade
INSTEAD OF INSERT ON SU_holder_OB_item_GRD_grade
FOR EACH ROW
BEGIN
    ip_SU_holder_OB_item_GRD_grade(
        p_SU_holder => :NEW.SU_ID_holder,
        p_OB_item => :NEW.OB_ID_item,
        p_GRD_grade => :NEW.GRD_ID_grade,
        p_changing => :NEW.SU_holder_OB_item_GRD_grade_ChangedAt,
        p_positor => :NEW.SU_holder_OB_item_GRD_grade_Positor,
        p_positing => :NEW.SU_holder_OB_item_GRD_grade_PositedAt,
        p_reliability => :NEW.SU_holder_OB_item_GRD_grade_Reliability,
        p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
    );
END it_SU_holder_OB_item_GRD_grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_holder_OB_item_GRD_grade
INSTEAD OF INSERT ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_GRD_grade number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_grade := :NEW.GRD_ID_grade;
    IF v_GRD_grade IS NULL AND :NEW.grade_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.grade_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GRD_grade := kv.GRD_ID;
        END LOOP;
    END IF;
    ip_SU_holder_OB_item_GRD_grade(
        p_SU_holder => :NEW.SU_ID_holder,
        p_OB_item => :NEW.OB_ID_item,
        p_GRD_grade => v_GRD_grade,
        p_changing => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_Reliability, 1),
        p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
    );
END it_lSU_holder_OB_item_GRD_grade;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_holder_OB_item_GRD_grade
INSTEAD OF UPDATE ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_positor number(5);
    v_GRD_grade number(5);
BEGIN
    IF (:NEW.SU_ID_holder <> :OLD.SU_ID_holder
        OR (:NEW.SU_ID_holder IS NULL AND :OLD.SU_ID_holder IS NOT NULL)
        OR (:NEW.SU_ID_holder IS NOT NULL AND :OLD.SU_ID_holder IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID_holder is not updatable.');
    END IF;
    IF (:NEW.OB_ID_item <> :OLD.OB_ID_item
        OR (:NEW.OB_ID_item IS NULL AND :OLD.OB_ID_item IS NOT NULL)
        OR (:NEW.OB_ID_item IS NOT NULL AND :OLD.OB_ID_item IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_item is not updatable.');
    END IF;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_grade := :NEW.GRD_ID_grade;
    IF (:NEW.grade_GRD_Grade <> :OLD.grade_GRD_Grade
        OR (:NEW.grade_GRD_Grade IS NULL AND :OLD.grade_GRD_Grade IS NOT NULL)
        OR (:NEW.grade_GRD_Grade IS NOT NULL AND :OLD.grade_GRD_Grade IS NULL))
    AND (:NEW.GRD_ID_grade = :OLD.GRD_ID_grade
        OR (:NEW.GRD_ID_grade IS NULL AND :OLD.GRD_ID_grade IS NULL)) THEN
        v_GRD_grade := NULL;
        IF :NEW.grade_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.grade_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GRD_grade := kv.GRD_ID;
            END LOOP;
        END IF;
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.SU_holder_OB_item_GRD_grade_Positor <> :OLD.SU_holder_OB_item_GRD_grade_Positor
            OR (:NEW.SU_holder_OB_item_GRD_grade_Positor IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_Positor IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_Positor IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_Positor IS NULL))
        THEN :NEW.SU_holder_OB_item_GRD_grade_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.SU_holder_OB_item_GRD_grade_PositedAt <> :OLD.SU_holder_OB_item_GRD_grade_PositedAt
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NULL))
        THEN :NEW.SU_holder_OB_item_GRD_grade_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.SU_ID_holder <> :OLD.SU_ID_holder
            OR (:NEW.SU_ID_holder IS NULL AND :OLD.SU_ID_holder IS NOT NULL)
            OR (:NEW.SU_ID_holder IS NOT NULL AND :OLD.SU_ID_holder IS NULL)) OR
        (:NEW.OB_ID_item <> :OLD.OB_ID_item
            OR (:NEW.OB_ID_item IS NULL AND :OLD.OB_ID_item IS NOT NULL)
            OR (:NEW.OB_ID_item IS NOT NULL AND :OLD.OB_ID_item IS NULL)) OR
        (v_GRD_grade <> :OLD.GRD_ID_grade
            OR (v_GRD_grade IS NULL AND :OLD.GRD_ID_grade IS NOT NULL)
            OR (v_GRD_grade IS NOT NULL AND :OLD.GRD_ID_grade IS NULL)) OR
        (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt <> :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
            OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL)) OR
        (:NEW.SU_holder_OB_item_GRD_grade_PositedAt <> :OLD.SU_holder_OB_item_GRD_grade_PositedAt
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_PositedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_PositedAt IS NULL)) OR
        (:NEW.SU_holder_OB_item_GRD_grade_Reliability <> :OLD.SU_holder_OB_item_GRD_grade_Reliability
            OR (:NEW.SU_holder_OB_item_GRD_grade_Reliability IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_Reliability IS NOT NULL)
            OR (:NEW.SU_holder_OB_item_GRD_grade_Reliability IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_Reliability IS NULL))
    THEN
        IF
            :NEW.SU_ID_holder IS NOT NULL
        AND
            :NEW.OB_ID_item IS NOT NULL
        AND
            v_GRD_grade IS NOT NULL
        THEN
            ip_SU_holder_OB_item_GRD_grade(
                p_SU_holder => :NEW.SU_ID_holder,
                p_OB_item => :NEW.OB_ID_item,
                p_GRD_grade => v_GRD_grade,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt <> :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
                        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL))
                    THEN :NEW.SU_holder_OB_item_GRD_grade_ChangedAt
                    WHEN
                        :NEW.SU_ID_holder = :OLD.SU_ID_holder
                    AND
                        :NEW.OB_ID_item = :OLD.OB_ID_item
                    AND
                        v_GRD_grade = :OLD.GRD_ID_grade
                    THEN :NEW.SU_holder_OB_item_GRD_grade_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.SU_holder_OB_item_GRD_grade_Reliability, 1),
                p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_SU_holder_OB_item_GRD_grade(
                p_SU_holder => :OLD.SU_ID_holder,
                p_OB_item => :OLD.OB_ID_item,
                p_GRD_grade => :OLD.GRD_ID_grade,
                p_changing => :OLD.SU_holder_OB_item_GRD_grade_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
            );
        END IF;
    END IF;
END ut_lSU_holder_OB_item_GRD_grade;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_holder_OB_item_GRD_grade
INSTEAD OF DELETE ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    ip_SU_holder_OB_item_GRD_grade(
        p_SU_holder => :OLD.SU_ID_holder,
        p_OB_item => :OLD.OB_ID_item,
        p_GRD_grade => :OLD.GRD_ID_grade,
        p_changing => :OLD.SU_holder_OB_item_GRD_grade_ChangedAt,
        p_positor => COALESCE(:OLD.SU_holder_OB_item_GRD_grade_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_SU_holder_OB_item_GRD_grade
    );
END dt_lSU_holder_OB_item_GRD_grade;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_keeper_OB_thing_GRD_rank is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_keeper_OB_thing_GRD_rank (
    p_id IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_ID%TYPE,
    p_positor IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Positor%TYPE,
    p_positing IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE
) RETURN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            SU_keeper_OB_thing_GRD_rank_Annex a
        WHERE
            a.SU_keeper_OB_thing_GRD_rank_ID = p_id
        AND
            a.SU_keeper_OB_thing_GRD_rank_Positor = p_positor
        AND
            a.SU_keeper_OB_thing_GRD_rank_PositedAt <= p_positing
        ORDER BY
            a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_keeper_OB_thing_GRD_rank_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_keeper_OB_thing_GRD_rank;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_keeper_OB_thing_GRD_rank tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_SU_keeper_OB_thing_GRD_rank (
    p_id IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_ID%TYPE,
    p_positor IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Positor%TYPE,
    p_positing IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(he_SU_keeper_OB_thing_GRD_rank(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_SU_keeper_OB_thing_GRD_rank;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_keeper_OB_thing_GRD_rank states a posit of SU_keeper_OB_thing_GRD_rank, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_keeper_OB_thing_GRD_rank (
    p_SU_keeper IN SU_keeper_OB_thing_GRD_rank_Posit.SU_ID_keeper%TYPE,
    p_OB_thing IN SU_keeper_OB_thing_GRD_rank_Posit.OB_ID_thing%TYPE,
    p_GRD_rank IN SU_keeper_OB_thing_GRD_rank_Posit.GRD_ID_rank%TYPE,
    p_changing IN SU_keeper_OB_thing_GRD_rank_Posit.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_keeper_OB_thing_GRD_rank_Annex.Metadata_SU_keeper_OB_thing_GRD_rank%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Positor%TYPE;
    v_positing SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_PositedAt%TYPE;
    v_reliability SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Reliability%TYPE;
    v_held SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_Reliability%TYPE;
    v_changing SU_keeper_OB_thing_GRD_rank_Posit.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE;
    v_posit SU_keeper_OB_thing_GRD_rank_Posit.SU_keeper_OB_thing_GRD_rank_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN SU_keeper_OB_thing_GRD_rank_Annex.SU_keeper_OB_thing_GRD_rank_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
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
                    SU_keeper_OB_thing_GRD_rank_Annex a
                WHERE
                    a.SU_keeper_OB_thing_GRD_rank_ID = p_id
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Positor = v_positor
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.SU_keeper_OB_thing_GRD_rank_ID
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.GRD_ID_rank = p_GRD_rank
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_keeper_OB_thing_GRD_rank_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_keeper_OB_thing_GRD_rank_Annex a
                WHERE
                    a.SU_keeper_OB_thing_GRD_rank_ID = v_posit
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Positor = v_positor
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' ||
                p_SU_keeper || ', ' ||
                p_OB_thing || ', ' ||
                p_GRD_rank || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF v_reliability <> 0 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_keeper_OB_thing_GRD_rank_Posit p
                JOIN
                    SU_keeper_OB_thing_GRD_rank_Annex a
                ON
                    a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
                WHERE
                    p.SU_ID_keeper = p_SU_keeper
                AND
                    p.OB_ID_thing = p_OB_thing
                AND
                    p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
                AND
                    NOT (
                        p.GRD_ID_rank = p_GRD_rank
                    )
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Positor = v_positor
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Reliability <> 0
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' ||
                p_SU_keeper || ', ' ||
                p_OB_thing || ', ' ||
                p_GRD_rank || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_keeper_OB_thing_GRD_rank_Annex a
                WHERE
                    a.SU_keeper_OB_thing_GRD_rank_ID = v_posit
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Positor = v_positor
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := he_SU_keeper_OB_thing_GRD_rank(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
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
    -- the same assertion that the positor holds is not stated again unless the tie is assertive
    IF v_held IS NOT NULL AND v_held = v_reliability THEN
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.SU_keeper_OB_thing_GRD_rank_ID
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        AND
            NOT (
                p.GRD_ID_rank = p_GRD_rank
            )
        AND
            ie_SU_keeper_OB_thing_GRD_rank(p.SU_keeper_OB_thing_GRD_rank_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.SU_keeper_OB_thing_GRD_rank_ID);
    END LOOP;
    -- the same values as the version before it, which the positor holds with the same sign at the positing time, is a restatement
    -- (an idempotent tie does not store it, and retracts the version after it that the new values make a restatement of)
    FOR r IN (
        SELECT
            p.SU_ID_keeper,
            p.OB_ID_thing,
            p.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt < v_changing
        AND
            ie_SU_keeper_OB_thing_GRD_rank(p.SU_keeper_OB_thing_GRD_rank_ID, v_positor, v_positing) = 1
        AND
            CASE WHEN he_SU_keeper_OB_thing_GRD_rank(p.SU_keeper_OB_thing_GRD_rank_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_sign
        ORDER BY
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF
            r.SU_ID_keeper = p_SU_keeper
        AND
            r.OB_ID_thing = p_OB_thing
        AND
            r.GRD_ID_rank = p_GRD_rank
        THEN
            RETURN;
        END IF;
    END LOOP;
    -- the same values as the version after it make that version a restatement
    FOR r IN (
        SELECT
            f.SU_keeper_OB_thing_GRD_rank_ID,
            f.SU_ID_keeper,
            f.OB_ID_thing,
            f.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit f
        WHERE
            f.SU_ID_keeper = p_SU_keeper
        AND
            f.OB_ID_thing = p_OB_thing
        AND
            f.SU_keeper_OB_thing_GRD_rank_ChangedAt > v_changing
        AND
            ie_SU_keeper_OB_thing_GRD_rank(f.SU_keeper_OB_thing_GRD_rank_ID, v_positor, v_positing) = 1
        AND
            CASE WHEN he_SU_keeper_OB_thing_GRD_rank(f.SU_keeper_OB_thing_GRD_rank_ID, v_positor, v_positing) > 0 THEN 1 ELSE 0 END = v_sign
        ORDER BY
            f.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF
            r.SU_ID_keeper = p_SU_keeper
        AND
            r.OB_ID_thing = p_OB_thing
        AND
            r.GRD_ID_rank = p_GRD_rank
        THEN
            -- (an idempotent tie retracts it)
            retract(r.SU_keeper_OB_thing_GRD_rank_ID);
        END IF;
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_keeper_OB_thing_GRD_rank_Posit (
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt
        )
        VALUES (
            p_SU_keeper,
            p_OB_thing,
            p_GRD_rank,
            v_changing
        )
        RETURNING SU_keeper_OB_thing_GRD_rank_ID INTO v_posit;
    END IF;
    INSERT INTO SU_keeper_OB_thing_GRD_rank_Annex (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_keeper_OB_thing_GRD_rank;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_keeper_OB_thing_GRD_rank instead of INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_keeper_OB_thing_GRD_rank
INSTEAD OF INSERT ON SU_keeper_OB_thing_GRD_rank
FOR EACH ROW
BEGIN
    ip_SU_keeper_OB_thing_GRD_rank(
        p_SU_keeper => :NEW.SU_ID_keeper,
        p_OB_thing => :NEW.OB_ID_thing,
        p_GRD_rank => :NEW.GRD_ID_rank,
        p_changing => :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        p_positor => :NEW.SU_keeper_OB_thing_GRD_rank_Positor,
        p_positing => :NEW.SU_keeper_OB_thing_GRD_rank_PositedAt,
        p_reliability => :NEW.SU_keeper_OB_thing_GRD_rank_Reliability,
        p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
    );
END it_SU_keeper_OB_thing_GRD_rank;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF INSERT ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_GRD_rank number(5);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_rank := :NEW.GRD_ID_rank;
    IF v_GRD_rank IS NULL AND :NEW.rank_GRD_Grade IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GRD_ID
            FROM
                GRD_Grade k
            WHERE
                k.GRD_Grade = :NEW.rank_GRD_Grade
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GRD_rank := kv.GRD_ID;
        END LOOP;
    END IF;
    ip_SU_keeper_OB_thing_GRD_rank(
        p_SU_keeper => :NEW.SU_ID_keeper,
        p_OB_thing => :NEW.OB_ID_thing,
        p_GRD_rank => v_GRD_rank,
        p_changing => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
        p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
    );
END it_lSU_keeper_OB_thing_GRD_rank;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF UPDATE ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_positor number(5);
    v_GRD_rank number(5);
BEGIN
    IF (:NEW.SU_ID_keeper <> :OLD.SU_ID_keeper
        OR (:NEW.SU_ID_keeper IS NULL AND :OLD.SU_ID_keeper IS NOT NULL)
        OR (:NEW.SU_ID_keeper IS NOT NULL AND :OLD.SU_ID_keeper IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column SU_ID_keeper is not updatable.');
    END IF;
    IF (:NEW.OB_ID_thing <> :OLD.OB_ID_thing
        OR (:NEW.OB_ID_thing IS NULL AND :OLD.OB_ID_thing IS NOT NULL)
        OR (:NEW.OB_ID_thing IS NOT NULL AND :OLD.OB_ID_thing IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_thing is not updatable.');
    END IF;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GRD_rank := :NEW.GRD_ID_rank;
    IF (:NEW.rank_GRD_Grade <> :OLD.rank_GRD_Grade
        OR (:NEW.rank_GRD_Grade IS NULL AND :OLD.rank_GRD_Grade IS NOT NULL)
        OR (:NEW.rank_GRD_Grade IS NOT NULL AND :OLD.rank_GRD_Grade IS NULL))
    AND (:NEW.GRD_ID_rank = :OLD.GRD_ID_rank
        OR (:NEW.GRD_ID_rank IS NULL AND :OLD.GRD_ID_rank IS NULL)) THEN
        v_GRD_rank := NULL;
        IF :NEW.rank_GRD_Grade IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GRD_ID
                FROM
                    GRD_Grade k
                WHERE
                    k.GRD_Grade = :NEW.rank_GRD_Grade
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GRD_rank := kv.GRD_ID;
            END LOOP;
        END IF;
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_Positor <> :OLD.SU_keeper_OB_thing_GRD_rank_Positor
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_Positor IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_Positor IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_Positor IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_Positor IS NULL))
        THEN :NEW.SU_keeper_OB_thing_GRD_rank_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL))
        THEN :NEW.SU_keeper_OB_thing_GRD_rank_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.SU_ID_keeper <> :OLD.SU_ID_keeper
            OR (:NEW.SU_ID_keeper IS NULL AND :OLD.SU_ID_keeper IS NOT NULL)
            OR (:NEW.SU_ID_keeper IS NOT NULL AND :OLD.SU_ID_keeper IS NULL)) OR
        (:NEW.OB_ID_thing <> :OLD.OB_ID_thing
            OR (:NEW.OB_ID_thing IS NULL AND :OLD.OB_ID_thing IS NOT NULL)
            OR (:NEW.OB_ID_thing IS NOT NULL AND :OLD.OB_ID_thing IS NULL)) OR
        (v_GRD_rank <> :OLD.GRD_ID_rank
            OR (v_GRD_rank IS NULL AND :OLD.GRD_ID_rank IS NOT NULL)
            OR (v_GRD_rank IS NOT NULL AND :OLD.GRD_ID_rank IS NULL)) OR
        (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL)) OR
        (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_PositedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_PositedAt IS NULL)) OR
        (:NEW.SU_keeper_OB_thing_GRD_rank_Reliability <> :OLD.SU_keeper_OB_thing_GRD_rank_Reliability
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_Reliability IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_Reliability IS NOT NULL)
            OR (:NEW.SU_keeper_OB_thing_GRD_rank_Reliability IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_Reliability IS NULL))
    THEN
        IF
            :NEW.SU_ID_keeper IS NOT NULL
        AND
            :NEW.OB_ID_thing IS NOT NULL
        AND
            v_GRD_rank IS NOT NULL
        THEN
            ip_SU_keeper_OB_thing_GRD_rank(
                p_SU_keeper => :NEW.SU_ID_keeper,
                p_OB_thing => :NEW.OB_ID_thing,
                p_GRD_rank => v_GRD_rank,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
                        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL))
                    THEN :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt
                    WHEN
                        :NEW.SU_ID_keeper = :OLD.SU_ID_keeper
                    AND
                        :NEW.OB_ID_thing = :OLD.OB_ID_thing
                    AND
                        v_GRD_rank = :OLD.GRD_ID_rank
                    THEN :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
                p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_SU_keeper_OB_thing_GRD_rank(
                p_SU_keeper => :OLD.SU_ID_keeper,
                p_OB_thing => :OLD.OB_ID_thing,
                p_GRD_rank => :OLD.GRD_ID_rank,
                p_changing => :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
            );
        END IF;
    END IF;
END ut_lSU_keeper_OB_thing_GRD_rank;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF DELETE ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    ip_SU_keeper_OB_thing_GRD_rank(
        p_SU_keeper => :OLD.SU_ID_keeper,
        p_OB_thing => :OLD.OB_ID_thing,
        p_GRD_rank => :OLD.GRD_ID_rank,
        p_changing => :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        p_positor => COALESCE(:OLD.SU_keeper_OB_thing_GRD_rank_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_SU_keeper_OB_thing_GRD_rank
    );
END dt_lSU_keeper_OB_thing_GRD_rank;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_OB_part_SU_owner is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_OB_part_SU_owner (
    p_id IN OB_part_SU_owner_Annex.OB_part_SU_owner_ID%TYPE,
    p_positor IN OB_part_SU_owner_Annex.OB_part_SU_owner_Positor%TYPE,
    p_positing IN OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE
) RETURN OB_part_SU_owner_Annex.OB_part_SU_owner_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.OB_part_SU_owner_Reliability
        FROM
            OB_part_SU_owner_Annex a
        WHERE
            a.OB_part_SU_owner_ID = p_id
        AND
            a.OB_part_SU_owner_Positor = p_positor
        AND
            a.OB_part_SU_owner_PositedAt <= p_positing
        ORDER BY
            a.OB_part_SU_owner_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.OB_part_SU_owner_Reliability;
    END LOOP;
    RETURN NULL;
END he_OB_part_SU_owner;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_OB_part_SU_owner tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_OB_part_SU_owner (
    p_id IN OB_part_SU_owner_Annex.OB_part_SU_owner_ID%TYPE,
    p_positor IN OB_part_SU_owner_Annex.OB_part_SU_owner_Positor%TYPE,
    p_positing IN OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(he_OB_part_SU_owner(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_OB_part_SU_owner;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_part_SU_owner states a posit of OB_part_SU_owner, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_part_SU_owner (
    p_OB_part IN OB_part_SU_owner_Posit.OB_ID_part%TYPE,
    p_SU_owner IN OB_part_SU_owner_Posit.SU_ID_owner%TYPE,
    p_positor IN OB_part_SU_owner_Annex.OB_part_SU_owner_Positor%TYPE DEFAULT NULL,
    p_positing IN OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN OB_part_SU_owner_Annex.OB_part_SU_owner_Reliability%TYPE DEFAULT NULL,
    p_metadata IN OB_part_SU_owner_Annex.Metadata_OB_part_SU_owner%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor OB_part_SU_owner_Annex.OB_part_SU_owner_Positor%TYPE;
    v_positing OB_part_SU_owner_Annex.OB_part_SU_owner_PositedAt%TYPE;
    v_reliability OB_part_SU_owner_Annex.OB_part_SU_owner_Reliability%TYPE;
    v_held OB_part_SU_owner_Annex.OB_part_SU_owner_Reliability%TYPE;
    v_posit OB_part_SU_owner_Posit.OB_part_SU_owner_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN OB_part_SU_owner_Annex.OB_part_SU_owner_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO OB_part_SU_owner_Annex (
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
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
                    OB_part_SU_owner_Annex a
                WHERE
                    a.OB_part_SU_owner_ID = p_id
                AND
                    a.OB_part_SU_owner_Positor = v_positor
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.OB_part_SU_owner_ID
        FROM
            OB_part_SU_owner_Posit p
        WHERE
            p.OB_ID_part = p_OB_part
        AND
            p.SU_ID_owner = p_SU_owner
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.OB_part_SU_owner_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    OB_part_SU_owner_Annex a
                WHERE
                    a.OB_part_SU_owner_ID = v_posit
                AND
                    a.OB_part_SU_owner_Positor = v_positor
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
                AND
                    a.OB_part_SU_owner_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_part_SU_owner for: ' ||
                p_OB_part || ', ' ||
                p_SU_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF v_reliability <> 0 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    OB_part_SU_owner_Posit p
                JOIN
                    OB_part_SU_owner_Annex a
                ON
                    a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
                WHERE
                    p.OB_ID_part = p_OB_part
                AND
                    NOT (
                        p.SU_ID_owner = p_SU_owner
                    )
                AND
                    a.OB_part_SU_owner_Positor = v_positor
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
                AND
                    a.OB_part_SU_owner_Reliability <> 0
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_part_SU_owner for: ' ||
                p_OB_part || ', ' ||
                p_SU_owner || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    OB_part_SU_owner_Annex a
                WHERE
                    a.OB_part_SU_owner_ID = v_posit
                AND
                    a.OB_part_SU_owner_Positor = v_positor
                AND
                    a.OB_part_SU_owner_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := he_OB_part_SU_owner(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO OB_part_SU_owner_Annex (
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
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
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.OB_part_SU_owner_ID
        FROM
            OB_part_SU_owner_Posit p
        WHERE
            p.OB_ID_part = p_OB_part
        AND
            NOT (
                p.SU_ID_owner = p_SU_owner
            )
        AND
            ie_OB_part_SU_owner(p.OB_part_SU_owner_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.OB_part_SU_owner_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO OB_part_SU_owner_Posit (
            OB_ID_part,
            SU_ID_owner
        )
        VALUES (
            p_OB_part,
            p_SU_owner
        )
        RETURNING OB_part_SU_owner_ID INTO v_posit;
    END IF;
    INSERT INTO OB_part_SU_owner_Annex (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_OB_part_SU_owner;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_part_SU_owner instead of INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_OB_part_SU_owner
INSTEAD OF INSERT ON OB_part_SU_owner
FOR EACH ROW
BEGIN
    ip_OB_part_SU_owner(
        p_OB_part => :NEW.OB_ID_part,
        p_SU_owner => :NEW.SU_ID_owner,
        p_positor => :NEW.OB_part_SU_owner_Positor,
        p_positing => :NEW.OB_part_SU_owner_PositedAt,
        p_reliability => :NEW.OB_part_SU_owner_Reliability,
        p_metadata => :NEW.Metadata_OB_part_SU_owner
    );
END it_OB_part_SU_owner;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lOB_part_SU_owner
INSTEAD OF INSERT ON lOB_part_SU_owner
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_OB_part_SU_owner(
        p_OB_part => :NEW.OB_ID_part,
        p_SU_owner => :NEW.SU_ID_owner,
        p_positor => COALESCE(:NEW.OB_part_SU_owner_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.OB_part_SU_owner_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.OB_part_SU_owner_Reliability, 1),
        p_metadata => :NEW.Metadata_OB_part_SU_owner
    );
END it_lOB_part_SU_owner;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lOB_part_SU_owner
INSTEAD OF UPDATE ON lOB_part_SU_owner
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_positor number(5);
BEGIN
    IF (:NEW.OB_ID_part <> :OLD.OB_ID_part
        OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
        OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_part is not updatable.');
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.OB_part_SU_owner_Positor <> :OLD.OB_part_SU_owner_Positor
            OR (:NEW.OB_part_SU_owner_Positor IS NULL AND :OLD.OB_part_SU_owner_Positor IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_Positor IS NOT NULL AND :OLD.OB_part_SU_owner_Positor IS NULL))
        THEN :NEW.OB_part_SU_owner_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.OB_part_SU_owner_PositedAt <> :OLD.OB_part_SU_owner_PositedAt
            OR (:NEW.OB_part_SU_owner_PositedAt IS NULL AND :OLD.OB_part_SU_owner_PositedAt IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_PositedAt IS NOT NULL AND :OLD.OB_part_SU_owner_PositedAt IS NULL))
        THEN :NEW.OB_part_SU_owner_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.OB_ID_part <> :OLD.OB_ID_part
            OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
            OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL)) OR
        (:NEW.SU_ID_owner <> :OLD.SU_ID_owner
            OR (:NEW.SU_ID_owner IS NULL AND :OLD.SU_ID_owner IS NOT NULL)
            OR (:NEW.SU_ID_owner IS NOT NULL AND :OLD.SU_ID_owner IS NULL)) OR
        (:NEW.OB_part_SU_owner_PositedAt <> :OLD.OB_part_SU_owner_PositedAt
            OR (:NEW.OB_part_SU_owner_PositedAt IS NULL AND :OLD.OB_part_SU_owner_PositedAt IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_PositedAt IS NOT NULL AND :OLD.OB_part_SU_owner_PositedAt IS NULL)) OR
        (:NEW.OB_part_SU_owner_Reliability <> :OLD.OB_part_SU_owner_Reliability
            OR (:NEW.OB_part_SU_owner_Reliability IS NULL AND :OLD.OB_part_SU_owner_Reliability IS NOT NULL)
            OR (:NEW.OB_part_SU_owner_Reliability IS NOT NULL AND :OLD.OB_part_SU_owner_Reliability IS NULL))
    THEN
        IF
            :NEW.OB_ID_part IS NOT NULL
        AND
            :NEW.SU_ID_owner IS NOT NULL
        THEN
            ip_OB_part_SU_owner(
                p_OB_part => :NEW.OB_ID_part,
                p_SU_owner => :NEW.SU_ID_owner,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.OB_part_SU_owner_Reliability, 1),
                p_metadata => :NEW.Metadata_OB_part_SU_owner
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_OB_part_SU_owner(
                p_OB_part => :OLD.OB_ID_part,
                p_SU_owner => :OLD.SU_ID_owner,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_OB_part_SU_owner
            );
        END IF;
    END IF;
END ut_lOB_part_SU_owner;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lOB_part_SU_owner
INSTEAD OF DELETE ON lOB_part_SU_owner
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    ip_OB_part_SU_owner(
        p_OB_part => :OLD.OB_ID_part,
        p_SU_owner => :OLD.SU_ID_owner,
        p_positor => COALESCE(:OLD.OB_part_SU_owner_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_OB_part_SU_owner
    );
END dt_lOB_part_SU_owner;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_SU_partner_SU_with is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION he_SU_partner_SU_with (
    p_id IN SU_partner_SU_with_Annex.SU_partner_SU_with_ID%TYPE,
    p_positor IN SU_partner_SU_with_Annex.SU_partner_SU_with_Positor%TYPE,
    p_positing IN SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE
) RETURN SU_partner_SU_with_Annex.SU_partner_SU_with_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.SU_partner_SU_with_Reliability
        FROM
            SU_partner_SU_with_Annex a
        WHERE
            a.SU_partner_SU_with_ID = p_id
        AND
            a.SU_partner_SU_with_Positor = p_positor
        AND
            a.SU_partner_SU_with_PositedAt <= p_positing
        ORDER BY
            a.SU_partner_SU_with_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.SU_partner_SU_with_Reliability;
    END LOOP;
    RETURN NULL;
END he_SU_partner_SU_with;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_partner_SU_with tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ie_SU_partner_SU_with (
    p_id IN SU_partner_SU_with_Annex.SU_partner_SU_with_ID%TYPE,
    p_positor IN SU_partner_SU_with_Annex.SU_partner_SU_with_Positor%TYPE,
    p_positing IN SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(he_SU_partner_SU_with(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_SU_partner_SU_with;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_partner_SU_with states a posit of SU_partner_SU_with, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_partner_SU_with (
    p_SU_partner IN SU_partner_SU_with_Posit.SU_ID_partner%TYPE,
    p_SU_with IN SU_partner_SU_with_Posit.SU_ID_with%TYPE,
    p_changing IN SU_partner_SU_with_Posit.SU_partner_SU_with_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN SU_partner_SU_with_Annex.SU_partner_SU_with_Positor%TYPE DEFAULT NULL,
    p_positing IN SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN SU_partner_SU_with_Annex.SU_partner_SU_with_Reliability%TYPE DEFAULT NULL,
    p_metadata IN SU_partner_SU_with_Annex.Metadata_SU_partner_SU_with%TYPE DEFAULT NULL
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor SU_partner_SU_with_Annex.SU_partner_SU_with_Positor%TYPE;
    v_positing SU_partner_SU_with_Annex.SU_partner_SU_with_PositedAt%TYPE;
    v_reliability SU_partner_SU_with_Annex.SU_partner_SU_with_Reliability%TYPE;
    v_held SU_partner_SU_with_Annex.SU_partner_SU_with_Reliability%TYPE;
    v_changing SU_partner_SU_with_Posit.SU_partner_SU_with_ChangedAt%TYPE;
    v_posit SU_partner_SU_with_Posit.SU_partner_SU_with_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN SU_partner_SU_with_Annex.SU_partner_SU_with_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO SU_partner_SU_with_Annex (
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
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
                    SU_partner_SU_with_Annex a
                WHERE
                    a.SU_partner_SU_with_ID = p_id
                AND
                    a.SU_partner_SU_with_Positor = v_positor
                AND
                    a.SU_partner_SU_with_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.SU_partner_SU_with_ID
        FROM
            SU_partner_SU_with_Posit p
        WHERE
            p.SU_ID_partner = p_SU_partner
        AND
            p.SU_ID_with = p_SU_with
        AND
            p.SU_partner_SU_with_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.SU_partner_SU_with_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_partner_SU_with_Annex a
                WHERE
                    a.SU_partner_SU_with_ID = v_posit
                AND
                    a.SU_partner_SU_with_Positor = v_positor
                AND
                    a.SU_partner_SU_with_PositedAt = v_positing
                AND
                    a.SU_partner_SU_with_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_partner_SU_with for: ' ||
                p_SU_partner || ', ' ||
                p_SU_with || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    SU_partner_SU_with_Annex a
                WHERE
                    a.SU_partner_SU_with_ID = v_posit
                AND
                    a.SU_partner_SU_with_Positor = v_positor
                AND
                    a.SU_partner_SU_with_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := he_SU_partner_SU_with(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO SU_partner_SU_with_Annex (
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
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
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO SU_partner_SU_with_Posit (
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt
        )
        VALUES (
            p_SU_partner,
            p_SU_with,
            v_changing
        )
        RETURNING SU_partner_SU_with_ID INTO v_posit;
    END IF;
    INSERT INTO SU_partner_SU_with_Annex (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_SU_partner_SU_with;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_partner_SU_with instead of INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_SU_partner_SU_with
INSTEAD OF INSERT ON SU_partner_SU_with
FOR EACH ROW
BEGIN
    ip_SU_partner_SU_with(
        p_SU_partner => :NEW.SU_ID_partner,
        p_SU_with => :NEW.SU_ID_with,
        p_changing => :NEW.SU_partner_SU_with_ChangedAt,
        p_positor => :NEW.SU_partner_SU_with_Positor,
        p_positing => :NEW.SU_partner_SU_with_PositedAt,
        p_reliability => :NEW.SU_partner_SU_with_Reliability,
        p_metadata => :NEW.Metadata_SU_partner_SU_with
    );
END it_SU_partner_SU_with;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_partner_SU_with
INSTEAD OF INSERT ON lSU_partner_SU_with
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    ip_SU_partner_SU_with(
        p_SU_partner => :NEW.SU_ID_partner,
        p_SU_with => :NEW.SU_ID_with,
        p_changing => COALESCE(:NEW.SU_partner_SU_with_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.SU_partner_SU_with_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.SU_partner_SU_with_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.SU_partner_SU_with_Reliability, 1),
        p_metadata => :NEW.Metadata_SU_partner_SU_with
    );
END it_lSU_partner_SU_with;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lSU_partner_SU_with
INSTEAD OF UPDATE ON lSU_partner_SU_with
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positing timestamp;
    v_positor number(5);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.SU_partner_SU_with_Positor <> :OLD.SU_partner_SU_with_Positor
            OR (:NEW.SU_partner_SU_with_Positor IS NULL AND :OLD.SU_partner_SU_with_Positor IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_Positor IS NOT NULL AND :OLD.SU_partner_SU_with_Positor IS NULL))
        THEN :NEW.SU_partner_SU_with_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.SU_partner_SU_with_PositedAt <> :OLD.SU_partner_SU_with_PositedAt
            OR (:NEW.SU_partner_SU_with_PositedAt IS NULL AND :OLD.SU_partner_SU_with_PositedAt IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_PositedAt IS NOT NULL AND :OLD.SU_partner_SU_with_PositedAt IS NULL))
        THEN :NEW.SU_partner_SU_with_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.SU_ID_partner <> :OLD.SU_ID_partner
            OR (:NEW.SU_ID_partner IS NULL AND :OLD.SU_ID_partner IS NOT NULL)
            OR (:NEW.SU_ID_partner IS NOT NULL AND :OLD.SU_ID_partner IS NULL)) OR
        (:NEW.SU_ID_with <> :OLD.SU_ID_with
            OR (:NEW.SU_ID_with IS NULL AND :OLD.SU_ID_with IS NOT NULL)
            OR (:NEW.SU_ID_with IS NOT NULL AND :OLD.SU_ID_with IS NULL)) OR
        (:NEW.SU_partner_SU_with_ChangedAt <> :OLD.SU_partner_SU_with_ChangedAt
            OR (:NEW.SU_partner_SU_with_ChangedAt IS NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_ChangedAt IS NOT NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NULL)) OR
        (:NEW.SU_partner_SU_with_PositedAt <> :OLD.SU_partner_SU_with_PositedAt
            OR (:NEW.SU_partner_SU_with_PositedAt IS NULL AND :OLD.SU_partner_SU_with_PositedAt IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_PositedAt IS NOT NULL AND :OLD.SU_partner_SU_with_PositedAt IS NULL)) OR
        (:NEW.SU_partner_SU_with_Reliability <> :OLD.SU_partner_SU_with_Reliability
            OR (:NEW.SU_partner_SU_with_Reliability IS NULL AND :OLD.SU_partner_SU_with_Reliability IS NOT NULL)
            OR (:NEW.SU_partner_SU_with_Reliability IS NOT NULL AND :OLD.SU_partner_SU_with_Reliability IS NULL))
    THEN
        IF
            :NEW.SU_ID_partner IS NOT NULL
        AND
            :NEW.SU_ID_with IS NOT NULL
        THEN
            ip_SU_partner_SU_with(
                p_SU_partner => :NEW.SU_ID_partner,
                p_SU_with => :NEW.SU_ID_with,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.SU_partner_SU_with_ChangedAt <> :OLD.SU_partner_SU_with_ChangedAt
                        OR (:NEW.SU_partner_SU_with_ChangedAt IS NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NOT NULL)
                        OR (:NEW.SU_partner_SU_with_ChangedAt IS NOT NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NULL))
                    THEN :NEW.SU_partner_SU_with_ChangedAt
                    WHEN
                        :NEW.SU_ID_partner = :OLD.SU_ID_partner
                    AND
                        :NEW.SU_ID_with = :OLD.SU_ID_with
                    THEN :NEW.SU_partner_SU_with_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.SU_partner_SU_with_Reliability, 1),
                p_metadata => :NEW.Metadata_SU_partner_SU_with
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ip_SU_partner_SU_with(
                p_SU_partner => :OLD.SU_ID_partner,
                p_SU_with => :OLD.SU_ID_with,
                p_changing => :OLD.SU_partner_SU_with_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_SU_partner_SU_with
            );
        END IF;
    END IF;
END ut_lSU_partner_SU_with;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_partner_SU_with
INSTEAD OF DELETE ON lSU_partner_SU_with
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown is retracted
    ip_SU_partner_SU_with(
        p_SU_partner => :OLD.SU_ID_partner,
        p_SU_with => :OLD.SU_ID_with,
        p_changing => :OLD.SU_partner_SU_with_ChangedAt,
        p_positor => COALESCE(:OLD.SU_partner_SU_with_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_SU_partner_SU_with
    );
END dt_lSU_partner_SU_with;
/
