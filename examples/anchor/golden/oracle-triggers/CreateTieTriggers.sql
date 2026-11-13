-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- A tie and its latest view behave like a table that is loaded with plain statements. The rules for a row of a tie (it is
-- stored only when it is not there already, a contradiction is refused and, for an idempotent tie, what only states again
-- what the row before it says is left out) are in an insert procedure for each tie, ip_<tie>. The latest view has
-- three 'instead of' triggers: insert, update, and delete. They propagate such operations to the tie table in a consistent
-- way, the insert and update triggers by calling the insert procedure. Default values are used for some columns if not
-- provided by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures and not in a trigger on the tie table, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. A load can call the procedure itself:
--
--     BEGIN ip_AC_parent_AC_child(p_AC_parent => 1, p_AC_child => 2); END;
--
-- A row put straight into a tie table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_holder_OB_item_GRD_grade states a row of SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_holder_OB_item_GRD_grade (
    p_SU_holder IN SU_holder_OB_item_GRD_grade.SU_ID_holder%TYPE,
    p_OB_item IN SU_holder_OB_item_GRD_grade.OB_ID_item%TYPE,
    p_GRD_grade IN SU_holder_OB_item_GRD_grade.GRD_ID_grade%TYPE,
    p_changing IN SU_holder_OB_item_GRD_grade.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE,
    p_metadata IN SU_holder_OB_item_GRD_grade.Metadata_SU_holder_OB_item_GRD_grade%TYPE
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_changing SU_holder_OB_item_GRD_grade.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE;
    v_metadata SU_holder_OB_item_GRD_grade.Metadata_SU_holder_OB_item_GRD_grade%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_holder_OB_item_GRD_grade x
        WHERE
            x.SU_ID_holder = p_SU_holder
        AND
            x.OB_ID_item = p_OB_item
        AND
            x.GRD_ID_grade = p_GRD_grade
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_holder_OB_item_GRD_grade x
        WHERE
            x.SU_ID_holder = p_SU_holder
        AND
            x.OB_ID_item = p_OB_item
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_holder_OB_item_GRD_grade for: '
            || p_SU_holder
            || ', '
            || p_OB_item
            || ', '
            || v_changing
        );
    END LOOP;
    INSERT INTO SU_holder_OB_item_GRD_grade (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    VALUES (
        v_metadata,
        v_changing,
        p_SU_holder,
        p_OB_item,
        p_GRD_grade
    );
END ip_SU_holder_OB_item_GRD_grade;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_holder_OB_item_GRD_grade
INSTEAD OF INSERT ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
DECLARE
    v_GRD_grade number(5);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
        p_changing => :NEW.SU_holder_OB_item_GRD_grade_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing SU_holder_OB_item_GRD_grade.SU_holder_OB_item_GRD_grade_ChangedAt%TYPE;
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
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt <> :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL)
        OR (:NEW.SU_holder_OB_item_GRD_grade_ChangedAt IS NOT NULL AND :OLD.SU_holder_OB_item_GRD_grade_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.SU_holder_OB_item_GRD_grade_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_GRD_grade := :NEW.GRD_ID_grade;
    IF (:NEW.grade_GRD_Grade <> :OLD.grade_GRD_Grade
        OR (:NEW.grade_GRD_Grade IS NULL AND :OLD.grade_GRD_Grade IS NOT NULL)
        OR (:NEW.grade_GRD_Grade IS NOT NULL AND :OLD.grade_GRD_Grade IS NULL)) THEN
        v_GRD_grade := NULL;
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
    -- values that are left as they are state nothing
    IF
        v_GRD_grade IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.SU_ID_holder <> :OLD.SU_ID_holder
                OR (:NEW.SU_ID_holder IS NULL AND :OLD.SU_ID_holder IS NOT NULL)
                OR (:NEW.SU_ID_holder IS NOT NULL AND :OLD.SU_ID_holder IS NULL))
        OR
            (:NEW.OB_ID_item <> :OLD.OB_ID_item
                OR (:NEW.OB_ID_item IS NULL AND :OLD.OB_ID_item IS NOT NULL)
                OR (:NEW.OB_ID_item IS NOT NULL AND :OLD.OB_ID_item IS NULL))
        OR
            (v_GRD_grade <> :OLD.GRD_ID_grade
                OR (v_GRD_grade IS NULL AND :OLD.GRD_ID_grade IS NOT NULL)
                OR (v_GRD_grade IS NOT NULL AND :OLD.GRD_ID_grade IS NULL))
        )
    THEN
        ip_SU_holder_OB_item_GRD_grade(
            p_SU_holder => :NEW.SU_ID_holder,
            p_OB_item => :NEW.OB_ID_item,
            p_GRD_grade => v_GRD_grade,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_SU_holder_OB_item_GRD_grade
        );
    END IF;
    -- a null in every value of a deletable tie moves what the identifiers have to the deletion table
    IF :NEW.Deletable_SU_holder_OB_item_GRD_grade = 1
    AND (:NEW.GRD_ID_grade IS NULL OR :NEW.grade_GRD_Grade IS NULL)
    THEN
        INSERT INTO SU_holder_OB_item_GRD_grade_Deleted (
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt,
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_Deleted
        )
        SELECT
            x.SU_ID_holder,
            x.OB_ID_item,
            x.GRD_ID_grade,
            x.SU_holder_OB_item_GRD_grade_ChangedAt,
            x.Metadata_SU_holder_OB_item_GRD_grade,
            CAST(v_changing AS timestamp)
        FROM
            SU_holder_OB_item_GRD_grade x
        WHERE
            x.SU_ID_holder = :OLD.SU_ID_holder
        AND
            x.OB_ID_item = :OLD.OB_ID_item
        ;
        DELETE FROM
            SU_holder_OB_item_GRD_grade
        WHERE
            SU_ID_holder = :OLD.SU_ID_holder
        AND
            OB_ID_item = :OLD.OB_ID_item
        ;
    END IF;
