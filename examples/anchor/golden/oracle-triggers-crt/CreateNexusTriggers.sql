-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
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
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lEV_Event
INSTEAD OF INSERT ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_id number(10);
BEGIN
    v_id := :NEW.EV_ID;
    IF v_id IS NULL THEN
        INSERT INTO EV_Event (
            SU_ID_for,
            Metadata_EV
        )
        VALUES (
            :NEW.SU_ID_for,
            :NEW.Metadata_EV
        )
        RETURNING EV_ID INTO v_id;
    END IF;
    IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
        ip_EV_QTY_Event_Quantity(
            p_owner => COALESCE(:NEW.EV_QTY_EV_ID, v_id),
            p_value => :NEW.EV_QTY_Event_Quantity,
            p_positor => COALESCE(:NEW.EV_QTY_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_QTY_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_QTY_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_QTY, :NEW.Metadata_EV)
        );
    END IF;
    IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
        ip_EV_PLC_Event_Place(
            p_owner => COALESCE(:NEW.EV_PLC_EV_ID, v_id),
            p_value => :NEW.EV_PLC_Event_Place,
            p_changing => COALESCE(:NEW.EV_PLC_ChangedAt, v_now),
            p_positor => COALESCE(:NEW.EV_PLC_Positor, :NEW.Positor, 0),
            p_positing => COALESCE(:NEW.EV_PLC_PositedAt, v_now),
            p_reliability => COALESCE(:NEW.EV_PLC_Reliability, :NEW.Reliability, 1),
            p_metadata => COALESCE(:NEW.Metadata_EV_PLC, :NEW.Metadata_EV)
        );
    END IF;
END it_lEV_Event;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lEV_Event
INSTEAD OF UPDATE ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
    v_positor number(5);
    v_positing timestamp;
    v_reliability number(5,2);
    v_suffix_diff BOOLEAN;
    v_positing_diff BOOLEAN;
    v_reliability_diff BOOLEAN;
    v_changing_diff BOOLEAN;
    v_value_diff BOOLEAN;
    v_knot_diff BOOLEAN;
    v_metadata number(10);
    v_nexus_meta_diff BOOLEAN;
    v_meta_diff BOOLEAN;
    v_PLC_changing timestamp;
