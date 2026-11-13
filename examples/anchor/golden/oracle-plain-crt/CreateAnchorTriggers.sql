-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the posit and annex tables of the attributes in a consistent way,
-- through the insert procedures of the attributes (ip_<attribute>, see the attribute triggers, which keep the posit and
-- annex tables). Default values are used for some columns if not provided by the corresponding SQL statements: the positor
-- is 0, the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the insert procedures of the attributes see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lST_Stage
INSTEAD OF INSERT ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO ST_Stage (
            ST_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
        ip_ST_NAM_Stage_Name(
            p_owner => v_id,
            p_value => :NEW.ST_NAM_Stage_Name,
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_NAM_Reliability, :NEW.Reliability, 1)
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        ip_ST_LOC_Stage_Location(
            p_owner => v_id,
            p_value => :NEW.ST_LOC_Stage_Location,
            p_positor => COALESCE(:NEW.ST_LOC_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_LOC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_LOC_Reliability, :NEW.Reliability, 1)
        );
    END IF;
    v_AVG := :NEW.UTL_ID;
    IF v_AVG IS NULL AND :NEW.UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        ip_ST_AVG_Stage_Average(
            p_owner => v_id,
            p_value => v_AVG,
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.ST_AVG_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_AVG_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_AVG_Reliability, :NEW.Reliability, 1)
        );
    END IF;
    v_MIN := :NEW.UTL_ID;
    IF v_MIN IS NULL AND :NEW.UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        ip_ST_MIN_Stage_Minimum(
            p_owner => v_id,
            p_value => v_MIN,
            p_positor => COALESCE(:NEW.ST_MIN_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.ST_MIN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.ST_MIN_Reliability, :NEW.Reliability, 1)
        );
    END IF;