END ut_lSU_holder_OB_item_GRD_grade;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_holder_OB_item_GRD_grade
INSTEAD OF DELETE ON lSU_holder_OB_item_GRD_grade
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_holder_OB_item_GRD_grade x
    WHERE
        x.SU_holder_OB_item_GRD_grade_ChangedAt = :OLD.SU_holder_OB_item_GRD_grade_ChangedAt
    AND
        x.SU_ID_holder = :OLD.SU_ID_holder
    AND
        x.OB_ID_item = :OLD.OB_ID_item
    ;
END dt_lSU_holder_OB_item_GRD_grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_keeper_OB_thing_GRD_rank states a row of SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_keeper_OB_thing_GRD_rank (
    p_SU_keeper IN SU_keeper_OB_thing_GRD_rank.SU_ID_keeper%TYPE,
    p_OB_thing IN SU_keeper_OB_thing_GRD_rank.OB_ID_thing%TYPE,
    p_GRD_rank IN SU_keeper_OB_thing_GRD_rank.GRD_ID_rank%TYPE,
    p_changing IN SU_keeper_OB_thing_GRD_rank.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE,
    p_metadata IN SU_keeper_OB_thing_GRD_rank.Metadata_SU_keeper_OB_thing_GRD_rank%TYPE
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_changing SU_keeper_OB_thing_GRD_rank.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE;
    v_metadata SU_keeper_OB_thing_GRD_rank.Metadata_SU_keeper_OB_thing_GRD_rank%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_keeper_OB_thing_GRD_rank x
        WHERE
            x.SU_ID_keeper = p_SU_keeper
        AND
            x.OB_ID_thing = p_OB_thing
        AND
            x.GRD_ID_rank = p_GRD_rank
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_keeper_OB_thing_GRD_rank x
        WHERE
            x.SU_ID_keeper = p_SU_keeper
        AND
            x.OB_ID_thing = p_OB_thing
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_keeper_OB_thing_GRD_rank for: '
            || p_SU_keeper
            || ', '
            || p_OB_thing
            || ', '
            || v_changing
        );
    END LOOP;
    -- what has the same values as the row before it, or as the row after it, is a restatement
    -- (an idempotent tie does not store it, and removes the row after it that the new row makes a restatement of)
    FOR r IN (
        SELECT
            p.SU_ID_keeper,
            p.OB_ID_thing,
            p.GRD_ID_rank
        FROM
            SU_keeper_OB_thing_GRD_rank p
        WHERE
            p.SU_ID_keeper = p_SU_keeper
        AND
            p.OB_ID_thing = p_OB_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt < v_changing
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
    DELETE FROM
        SU_keeper_OB_thing_GRD_rank x
    WHERE
        x.SU_ID_keeper = p_SU_keeper
    AND
        x.OB_ID_thing = p_OB_thing
    AND
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
            SELECT
                MIN(f.SU_keeper_OB_thing_GRD_rank_ChangedAt)
            FROM
                SU_keeper_OB_thing_GRD_rank f
            WHERE
                f.SU_ID_keeper = p_SU_keeper
            AND
                f.OB_ID_thing = p_OB_thing
            AND
                f.SU_keeper_OB_thing_GRD_rank_ChangedAt > v_changing
        )
    AND
        x.SU_ID_keeper = p_SU_keeper
    AND
        x.OB_ID_thing = p_OB_thing
    AND
        x.GRD_ID_rank = p_GRD_rank
    ;
    INSERT INTO SU_keeper_OB_thing_GRD_rank (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    VALUES (
        v_metadata,
        v_changing,
        p_SU_keeper,
        p_OB_thing,
        p_GRD_rank
    );
END ip_SU_keeper_OB_thing_GRD_rank;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF INSERT ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
DECLARE
    v_GRD_rank number(5);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
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
        p_changing => :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing SU_keeper_OB_thing_GRD_rank.SU_keeper_OB_thing_GRD_rank_ChangedAt%TYPE;
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
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt <> :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL)
        OR (:NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NOT NULL AND :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.SU_keeper_OB_thing_GRD_rank_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_GRD_rank := :NEW.GRD_ID_rank;
    IF (:NEW.rank_GRD_Grade <> :OLD.rank_GRD_Grade
        OR (:NEW.rank_GRD_Grade IS NULL AND :OLD.rank_GRD_Grade IS NOT NULL)
        OR (:NEW.rank_GRD_Grade IS NOT NULL AND :OLD.rank_GRD_Grade IS NULL)) THEN
        v_GRD_rank := NULL;
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
    -- values that are left as they are state nothing
    IF
        v_GRD_rank IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.SU_ID_keeper <> :OLD.SU_ID_keeper
                OR (:NEW.SU_ID_keeper IS NULL AND :OLD.SU_ID_keeper IS NOT NULL)
                OR (:NEW.SU_ID_keeper IS NOT NULL AND :OLD.SU_ID_keeper IS NULL))
        OR
            (:NEW.OB_ID_thing <> :OLD.OB_ID_thing
                OR (:NEW.OB_ID_thing IS NULL AND :OLD.OB_ID_thing IS NOT NULL)
                OR (:NEW.OB_ID_thing IS NOT NULL AND :OLD.OB_ID_thing IS NULL))
        OR
            (v_GRD_rank <> :OLD.GRD_ID_rank
                OR (v_GRD_rank IS NULL AND :OLD.GRD_ID_rank IS NOT NULL)
                OR (v_GRD_rank IS NOT NULL AND :OLD.GRD_ID_rank IS NULL))
        )
    THEN
        ip_SU_keeper_OB_thing_GRD_rank(
            p_SU_keeper => :NEW.SU_ID_keeper,
            p_OB_thing => :NEW.OB_ID_thing,
            p_GRD_rank => v_GRD_rank,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_SU_keeper_OB_thing_GRD_rank
        );
    END IF;