BEGIN
    IF (:NEW.EV_ID <> :OLD.EV_ID
        OR (:NEW.EV_ID IS NULL AND :OLD.EV_ID IS NOT NULL)
        OR (:NEW.EV_ID IS NOT NULL AND :OLD.EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID is not updatable.');
    END IF;
    IF (:NEW.SU_ID_for <> :OLD.SU_ID_for
        OR (:NEW.SU_ID_for IS NULL AND :OLD.SU_ID_for IS NOT NULL)
        OR (:NEW.SU_ID_for IS NOT NULL AND :OLD.SU_ID_for IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The role column SU_ID_for is not updatable.');
    END IF;
    -- whether the reliability that is common to the attributes is set
    v_suffix_diff := CASE WHEN (:NEW.Reliability <> :OLD.Reliability
        OR (:NEW.Reliability IS NULL AND :OLD.Reliability IS NOT NULL)
        OR (:NEW.Reliability IS NOT NULL AND :OLD.Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    v_nexus_meta_diff := CASE WHEN (:NEW.Metadata_EV <> :OLD.Metadata_EV
        OR (:NEW.Metadata_EV IS NULL AND :OLD.Metadata_EV IS NOT NULL)
        OR (:NEW.Metadata_EV IS NOT NULL AND :OLD.Metadata_EV IS NULL)) THEN TRUE ELSE FALSE END;
    -- EV_QTY_Event_Quantity
    IF (:NEW.EV_QTY_ID <> :OLD.EV_QTY_ID
        OR (:NEW.EV_QTY_ID IS NULL AND :OLD.EV_QTY_ID IS NOT NULL)
        OR (:NEW.EV_QTY_ID IS NOT NULL AND :OLD.EV_QTY_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_QTY_ID is not updatable.');
    END IF;
    IF (:NEW.EV_QTY_EV_ID <> :OLD.EV_QTY_EV_ID
        OR (:NEW.EV_QTY_EV_ID IS NULL AND :OLD.EV_QTY_EV_ID IS NOT NULL)
        OR (:NEW.EV_QTY_EV_ID IS NOT NULL AND :OLD.EV_QTY_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_QTY_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_QTY_Event_Quantity, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_QTY_Reliability <> :OLD.EV_QTY_Reliability
        OR (:NEW.EV_QTY_Reliability IS NULL AND :OLD.EV_QTY_Reliability IS NOT NULL)
        OR (:NEW.EV_QTY_Reliability IS NOT NULL AND :OLD.EV_QTY_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_QTY_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_QTY_Reliability;
    END IF;
    IF (:NEW.EV_QTY_Positor <> :OLD.EV_QTY_Positor
        OR (:NEW.EV_QTY_Positor IS NULL AND :OLD.EV_QTY_Positor IS NOT NULL)
        OR (:NEW.EV_QTY_Positor IS NOT NULL AND :OLD.EV_QTY_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_QTY_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_QTY_PositedAt <> :OLD.EV_QTY_PositedAt
        OR (:NEW.EV_QTY_PositedAt IS NULL AND :OLD.EV_QTY_PositedAt IS NOT NULL)
        OR (:NEW.EV_QTY_PositedAt IS NOT NULL AND :OLD.EV_QTY_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_QTY_PositedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_QTY_Event_Quantity <> :OLD.EV_QTY_Event_Quantity
        OR (:NEW.EV_QTY_Event_Quantity IS NULL AND :OLD.EV_QTY_Event_Quantity IS NOT NULL)
        OR (:NEW.EV_QTY_Event_Quantity IS NOT NULL AND :OLD.EV_QTY_Event_Quantity IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_QTY <> :OLD.Metadata_EV_QTY
        OR (:NEW.Metadata_EV_QTY IS NULL AND :OLD.Metadata_EV_QTY IS NOT NULL)
        OR (:NEW.Metadata_EV_QTY IS NOT NULL AND :OLD.Metadata_EV_QTY IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_QTY
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        IF :NEW.EV_QTY_Event_Quantity IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_QTY_Event_Quantity IS NULL
            OR v_positing_diff
            OR :OLD.EV_QTY_Reliability IS NULL
            OR :OLD.EV_QTY_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_QTY_Positor IS NULL
            OR :OLD.EV_QTY_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_EV_QTY_Event_Quantity(
                    p_owner => COALESCE(:NEW.EV_QTY_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_QTY_Event_Quantity,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_QTY_Event_Quantity IS NULL AND :OLD.EV_QTY_Event_Quantity IS NOT NULL THEN
            ip_EV_QTY_Event_Quantity(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_QTY_Event_Quantity,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
    -- EV_PLC_Event_Place
    IF (:NEW.EV_PLC_ID <> :OLD.EV_PLC_ID
        OR (:NEW.EV_PLC_ID IS NULL AND :OLD.EV_PLC_ID IS NOT NULL)
        OR (:NEW.EV_PLC_ID IS NOT NULL AND :OLD.EV_PLC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_PLC_ID is not updatable.');
    END IF;
    IF (:NEW.EV_PLC_EV_ID <> :OLD.EV_PLC_EV_ID
        OR (:NEW.EV_PLC_EV_ID IS NULL AND :OLD.EV_PLC_EV_ID IS NOT NULL)
        OR (:NEW.EV_PLC_EV_ID IS NOT NULL AND :OLD.EV_PLC_EV_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The foreign key column EV_PLC_EV_ID is not updatable.');
    END IF;
    -- what the update says about the reliability of EV_PLC_Event_Place, and when it posits
    v_reliability_diff := CASE WHEN (:NEW.EV_PLC_Reliability <> :OLD.EV_PLC_Reliability
        OR (:NEW.EV_PLC_Reliability IS NULL AND :OLD.EV_PLC_Reliability IS NOT NULL)
        OR (:NEW.EV_PLC_Reliability IS NOT NULL AND :OLD.EV_PLC_Reliability IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_reliability_diff THEN
        v_reliability := :NEW.EV_PLC_Reliability;
    ELSIF v_suffix_diff THEN
        v_reliability := :NEW.Reliability;
    ELSE
        v_reliability := :NEW.EV_PLC_Reliability;
    END IF;
    IF (:NEW.EV_PLC_Positor <> :OLD.EV_PLC_Positor
        OR (:NEW.EV_PLC_Positor IS NULL AND :OLD.EV_PLC_Positor IS NOT NULL)
        OR (:NEW.EV_PLC_Positor IS NOT NULL AND :OLD.EV_PLC_Positor IS NULL)) THEN
        v_positor := COALESCE(:NEW.EV_PLC_Positor, 0);
    ELSE
        v_positor := COALESCE(:NEW.Positor, 0);
    END IF;
    v_positing_diff := CASE WHEN (:NEW.EV_PLC_PositedAt <> :OLD.EV_PLC_PositedAt
        OR (:NEW.EV_PLC_PositedAt IS NULL AND :OLD.EV_PLC_PositedAt IS NOT NULL)
        OR (:NEW.EV_PLC_PositedAt IS NOT NULL AND :OLD.EV_PLC_PositedAt IS NULL)) THEN TRUE ELSE FALSE END;
    v_changing_diff := CASE WHEN (:NEW.EV_PLC_ChangedAt <> :OLD.EV_PLC_ChangedAt
        OR (:NEW.EV_PLC_ChangedAt IS NULL AND :OLD.EV_PLC_ChangedAt IS NOT NULL)
        OR (:NEW.EV_PLC_ChangedAt IS NOT NULL AND :OLD.EV_PLC_ChangedAt IS NULL)) THEN TRUE ELSE FALSE END;
    IF v_positing_diff THEN
        v_positing := :NEW.EV_PLC_PositedAt;
    ELSIF v_changing_diff AND :NEW.EV_PLC_Event_Place IS NULL THEN
        v_positing := :NEW.EV_PLC_ChangedAt;
    ELSE
        v_positing := v_now;
    END IF;
    v_value_diff := CASE WHEN (:NEW.EV_PLC_Event_Place <> :OLD.EV_PLC_Event_Place
        OR (:NEW.EV_PLC_Event_Place IS NULL AND :OLD.EV_PLC_Event_Place IS NOT NULL)
        OR (:NEW.EV_PLC_Event_Place IS NOT NULL AND :OLD.EV_PLC_Event_Place IS NULL)) THEN TRUE ELSE FALSE END;
    v_meta_diff := CASE WHEN (:NEW.Metadata_EV_PLC <> :OLD.Metadata_EV_PLC
        OR (:NEW.Metadata_EV_PLC IS NULL AND :OLD.Metadata_EV_PLC IS NOT NULL)
        OR (:NEW.Metadata_EV_PLC IS NOT NULL AND :OLD.Metadata_EV_PLC IS NULL)) THEN TRUE ELSE FALSE END;
    v_metadata := COALESCE(
        CASE
            WHEN v_nexus_meta_diff AND NOT v_meta_diff THEN :NEW.Metadata_EV
            ELSE :NEW.Metadata_EV_PLC
        END, :NEW.Metadata_EV);
    IF v_value_diff
    OR v_changing_diff
    OR v_positing_diff
    OR v_reliability_diff
    OR v_suffix_diff
    THEN
        -- the changing time of the value that is stated: the shown version asserted again keeps its changing time, as does one that is given
        IF v_changing_diff THEN
            v_PLC_changing := :NEW.EV_PLC_ChangedAt;
        ELSIF NOT v_value_diff THEN
            v_PLC_changing := :NEW.EV_PLC_ChangedAt;
        ELSE
            v_PLC_changing := v_now;
        END IF;
        IF :NEW.EV_PLC_Event_Place IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF :OLD.EV_PLC_Event_Place IS NULL
            OR v_changing_diff
            OR v_positing_diff
            OR :OLD.EV_PLC_Reliability IS NULL
            OR :OLD.EV_PLC_Reliability <> COALESCE(v_reliability, 1)
            OR :OLD.EV_PLC_Positor IS NULL
            OR :OLD.EV_PLC_Positor <> v_positor
            OR v_value_diff
            THEN
                ip_EV_PLC_Event_Place(
                    p_owner => COALESCE(:NEW.EV_PLC_EV_ID, :NEW.EV_ID),
                    p_value => :NEW.EV_PLC_Event_Place,
                    p_changing => v_PLC_changing,
                    p_positor => v_positor,
                    p_positing => v_positing,
                    p_reliability => COALESCE(v_reliability, 1),
                    p_metadata => v_metadata
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF :NEW.EV_PLC_Event_Place IS NULL AND :OLD.EV_PLC_Event_Place IS NOT NULL THEN
            ip_EV_PLC_Event_Place(
                p_owner => :OLD.EV_ID,
                p_value => :OLD.EV_PLC_Event_Place,
                p_changing => :OLD.EV_PLC_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => v_metadata
            );
        END IF;
    END IF;
END ut_lEV_Event;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lEV_Event
INSTEAD OF DELETE ON lEV_Event
FOR EACH ROW
DECLARE
    v_now timestamp := CAST(current_timestamp AS timestamp);
BEGIN
    -- what is shown of EV_QTY_Event_Quantity is retracted
    INSERT INTO EV_QTY_Event_Quantity_Annex (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_Positor,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        :OLD.Metadata_EV_QTY,
        :OLD.EV_QTY_ID,
        COALESCE(:OLD.EV_QTY_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_QTY_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_QTY_Event_Quantity_Annex x
            WHERE
                x.EV_QTY_ID = :OLD.EV_QTY_ID
            AND
                x.EV_QTY_Positor = COALESCE(:OLD.EV_QTY_Positor, :OLD.Positor, 0)
            AND
                x.EV_QTY_PositedAt = v_now
        );
    -- what is shown of EV_PLC_Event_Place is retracted
    INSERT INTO EV_PLC_Event_Place_Annex (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_Positor,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    SELECT
        :OLD.Metadata_EV_PLC,
        :OLD.EV_PLC_ID,
        COALESCE(:OLD.EV_PLC_Positor, :OLD.Positor, 0),
        v_now,
        0
    FROM
        dual
    WHERE
        :OLD.EV_PLC_ID IS NOT NULL
    AND
        NOT EXISTS (
            SELECT
                1
            FROM
                EV_PLC_Event_Place_Annex x
            WHERE
                x.EV_PLC_ID = :OLD.EV_PLC_ID
            AND
                x.EV_PLC_Positor = COALESCE(:OLD.EV_PLC_Positor, :OLD.Positor, 0)
            AND
                x.EV_PLC_PositedAt = v_now
        );
END dt_lEV_Event;
/