END it_lST_Stage;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lST_Stage
INSTEAD OF UPDATE ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_AVG number(3);
    v_AVG_changing timestamp;
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    -- ST_NAM_Stage_Name
    IF (:NEW.ST_NAM_ID <> :OLD.ST_NAM_ID
        OR (:NEW.ST_NAM_ID IS NULL AND :OLD.ST_NAM_ID IS NOT NULL)
        OR (:NEW.ST_NAM_ID IS NOT NULL AND :OLD.ST_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_NAM_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_NAM_Stage_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_NAM_Reliability <> :OLD.ST_NAM_Reliability
        OR (:NEW.ST_NAM_Reliability IS NULL AND :OLD.ST_NAM_Reliability IS NOT NULL)
        OR (:NEW.ST_NAM_Reliability IS NOT NULL AND :OLD.ST_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_NAM_Reliability;
    END IF;
    IF (:NEW.ST_NAM_Positor <> :OLD.ST_NAM_Positor
        OR (:NEW.ST_NAM_Positor IS NULL AND :OLD.ST_NAM_Positor IS NOT NULL)
        OR (:NEW.ST_NAM_Positor IS NOT NULL AND :OLD.ST_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_NAM_PositedAt <> :OLD.ST_NAM_PositedAt
        OR (:NEW.ST_NAM_PositedAt IS NULL AND :OLD.ST_NAM_PositedAt IS NOT NULL)
        OR (:NEW.ST_NAM_PositedAt IS NOT NULL AND :OLD.ST_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.ST_NAM_Stage_Name IS NULL THEN
        v_positing := :NEW.ST_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_NAM_Stage_Name <> :OLD.ST_NAM_Stage_Name
        OR (:NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL)
        OR (:NEW.ST_NAM_Stage_Name IS NOT NULL AND :OLD.ST_NAM_Stage_Name IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.ST_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_NAM_Stage_Name IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_NAM_Reliability IS NULL
            OR :OLD.ST_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_NAM_Positor IS NULL
            OR :OLD.ST_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_ST_NAM_Stage_Name(
                    p_owner => :NEW.ST_ID,
                    p_value => :NEW.ST_NAM_Stage_Name,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL THEN
            ip_ST_NAM_Stage_Name(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_NAM_Stage_Name,
                p_changing => :OLD.ST_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
    -- ST_LOC_Stage_Location
    IF (:NEW.ST_LOC_ID <> :OLD.ST_LOC_ID
        OR (:NEW.ST_LOC_ID IS NULL AND :OLD.ST_LOC_ID IS NOT NULL)
        OR (:NEW.ST_LOC_ID IS NOT NULL AND :OLD.ST_LOC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_LOC_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_LOC_Stage_Location, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_LOC_Reliability <> :OLD.ST_LOC_Reliability
        OR (:NEW.ST_LOC_Reliability IS NULL AND :OLD.ST_LOC_Reliability IS NOT NULL)
        OR (:NEW.ST_LOC_Reliability IS NOT NULL AND :OLD.ST_LOC_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_LOC_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_LOC_Reliability;
    END IF;
    IF (:NEW.ST_LOC_Positor <> :OLD.ST_LOC_Positor
        OR (:NEW.ST_LOC_Positor IS NULL AND :OLD.ST_LOC_Positor IS NOT NULL)
        OR (:NEW.ST_LOC_Positor IS NOT NULL AND :OLD.ST_LOC_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_LOC_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_LOC_PositedAt <> :OLD.ST_LOC_PositedAt
        OR (:NEW.ST_LOC_PositedAt IS NULL AND :OLD.ST_LOC_PositedAt IS NOT NULL)
        OR (:NEW.ST_LOC_PositedAt IS NOT NULL AND :OLD.ST_LOC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_LOC_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.ST_LOC_Stage_Location <> :OLD.ST_LOC_Stage_Location
        OR (:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.ST_LOC_Stage_Location IS NULL
            OR v_positing_diff
            OR :OLD.ST_LOC_Reliability IS NULL
            OR :OLD.ST_LOC_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_LOC_Positor IS NULL
            OR :OLD.ST_LOC_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_ST_LOC_Stage_Location(
                    p_owner => :NEW.ST_ID,
                    p_value => :NEW.ST_LOC_Stage_Location,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL THEN
            ip_ST_LOC_Stage_Location(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.ST_LOC_Stage_Location,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
    -- ST_AVG_Stage_Average
    IF (:NEW.ST_AVG_ID <> :OLD.ST_AVG_ID
        OR (:NEW.ST_AVG_ID IS NULL AND :OLD.ST_AVG_ID IS NOT NULL)
        OR (:NEW.ST_AVG_ID IS NOT NULL AND :OLD.ST_AVG_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_AVG_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_AVG_Stage_Average, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_AVG_Reliability <> :OLD.ST_AVG_Reliability
        OR (:NEW.ST_AVG_Reliability IS NULL AND :OLD.ST_AVG_Reliability IS NOT NULL)
        OR (:NEW.ST_AVG_Reliability IS NOT NULL AND :OLD.ST_AVG_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_AVG_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_AVG_Reliability;
    END IF;
    IF (:NEW.ST_AVG_Positor <> :OLD.ST_AVG_Positor
        OR (:NEW.ST_AVG_Positor IS NULL AND :OLD.ST_AVG_Positor IS NOT NULL)
        OR (:NEW.ST_AVG_Positor IS NOT NULL AND :OLD.ST_AVG_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_AVG_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_AVG_PositedAt <> :OLD.ST_AVG_PositedAt
        OR (:NEW.ST_AVG_PositedAt IS NULL AND :OLD.ST_AVG_PositedAt IS NOT NULL)
        OR (:NEW.ST_AVG_PositedAt IS NOT NULL AND :OLD.ST_AVG_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_AVG_PositedAt;
    ELSIF v_changing_diff AND :NEW.UTL_ID IS NULL THEN
        v_positing := :NEW.ST_AVG_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.UTL_ID <> :OLD.UTL_ID
        OR (:NEW.UTL_ID IS NULL AND :OLD.UTL_ID IS NOT NULL)
        OR (:NEW.UTL_ID IS NOT NULL AND :OLD.UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_knot_diff := CASE WHEN (:NEW.UTL_Utilization <> :OLD.UTL_Utilization
        OR (:NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL)
        OR (:NEW.UTL_Utilization IS NOT NULL AND :OLD.UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_AVG := :NEW.UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_AVG := NULL;
        IF :NEW.UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_AVG := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSIF :OLD.UTL_ID = v_AVG THEN
            v_AVG_changing := :NEW.ST_AVG_ChangedAt;
        ELSE
            v_AVG_changing := v_now;
        END IF;
        IF v_AVG IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.UTL_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.ST_AVG_Reliability IS NULL
            OR :OLD.ST_AVG_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_AVG_Positor IS NULL
            OR :OLD.ST_AVG_Positor <> v_positor
            OR :OLD.UTL_ID <> v_AVG
            THEN
                ip_ST_AVG_Stage_Average(
                    p_owner => :NEW.ST_ID,
                    p_value => v_AVG,
                    p_changing => v_AVG_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.UTL_ID IS NOT NULL AND (
            :NEW.UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL
            )
        ) THEN
            ip_ST_AVG_Stage_Average(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.UTL_ID,
                p_changing => :OLD.ST_AVG_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
    -- ST_MIN_Stage_Minimum
    IF (:NEW.ST_MIN_ID <> :OLD.ST_MIN_ID
        OR (:NEW.ST_MIN_ID IS NULL AND :OLD.ST_MIN_ID IS NOT NULL)
        OR (:NEW.ST_MIN_ID IS NOT NULL AND :OLD.ST_MIN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_MIN_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of ST_MIN_Stage_Minimum, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.ST_MIN_Reliability <> :OLD.ST_MIN_Reliability
        OR (:NEW.ST_MIN_Reliability IS NULL AND :OLD.ST_MIN_Reliability IS NOT NULL)
        OR (:NEW.ST_MIN_Reliability IS NOT NULL AND :OLD.ST_MIN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.ST_MIN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.ST_MIN_Reliability;
    END IF;
    IF (:NEW.ST_MIN_Positor <> :OLD.ST_MIN_Positor
        OR (:NEW.ST_MIN_Positor IS NULL AND :OLD.ST_MIN_Positor IS NOT NULL)
        OR (:NEW.ST_MIN_Positor IS NOT NULL AND :OLD.ST_MIN_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.ST_MIN_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.ST_MIN_PositedAt <> :OLD.ST_MIN_PositedAt
        OR (:NEW.ST_MIN_PositedAt IS NULL AND :OLD.ST_MIN_PositedAt IS NOT NULL)
        OR (:NEW.ST_MIN_PositedAt IS NOT NULL AND :OLD.ST_MIN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.ST_MIN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.UTL_ID <> :OLD.UTL_ID
        OR (:NEW.UTL_ID IS NULL AND :OLD.UTL_ID IS NOT NULL)
        OR (:NEW.UTL_ID IS NOT NULL AND :OLD.UTL_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_knot_diff := CASE WHEN (:NEW.UTL_Utilization <> :OLD.UTL_Utilization
        OR (:NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL)
        OR (:NEW.UTL_Utilization IS NOT NULL AND :OLD.UTL_Utilization IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_MIN := :NEW.UTL_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_MIN := NULL;
        IF :NEW.UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_MIN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.UTL_ID IS NULL
            OR v_positing_diff
            OR :OLD.ST_MIN_Reliability IS NULL
            OR :OLD.ST_MIN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.ST_MIN_Positor IS NULL
            OR :OLD.ST_MIN_Positor <> v_positor
            OR :OLD.UTL_ID <> v_MIN
            THEN
                ip_ST_MIN_Stage_Minimum(
                    p_owner => :NEW.ST_ID,
                    p_value => v_MIN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.UTL_ID IS NOT NULL AND (
            :NEW.UTL_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL
            )
        ) THEN
            ip_ST_MIN_Stage_Minimum(
                p_owner => :OLD.ST_ID,
                p_value => :OLD.UTL_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_Stage
INSTEAD OF DELETE ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of ST_NAM_Stage_Name is retracted
    INSERT INTO ST_NAM_Stage_Name_Annex (
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        :OLD.ST_NAM_ID,
        COALESCE(:OLD.ST_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_NAM_Stage_Name_Annex x
            WHERE
                x.ST_NAM_ID = :OLD.ST_NAM_ID
            AND
                x.ST_NAM_Positor = COALESCE(:OLD.ST_NAM_Positor, :OLD.Positor, 0)
            AND
                x.ST_NAM_PositedAt = v_now
        );
    -- what is shown of ST_LOC_Stage_Location is retracted
    INSERT INTO ST_LOC_Stage_Location_Annex (
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        :OLD.ST_LOC_ID,
        COALESCE(:OLD.ST_LOC_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_LOC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_LOC_Stage_Location_Annex x
            WHERE
                x.ST_LOC_ID = :OLD.ST_LOC_ID
            AND
                x.ST_LOC_Positor = COALESCE(:OLD.ST_LOC_Positor, :OLD.Positor, 0)
            AND
                x.ST_LOC_PositedAt = v_now
        );
    -- what is shown of ST_AVG_Stage_Average is retracted
    INSERT INTO ST_AVG_Stage_Average_Annex (
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        :OLD.ST_AVG_ID,
        COALESCE(:OLD.ST_AVG_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_AVG_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_AVG_Stage_Average_Annex x
            WHERE
                x.ST_AVG_ID = :OLD.ST_AVG_ID
            AND
                x.ST_AVG_Positor = COALESCE(:OLD.ST_AVG_Positor, :OLD.Positor, 0)
            AND
                x.ST_AVG_PositedAt = v_now
        );
    -- what is shown of ST_MIN_Stage_Minimum is retracted
    INSERT INTO ST_MIN_Stage_Minimum_Annex (
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        :OLD.ST_MIN_ID,
        COALESCE(:OLD.ST_MIN_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.ST_MIN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                ST_MIN_Stage_Minimum_Annex x
            WHERE
                x.ST_MIN_ID = :OLD.ST_MIN_ID
            AND
                x.ST_MIN_Positor = COALESCE(:OLD.ST_MIN_Positor, :OLD.Positor, 0)
            AND
                x.ST_MIN_PositedAt = v_now
        );
END dt_lST_Stage;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_Actor
INSTEAD OF INSERT ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO AC_Actor (
            AC_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
        ip_AC_NAM_Actor_Name(
            p_owner => v_id,
            p_value => :NEW.AC_NAM_Actor_Name,
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.AC_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_NAM_Reliability, :NEW.Reliability, 1)
        );
    END IF;
    v_GEN := :NEW.GEN_ID;
    IF v_GEN IS NULL AND :NEW.GEN_Gender IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                GEN_Gender k
            WHERE
                k.GEN_Gender = :NEW.GEN_Gender
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        ip_AC_GEN_Actor_Gender(
            p_owner => v_id,
            p_value => v_GEN,
            p_positor => COALESCE(:NEW.AC_GEN_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.AC_GEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_GEN_Reliability, :NEW.Reliability, 1)
        );
    END IF;
    v_PLV := :NEW.PLV_ID;
    IF v_PLV IS NULL AND :NEW.PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        ip_AC_PLV_Actor_ProfessionalLevel(
            p_owner => v_id,
            p_value => v_PLV,
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.AC_PLV_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.AC_PLV_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.AC_PLV_Reliability, :NEW.Reliability, 1)
        );
    END IF;
END it_lAC_Actor;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_Actor
INSTEAD OF UPDATE ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_NAM_changing timestamp;
    v_GEN number(3);
    v_PLV number(3);
    v_PLV_changing timestamp;
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    -- AC_NAM_Actor_Name
    IF (:NEW.AC_NAM_ID <> :OLD.AC_NAM_ID
        OR (:NEW.AC_NAM_ID IS NULL AND :OLD.AC_NAM_ID IS NOT NULL)
        OR (:NEW.AC_NAM_ID IS NOT NULL AND :OLD.AC_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_NAM_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_NAM_Actor_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_NAM_Reliability <> :OLD.AC_NAM_Reliability
        OR (:NEW.AC_NAM_Reliability IS NULL AND :OLD.AC_NAM_Reliability IS NOT NULL)
        OR (:NEW.AC_NAM_Reliability IS NOT NULL AND :OLD.AC_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_NAM_Reliability;
    END IF;
    IF (:NEW.AC_NAM_Positor <> :OLD.AC_NAM_Positor
        OR (:NEW.AC_NAM_Positor IS NULL AND :OLD.AC_NAM_Positor IS NOT NULL)
        OR (:NEW.AC_NAM_Positor IS NOT NULL AND :OLD.AC_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_NAM_PositedAt <> :OLD.AC_NAM_PositedAt
        OR (:NEW.AC_NAM_PositedAt IS NULL AND :OLD.AC_NAM_PositedAt IS NOT NULL)
        OR (:NEW.AC_NAM_PositedAt IS NOT NULL AND :OLD.AC_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_NAM_PositedAt;
    ELSIF v_changing_diff AND :NEW.AC_NAM_Actor_Name IS NULL THEN
        v_positing := :NEW.AC_NAM_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.AC_NAM_Actor_Name <> :OLD.AC_NAM_Actor_Name
        OR (:NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL)
        OR (:NEW.AC_NAM_Actor_Name IS NOT NULL AND :OLD.AC_NAM_Actor_Name IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_NAM_changing := :NEW.AC_NAM_ChangedAt;
        ELSE
            v_NAM_changing := v_now;
        END IF;
        IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.AC_NAM_Actor_Name IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_NAM_Reliability IS NULL
            OR :OLD.AC_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_NAM_Positor IS NULL
            OR :OLD.AC_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_AC_NAM_Actor_Name(
                    p_owner => :NEW.AC_ID,
                    p_value => :NEW.AC_NAM_Actor_Name,
                    p_changing => v_NAM_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL THEN
            ip_AC_NAM_Actor_Name(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.AC_NAM_Actor_Name,
                p_changing => :OLD.AC_NAM_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
    -- AC_GEN_Actor_Gender
    IF (:NEW.AC_GEN_ID <> :OLD.AC_GEN_ID
        OR (:NEW.AC_GEN_ID IS NULL AND :OLD.AC_GEN_ID IS NOT NULL)
        OR (:NEW.AC_GEN_ID IS NOT NULL AND :OLD.AC_GEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_GEN_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_GEN_Actor_Gender, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_GEN_Reliability <> :OLD.AC_GEN_Reliability
        OR (:NEW.AC_GEN_Reliability IS NULL AND :OLD.AC_GEN_Reliability IS NOT NULL)
        OR (:NEW.AC_GEN_Reliability IS NOT NULL AND :OLD.AC_GEN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_GEN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_GEN_Reliability;
    END IF;
    IF (:NEW.AC_GEN_Positor <> :OLD.AC_GEN_Positor
        OR (:NEW.AC_GEN_Positor IS NULL AND :OLD.AC_GEN_Positor IS NOT NULL)
        OR (:NEW.AC_GEN_Positor IS NOT NULL AND :OLD.AC_GEN_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_GEN_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_GEN_PositedAt <> :OLD.AC_GEN_PositedAt
        OR (:NEW.AC_GEN_PositedAt IS NULL AND :OLD.AC_GEN_PositedAt IS NOT NULL)
        OR (:NEW.AC_GEN_PositedAt IS NOT NULL AND :OLD.AC_GEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_GEN_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.GEN_ID <> :OLD.GEN_ID
        OR (:NEW.GEN_ID IS NULL AND :OLD.GEN_ID IS NOT NULL)
        OR (:NEW.GEN_ID IS NOT NULL AND :OLD.GEN_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_knot_diff := CASE WHEN (:NEW.GEN_Gender <> :OLD.GEN_Gender
        OR (:NEW.GEN_Gender IS NULL AND :OLD.GEN_Gender IS NOT NULL)
        OR (:NEW.GEN_Gender IS NOT NULL AND :OLD.GEN_Gender IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_GEN := :NEW.GEN_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_GEN := NULL;
        IF :NEW.GEN_Gender IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    GEN_Gender k
                WHERE
                    k.GEN_Gender = :NEW.GEN_Gender
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF v_GEN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.GEN_ID IS NULL
            OR v_positing_diff
            OR :OLD.AC_GEN_Reliability IS NULL
            OR :OLD.AC_GEN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_GEN_Positor IS NULL
            OR :OLD.AC_GEN_Positor <> v_positor
            OR :OLD.GEN_ID <> v_GEN
            THEN
                ip_AC_GEN_Actor_Gender(
                    p_owner => :NEW.AC_ID,
                    p_value => v_GEN,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.GEN_ID IS NOT NULL AND (
            :NEW.GEN_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.GEN_Gender IS NULL AND :OLD.GEN_Gender IS NOT NULL
            )
        ) THEN
            ip_AC_GEN_Actor_Gender(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.GEN_ID,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
    -- AC_PLV_Actor_ProfessionalLevel
    IF (:NEW.AC_PLV_ID <> :OLD.AC_PLV_ID
        OR (:NEW.AC_PLV_ID IS NULL AND :OLD.AC_PLV_ID IS NOT NULL)
        OR (:NEW.AC_PLV_ID IS NOT NULL AND :OLD.AC_PLV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_PLV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of AC_PLV_Actor_ProfessionalLevel, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.AC_PLV_Reliability <> :OLD.AC_PLV_Reliability
        OR (:NEW.AC_PLV_Reliability IS NULL AND :OLD.AC_PLV_Reliability IS NOT NULL)
        OR (:NEW.AC_PLV_Reliability IS NOT NULL AND :OLD.AC_PLV_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.AC_PLV_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.AC_PLV_Reliability;
    END IF;
    IF (:NEW.AC_PLV_Positor <> :OLD.AC_PLV_Positor
        OR (:NEW.AC_PLV_Positor IS NULL AND :OLD.AC_PLV_Positor IS NOT NULL)
        OR (:NEW.AC_PLV_Positor IS NOT NULL AND :OLD.AC_PLV_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.AC_PLV_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.AC_PLV_PositedAt <> :OLD.AC_PLV_PositedAt
        OR (:NEW.AC_PLV_PositedAt IS NULL AND :OLD.AC_PLV_PositedAt IS NOT NULL)
        OR (:NEW.AC_PLV_PositedAt IS NOT NULL AND :OLD.AC_PLV_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.AC_PLV_PositedAt;
    ELSIF v_changing_diff AND :NEW.PLV_ID IS NULL THEN
        v_positing := :NEW.AC_PLV_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PLV_ID <> :OLD.PLV_ID
        OR (:NEW.PLV_ID IS NULL AND :OLD.PLV_ID IS NOT NULL)
        OR (:NEW.PLV_ID IS NOT NULL AND :OLD.PLV_ID IS NULL)) THEN TRUE ELSE FALSE END;
    v_knot_diff := CASE WHEN (:NEW.PLV_ProfessionalLevel <> :OLD.PLV_ProfessionalLevel
        OR (:NEW.PLV_ProfessionalLevel IS NULL AND :OLD.PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.PLV_ProfessionalLevel IS NOT NULL AND :OLD.PLV_ProfessionalLevel IS NULL)) THEN TRUE ELSE FALSE END;
    -- the identity of the knot value, given as it is or looked up from the value
    v_PLV := :NEW.PLV_ID;
    IF NOT v_value_diff AND v_knot_diff THEN
        v_PLV := NULL;
        IF :NEW.PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.PLV_ProfessionalLevel, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_PLV := kv.PLV_ID;
            END LOOP;
        END IF;
    END IF;
    IF v_value_diff OR v_knot_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSIF :OLD.PLV_ID = v_PLV THEN
            v_PLV_changing := :NEW.AC_PLV_ChangedAt;
        ELSE
            v_PLV_changing := v_now;
        END IF;
        IF v_PLV IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PLV_ID IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.AC_PLV_Reliability IS NULL
            OR :OLD.AC_PLV_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.AC_PLV_Positor IS NULL
            OR :OLD.AC_PLV_Positor <> v_positor
            OR :OLD.PLV_ID <> v_PLV
            THEN
                ip_AC_PLV_Actor_ProfessionalLevel(
                    p_owner => :NEW.AC_ID,
                    p_value => v_PLV,
                    p_changing => v_PLV_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :OLD.PLV_ID IS NOT NULL AND (
            :NEW.PLV_ID IS NULL OR (
                NOT v_value_diff
                AND :NEW.PLV_ProfessionalLevel IS NULL AND :OLD.PLV_ProfessionalLevel IS NOT NULL
            )
        ) THEN
            ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => :OLD.AC_ID,
                p_value => :OLD.PLV_ID,
                p_changing => :OLD.AC_PLV_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
END ut_lAC_Actor;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_Actor
INSTEAD OF DELETE ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of AC_NAM_Actor_Name is retracted
    INSERT INTO AC_NAM_Actor_Name_Annex (
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        :OLD.AC_NAM_ID,
        COALESCE(:OLD.AC_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_NAM_Actor_Name_Annex x
            WHERE
                x.AC_NAM_ID = :OLD.AC_NAM_ID
            AND
                x.AC_NAM_Positor = COALESCE(:OLD.AC_NAM_Positor, :OLD.Positor, 0)
            AND
                x.AC_NAM_PositedAt = v_now
        );
    -- what is shown of AC_GEN_Actor_Gender is retracted
    INSERT INTO AC_GEN_Actor_Gender_Annex (
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        :OLD.AC_GEN_ID,
        COALESCE(:OLD.AC_GEN_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_GEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_GEN_Actor_Gender_Annex x
            WHERE
                x.AC_GEN_ID = :OLD.AC_GEN_ID
            AND
                x.AC_GEN_Positor = COALESCE(:OLD.AC_GEN_Positor, :OLD.Positor, 0)
            AND
                x.AC_GEN_PositedAt = v_now
        );
    -- what is shown of AC_PLV_Actor_ProfessionalLevel is retracted
    INSERT INTO AC_PLV_Actor_ProfessionalLevel_Annex (
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        :OLD.AC_PLV_ID,
        COALESCE(:OLD.AC_PLV_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.AC_PLV_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                AC_PLV_Actor_ProfessionalLevel_Annex x
            WHERE
                x.AC_PLV_ID = :OLD.AC_PLV_ID
            AND
                x.AC_PLV_Positor = COALESCE(:OLD.AC_PLV_Positor, :OLD.Positor, 0)
            AND
                x.AC_PLV_PositedAt = v_now
        );
END dt_lAC_Actor;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_Program
INSTEAD OF INSERT ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO PR_Program (
            PR_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
        ip_PR_NAM_Program_Name(
            p_owner => v_id,
            p_value => :NEW.PR_NAM_Program_Name,
            p_positor => COALESCE(:NEW.PR_NAM_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.PR_NAM_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_NAM_Reliability, :NEW.Reliability, 1)
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        ip_PR_LEN_Program_Length(
            p_owner => v_id,
            p_value => :NEW.PR_LEN_Program_Length,
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.PR_LEN_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.PR_LEN_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.PR_LEN_Reliability, :NEW.Reliability, 1)
        );
    END IF;
END it_lPR_Program;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lPR_Program
INSTEAD OF UPDATE ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor number(3);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_LEN_changing date;
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    -- PR_NAM_Program_Name
    IF (:NEW.PR_NAM_ID <> :OLD.PR_NAM_ID
        OR (:NEW.PR_NAM_ID IS NULL AND :OLD.PR_NAM_ID IS NOT NULL)
        OR (:NEW.PR_NAM_ID IS NOT NULL AND :OLD.PR_NAM_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_NAM_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_NAM_Program_Name, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_NAM_Reliability <> :OLD.PR_NAM_Reliability
        OR (:NEW.PR_NAM_Reliability IS NULL AND :OLD.PR_NAM_Reliability IS NOT NULL)
        OR (:NEW.PR_NAM_Reliability IS NOT NULL AND :OLD.PR_NAM_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_NAM_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.PR_NAM_Reliability;
    END IF;
    IF (:NEW.PR_NAM_Positor <> :OLD.PR_NAM_Positor
        OR (:NEW.PR_NAM_Positor IS NULL AND :OLD.PR_NAM_Positor IS NOT NULL)
        OR (:NEW.PR_NAM_Positor IS NOT NULL AND :OLD.PR_NAM_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_NAM_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_NAM_PositedAt <> :OLD.PR_NAM_PositedAt
        OR (:NEW.PR_NAM_PositedAt IS NULL AND :OLD.PR_NAM_PositedAt IS NOT NULL)
        OR (:NEW.PR_NAM_PositedAt IS NOT NULL AND :OLD.PR_NAM_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_NAM_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_NAM_Program_Name <> :OLD.PR_NAM_Program_Name
        OR (:NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL)
        OR (:NEW.PR_NAM_Program_Name IS NOT NULL AND :OLD.PR_NAM_Program_Name IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_NAM_Program_Name IS NULL
            OR v_positing_diff
            OR :OLD.PR_NAM_Reliability IS NULL
            OR :OLD.PR_NAM_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.PR_NAM_Positor IS NULL
            OR :OLD.PR_NAM_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_PR_NAM_Program_Name(
                    p_owner => :NEW.PR_ID,
                    p_value => :NEW.PR_NAM_Program_Name,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL THEN
            ip_PR_NAM_Program_Name(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_NAM_Program_Name,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
    -- PR_LEN_Program_Length
    IF (:NEW.PR_LEN_ID <> :OLD.PR_LEN_ID
        OR (:NEW.PR_LEN_ID IS NULL AND :OLD.PR_LEN_ID IS NOT NULL)
        OR (:NEW.PR_LEN_ID IS NOT NULL AND :OLD.PR_LEN_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_LEN_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of PR_LEN_Program_Length, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.PR_LEN_Reliability <> :OLD.PR_LEN_Reliability
        OR (:NEW.PR_LEN_Reliability IS NULL AND :OLD.PR_LEN_Reliability IS NOT NULL)
        OR (:NEW.PR_LEN_Reliability IS NOT NULL AND :OLD.PR_LEN_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.PR_LEN_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.PR_LEN_Reliability;
    END IF;
    IF (:NEW.PR_LEN_Positor <> :OLD.PR_LEN_Positor
        OR (:NEW.PR_LEN_Positor IS NULL AND :OLD.PR_LEN_Positor IS NOT NULL)
        OR (:NEW.PR_LEN_Positor IS NOT NULL AND :OLD.PR_LEN_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.PR_LEN_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.PR_LEN_PositedAt <> :OLD.PR_LEN_PositedAt
        OR (:NEW.PR_LEN_PositedAt IS NULL AND :OLD.PR_LEN_PositedAt IS NOT NULL)
        OR (:NEW.PR_LEN_PositedAt IS NOT NULL AND :OLD.PR_LEN_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.PR_LEN_PositedAt;
    ELSIF v_changing_diff AND :NEW.PR_LEN_Program_Length IS NULL THEN
        v_positing := :NEW.PR_LEN_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.PR_LEN_Program_Length <> :OLD.PR_LEN_Program_Length
        OR (:NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL)
        OR (:NEW.PR_LEN_Program_Length IS NOT NULL AND :OLD.PR_LEN_Program_Length IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_LEN_changing := :NEW.PR_LEN_ChangedAt;
        ELSE
            v_LEN_changing := v_now;
        END IF;
        IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.PR_LEN_Program_Length IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.PR_LEN_Reliability IS NULL
            OR :OLD.PR_LEN_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.PR_LEN_Positor IS NULL
            OR :OLD.PR_LEN_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_PR_LEN_Program_Length(
                    p_owner => :NEW.PR_ID,
                    p_value => :NEW.PR_LEN_Program_Length,
                    p_changing => v_LEN_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL THEN
            ip_PR_LEN_Program_Length(
                p_owner => :OLD.PR_ID,
                p_value => :OLD.PR_LEN_Program_Length,
                p_changing => :OLD.PR_LEN_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0
            );
        END IF;
    END IF;
END ut_lPR_Program;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lPR_Program
INSTEAD OF DELETE ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown of PR_NAM_Program_Name is retracted
    INSERT INTO PR_NAM_Program_Name_Annex (
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        :OLD.PR_NAM_ID,
        COALESCE(:OLD.PR_NAM_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_NAM_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                PR_NAM_Program_Name_Annex x
            WHERE
                x.PR_NAM_ID = :OLD.PR_NAM_ID
            AND
                x.PR_NAM_Positor = COALESCE(:OLD.PR_NAM_Positor, :OLD.Positor, 0)
            AND
                x.PR_NAM_PositedAt = v_now
        );
    -- what is shown of PR_LEN_Program_Length is retracted
    INSERT INTO PR_LEN_Program_Length_Annex (
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        :OLD.PR_LEN_ID,
        COALESCE(:OLD.PR_LEN_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.PR_LEN_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                PR_LEN_Program_Length_Annex x
            WHERE
                x.PR_LEN_ID = :OLD.PR_LEN_ID
            AND
                x.PR_LEN_Positor = COALESCE(:OLD.PR_LEN_Positor, :OLD.Positor, 0)
            AND
                x.PR_LEN_PositedAt = v_now
        );
END dt_lPR_Program;
/