END ut_lSU_keeper_OB_thing_GRD_rank;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_keeper_OB_thing_GRD_rank
INSTEAD OF DELETE ON lSU_keeper_OB_thing_GRD_rank
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_keeper_OB_thing_GRD_rank x
    WHERE
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt = :OLD.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        x.SU_ID_keeper = :OLD.SU_ID_keeper
    AND
        x.OB_ID_thing = :OLD.OB_ID_thing
    ;
END dt_lSU_keeper_OB_thing_GRD_rank;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_part_SU_owner states a row of OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_part_SU_owner (
    p_OB_part IN OB_part_SU_owner.OB_ID_part%TYPE,
    p_SU_owner IN OB_part_SU_owner.SU_ID_owner%TYPE,
    p_metadata IN OB_part_SU_owner.Metadata_OB_part_SU_owner%TYPE
)
IS
    v_metadata OB_part_SU_owner.Metadata_OB_part_SU_owner%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            OB_part_SU_owner x
        WHERE
            x.OB_ID_part = p_OB_part
        AND
            x.SU_ID_owner = p_SU_owner
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            OB_part_SU_owner x
        WHERE
            x.OB_ID_part = p_OB_part
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_part_SU_owner for: '
            || p_OB_part
        );
    END LOOP;
    INSERT INTO OB_part_SU_owner (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    )
    VALUES (
        v_metadata,
        p_OB_part,
        p_SU_owner
    );
END ip_OB_part_SU_owner;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lOB_part_SU_owner
INSTEAD OF INSERT ON lOB_part_SU_owner
FOR EACH ROW
BEGIN
    ip_OB_part_SU_owner(
        p_OB_part => :NEW.OB_ID_part,
        p_SU_owner => :NEW.SU_ID_owner,
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
BEGIN
    IF (:NEW.OB_ID_part <> :OLD.OB_ID_part
        OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
        OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column OB_ID_part is not updatable.');
    END IF;
    -- values that are left as they are state nothing
    IF
        :NEW.SU_ID_owner IS NOT NULL
    AND
        (
            (:NEW.OB_ID_part <> :OLD.OB_ID_part
                OR (:NEW.OB_ID_part IS NULL AND :OLD.OB_ID_part IS NOT NULL)
                OR (:NEW.OB_ID_part IS NOT NULL AND :OLD.OB_ID_part IS NULL))
        OR
            (:NEW.SU_ID_owner <> :OLD.SU_ID_owner
                OR (:NEW.SU_ID_owner IS NULL AND :OLD.SU_ID_owner IS NOT NULL)
                OR (:NEW.SU_ID_owner IS NOT NULL AND :OLD.SU_ID_owner IS NULL))
        )
    THEN
        ip_OB_part_SU_owner(
            p_OB_part => :NEW.OB_ID_part,
            p_SU_owner => :NEW.SU_ID_owner,
            p_metadata => :NEW.Metadata_OB_part_SU_owner
        );
    END IF;
    -- a null in every value of a deletable tie moves what the identifiers have to the deletion table
    IF :NEW.Deletable_OB_part_SU_owner = 1
    AND :NEW.SU_ID_owner IS NULL
    THEN
        INSERT INTO OB_part_SU_owner_Deleted (
            OB_ID_part,
            SU_ID_owner,
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_Deleted
        )
        SELECT
            x.OB_ID_part,
            x.SU_ID_owner,
            x.Metadata_OB_part_SU_owner,
            v_now
        FROM
            OB_part_SU_owner x
        WHERE
            x.OB_ID_part = :OLD.OB_ID_part
        ;
        DELETE FROM
            OB_part_SU_owner
        WHERE
            OB_ID_part = :OLD.OB_ID_part
        ;
    END IF;
END ut_lOB_part_SU_owner;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lOB_part_SU_owner
INSTEAD OF DELETE ON lOB_part_SU_owner
FOR EACH ROW
BEGIN
    DELETE FROM
        OB_part_SU_owner x
    WHERE
        x.OB_ID_part = :OLD.OB_ID_part
    ;
END dt_lOB_part_SU_owner;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_partner_SU_with states a row of SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_partner_SU_with (
    p_SU_partner IN SU_partner_SU_with.SU_ID_partner%TYPE,
    p_SU_with IN SU_partner_SU_with.SU_ID_with%TYPE,
    p_changing IN SU_partner_SU_with.SU_partner_SU_with_ChangedAt%TYPE,
    p_metadata IN SU_partner_SU_with.Metadata_SU_partner_SU_with%TYPE
)
IS
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_changing SU_partner_SU_with.SU_partner_SU_with_ChangedAt%TYPE;
    v_metadata SU_partner_SU_with.Metadata_SU_partner_SU_with%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            SU_partner_SU_with x
        WHERE
            x.SU_ID_partner = p_SU_partner
        AND
            x.SU_ID_with = p_SU_with
        AND
            x.SU_partner_SU_with_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO SU_partner_SU_with (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    VALUES (
        v_metadata,
        v_changing,
        p_SU_partner,
        p_SU_with
    );
END ip_SU_partner_SU_with;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lSU_partner_SU_with
INSTEAD OF INSERT ON lSU_partner_SU_with
FOR EACH ROW
BEGIN
    ip_SU_partner_SU_with(
        p_SU_partner => :NEW.SU_ID_partner,
        p_SU_with => :NEW.SU_ID_with,
        p_changing => :NEW.SU_partner_SU_with_ChangedAt,
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
    v_changed NUMBER(1);
    v_changing SU_partner_SU_with.SU_partner_SU_with_ChangedAt%TYPE;
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.SU_partner_SU_with_ChangedAt <> :OLD.SU_partner_SU_with_ChangedAt
        OR (:NEW.SU_partner_SU_with_ChangedAt IS NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NOT NULL)
        OR (:NEW.SU_partner_SU_with_ChangedAt IS NOT NULL AND :OLD.SU_partner_SU_with_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.SU_partner_SU_with_ChangedAt ELSE v_now END;
    -- values that are left as they are state nothing
    IF
        :NEW.SU_ID_partner IS NOT NULL
    AND
        :NEW.SU_ID_with IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.SU_ID_partner <> :OLD.SU_ID_partner
                OR (:NEW.SU_ID_partner IS NULL AND :OLD.SU_ID_partner IS NOT NULL)
                OR (:NEW.SU_ID_partner IS NOT NULL AND :OLD.SU_ID_partner IS NULL))
        OR
            (:NEW.SU_ID_with <> :OLD.SU_ID_with
                OR (:NEW.SU_ID_with IS NULL AND :OLD.SU_ID_with IS NOT NULL)
                OR (:NEW.SU_ID_with IS NOT NULL AND :OLD.SU_ID_with IS NULL))
        )
    THEN
        ip_SU_partner_SU_with(
            p_SU_partner => :NEW.SU_ID_partner,
            p_SU_with => :NEW.SU_ID_with,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_SU_partner_SU_with
        );
    END IF;
END ut_lSU_partner_SU_with;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lSU_partner_SU_with
INSTEAD OF DELETE ON lSU_partner_SU_with
FOR EACH ROW
BEGIN
    DELETE FROM
        SU_partner_SU_with x
    WHERE
        x.SU_partner_SU_with_ChangedAt = :OLD.SU_partner_SU_with_ChangedAt
    AND
        x.SU_ID_partner = :OLD.SU_ID_partner
    AND
        x.SU_ID_with = :OLD.SU_ID_with
    ;
END dt_lSU_partner_SU_with;
/
